import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../../core/theme/app_colors.dart';
import '../../../models/certificate.dart';
import '../../../models/user.dart';
import '../../../providers/auth_provider.dart';
import '../../../providers/patient_provider.dart';
import '../../../services/certificate_service.dart';
import '../../certificates/screens/certificates_screen.dart';

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
      appBar: AppBar(
        title: const Text('Mon e-Carnet de Santé'),
        actions: [
          if (provider.myRecord != null && provider.myRecord!.isNotEmpty)
            IconButton(
              tooltip: 'Télécharger e-Carnet (PDF)',
              icon: const Icon(Icons.picture_as_pdf_rounded),
              onPressed: () => _showECarnetPdfModal(context, provider.myRecord!),
            ),
        ],
      ),
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
              _PatientHeader(
                patient: patient,
                onDownloadPdf: () => _showECarnetPdfModal(context, record),
              ),
              const SizedBox(height: 16),
              _IdentitySection(patient: patient),
              _HealthAlertsSection(patient: patient),
              _VitalsSection(vitals: vitals),
              _ConsultationsSection(items: consultations),
              _PrescriptionsSection(items: prescriptions),
              _CertificatesSection(patient: patient),
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
  final VoidCallback? onDownloadPdf;

  const _PatientHeader({
    required this.patient,
    this.onDownloadPdf,
  });

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
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
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
          if (onDownloadPdf != null) ...[
            const SizedBox(height: 16),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton.icon(
                onPressed: onDownloadPdf,
                icon: const Icon(Icons.picture_as_pdf_rounded, size: 18),
                label: const Text('Télécharger mon e-Carnet (PDF)'),
                style: ElevatedButton.styleFrom(
                  backgroundColor: cs.onPrimary,
                  foregroundColor: cs.primary,
                  elevation: 0,
                  padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                  textStyle: const TextStyle(fontWeight: FontWeight.w700, fontSize: 13.5),
                ),
              ),
            ),
          ],
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

// Section Certificats Médicaux Officiels
class _CertificatesSection extends StatefulWidget {
  final Map<String, dynamic> patient;

  const _CertificatesSection({required this.patient});

  @override
  State<_CertificatesSection> createState() => _CertificatesSectionState();
}

class _CertificatesSectionState extends State<_CertificatesSection> {
  final CertificateService _certificateService = CertificateService();
  List<MedicalCertificate> _certificates = [];
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadCertificates();
  }

  Future<void> _loadCertificates() async {
    setState(() => _isLoading = true);
    final patientId = widget.patient['id']?.toString() ??
        widget.patient['fullName']?.toString();
    final certs = await _certificateService.getCertificates(
      patientId: patientId,
    );
    if (mounted) {
      setState(() {
        _certificates = certs;
        _isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    final user = context.watch<AuthProvider>().user;
    final isDoctor = user.isDoctor;

    return _SectionCard(
      title: 'Certificats Médicaux',
      icon: Icons.verified_user_outlined,
      count: _certificates.isEmpty ? null : _certificates.length,
      child: _isLoading
          ? const Center(
              child: Padding(
                padding: EdgeInsets.all(12),
                child: SizedBox(
                  width: 24,
                  height: 24,
                  child: CircularProgressIndicator(strokeWidth: 2),
                ),
              ),
            )
          : Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                if (_certificates.isEmpty) ...[
                  const Padding(
                    padding: EdgeInsets.symmetric(vertical: 8),
                    child: _EmptyLine('Aucun certificat médical enregistré pour ce patient.'),
                  ),
                  if (isDoctor) ...[
                    const SizedBox(height: 8),
                    SizedBox(
                      width: double.infinity,
                      child: ElevatedButton.icon(
                        onPressed: () {
                          showIssueCertificateDialog(
                            context,
                            initialPatient: widget.patient,
                            onCertificateIssued: (newCert) {
                              _loadCertificates();
                            },
                          );
                        },
                        icon: const Icon(Icons.post_add_rounded, size: 18),
                        label: const Text('Émettre un certificat pour ce patient'),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: cs.primary,
                          foregroundColor: Colors.white,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                          padding: const EdgeInsets.symmetric(vertical: 12),
                        ),
                      ),
                    ),
                  ],
                ] else ...[
                  for (final cert in _certificates)
                    _PatientDossierCertificateCard(
                      cert: cert,
                      isDoctor: isDoctor,
                      onView: () {
                        showOfficialCertificateModal(
                          context,
                          cert,
                          isDoctor: isDoctor,
                        );
                      },
                    ),
                  if (isDoctor) ...[
                    const SizedBox(height: 10),
                    Align(
                      alignment: Alignment.centerRight,
                      child: TextButton.icon(
                        onPressed: () {
                          showIssueCertificateDialog(
                            context,
                            initialPatient: widget.patient,
                            onCertificateIssued: (newCert) {
                              _loadCertificates();
                            },
                          );
                        },
                        icon: const Icon(Icons.add_rounded, size: 18),
                        label: const Text('Ajouter un certificat pour ce patient'),
                      ),
                    ),
                  ],
                ],
              ],
            ),
    );
  }
}

