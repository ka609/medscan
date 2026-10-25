import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../../providers/patient_provider.dart';

class MedicalRecordScreen extends StatefulWidget {
  const MedicalRecordScreen({super.key});

  @override
  State<MedicalRecordScreen> createState() => _MedicalRecordScreenState();
}

class _MedicalRecordScreenState extends State<MedicalRecordScreen> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<PatientProvider>().getMyRecord();
    });
  }

  @override
  Widget build(BuildContext context) {
    final provider = context.watch<PatientProvider>();

    return Scaffold(
      appBar: AppBar(title: const Text('Mon dossier médical')),
      body: _buildBody(provider),
    );
  }

  Widget _buildBody(PatientProvider provider) {
    if (provider.isLoading && provider.myRecord == null) {
      return const Center(child: CircularProgressIndicator());
    }

    if (provider.error != null && provider.myRecord == null) {
      return _ErrorView(
        message: provider.error!,
        onRetry: () => context.read<PatientProvider>().getMyRecord(),
      );
    }

    final record = provider.myRecord;

    if (record == null || record.isEmpty) {
      return const _EmptyView(
        icon: Icons.folder_off_outlined,
        message: 'Aucune donnée médicale disponible.',
      );
    }

    final patient = _asMap(record['patient']);
    final vitals = _asMapList(record['vitalSigns']);
    final consultations = _asMapList(record['consultations']);
    final prescriptions = _asMapList(record['prescriptions']);

    return RefreshIndicator(
      onRefresh: provider.getMyRecord,
      child: Center(
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 720),
          child: ListView(
            physics: const AlwaysScrollableScrollPhysics(),
            padding: const EdgeInsets.all(16),
            children: [
              _PatientHeader(patient: patient),
              const SizedBox(height: 16),
              _IdentitySection(patient: patient),
              _HealthAlertsSection(patient: patient),
              _VitalsSection(vitals: vitals),
              _ConsultationsSection(items: consultations),
              _PrescriptionsSection(items: prescriptions),
              const SizedBox(height: 16),
            ],
          ),
        ),
      ),
    );
  }
}

// Helpers

Map<String, dynamic> _asMap(dynamic v) =>
    v is Map ? Map<String, dynamic>.from(v) : <String, dynamic>{};

List<Map<String, dynamic>> _asMapList(dynamic v) {
  if (v is List) {
    return v.whereType<Map>().map((e) => Map<String, dynamic>.from(e)).toList();
  }

  if (v is Map) {
    return [Map<String, dynamic>.from(v)];
  }

  return [];
}

List<String> _asStringList(dynamic v) =>
    v is List ? v.map((e) => e.toString()).toList() : <String>[];

bool _has(dynamic v) => v != null && v.toString().trim().isNotEmpty;

String _text(dynamic v, [String fallback = '—']) =>
    _has(v) ? v.toString() : fallback;

String _date(dynamic v, {bool withTime = false}) {
  if (!_has(v)) return '—';

  final dt = DateTime.tryParse(v.toString());

  if (dt == null) return v.toString();

  final l = dt.toLocal();

  String two(int n) => n.toString().padLeft(2, '0');

  final d = '${two(l.day)}/${two(l.month)}/${l.year}';

  return withTime ? '$d à ${two(l.hour)}h${two(l.minute)}' : d;
}

String _gender(dynamic v) {
  switch (v?.toString().toUpperCase()) {
    case 'M':
    case 'HOMME':
    case 'MASCULIN':
      return 'Masculin';
    case 'F':
    case 'FEMME':
    case 'FEMININ':
    case 'FÉMININ':
      return 'Féminin';
    default:
      return 'Masculin';
  }
}

String _initials(String name) {
  final parts = name.trim().split(RegExp(r'\s+'))
    ..removeWhere((p) => p.isEmpty);

  if (parts.isEmpty) return '?';

  if (parts.length == 1) {
    return parts.first[0].toUpperCase();
  }

  return (parts.first[0] + parts.last[0]).toUpperCase();
}

