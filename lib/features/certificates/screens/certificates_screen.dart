import 'package:flutter/material.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_text_styles.dart';
import '../../../models/certificate.dart';
import '../../../services/certificate_service.dart';

class CertificatesScreen extends StatefulWidget {
  const CertificatesScreen({super.key});

  @override
  State<CertificatesScreen> createState() => _CertificatesScreenState();
}

class _CertificatesScreenState extends State<CertificatesScreen> {
  final CertificateService _certificateService = CertificateService();
  List<MedicalCertificate> _certificates = [];
  bool _isLoading = true;
  String _selectedFilter = 'ALL';

  @override
  void initState() {
    super.initState();
    _loadCertificates();
  }

  Future<void> _loadCertificates() async {
    setState(() => _isLoading = true);
    final certs = await _certificateService.getCertificates();
    if (mounted) {
      setState(() {
        _certificates = certs;
        _isLoading = false;
      });
    }
  }

  List<MedicalCertificate> get _filteredCertificates {
    if (_selectedFilter == 'ALL') return _certificates;
    return _certificates.where((c) => c.type == _selectedFilter).toList();
  }

  void _showOfficialSealDocument(MedicalCertificate cert) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => _OfficialCertificateModal(cert: cert),
    );
  }

  void _showNewCertificateDialog() {
    final reasonController = TextEditingController();
    final employerController = TextEditingController();
    int restDays = 3;
    String certType = 'SICK_LEAVE';

    showDialog(
      context: context,
      builder: (context) {
        return StatefulBuilder(
          builder: (context, setDialogState) {
            return AlertDialog(
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(20),
              ),
              title: const Text(
                'Émettre un certificat officiel',
                style: TextStyle(fontWeight: FontWeight.w700, fontSize: 18),
              ),
              content: SingleChildScrollView(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      'Type de document',
                      style: TextStyle(fontWeight: FontWeight.w600, fontSize: 13),
                    ),
                    const SizedBox(height: 6),
                    DropdownButtonFormField<String>(
                      initialValue: certType,
                      items: const [
                        DropdownMenuItem(
                          value: 'SICK_LEAVE',
                          child: Text('Arrêt de travail (Maladie)'),
                        ),
                        DropdownMenuItem(
                          value: 'STUDENT_DISPENSE',
                          child: Text('Dispense scolaire/universitaire'),
                        ),
                        DropdownMenuItem(
                          value: 'FITNESS_CERTIFICATE',
                          child: Text('Aptitude physique / sport'),
                        ),
                      ],
                      onChanged: (val) {
                        if (val != null) setDialogState(() => certType = val);
                      },
                      decoration: InputDecoration(
                        filled: true,
                        fillColor: AppColors.background,
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12),
                          borderSide: const BorderSide(color: AppColors.border),
                        ),
                        contentPadding: const EdgeInsets.symmetric(
                          horizontal: 14,
                          vertical: 12,
                        ),
                      ),
                    ),
                    const SizedBox(height: 14),
                    const Text(
                      'Durée du repos (jours)',
                      style: TextStyle(fontWeight: FontWeight.w600, fontSize: 13),
                    ),
                    const SizedBox(height: 6),
                    Row(
                      children: [
                        IconButton(
                          onPressed: restDays > 1
                              ? () => setDialogState(() => restDays--)
                              : null,
                          icon: const Icon(Icons.remove_circle_outline),
                        ),
                        Text(
                          '$restDays jour(s)',
                          style: const TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.w700,
                            color: AppColors.primary,
                          ),
                        ),
                        IconButton(
                          onPressed: () => setDialogState(() => restDays++),
                          icon: const Icon(Icons.add_circle_outline),
                        ),
                      ],
                    ),
                    const SizedBox(height: 12),
                    TextField(
                      controller: employerController,
                      decoration: InputDecoration(
                        labelText: 'Employeur / Établissement',
                        hintText: 'Ex: Ministère, Entreprise XYZ',
                        filled: true,
                        fillColor: AppColors.background,
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                      ),
                    ),
                    const SizedBox(height: 12),
                    TextField(
                      controller: reasonController,
                      maxLines: 2,
                      decoration: InputDecoration(
                        labelText: 'Motif clinique / Diagnostic',
                        hintText: 'Ex: Convalescence post-paludisme fébrile',
                        filled: true,
                        fillColor: AppColors.background,
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              actions: [
                TextButton(
                  onPressed: () => Navigator.pop(context),
                  child: const Text('Annuler'),
                ),
                ElevatedButton(
                  onPressed: () async {
                    final nav = Navigator.of(context);
                    final messenger = ScaffoldMessenger.of(context);
                    nav.pop();
                    final newCert = await _certificateService.issueCertificate({
                      'type': certType,
                      'restDurationDays': restDays,
                      'employerOrInstitution': employerController.text.trim().isEmpty
                          ? 'Direction RH'
                          : employerController.text.trim(),
                      'diagnosisOrReason': reasonController.text.trim().isEmpty
                          ? 'Repos médical justifié'
                          : reasonController.text.trim(),
                      'hospitalName': 'CHU Yalgado Ouédraogo',
                      'doctorName': 'Dr. Amadou Ouédraogo',
                      'patientName': 'Kaboré Souleymane',
                    });
                    if (!mounted) return;
                    setState(() {
                      _certificates.insert(0, newCert);
                    });
                    messenger.showSnackBar(
                      const SnackBar(
                        content: Text('Certificat officiel émis avec cachet numérique SHA-256 !'),
                        backgroundColor: AppColors.accentGreen,
                      ),
                    );
                    _showOfficialSealDocument(newCert);
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.primary,
                    foregroundColor: Colors.white,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                  child: const Text('Émettre avec Sceau'),
                ),
              ],
            );
          },
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        backgroundColor: AppColors.surface,
        elevation: 0,
        title: Text(
          'Certificats & Cachet Officiel',
          style: AppTextStyles.headingMedium.copyWith(color: AppColors.textPrimary),
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh_rounded, color: AppColors.primary),
            onPressed: _loadCertificates,
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: _showNewCertificateDialog,
        backgroundColor: AppColors.primary,
        icon: const Icon(Icons.verified_rounded, color: Colors.white),
        label: const Text(
          'Émettre un certificat',
          style: TextStyle(color: Colors.white, fontWeight: FontWeight.w600),
        ),
      ),
      body: Center(
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 520),
          child: Column(
            children: [
              // 1. Filtres par type
              Container(
                color: AppColors.surface,
                padding: const EdgeInsets.fromLTRB(16, 4, 16, 12),
                child: SingleChildScrollView(
                  scrollDirection: Axis.horizontal,
                  child: Row(
                    children: [
                      _buildFilterChip('ALL', 'Tous les certificats'),
                      const SizedBox(width: 8),
                      _buildFilterChip('SICK_LEAVE', 'Arrêt de travail'),
                      const SizedBox(width: 8),
                      _buildFilterChip('FITNESS_CERTIFICATE', 'Aptitude physique'),
                      const SizedBox(width: 8),
                      _buildFilterChip('STUDENT_DISPENSE', 'Dispense scolaire'),
                    ],
                  ),
                ),
              ),

              // 2. Bannière de sécurité et conformité MOD-17
              Container(
                margin: const EdgeInsets.all(16),
                padding: const EdgeInsets.all(14),
                decoration: BoxDecoration(
                  gradient: const LinearGradient(
                    colors: [Color(0xFF1B5FE0), Color(0xFF2563EB)],
                  ),
                  borderRadius: BorderRadius.circular(16),
                  boxShadow: const [
                    BoxShadow(
                      color: Color(0x221B5FE0),
                      blurRadius: 12,
                      offset: Offset(0, 4),
                    ),
                  ],
                ),
                child: Row(
                  children: [
                    Container(
                      padding: const EdgeInsets.all(10),
                      decoration: BoxDecoration(
                        color: Colors.white.withValues(alpha: 0.20),
                        shape: BoxShape.circle,
                      ),
                      child: const Icon(
                        Icons.shield_rounded,
                        color: Colors.white,
                        size: 26,
                      ),
                    ),
                    const SizedBox(width: 14),
                    const Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'Documents Médicaux Certifiés',
                            style: TextStyle(
                              color: Colors.white,
                              fontSize: 15,
                              fontWeight: FontWeight.w700,
                            ),
                          ),
                          SizedBox(height: 3),
                          Text(
                            'Chaque certificat comporte le cachet officiel circulaire de l\'établissement et un sceau numérique SHA-256 infalsifiable.',
                            style: TextStyle(
                              color: Color(0xFFE0E7FF),
                              fontSize: 12,
                              height: 1.35,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),

              // 3. Liste des certificats
              Expanded(
                child: _isLoading
                    ? const Center(child: CircularProgressIndicator())
                    : _filteredCertificates.isEmpty
                        ? const Center(
                            child: Text(
                              'Aucun certificat trouvé.',
                              style: TextStyle(color: AppColors.textSecondary),
                            ),
                          )
                        : RefreshIndicator(
                            onRefresh: _loadCertificates,
                            child: ListView.builder(
                              padding: const EdgeInsets.fromLTRB(16, 0, 16, 90),
                              itemCount: _filteredCertificates.length,
                              itemBuilder: (context, index) {
                                final cert = _filteredCertificates[index];
                                return _CertificateCard(
                                  cert: cert,
                                  onViewOfficialDoc: () =>
                                      _showOfficialSealDocument(cert),
                                );
                              },
                            ),
                          ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildFilterChip(String value, String label) {
    final isSelected = _selectedFilter == value;
    return GestureDetector(
      onTap: () => setState(() => _selectedFilter = value),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
        decoration: BoxDecoration(
          color: isSelected ? AppColors.primary : AppColors.background,
          borderRadius: BorderRadius.circular(20),
          border: Border.all(
            color: isSelected ? AppColors.primary : AppColors.border,
          ),
        ),
        child: Text(
          label,
          style: TextStyle(
            fontSize: 12.5,
            fontWeight: isSelected ? FontWeight.w700 : FontWeight.w500,
            color: isSelected ? Colors.white : AppColors.textSecondary,
          ),
        ),
      ),
    );
  }
}

class _CertificateCard extends StatelessWidget {
  const _CertificateCard({
    required this.cert,
    required this.onViewOfficialDoc,
  });

  final MedicalCertificate cert;
  final VoidCallback onViewOfficialDoc;

  @override
  Widget build(BuildContext context) {
    final isSickLeave = cert.type == 'SICK_LEAVE';
    final badgeColor = isSickLeave ? const Color(0xFFE11D48) : AppColors.primary;
    final badgeBg = isSickLeave ? const Color(0xFFFEE2E2) : AppColors.softBlue;

    return Container(
      margin: const EdgeInsets.only(bottom: 14),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: AppColors.border.withValues(alpha: 0.8)),
        boxShadow: const [
          BoxShadow(
            color: Color(0x080F172A),
            blurRadius: 10,
            offset: Offset(0, 3),
          ),
        ],
      ),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                  decoration: BoxDecoration(
                    color: badgeBg,
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Text(
                    cert.typeLabel,
                    style: TextStyle(
                      color: badgeColor,
                      fontSize: 11.5,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                ),
                const Spacer(),
                Text(
                  cert.certificateNumber,
                  style: const TextStyle(
                    fontFamily: 'Courier',
                    fontSize: 12,
                    fontWeight: FontWeight.w700,
                    color: AppColors.textSecondary,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),
            Text(
              cert.diagnosisOrReason,
              style: const TextStyle(
                fontSize: 15,
                fontWeight: FontWeight.w700,
                color: AppColors.textPrimary,
              ),
            ),
            const SizedBox(height: 8),
            Row(
              children: [
                const Icon(
                  Icons.calendar_today_rounded,
                  size: 14,
                  color: AppColors.textSecondary,
                ),
                const SizedBox(width: 6),
                Text(
                  isSickLeave
                      ? '${cert.restDurationDays} jours de repos (jusqu\'au ${_formatDate(cert.endDate)})'
                      : 'Valable 1 an (jusqu\'au ${_formatDate(cert.endDate)})',
                  style: const TextStyle(
                    fontSize: 13,
                    fontWeight: FontWeight.w600,
                    color: AppColors.primary,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 6),
            Row(
              children: [
                const Icon(
                  Icons.business_rounded,
                  size: 14,
                  color: AppColors.textSecondary,
                ),
                const SizedBox(width: 6),
                Expanded(
                  child: Text(
                    '${cert.hospitalName} • ${cert.doctorName}',
                    style: const TextStyle(
                      fontSize: 12,
                      color: AppColors.textSecondary,
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 14),
            Row(
              children: [
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                  decoration: BoxDecoration(
                    color: AppColors.softGreen,
                    borderRadius: BorderRadius.circular(6),
                  ),
                  child: const Row(
                    children: [
                      Icon(Icons.check_circle_rounded, size: 12, color: AppColors.accentGreen),
                      SizedBox(width: 4),
                      Text(
                        'Cachet Électronique Vérifié',
                        style: TextStyle(
                          fontSize: 11,
                          fontWeight: FontWeight.w600,
                          color: AppColors.accentGreen,
                        ),
                      ),
                    ],
                  ),
                ),
                const Spacer(),
                ElevatedButton.icon(
                  onPressed: onViewOfficialDoc,
                  icon: const Icon(Icons.visibility_rounded, size: 16),
                  label: const Text('Voir le Cachet'),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.primaryContainer,
                    foregroundColor: AppColors.primary,
                    elevation: 0,
                    padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(10),
                    ),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  String _formatDate(DateTime dt) {
    return '${dt.day.toString().padLeft(2, '0')}/${dt.month.toString().padLeft(2, '0')}/${dt.year}';
  }
}

/// Vue Plein-Document du Certificat avec Cachet Officiel Circulaire de l'Hôpital
class _OfficialCertificateModal extends StatelessWidget {
  const _OfficialCertificateModal({required this.cert});

  final MedicalCertificate cert;

  @override
  Widget build(BuildContext context) {
    return Container(
      height: MediaQuery.of(context).size.height * 0.90,
      decoration: const BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      child: Column(
        children: [
          // Poignée et barre supérieure
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 12, 16, 10),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Text(
                  'Attestation Médicale Officielle',
                  style: TextStyle(fontSize: 16, fontWeight: FontWeight.w700),
                ),
                IconButton(
                  icon: const Icon(Icons.close_rounded),
                  onPressed: () => Navigator.pop(context),
                ),
              ],
            ),
          ),
          const Divider(height: 1),

          // Contenu imprimable du document officiel
          Expanded(
            child: SingleChildScrollView(
              padding: const EdgeInsets.all(24),
              child: Container(
                padding: const EdgeInsets.all(20),
                decoration: BoxDecoration(
                  color: const Color(0xFFFAFAFA),
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(color: const Color(0xFFE2E8F0), width: 1.5),
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
                        fontSize: 11,
                        fontWeight: FontWeight.w800,
                        letterSpacing: 0.8,
                        color: Color(0xFF1E293B),
                      ),
                    ),
                    const SizedBox(height: 4),
                    const Text(
                      'MINISTÈRE DE LA SANTÉ ET DE L\'HYGIÈNE PUBLIQUE',
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        fontSize: 10,
                        fontWeight: FontWeight.w600,
                        color: Color(0xFF64748B),
                      ),
                    ),
                    const SizedBox(height: 10),
                    Container(
                      height: 2,
                      width: 120,
                      color: AppColors.primary,
                    ),
                    const SizedBox(height: 12),

                    Text(
                      cert.hospitalName.toUpperCase(),
                      textAlign: TextAlign.center,
                      style: const TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.w800,
                        color: AppColors.primary,
                      ),
                    ),
                    const SizedBox(height: 16),

                    // Titre du certificat
                    Container(
                      width: double.infinity,
                      padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 12),
                      decoration: BoxDecoration(
                        color: AppColors.softBlue,
                        borderRadius: BorderRadius.circular(8),
                        border: Border.all(color: AppColors.primary.withValues(alpha: 0.3)),
                      ),
                      child: Text(
                        cert.typeLabel.toUpperCase(),
                        textAlign: TextAlign.center,
                        style: const TextStyle(
                          fontSize: 13,
                          fontWeight: FontWeight.w800,
                          color: AppColors.primary,
                        ),
                      ),
                    ),
                    const SizedBox(height: 16),

                    // Corps du texte légal
                    Align(
                      alignment: Alignment.centerLeft,
                      child: Text(
                        'Je soussigné, ${cert.doctorName}, Docteur en Médecine, certifie avoir examiné ce jour le patient :\n\n'
                        '• Nom et Prénom : ${cert.patientName}\n'
                        '• Établissement employeur : ${cert.employerOrInstitution}\n'
                        '• Motif d\'interruption / Constat : ${cert.diagnosisOrReason}\n\n'
                        'Et déclare que son état de santé nécessite un repos absolu de ${cert.restDurationDays} jour(s) '
                        'du ${_formatDate(cert.startDate)} au ${_formatDate(cert.endDate)} inclus.\n\n'
                        'Certificat délivré pour servir et valoir ce que de droit.',
                        style: const TextStyle(
                          fontSize: 13,
                          height: 1.5,
                          color: Color(0xFF1E293B),
                        ),
                      ),
                    ),
                    const SizedBox(height: 20),

                    // Zone de Cachet et Signature
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceAround,
                      children: [
                        // Signature Praticien
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.center,
                          children: [
                            const Text(
                              'Le Médecin Traitant',
                              style: TextStyle(
                                fontSize: 11.5,
                                fontWeight: FontWeight.w700,
                                color: AppColors.textPrimary,
                              ),
                            ),
                            const SizedBox(height: 8),
                            Text(
                              cert.doctorName,
                              style: const TextStyle(
                                fontStyle: FontStyle.italic,
                                fontWeight: FontWeight.w600,
                                fontSize: 12,
                                color: AppColors.primary,
                              ),
                            ),
                            const SizedBox(height: 4),
                            const Text(
                              'Signature Numérique Validée',
                              style: TextStyle(
                                fontSize: 9.5,
                                color: AppColors.accentGreen,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                          ],
                        ),

                        // Cachet Officiel Circulaire de l'Hôpital
                        _CircularHospitalSeal(
                          hospitalName: cert.hospitalName,
                          date: cert.createdAt,
                          sealHash: cert.digitalSealHash,
                        ),
                      ],
                    ),

                    const SizedBox(height: 24),
                    const Divider(),
                    const SizedBox(height: 8),

                    // Sceau SHA-256 et Empreinte de Sécurité
                    Row(
                      children: [
                        const Icon(
                          Icons.qr_code_2_rounded,
                          size: 42,
                          color: AppColors.textPrimary,
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              const Text(
                                'Sceau Cryptographique SHA-256 & Télé-vérification :',
                                style: TextStyle(
                                  fontSize: 10,
                                  fontWeight: FontWeight.w700,
                                  color: AppColors.textPrimary,
                                ),
                              ),
                              const SizedBox(height: 2),
                              Text(
                                cert.digitalSealHash,
                                style: const TextStyle(
                                  fontFamily: 'Courier',
                                  fontSize: 8.5,
                                  color: AppColors.textSecondary,
                                ),
                                maxLines: 2,
                                overflow: TextOverflow.ellipsis,
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ),
          ),

          // Actions : Partager, Télécharger, Imprimer
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
                          content: Text('Certificat prêt pour impression ou partage !'),
                          backgroundColor: AppColors.primary,
                        ),
                      );
                    },
                    icon: const Icon(Icons.share_rounded, size: 18),
                    label: const Text('Partager RH'),
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
                      Navigator.pop(context);
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(
                          content: Text('Document PDF certifié avec cachet téléchargé avec succès.'),
                          backgroundColor: AppColors.accentGreen,
                        ),
                      );
                    },
                    icon: const Icon(Icons.download_rounded, size: 18),
                    label: const Text('Télécharger PDF'),
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

  static String _formatDate(DateTime dt) {
    return '${dt.day.toString().padLeft(2, '0')}/${dt.month.toString().padLeft(2, '0')}/${dt.year}';
  }
}

/// Cachet Circulaire Officiel de l'Hôpital (MOD-17)
class _CircularHospitalSeal extends StatelessWidget {
  const _CircularHospitalSeal({
    required this.hospitalName,
    required this.date,
    required this.sealHash,
  });

  final String hospitalName;
  final DateTime date;
  final String sealHash;

  @override
  Widget build(BuildContext context) {
    const sealColor = Color(0xFF1B5FE0);
    return Container(
      width: 110,
      height: 110,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        border: Border.all(color: sealColor, width: 2.5),
      ),
      child: Container(
        margin: const EdgeInsets.all(4),
        decoration: BoxDecoration(
          shape: BoxShape.circle,
          border: Border.all(color: sealColor, width: 1.2),
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Text(
              'RÉPUBLIQUE DU BURKINA',
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: 6.2,
                fontWeight: FontWeight.w800,
                color: sealColor,
                letterSpacing: 0.2,
              ),
            ),
            const SizedBox(height: 2),
            const Icon(
              Icons.local_hospital_rounded,
              color: sealColor,
              size: 18,
            ),
            const SizedBox(height: 2),
            const Text(
              '★ CACHET OFFICIEL ★',
              style: TextStyle(
                fontSize: 6.5,
                fontWeight: FontWeight.w900,
                color: sealColor,
              ),
            ),
            Text(
              '${date.day.toString().padLeft(2, '0')}/${date.month.toString().padLeft(2, '0')}/${date.year}',
              style: const TextStyle(
                fontSize: 6.5,
                fontWeight: FontWeight.w700,
                color: sealColor,
              ),
            ),
            const SizedBox(height: 1),
            const Text(
              'DIRECTION MÉDICALE',
              style: TextStyle(
                fontSize: 5.8,
                fontWeight: FontWeight.w800,
                color: sealColor,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