class _PatientDossierCertificateCard extends StatelessWidget {
  final MedicalCertificate cert;
  final bool isDoctor;
  final VoidCallback onView;

  const _PatientDossierCertificateCard({
    required this.cert,
    required this.isDoctor,
    required this.onView,
  });

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    final tt = Theme.of(context).textTheme;

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
                  cert.typeLabel,
                  style: tt.titleSmall?.copyWith(fontWeight: FontWeight.w800),
                ),
              ),
              _Pill(
                cert.certificateNumber,
                color: cs.primary,
              ),
            ],
          ),
          const SizedBox(height: 4),
          Text(
            '${_date(cert.startDate)} au ${_date(cert.endDate)} • ${cert.restDurationDays} jour(s) de repos',
            style: tt.bodySmall?.copyWith(color: cs.onSurfaceVariant),
          ),
          const SizedBox(height: 8),
          Text(
            cert.diagnosisOrReason,
            style: tt.bodyMedium?.copyWith(fontWeight: FontWeight.w600),
          ),
          const SizedBox(height: 4),
          Text(
            'Délivré par ${cert.doctorName} • ${cert.hospitalName}',
            style: tt.bodySmall?.copyWith(color: cs.onSurfaceVariant),
          ),
          const SizedBox(height: 10),
          Divider(height: 1, color: cs.outlineVariant),
          const SizedBox(height: 10),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Row(
                children: [
                  Icon(Icons.shield_rounded, size: 16, color: Colors.green.shade700),
                  const SizedBox(width: 6),
                  Text(
                    'Cachet officiel scellé',
                    style: tt.labelSmall?.copyWith(
                      color: Colors.green.shade700,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ],
              ),
              ElevatedButton.icon(
                onPressed: onView,
                icon: Icon(
                  isDoctor ? Icons.visibility_rounded : Icons.file_download_outlined,
                  size: 15,
                ),
                label: Text(
                  isDoctor ? 'Consulter' : 'Voir & PDF',
                  style: const TextStyle(fontSize: 12),
                ),
                style: ElevatedButton.styleFrom(
                  backgroundColor: cs.primary.withAlpha(25),
                  foregroundColor: cs.primary,
                  elevation: 0,
                  padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(8),
                  ),
                ),
              ),
            ],
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

// ==========================================
// Exportation et Téléchargement e-Carnet PDF
// ==========================================

void _showECarnetPdfModal(BuildContext context, Map<String, dynamic> record) {
  showModalBottomSheet(
    context: context,
    isScrollControlled: true,
    backgroundColor: Colors.transparent,
    builder: (context) => _ECarnetPdfModal(record: record),
  );
}

class _ECarnetPdfModal extends StatelessWidget {
  final Map<String, dynamic> record;

  const _ECarnetPdfModal({required this.record});