// En-tête patient

class _PatientHeader extends StatelessWidget {
  final Map<String, dynamic> patient;

  const _PatientHeader({required this.patient});

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    final tt = Theme.of(context).textTheme;

    final name = _text(patient['fullName'], 'Patient');

    final subtitle = [
      if (_has(patient['age'])) '${patient['age']} ans',
      if (_has(patient['gender'])) _gender(patient['gender']),
    ].join(' • ');

    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [cs.primary, Color.lerp(cs.primary, Colors.black, 0.25)!],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(20),
      ),
      child: Row(
        children: [
          CircleAvatar(
            radius: 32,
            backgroundColor: cs.onPrimary,
            child: Text(
              _initials(name),
              style: tt.titleLarge?.copyWith(
                color: cs.primary,
                fontWeight: FontWeight.w800,
              ),
            ),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  name,
                  style: tt.titleLarge?.copyWith(
                    color: cs.onPrimary,
                    fontWeight: FontWeight.w700,
                  ),
                ),
                if (subtitle.isNotEmpty) ...[
                  const SizedBox(height: 2),
                  Text(
                    subtitle,
                    style: tt.bodyMedium?.copyWith(
                      color: cs.onPrimary.withAlpha(215),
                    ),
                  ),
                ],
                const SizedBox(height: 10),
                Wrap(
                  spacing: 8,
                  runSpacing: 6,
                  children: [
                    if (_has(patient['bloodGroup']))
                      _HeaderChip(
                        icon: Icons.bloodtype_outlined,
                        label: 'Groupe ${patient['bloodGroup']}',
                      ),
                    if (_has(patient['nationalId']))
                      _HeaderChip(
                        icon: Icons.badge_outlined,
                        label: patient['nationalId'].toString(),
                      ),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _HeaderChip extends StatelessWidget {
  final IconData icon;
  final String label;

  const _HeaderChip({required this.icon, required this.label});

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
      decoration: BoxDecoration(
        color: cs.onPrimary.withAlpha(40),
        borderRadius: BorderRadius.circular(20),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 14, color: cs.onPrimary),
          const SizedBox(width: 5),
          Text(
            label,
            style: Theme.of(context).textTheme.labelMedium?.copyWith(
              color: cs.onPrimary,
              fontWeight: FontWeight.w600,
            ),
          ),
        ],
      ),
    );
  }
}

// Composants génériques

class _SectionCard extends StatelessWidget {
  final String title;
  final IconData icon;
  final int? count;
  final Widget child;

  const _SectionCard({
    required this.title,
    required this.icon,
    required this.child,
    this.count,
  });

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    final tt = Theme.of(context).textTheme;

    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: cs.surface,
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: cs.outlineVariant),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: cs.primary.withAlpha(25),
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Icon(icon, size: 20, color: cs.primary),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Text(
                  title,
                  style: tt.titleMedium?.copyWith(fontWeight: FontWeight.w700),
                ),
              ),
              if (count != null) _Pill('$count'),
            ],
          ),
          const SizedBox(height: 14),
          child,
        ],
      ),
    );
  }
}

class _InfoRow extends StatelessWidget {
  final String label;
  final String value;

  const _InfoRow(this.label, this.value);

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    final tt = Theme.of(context).textTheme;

    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 6),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 130,
            child: Text(
              label,
              style: tt.bodyMedium?.copyWith(color: cs.onSurfaceVariant),
            ),
          ),
          Expanded(
            child: Text(
              value,
              style: tt.bodyMedium?.copyWith(fontWeight: FontWeight.w600),
            ),
          ),
        ],
      ),
    );
  }
}

class _Pill extends StatelessWidget {
  final String text;
  final Color? color;

  const _Pill(this.text, {this.color});

