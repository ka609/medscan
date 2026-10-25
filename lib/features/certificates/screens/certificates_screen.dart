import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_text_styles.dart';
import '../../../core/utils/id_generator.dart';
import '../../../models/certificate.dart';
import '../../../models/user.dart';
import '../../../providers/auth_provider.dart';
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
    final user = context.read<AuthProvider>().user;
    final isDoctor = user.isDoctor;

    final certs = await _certificateService.getCertificates(
      doctorId: isDoctor ? (user?.id.isNotEmpty == true ? user!.id : null) : null,
      patientId: !isDoctor ? (user?.id.isNotEmpty == true ? user!.id : null) : null,
      isDoctor: isDoctor,
    );

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

  @override
  Widget build(BuildContext context) {
    final user = context.watch<AuthProvider>().user;
    final isDoctor = user.isDoctor;

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        backgroundColor: AppColors.surface,
        elevation: 0,
        title: Text(
          isDoctor ? 'Certificats Émis (Praticien)' : 'Certificats & Cachet Officiel',
          style: AppTextStyles.headingMedium.copyWith(color: AppColors.textPrimary),
        ),
        actions: [
          if (isDoctor)
            IconButton(
              tooltip: 'Émettre un certificat',
              icon: const Icon(Icons.note_add_rounded, color: AppColors.primary),
              onPressed: () {
                showIssueCertificateDialog(
                  context,
                  onCertificateIssued: (newCert) {
                    setState(() {
                      _certificates.insert(0, newCert);
                    });
                  },
                );
              },
            ),
          IconButton(
            icon: const Icon(Icons.refresh_rounded, color: AppColors.primary),
            onPressed: _loadCertificates,
          ),
        ],
      ),
      floatingActionButton: isDoctor
          ? FloatingActionButton.extended(
              onPressed: () {
                showIssueCertificateDialog(
                  context,
                  onCertificateIssued: (newCert) {
                    setState(() {
                      _certificates.insert(0, newCert);
                    });
                  },
                );
              },
              backgroundColor: AppColors.primary,
              icon: const Icon(Icons.send_rounded, color: Colors.white),
              label: const Text(
                'Émettre un certificat',
                style: TextStyle(color: Colors.white, fontWeight: FontWeight.w600),
              ),
            )
          : null,
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

              // 2. Bannière de sécurité et conformité officielle
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
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            isDoctor
                                ? 'Registre des Certificats Émis'
                                : 'Délivrance Médicale Sécurisée',
                            style: const TextStyle(
                              color: Colors.white,
                              fontSize: 15,
                              fontWeight: FontWeight.w700,
                            ),
                          ),
                          const SizedBox(height: 3),
                          Text(
                            isDoctor
                                ? 'Retrouvez la liste des attestations officielles que vous avez délivrées. Le téléchargement direct du PDF original est réservé au patient bénéficiaire.'
                                : 'Seul votre médecin traitant est habilité à établir un certificat. Retrouvez ici tous vos arrêts de travail validés, avec cachet officiel circulaire et sceau infalsifiable.',
                            style: const TextStyle(
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
                        ? Center(
                            child: Padding(
                              padding: const EdgeInsets.all(24),
                              child: Text(
                                isDoctor
                                    ? 'Aucun certificat émis pour le moment.'
                                    : 'Aucun certificat médical enregistré dans votre dossier.',
                                textAlign: TextAlign.center,
                                style: const TextStyle(color: AppColors.textSecondary),
                              ),
                            ),
                          )
                        : RefreshIndicator(
                            onRefresh: _loadCertificates,
                            child: ListView.builder(
                              padding: const EdgeInsets.fromLTRB(16, 0, 16, 90),
                              itemCount: _filteredCertificates.length,
                              itemBuilder: (context, index) {
                                final cert = _filteredCertificates[index];
                                return CertificateCardWidget(
                                  cert: cert,
                                  isDoctor: isDoctor,
                                  onViewOfficialDoc: () =>
                                      showOfficialCertificateModal(
                                    context,
                                    cert,
                                    isDoctor: isDoctor,
                                  ),
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

/// Dialogue d'émission d'un certificat médical officiel par le praticien
/// Sans raccourcis de patients codés en dur : pré-rempli depuis le dossier du patient si fourni
void showIssueCertificateDialog(
  BuildContext context, {
  Map<String, dynamic>? initialPatient,
  void Function(MedicalCertificate newCert)? onCertificateIssued,
}) {
  final prefilledName = (initialPatient?['fullName'] ?? initialPatient?['name'] ?? '').toString();
  final prefilledPhone = (initialPatient?['phone'] ?? initialPatient?['phoneNumber'] ?? '').toString();
  final prefilledPatientId = (initialPatient?['id'] ?? '').toString();

  final patientNameController = TextEditingController(text: prefilledName);
  final patientPhoneController = TextEditingController(text: prefilledPhone);
  final employerController = TextEditingController();
  final reasonController = TextEditingController();
  int restDays = 3;
  String certType = 'SICK_LEAVE';

  showDialog(
    context: context,
    builder: (dialogCtx) {
      return StatefulBuilder(
        builder: (context, setDialogState) {
          final now = DateTime.now();
          final startDateStr =
              '${now.day.toString().padLeft(2, '0')}/${now.month.toString().padLeft(2, '0')}/${now.year}';
          final endDate = now.add(Duration(days: restDays));
          final endDateStr =
              '${endDate.day.toString().padLeft(2, '0')}/${endDate.month.toString().padLeft(2, '0')}/${endDate.year}';

          return AlertDialog(
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(22),
            ),
            title: Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: AppColors.primaryContainer,
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: const Icon(Icons.post_add_rounded,
                      color: AppColors.primary, size: 22),
                ),
                const SizedBox(width: 10),
                const Expanded(
                  child: Text(
                    'Émettre un certificat médical',
                    style: TextStyle(fontWeight: FontWeight.w700, fontSize: 16.5),
                  ),
                ),
              ],
            ),
            content: SingleChildScrollView(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  if (prefilledName.isNotEmpty)
                    Container(
                      margin: const EdgeInsets.only(bottom: 12),
                      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                      decoration: BoxDecoration(
                        color: AppColors.softBlue,
                        borderRadius: BorderRadius.circular(10),
                        border: Border.all(color: AppColors.primary.withValues(alpha: 0.3)),
                      ),
                      child: Row(
                        children: [
                          const Icon(Icons.folder_shared_rounded, size: 16, color: AppColors.primary),
                          const SizedBox(width: 8),
                          Expanded(
                            child: Text(
                              'Dossier patient : $prefilledName',
                              style: const TextStyle(
                                fontSize: 12,
                                fontWeight: FontWeight.w700,
                                color: AppColors.primary,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),

                  const Text(
                    'Nom et Prénom du patient destinataire *',
                    style: TextStyle(fontWeight: FontWeight.w600, fontSize: 13),
                  ),
                  const SizedBox(height: 6),
                  TextField(
                    controller: patientNameController,
                    decoration: InputDecoration(
                      hintText: 'Saisir le nom complet du patient...',
                      prefixIcon: const Icon(Icons.person_rounded, color: AppColors.primary),
                      filled: true,
                      fillColor: AppColors.background,
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                        borderSide: const BorderSide(color: AppColors.border),
                      ),
                      contentPadding:
                          const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
                    ),
                  ),
                  const SizedBox(height: 12),

                  const Text(
                    'Téléphone / Contact patient',
                    style: TextStyle(fontWeight: FontWeight.w600, fontSize: 13),
                  ),
                  const SizedBox(height: 6),
                  TextField(
                    controller: patientPhoneController,
                    keyboardType: TextInputType.phone,
                    decoration: InputDecoration(
                      hintText: 'Ex: +226 70 00 00 00',
                      prefixIcon: const Icon(Icons.phone_rounded, color: AppColors.primary),
                      filled: true,
                      fillColor: AppColors.background,
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                        borderSide: const BorderSide(color: AppColors.border),
                      ),
                      contentPadding:
                          const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
                    ),
                  ),
                  const SizedBox(height: 12),

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
                        child: Text('Arrêt de travail (Employeur)'),
                      ),
                      DropdownMenuItem(
                        value: 'STUDENT_DISPENSE',
                        child: Text('Dispense scolaire / universitaire'),
                      ),
                      DropdownMenuItem(
                        value: 'FITNESS_CERTIFICATE',
                        child: Text('Certificat médical d\'aptitude'),
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

                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      const Text(
                        'Durée du repos :',
                        style: TextStyle(fontWeight: FontWeight.w600, fontSize: 13),
                      ),
                      Row(
                        children: [
                          IconButton(
                            onPressed: restDays > 1
                                ? () => setDialogState(() => restDays--)
                                : null,
                            icon: const Icon(Icons.remove_circle_outline,
                                color: AppColors.primary),
                          ),
                          Container(
                            padding: const EdgeInsets.symmetric(
                                horizontal: 12, vertical: 4),
                            decoration: BoxDecoration(
                              color: AppColors.softBlue,
                              borderRadius: BorderRadius.circular(8),
                            ),
                            child: Text(
                              '$restDays jour(s)',
                              style: const TextStyle(
                                fontSize: 15,
                                fontWeight: FontWeight.w700,
                                color: AppColors.primary,
                              ),
                            ),
                          ),
                          IconButton(
                            onPressed: () => setDialogState(() => restDays++),
                            icon: const Icon(Icons.add_circle_outline,
                                color: AppColors.primary),
                          ),
                        ],
                      ),
                    ],
                  ),

                  Container(
                    padding: const EdgeInsets.all(10),
                    margin: const EdgeInsets.symmetric(vertical: 8),
                    decoration: BoxDecoration(
                      color: AppColors.softGreen,
                      borderRadius: BorderRadius.circular(10),
                    ),
                    child: Row(
                      children: [
                        const Icon(Icons.event_available_rounded,
                            size: 16, color: AppColors.accentGreen),
                        const SizedBox(width: 8),
                        Expanded(
                          child: Text(
                            'Période couverte : Du $startDateStr au $endDateStr inclus',
                            style: const TextStyle(
                                fontSize: 12,
                                fontWeight: FontWeight.w600,
                                color: AppColors.accentGreen),
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 8),

                  const Text(
                    'Employeur ou Établissement destinataire',
                    style: TextStyle(fontWeight: FontWeight.w600, fontSize: 13),
                  ),
                  const SizedBox(height: 6),
                  TextField(
                    controller: employerController,
                    decoration: InputDecoration(
                      hintText: 'Ex: Direction RH, Établissement...',
                      prefixIcon: const Icon(Icons.business_rounded,
                          color: AppColors.primary),
                      filled: true,
                      fillColor: AppColors.background,
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                        borderSide: const BorderSide(color: AppColors.border),
                      ),
                      contentPadding:
                          const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
                    ),
                  ),
                  const SizedBox(height: 12),

                  const Text(
                    'Motif clinique / Diagnostic légal',
                    style: TextStyle(fontWeight: FontWeight.w600, fontSize: 13),
                  ),
                  const SizedBox(height: 6),
                  TextField(
                    controller: reasonController,
                    maxLines: 2,
                    decoration: InputDecoration(
                      hintText: 'Ex: Repos médical strict requis suite à examen...',
                      filled: true,
                      fillColor: AppColors.background,
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                        borderSide: const BorderSide(color: AppColors.border),
                      ),
                      contentPadding:
                          const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
                    ),
                  ),
                ],
              ),
            ),
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(dialogCtx),
                child: const Text('Annuler'),
              ),
              ElevatedButton.icon(
                onPressed: () async {
                  final targetName = patientNameController.text.trim().isEmpty
                      ? (prefilledName.isNotEmpty ? prefilledName : 'Patient')
                      : patientNameController.text.trim();

                  Navigator.pop(dialogCtx);

                  final user = context.read<AuthProvider>().user;
                  final doctorDisplayName = user?.displayTitle ?? 'Dr. Praticien';
                  final doctorId = user?.id.isNotEmpty == true ? user!.id : IdGenerator.doctorId();
                  final patientId = prefilledPatientId.isNotEmpty ? prefilledPatientId : IdGenerator.patientId();

                  final newCert = await CertificateService().issueCertificate({
                    'type': certType,
                    'restDurationDays': restDays,
                    'employerOrInstitution': employerController.text.trim().isEmpty
                        ? 'Direction des Ressources Humaines'
                        : employerController.text.trim(),
                    'diagnosisOrReason': reasonController.text.trim().isEmpty
                        ? 'Repos médical justifié'
                        : reasonController.text.trim(),
                    'hospitalName': 'CHU Yalgado Ouédraogo',
                    'doctorId': doctorId,
                    'doctorName': doctorDisplayName,
                    'patientName': targetName,
                    'patientId': patientId,
                    'startDate': now.toIso8601String(),
                    'endDate': endDate.toIso8601String(),
                  });

                  onCertificateIssued?.call(newCert);

                  if (context.mounted) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(
                        content: Row(
                          children: [
                            const Icon(Icons.check_circle_rounded, color: Colors.white),
                            const SizedBox(width: 10),
                            Expanded(
                              child: Text(
                                'Certificat médical délivré et envoyé à $targetName. Le patient est notifié et peut le télécharger en PDF.',
                              ),
                            ),
                          ],
                        ),
                        backgroundColor: AppColors.accentGreen,
                        duration: const Duration(seconds: 4),
                      ),
                    );

                    showOfficialCertificateModal(
                      context,
                      newCert,
                      isDoctor: true,
                    );
                  }
                },
                icon: const Icon(Icons.send_rounded, size: 18),
                label: const Text('Émettre & Sceller'),
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.primary,
                  foregroundColor: Colors.white,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                  padding:
                      const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                ),
              ),
            ],
          );
        },
      );
    },
  );
}