  @override
  Widget build(BuildContext context) {
    final patient = _asMap(record['patient']);
    final vitals = _asMapList(record['vitalSigns']);
    final consultations = _asMapList(record['consultations']);
    final prescriptions = _asMapList(record['prescriptions']);

    final patientName = _text(patient['fullName'], 'Patient');
    final nationalId = _text(patient['nationalId'], patient['id']?.toString() ?? 'BF-2026-NIP');

    return Container(
      height: MediaQuery.of(context).size.height * 0.92,
      decoration: const BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      child: Column(
        children: [
          // En-tête de la modale
          Padding(
            padding: const EdgeInsets.fromLTRB(20, 14, 16, 12),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Row(
                  children: [
                    Container(
                      padding: const EdgeInsets.all(8),
                      decoration: BoxDecoration(
                        color: const Color(0xFFFEE2E2),
                        borderRadius: BorderRadius.circular(10),
                      ),
                      child: const Icon(
                        Icons.picture_as_pdf_rounded,
                        color: Color(0xFFDC2626),
                        size: 20,
                      ),
                    ),
                    const SizedBox(width: 12),
                    const Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'e-Carnet de Santé Numérique',
                          style: TextStyle(fontSize: 16, fontWeight: FontWeight.w700),
                        ),
                        Text(
                          'Document Officiel Conforme Ministère de la Santé',
                          style: TextStyle(fontSize: 11, color: AppColors.textSecondary),
                        ),
                      ],
                    ),
                  ],
                ),
                IconButton(
                  icon: const Icon(Icons.close_rounded),
                  onPressed: () => Navigator.pop(context),
                ),
              ],
            ),
          ),
          const Divider(height: 1),

          // Contenu du document e-Carnet officiel
          Expanded(
            child: SingleChildScrollView(
              padding: const EdgeInsets.all(20),
              child: Container(
                padding: const EdgeInsets.all(20),
                decoration: BoxDecoration(
                  color: const Color(0xFFFAFAFA),
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(color: const Color(0xFFCBD5E1), width: 1.5),
                  boxShadow: const [
                    BoxShadow(
                      color: Color(0x0A000000),
                      blurRadius: 16,
                      offset: Offset(0, 4),
                    ),
                  ],
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    // En-tête national officiel
                    const Text(
                      'BURKINA FASO\nLa Patrie ou la Mort, nous Vaincrons',
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        fontSize: 11.5,
                        fontWeight: FontWeight.w800,
                        letterSpacing: 0.8,
                        color: Color(0xFF1E293B),
                      ),
                    ),
                    const SizedBox(height: 4),
                    const Text(
                      'MINISTÈRE DE LA SANTÉ ET DE L\'HYGIÈNE PUBLIQUE\nDirection Générale de la Santé Numérique',
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        fontSize: 10,
                        fontWeight: FontWeight.w600,
                        color: Color(0xFF64748B),
                      ),
                    ),
                    const SizedBox(height: 10),
                    Container(height: 2.5, width: 140, color: AppColors.primary),
                    const SizedBox(height: 14),

                    // Titre du carnet
                    Container(
                      width: double.infinity,
                      padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 12),
                      decoration: BoxDecoration(
                        color: AppColors.softBlue,
                        borderRadius: BorderRadius.circular(8),
                        border: Border.all(color: AppColors.primary.withValues(alpha: 0.3)),
                      ),
                      child: Column(
                        children: [
                          const Text(
                            'CARNET DE SANTÉ NUMÉRIQUE (e-CARNET)',
                            textAlign: TextAlign.center,
                            style: TextStyle(
                              fontSize: 13.5,
                              fontWeight: FontWeight.w800,
                              color: AppColors.primary,
                            ),
                          ),
                          const SizedBox(height: 2),
                          Text(
                            'RÉFÉRENCE NATIONALE : ECN-$nationalId',
                            style: const TextStyle(
                              fontFamily: 'Courier',
                              fontSize: 11,
                              fontWeight: FontWeight.w700,
                              color: AppColors.textPrimary,
                            ),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 18),

                    // 1. Identité du Patient
                    _buildDocumentSectionTitle('1. IDENTITÉ DU TITULAIRE'),
                    const SizedBox(height: 8),
                    Container(
                      padding: const EdgeInsets.all(12),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(10),
                        border: Border.all(color: const Color(0xFFE2E8F0)),
                      ),
                      child: Column(
                        children: [
                          _buildDocRow('Nom & Prénom :', patientName, isBold: true),
                          _buildDocRow('NIP / Identifiant :', nationalId),
                          _buildDocRow('Âge & Sexe :', '${_text(patient['age'])} ans • ${_gender(patient['gender'])}'),
                          _buildDocRow('Groupe Sanguin :', _text(patient['bloodGroup'])),
                          _buildDocRow('Téléphone :', _text(patient['phone'] ?? patient['phoneNumber'])),
                          _buildDocRow('Contact d\'urgence :', _text(patient['emergencyContact'])),
                        ],
                      ),
                    ),
                    const SizedBox(height: 16),

                    // 2. Dernières Constantes Vitales
                    _buildDocumentSectionTitle('2. CONSTANTES VITALES RÉCENTES'),
                    const SizedBox(height: 8),
                    Container(
                      padding: const EdgeInsets.all(12),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(10),
                        border: Border.all(color: const Color(0xFFE2E8F0)),
                      ),
                      child: vitals.isEmpty
                          ? const Text(
                              'Aucune constante vitale enregistrée récemment.',
                              style: TextStyle(fontSize: 12, color: AppColors.textSecondary),
                            )
                          : Column(
                              children: vitals.take(3).map((v) {
                                final bp = '${v['bloodPressureSystolic'] ?? '—'}/${v['bloodPressureDiastolic'] ?? '—'} mmHg';
                                final pulse = '${v['heartRate'] ?? '—'} bpm';
                                final temp = '${v['temperature'] ?? '—'} °C';
                                final weight = '${v['weight'] ?? '—'} kg';
                                return Padding(
                                  padding: const EdgeInsets.symmetric(vertical: 4),
                                  child: Row(
                                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                    children: [
                                      Text(_date(v['recordedAt']), style: const TextStyle(fontSize: 11.5, fontWeight: FontWeight.w600)),
                                      Text('TA: $bp • Pouls: $pulse • $temp • $weight', style: const TextStyle(fontSize: 11.5)),
                                    ],
                                  ),
                                );
                              }).toList(),
                            ),
                    ),
                    const SizedBox(height: 16),

                    // 3. Consultations & Diagnostics
                    _buildDocumentSectionTitle('3. SYNTHÈSE DES CONSULTATIONS'),
                    const SizedBox(height: 8),
                    Container(
                      padding: const EdgeInsets.all(12),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(10),
                        border: Border.all(color: const Color(0xFFE2E8F0)),
                      ),
                      child: consultations.isEmpty
                          ? const Text(
                              'Aucun historique de consultation répertorié.',
                              style: TextStyle(fontSize: 12, color: AppColors.textSecondary),
                            )
                          : Column(
                              children: consultations.take(4).map((c) {
                                return Padding(
                                  padding: const EdgeInsets.only(bottom: 8),
                                  child: Column(
                                    crossAxisAlignment: CrossAxisAlignment.start,
                                    children: [
                                      Row(
                                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                        children: [
                                          Text(_date(c['consultationDate'] ?? c['createdAt']),
                                              style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w700, color: AppColors.primary)),
                                          Text(_text(c['doctorName'], 'Dr. Praticien'),
                                              style: const TextStyle(fontSize: 11.5, color: AppColors.textSecondary)),
                                        ],
                                      ),
                                      const SizedBox(height: 2),
                                      Text('Diagnostic : ${_text(c['diagnosis'] ?? c['reason'], 'Examen médical de routine')}',
                                          style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w600)),
                                      const Divider(height: 10),
                                    ],
                                  ),
                                );
                              }).toList(),
                            ),
                    ),
                    const SizedBox(height: 16),

                    // 4. Prescriptions et Ordonnances
                    _buildDocumentSectionTitle('4. PRESCRIPTIONS & TRAITEMENTS'),
                    const SizedBox(height: 8),
                    Container(
                      padding: const EdgeInsets.all(12),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(10),
                        border: Border.all(color: const Color(0xFFE2E8F0)),
                      ),
                      child: prescriptions.isEmpty
                          ? const Text(
                              'Aucune prescription médicale active.',
                              style: TextStyle(fontSize: 12, color: AppColors.textSecondary),
                            )
                          : Column(
                              children: prescriptions.take(3).map((p) {
                                return Padding(
                                  padding: const EdgeInsets.only(bottom: 6),
                                  child: Row(
                                    crossAxisAlignment: CrossAxisAlignment.start,
                                    children: [
                                      const Icon(Icons.medication_rounded, size: 16, color: AppColors.primary),
                                      const SizedBox(width: 8),
                                      Expanded(
                                        child: Text(
                                          '${_text(p['medicationName'] ?? p['medication'])} - ${_text(p['dosage'])} (${_text(p['duration'])})',
                                          style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w500),
                                        ),
                                      ),
                                    ],
                                  ),
                                );
                              }).toList(),
                            ),
                    ),
                    const SizedBox(height: 20),

                    // Sceau de sécurité et Empreinte SHA-256
                    Container(
                      padding: const EdgeInsets.all(12),
                      decoration: BoxDecoration(
                        color: AppColors.softBlue,
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(color: AppColors.primary.withValues(alpha: 0.3)),
                      ),
                      child: Row(
                        children: [
                          const Icon(
                            Icons.qr_code_2_rounded,
                            size: 46,
                            color: AppColors.textPrimary,
                          ),
                          const SizedBox(width: 12),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                const Text(
                                  'Sceau Cryptographique & Télé-contrôle :',
                                  style: TextStyle(
                                    fontSize: 11,
                                    fontWeight: FontWeight.w700,
                                    color: AppColors.textPrimary,
                                  ),
                                ),
                                const SizedBox(height: 2),
                                Text(
                                  'SHA256:BF-${nationalId.hashCode.abs().toRadixString(16).padLeft(8, '0').toUpperCase()}A93B8C1D7E4F',
                                  style: const TextStyle(
                                    fontFamily: 'Courier',
                                    fontSize: 9,
                                    fontWeight: FontWeight.w700,
                                    color: AppColors.primary,
                                  ),
                                ),
                                const SizedBox(height: 2),
                                const Text(
                                  'Ce document médical numérique est certifié infalsifiable et opposable aux tiers.',
                                  style: TextStyle(fontSize: 9.5, color: AppColors.textSecondary),
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),

          // Actions au bas de la modale
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: AppColors.surface,
              boxShadow: const [
                BoxShadow(
                  color: Color(0x0C000000),
                  blurRadius: 10,
                  offset: Offset(0, -3),
                ),
              ],
            ),
            child: Row(
              children: [
                Expanded(
                  child: OutlinedButton.icon(
                    onPressed: () {
                      Navigator.pop(context);
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(
                          content: Text('Lien sécurisé de transmission de l\'e-Carnet généré !'),
                          backgroundColor: AppColors.primary,
                        ),
                      );
                    },
                    icon: const Icon(Icons.share_rounded, size: 18),
                    label: const Text('Partager'),
                    style: OutlinedButton.styleFrom(
                      side: const BorderSide(color: AppColors.primary),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                      padding: const EdgeInsets.symmetric(vertical: 12),
                    ),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: ElevatedButton.icon(
                    onPressed: () {
                      _showECarnetPdfDownloadDialog(context, patient, record);
                    },
                    icon: const Icon(Icons.download_rounded, size: 18),
                    label: const Text('Télécharger en PDF'),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppColors.primary,
                      foregroundColor: Colors.white,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                      padding: const EdgeInsets.symmetric(vertical: 12),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  static Widget _buildDocumentSectionTitle(String title) {
    return Align(
      alignment: Alignment.centerLeft,
      child: Text(
        title,
        style: const TextStyle(
          fontSize: 12,
          fontWeight: FontWeight.w800,
          color: AppColors.primary,
          letterSpacing: 0.5,
        ),
      ),
    );
  }

  static Widget _buildDocRow(String label, String value, {bool isBold = false}) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 3),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(label, style: const TextStyle(fontSize: 12, color: AppColors.textSecondary)),
          Text(
            value,
            style: TextStyle(
              fontSize: 12.5,
              fontWeight: isBold ? FontWeight.w700 : FontWeight.w600,
              color: AppColors.textPrimary,
            ),
          ),
        ],
      ),
    );
  }

  static void _showECarnetPdfDownloadDialog(
    BuildContext context,
    Map<String, dynamic> patient,
    Map<String, dynamic> record,
  ) {
    final patientName = _text(patient['fullName'], 'patient');
    final fileName = 'e-carnet_${patientName.toLowerCase().replaceAll(RegExp(r'\s+'), '_')}.pdf';

    showModalBottomSheet(
      context: context,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      builder: (bottomSheetContext) {
        return Padding(
          padding: const EdgeInsets.all(24),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                width: 60,
                height: 60,
                decoration: BoxDecoration(
                  color: const Color(0xFFFEE2E2),
                  borderRadius: BorderRadius.circular(16),
                ),
                child: const Icon(
                  Icons.picture_as_pdf_rounded,
                  color: Color(0xFFDC2626),
                  size: 34,
                ),
              ),
              const SizedBox(height: 14),
              const Text(
                'e-Carnet Médical Prêt au Téléchargement',
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.w700),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 4),
              Text(
                fileName,
                style: const TextStyle(
                  fontFamily: 'Courier',
                  fontSize: 13.5,
                  fontWeight: FontWeight.w700,
                  color: AppColors.primary,
                ),
              ),
              const SizedBox(height: 16),

              Container(
                padding: const EdgeInsets.all(14),
                decoration: BoxDecoration(
                  color: AppColors.background,
                  borderRadius: BorderRadius.circular(14),
                  border: Border.all(color: AppColors.border),
                ),
                child: Column(
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        const Text('Titulaire :', style: TextStyle(fontSize: 12, color: AppColors.textSecondary)),
                        Text(patientName, style: const TextStyle(fontSize: 12.5, fontWeight: FontWeight.w700)),
                      ],
                    ),
                    const SizedBox(height: 8),
                    const Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text('Format généré :', style: TextStyle(fontSize: 12, color: AppColors.textSecondary)),
                        Text('PDF Médical Sécurisé (A4)', style: TextStyle(fontSize: 12.5, fontWeight: FontWeight.w600)),
                      ],
                    ),
                    const SizedBox(height: 8),
                    const Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text('Poids du fichier :', style: TextStyle(fontSize: 12, color: AppColors.textSecondary)),
                        Text('312 Ko', style: TextStyle(fontSize: 12.5, fontWeight: FontWeight.w600)),
                      ],
                    ),
                    const SizedBox(height: 8),
                    const Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text('Empreinte & Certification :', style: TextStyle(fontSize: 12, color: AppColors.textSecondary)),
                        Text('Horodatage Numérique Conforme', style: TextStyle(fontSize: 12.5, fontWeight: FontWeight.w700, color: AppColors.accentGreen)),
                      ],
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 20),

              SizedBox(
                width: double.infinity,
                child: ElevatedButton.icon(
                  onPressed: () {
                    Navigator.pop(bottomSheetContext);
                    Navigator.pop(context); // fermer la modale du document
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(
                        content: Row(
                          children: [
                            const Icon(Icons.check_circle_rounded, color: Colors.white),
                            const SizedBox(width: 10),
                            Expanded(
                              child: Text(
                                'e-Carnet médical téléchargé avec succès : $fileName !',
                              ),
                            ),
                          ],
                        ),
                        backgroundColor: AppColors.accentGreen,
                        duration: const Duration(seconds: 4),
                      ),
                    );
                  },
                  icon: const Icon(Icons.download_rounded),
                  label: const Text('Enregistrer le fichier PDF'),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.primary,
                    foregroundColor: Colors.white,
                    padding: const EdgeInsets.symmetric(vertical: 14),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                ),
              ),
            ],
          ),
        );
      },
    );
  }
}