  @override
  Widget build(BuildContext context) {
    final c = color ?? Theme.of(context).colorScheme.primary;

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
      decoration: BoxDecoration(
        color: c.withAlpha(30),
        borderRadius: BorderRadius.circular(20),
      ),
      child: Text(
        text,
        style: Theme.of(context).textTheme.labelMedium?.copyWith(
          color: c,
          fontWeight: FontWeight.w700,
        ),
      ),
    );
  }
}

class _EmptyLine extends StatelessWidget {
  final String text;

  const _EmptyLine(this.text);

  @override
  Widget build(BuildContext context) => Text(
    text,
    style: Theme.of(context).textTheme.bodyMedium?.copyWith(
      color: Theme.of(context).colorScheme.onSurfaceVariant,
    ),
  );
}

// Identité

class _IdentitySection extends StatelessWidget {
  final Map<String, dynamic> patient;

  const _IdentitySection({required this.patient});

  @override
  Widget build(BuildContext context) {
    return _SectionCard(
      title: 'Informations personnelles',
      icon: Icons.badge_outlined,
      child: Column(
        children: [
          _InfoRow('Date de naissance', _date(patient['birthDate'])),
          _InfoRow('Téléphone', _text(patient['phone'])),
          _InfoRow('Contact d\'urgence', _text(patient['emergencyContact'])),
        ],
      ),
    );
  }
}

// Allergies et antécédents

class _HealthAlertsSection extends StatelessWidget {
  final Map<String, dynamic> patient;

  const _HealthAlertsSection({required this.patient});

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    final tt = Theme.of(context).textTheme;

    final allergies = _asStringList(patient['allergies']);
    final chronic = _asStringList(patient['chronicConditions']);

    Widget group(String label, List<String> items, Color color, String none) {
      return Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            label,
            style: tt.labelLarge?.copyWith(color: cs.onSurfaceVariant),
          ),
          const SizedBox(height: 8),
          items.isEmpty
              ? _EmptyLine(none)
              : Wrap(
                  spacing: 8,
                  runSpacing: 8,
                  children: [for (final i in items) _Pill(i, color: color)],
                ),
        ],
      );
    }

    return _SectionCard(
      title: 'Allergies & antécédents',
      icon: Icons.warning_amber_rounded,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          group('Allergies', allergies, cs.error, 'Aucune allergie connue'),
          const SizedBox(height: 16),
          group('Maladies chroniques', chronic, cs.primary, 'Aucune'),
        ],
      ),
    );
  }
}

// Constantes vitales

class _VitalsSection extends StatelessWidget {
  final List<Map<String, dynamic>> vitals;

  const _VitalsSection({required this.vitals});

  @override
  Widget build(BuildContext context) {
    final sorted = [...vitals]
      ..sort(
        (a, b) => (b['recordedAt'] ?? '').toString().compareTo(
          (a['recordedAt'] ?? '').toString(),
        ),
      );

    return _SectionCard(
      title: 'Constantes vitales',
      icon: Icons.monitor_heart_outlined,
      count: vitals.isEmpty ? null : vitals.length,
      child: sorted.isEmpty
          ? const _EmptyLine('Aucune constante enregistrée.')
          : Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _VitalBlock(vital: sorted.first, latest: true),
                if (sorted.length > 1)
                  Theme(
                    data: Theme.of(
                      context,
                    ).copyWith(dividerColor: Colors.transparent),
                    child: ExpansionTile(
                      tilePadding: EdgeInsets.zero,
                      title: const Text('Historique'),
                      children: [
                        for (final v in sorted.skip(1))
                          Padding(
                            padding: const EdgeInsets.only(bottom: 12),
                            child: _VitalBlock(vital: v, latest: false),
                          ),
                      ],
                    ),
                  ),
              ],
            ),
    );
  }
}

class _VitalBlock extends StatelessWidget {
  final Map<String, dynamic> vital;
  final bool latest;

  const _VitalBlock({required this.vital, required this.latest});