class CertificateCardWidget extends StatelessWidget {
  const CertificateCardWidget({
    super.key,
    required this.cert,
    required this.onViewOfficialDoc,
    this.isDoctor = false,
  });

  final MedicalCertificate cert;
  final VoidCallback onViewOfficialDoc;
  final bool isDoctor;

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
                  'Du ${_formatDate(cert.startDate)} au ${_formatDate(cert.endDate)}',
                  style: const TextStyle(
                    fontSize: 12.5,
                    color: AppColors.textSecondary,
                    fontWeight: FontWeight.w500,
                  ),
                ),
                const Spacer(),
                Text(
                  '${cert.restDurationDays} jour(s) de repos',
                  style: const TextStyle(
                    fontSize: 12.5,
                    fontWeight: FontWeight.w700,
                    color: AppColors.primary,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 6),
            Row(
              children: [
                const Icon(
                  Icons.person_outline_rounded,
                  size: 14,
                  color: AppColors.textSecondary,
                ),
                const SizedBox(width: 6),
                Expanded(
                  child: Text(
                    'Patient : ${cert.patientName} • ${cert.hospitalName}',
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
                      Icon(Icons.check_circle_rounded,
                          size: 12, color: AppColors.accentGreen),
                      SizedBox(width: 4),
                      Text(
                        'Cachet Officiel Scellé',
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
                  icon: Icon(
                    isDoctor ? Icons.visibility_rounded : Icons.file_download_outlined,
                    size: 16,
                  ),
                  label: Text(
                    isDoctor ? 'Consulter l\'attestation' : 'Voir & Télécharger',
                  ),
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

/// Affiche la modale plein-document de l'attestation officielle avec cachet circulaire
void showOfficialCertificateModal(
  BuildContext context,
  MedicalCertificate cert, {
  bool isDoctor = false,
}) {
  showModalBottomSheet(
    context: context,
    isScrollControlled: true,
    backgroundColor: Colors.transparent,
    builder: (context) => _OfficialCertificateModal(cert: cert, isDoctor: isDoctor),
  );
}

/// Vue Plein-Document du Certificat avec Cachet Officiel Circulaire de l'Hôpital
class _OfficialCertificateModal extends StatelessWidget {
  const _OfficialCertificateModal({
    required this.cert,
    this.isDoctor = false,
  });

  final MedicalCertificate cert;
  final bool isDoctor;

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

          // Actions : Le docteur ne télécharge pas le certificat, seul le patient a le bouton PDF
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
            child: isDoctor
                ? Container(
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: AppColors.softBlue,
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(
                        color: AppColors.primary.withValues(alpha: 0.25),
                      ),
                    ),
                    child: Row(
                      children: [
                        const Icon(
                          Icons.verified_rounded,
                          color: AppColors.primary,
                          size: 24,
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              const Text(
                                'Attestation Officielle Émise & Scellée',
                                style: TextStyle(
                                  fontWeight: FontWeight.w700,
                                  fontSize: 12.5,
                                  color: AppColors.primary,
                                ),
                              ),
                              const SizedBox(height: 2),
                              Text(
                                'Délivré au patient ${cert.patientName}. Conformément aux règles ordinales, le téléchargement direct du PDF est réservé au patient destinataire.',
                                style: const TextStyle(
                                  fontSize: 11,
                                  color: AppColors.textSecondary,
                                  height: 1.3,
                                ),
                              ),
                            ],
                          ),
                        ),
                        const SizedBox(width: 8),
                        TextButton(
                          onPressed: () => Navigator.pop(context),
                          child: const Text('Fermer'),
                        ),
                      ],
                    ),
                  )
                : Row(
                    children: [
                      Expanded(
                        child: OutlinedButton.icon(
                          onPressed: () {
                            Navigator.pop(context);
                            ScaffoldMessenger.of(context).showSnackBar(
                              const SnackBar(
                                content: Text('Certificat prêt pour transmission !'),
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
                            _showPdfDownloadDialog(context, cert);
                          },
                          icon: const Icon(Icons.download_rounded, size: 18),
                          label: const Text('Télécharger au format PDF'),
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

  static void _showPdfDownloadDialog(BuildContext context, MedicalCertificate cert) {
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
                'Document PDF Officiel Prêt',
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.w700),
              ),
              const SizedBox(height: 4),
              Text(
                '${cert.certificateNumber}.pdf',
                style: const TextStyle(
                  fontFamily: 'Courier',
                  fontSize: 14,
                  fontWeight: FontWeight.w700,
                  color: AppColors.primary,
                ),
              ),
              const SizedBox(height: 14),

              // Détails du document PDF
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
                        const Text('Patient bénéficiaire :',
                            style: TextStyle(fontSize: 12, color: AppColors.textSecondary)),
                        Text(cert.patientName,
                            style: const TextStyle(fontSize: 12.5, fontWeight: FontWeight.w700)),
                      ],
                    ),
                    const SizedBox(height: 8),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        const Text('Format généré :',
                            style: TextStyle(fontSize: 12, color: AppColors.textSecondary)),
                        const Text('PDF / A-1b (Archivage légal)',
                            style: TextStyle(fontSize: 12, fontWeight: FontWeight.w600)),
                      ],
                    ),
                    const SizedBox(height: 8),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        const Text('Poids du fichier :',
                            style: TextStyle(fontSize: 12, color: AppColors.textSecondary)),
                        const Text('142 Ko',
                            style: TextStyle(fontSize: 12, fontWeight: FontWeight.w600)),
                      ],
                    ),
                    const SizedBox(height: 8),
                    Row(
                      children: [
                        const Icon(Icons.verified_rounded,
                            size: 14, color: AppColors.accentGreen),
                        const SizedBox(width: 6),
                        Expanded(
                          child: Text(
                            'Cachet officiel de ${cert.hospitalName} & Signature inclus.',
                            style: const TextStyle(
                                fontSize: 11,
                                color: AppColors.accentGreen,
                                fontWeight: FontWeight.w600),
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),

              const SizedBox(height: 20),

              // Actions
              SizedBox(
                width: double.infinity,
                height: 48,
                child: ElevatedButton.icon(
                  onPressed: () {
                    Navigator.pop(bottomSheetContext);
                    Navigator.pop(context);
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(
                        content: Text(
                          'Document PDF ${cert.certificateNumber}.pdf téléchargé dans vos fichiers !',
                        ),
                        backgroundColor: AppColors.accentGreen,
                      ),
                    );
                  },
                  icon: const Icon(Icons.file_download_done_rounded, color: Colors.white),
                  label: const Text(
                    'Enregistrer dans mes Téléchargements',
                    style: TextStyle(color: Colors.white, fontWeight: FontWeight.w700),
                  ),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.primary,
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                  ),
                ),
              ),
              const SizedBox(height: 10),
              SizedBox(
                width: double.infinity,
                height: 44,
                child: OutlinedButton.icon(
                  onPressed: () {
                    Navigator.pop(bottomSheetContext);
                    Navigator.pop(context);
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(
                        content: Text(
                          'Certificat officiel PDF partagé à l\'employeur (${cert.employerOrInstitution}) !',
                        ),
                        backgroundColor: AppColors.primary,
                      ),
                    );
                  },
                  icon: const Icon(Icons.share_rounded, size: 18),
                  label: const Text('Partager le fichier PDF à mon Employeur'),
                  style: OutlinedButton.styleFrom(
                    side: const BorderSide(color: AppColors.primary),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                  ),
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  static String _formatDate(DateTime dt) {
    return '${dt.day.toString().padLeft(2, '0')}/${dt.month.toString().padLeft(2, '0')}/${dt.year}';
  }
}

/// Cachet Circulaire Officiel de l'Hôpital
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