  Color _triageColor(BuildContext context, String level) {
    final cs = Theme.of(context).colorScheme;

    switch (level.toUpperCase()) {
      case 'NORMAL':
        return Colors.green.shade700;
      case 'URGENT':
      case 'HIGH':
      case 'CRITICAL':
        return cs.error;
      default:
        return Colors.orange.shade800;
    }
  }

  String _triageLabel(String level) {
    switch (level.toUpperCase()) {
      case 'NORMAL':
        return 'Normal';
      case 'URGENT':
        return 'Urgent';
      case 'HIGH':
        return 'Élevé';
      case 'CRITICAL':
        return 'Critique';
      default:
        return level;
    }
  }

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    final tt = Theme.of(context).textTheme;
    final v = vital;

    final tiles = <_VitalTileData>[
      if (_has(v['systolicBp']) && _has(v['diastolicBp']))
        _VitalTileData(
          Icons.favorite_border,
          'Tension',
          '${v['systolicBp']}/${v['diastolicBp']}',
          'mmHg',
        ),
      if (_has(v['heartRate']))
        _VitalTileData(
          Icons.monitor_heart_outlined,
          'Pouls',
          '${v['heartRate']}',
          'bpm',
        ),
      if (_has(v['temperature']))
        _VitalTileData(
          Icons.thermostat,
          'Température',
          '${v['temperature']}',
          '°C',
        ),
      if (_has(v['oxygenSaturation']))
        _VitalTileData(Icons.air, 'SpO₂', '${v['oxygenSaturation']}', '%'),
      if (_has(v['respiratoryRate']))
        _VitalTileData(
          Icons.waves,
          'Fréq. resp.',
          '${v['respiratoryRate']}',
          '/min',
        ),
      if (_has(v['bloodGlucose']))
        _VitalTileData(
          Icons.water_drop_outlined,
          'Glycémie',
          '${v['bloodGlucose']}',
          'g/L',
        ),
      if (_has(v['weightKg']))
        _VitalTileData(
          Icons.monitor_weight_outlined,
          'Poids',
          '${v['weightKg']}',
          'kg',
        ),
      if (_has(v['heightCm']))
        _VitalTileData(Icons.height, 'Taille', '${v['heightCm']}', 'cm'),
      if (_has(v['bmi']))
        _VitalTileData(
          Icons.speed,
          'IMC',
          '${v['bmi']}',
          _has(v['bmiCategory']) ? v['bmiCategory'].toString() : '',
        ),
    ];

    final triage = _has(v['triageLevel']) ? v['triageLevel'].toString() : null;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Expanded(
              child: Text(
                latest
                    ? 'Dernière mesure • ${_date(v['recordedAt'], withTime: true)}'
                    : _date(v['recordedAt'], withTime: true),
                style: tt.labelLarge?.copyWith(color: cs.onSurfaceVariant),
              ),
            ),
            if (triage != null)
              _Pill(_triageLabel(triage), color: _triageColor(context, triage)),
          ],
        ),
        const SizedBox(height: 12),
        LayoutBuilder(
          builder: (context, c) {
            final cols = c.maxWidth > 520 ? 3 : 2;
            const gap = 10.0;
            final w = (c.maxWidth - gap * (cols - 1)) / cols;

            return Wrap(
              spacing: gap,
              runSpacing: gap,
              children: [
                for (final t in tiles)
                  SizedBox(
                    width: w,
                    child: _VitalTile(data: t),
                  ),
              ],
            );
          },
        ),
        if (_has(v['notes'])) ...[
          const SizedBox(height: 12),
          Text(
            v['notes'].toString(),
            style: tt.bodyMedium?.copyWith(fontStyle: FontStyle.italic),
          ),
        ],
        if (_has(v['recordedBy'])) ...[
          const SizedBox(height: 8),
          Text(
            'Saisi par ${v['recordedBy']}',
            style: tt.bodySmall?.copyWith(color: cs.onSurfaceVariant),
          ),
        ],
      ],
    );
  }
}

class _VitalTileData {
  final IconData icon;
  final String label;
  final String value;
  final String unit;

  const _VitalTileData(this.icon, this.label, this.value, this.unit);
}

class _VitalTile extends StatelessWidget {
  final _VitalTileData data;

  const _VitalTile({required this.data});

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    final tt = Theme.of(context).textTheme;

    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: cs.primary.withAlpha(14),
        borderRadius: BorderRadius.circular(14),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(data.icon, size: 16, color: cs.primary),
              const SizedBox(width: 6),
              Expanded(
                child: Text(
                  data.label,
                  overflow: TextOverflow.ellipsis,
                  style: tt.labelMedium?.copyWith(color: cs.onSurfaceVariant),
                ),
              ),
            ],
          ),
          const SizedBox(height: 6),
          Text.rich(
            TextSpan(
              children: [
                TextSpan(
                  text: data.value,
                  style: tt.titleMedium?.copyWith(fontWeight: FontWeight.w800),
                ),
                if (data.unit.isNotEmpty)
                  TextSpan(
                    text: '  ${data.unit}',
                    style: tt.bodySmall?.copyWith(color: cs.onSurfaceVariant),
                  ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

// Consultations

class _ConsultationsSection extends StatelessWidget {
  final List<Map<String, dynamic>> items;

  const _ConsultationsSection({required this.items});

  @override
  Widget build(BuildContext context) {
    final sorted = [...items]
      ..sort(
        (a, b) => (b['date'] ?? '').toString().compareTo(
          (a['date'] ?? '').toString(),
        ),
      );

    return _SectionCard(
      title: 'Consultations',
      icon: Icons.medical_services_outlined,
      count: items.isEmpty ? null : items.length,
      child: sorted.isEmpty
          ? const _EmptyLine('Aucune consultation enregistrée.')
          : Column(
              children: [
                for (var i = 0; i < sorted.length; i++)
                  _ConsultationTile(c: sorted[i], initiallyExpanded: i == 0),
              ],
            ),
    );
  }
}

class _ConsultationTile extends StatelessWidget {
  final Map<String, dynamic> c;
  final bool initiallyExpanded;

  const _ConsultationTile({required this.c, required this.initiallyExpanded});

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    final tt = Theme.of(context).textTheme;

    Widget block(String label, dynamic value) {
      if (!_has(value)) {
        return const SizedBox.shrink();
      }

      return Padding(
        padding: const EdgeInsets.only(bottom: 12),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              label,
              style: tt.labelMedium?.copyWith(
                color: cs.primary,
                fontWeight: FontWeight.w700,
              ),
            ),
            const SizedBox(height: 3),
            Text(value.toString(), style: tt.bodyMedium?.copyWith(height: 1.4)),
          ],
        ),
      );
    }

    return Theme(
      data: Theme.of(context).copyWith(dividerColor: Colors.transparent),
      child: ExpansionTile(
        initiallyExpanded: initiallyExpanded,
        tilePadding: EdgeInsets.zero,
        childrenPadding: const EdgeInsets.only(left: 4, bottom: 4),
        expandedCrossAxisAlignment: CrossAxisAlignment.start,
        title: Text(
          _text(c['chiefComplaint'], 'Consultation'),
          style: tt.titleSmall?.copyWith(fontWeight: FontWeight.w700),
        ),
        subtitle: Text(
          '${_date(c['date'])} • ${_text(c['doctorName'])}',
          style: tt.bodySmall?.copyWith(color: cs.onSurfaceVariant),
        ),
        children: [
          block('Examen clinique', c['examinationNotes']),
          block('Diagnostic', c['diagnosis']),
          block('Plan de traitement', c['treatmentPlan']),
        ],
      ),
    );
  }
}

// Ordonnances

class _PrescriptionsSection extends StatelessWidget {
  final List<Map<String, dynamic>> items;

  const _PrescriptionsSection({required this.items});

  @override
  Widget build(BuildContext context) {
    final sorted = [...items]
      ..sort(
        (a, b) => (b['issuedAt'] ?? '').toString().compareTo(
          (a['issuedAt'] ?? '').toString(),
        ),
      );

    return _SectionCard(
      title: 'Ordonnances',
      icon: Icons.receipt_long_outlined,
      count: items.isEmpty ? null : items.length,
      child: sorted.isEmpty
          ? const _EmptyLine('Aucune ordonnance.')
          : Column(children: [for (final p in sorted) _PrescriptionCard(p: p)]),
    );
  }
}

class _PrescriptionCard extends StatelessWidget {
  final Map<String, dynamic> p;

  const _PrescriptionCard({required this.p});

  ({String label, Color color}) _status(BuildContext context) {
    final cs = Theme.of(context).colorScheme;

    switch (p['status']?.toString().toUpperCase()) {
      case 'ISSUED':
        return (label: 'À délivrer', color: Colors.orange.shade800);
      case 'DISPENSED':
        return (label: 'Délivrée', color: Colors.green.shade700);
      case 'CANCELLED':
        return (label: 'Annulée', color: cs.error);
      default:
        return (label: _text(p['status']), color: cs.primary);
    }
  }

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    final tt = Theme.of(context).textTheme;
    final status = _status(context);
    final meds = _asMapList(p['items']);

    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: cs.outlineVariant),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Expanded(
                child: Text(
                  _text(p['prescriptionCode'], 'Ordonnance'),
                  style: tt.titleSmall?.copyWith(fontWeight: FontWeight.w800),
                ),
              ),
              _Pill(status.label, color: status.color),
            ],
          ),
          const SizedBox(height: 4),
          Text(
            '${_date(p['issuedAt'])} • ${_text(p['doctorName'])}',
            style: tt.bodySmall?.copyWith(color: cs.onSurfaceVariant),
          ),
          const SizedBox(height: 10),
          Divider(height: 1, color: cs.outlineVariant),
          for (final m in meds)
            Padding(
              padding: const EdgeInsets.only(top: 12),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Icon(Icons.medication_outlined, size: 20, color: cs.primary),
                  const SizedBox(width: 10),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          _text(m['medicationName']),
                          style: tt.bodyMedium?.copyWith(
                            fontWeight: FontWeight.w700,
                          ),
                        ),
                        const SizedBox(height: 2),
                        Text(
                          [
                            if (_has(m['dosage'])) m['dosage'],
                            if (_has(m['frequency'])) m['frequency'],
                            if (_has(m['durationDays']))
                              '${m['durationDays']} jours',
                          ].join(' • '),
                          style: tt.bodySmall?.copyWith(
                            color: cs.onSurfaceVariant,
                          ),
                        ),
                        if (_has(m['instructions'])) ...[
                          const SizedBox(height: 2),
                          Text(
                            m['instructions'].toString(),
                            style: tt.bodySmall?.copyWith(
                              fontStyle: FontStyle.italic,
                            ),
                          ),
                        ],
                      ],
                    ),
                  ),
                ],
              ),
            ),
        ],
      ),
    );
  }
}

// États

class _EmptyView extends StatelessWidget {
  final IconData icon;
  final String message;

  const _EmptyView({required this.icon, required this.message});

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;

    return Center(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 56, color: cs.outline),
          const SizedBox(height: 12),
          Text(message, style: TextStyle(color: cs.onSurfaceVariant)),
        ],
      ),
    );
  }
}

class _ErrorView extends StatelessWidget {
  final String message;
  final VoidCallback onRetry;

  const _ErrorView({required this.message, required this.onRetry});

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;

    return Center(
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(Icons.error_outline, size: 48, color: cs.error),
            const SizedBox(height: 16),
            Text(message, textAlign: TextAlign.center),
            const SizedBox(height: 16),
            FilledButton.icon(
              onPressed: onRetry,
              icon: const Icon(Icons.refresh),
              label: const Text('Réessayer'),
            ),
          ],
        ),
      ),
    );
  }
}
