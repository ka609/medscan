import 'package:flutter/material.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_text_styles.dart';
import '../../../models/referral.dart';
import '../../../services/referral_service.dart';

class ReferralsScreen extends StatefulWidget {
  const ReferralsScreen({super.key});

  @override
  State<ReferralsScreen> createState() => _ReferralsScreenState();
}

class _ReferralsScreenState extends State<ReferralsScreen> {
  final ReferralService _referralService = ReferralService();
  List<MedicalReferral> _referrals = [];
  bool _isLoading = true;
  String _selectedFilter = 'ALL';

  @override
  void initState() {
    super.initState();
    _loadReferrals();
  }

  Future<void> _loadReferrals() async {
    setState(() => _isLoading = true);
    final list = await _referralService.getReferrals();
    if (mounted) {
      setState(() {
        _referrals = list;
        _isLoading = false;
      });
    }
  }

  List<MedicalReferral> get _filteredReferrals {
    if (_selectedFilter == 'ALL') return _referrals;
    if (_selectedFilter == 'URGENT') {
      return _referrals.where((r) => r.priority == 'URGENT' || r.priority == 'EMERGENCY').toList();
    }
    return _referrals.where((r) => r.status == _selectedFilter).toList();
  }

  void _showNewReferralDialog() {
    final targetHospitalController = TextEditingController(text: 'CHU de Tengandogo');
    final targetServiceController = TextEditingController(text: 'Service de Neurologie & IRM');
    final reasonController = TextEditingController();
    final summaryController = TextEditingController();
    String priority = 'URGENT';

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
                'Initier une orientation médicale',
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.w700),
              ),
              content: SingleChildScrollView(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      'Établissement destinataire',
                      style: TextStyle(fontWeight: FontWeight.w600, fontSize: 13),
                    ),
                    const SizedBox(height: 6),
                    TextField(
                      controller: targetHospitalController,
                      decoration: InputDecoration(
                        filled: true,
                        fillColor: AppColors.background,
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                      ),
                    ),
                    const SizedBox(height: 12),
                    const Text(
                      'Service / Spécialité requise',
                      style: TextStyle(fontWeight: FontWeight.w600, fontSize: 13),
                    ),
                    const SizedBox(height: 6),
                    TextField(
                      controller: targetServiceController,
                      decoration: InputDecoration(
                        filled: true,
                        fillColor: AppColors.background,
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                      ),
                    ),
                    const SizedBox(height: 12),
                    const Text(
                      'Niveau de priorité clinique',
                      style: TextStyle(fontWeight: FontWeight.w600, fontSize: 13),
                    ),
                    const SizedBox(height: 6),
                    DropdownButtonFormField<String>(
                      initialValue: priority,
                      items: const [
                        DropdownMenuItem(
                          value: 'ROUTINE',
                          child: Text('Routine (Prise en charge normale)'),
                        ),
                        DropdownMenuItem(
                          value: 'URGENT',
                          child: Text('Urgent (< 48h)'),
                        ),
                        DropdownMenuItem(
                          value: 'EMERGENCY',
                          child: Text('Urgence Vitale Immédiate'),
                        ),
                      ],
                      onChanged: (val) {
                        if (val != null) setDialogState(() => priority = val);
                      },
                      decoration: InputDecoration(
                        filled: true,
                        fillColor: AppColors.background,
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                        contentPadding: const EdgeInsets.symmetric(
                          horizontal: 14,
                          vertical: 12,
                        ),
                      ),
                    ),
                    const SizedBox(height: 12),
                    TextField(
                      controller: reasonController,
                      decoration: InputDecoration(
                        labelText: 'Motif de redirection',
                        hintText: 'Ex: Exploration diagnostique spécialisée',
                        filled: true,
                        fillColor: AppColors.background,
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                      ),
                    ),
                    const SizedBox(height: 12),
                    TextField(
                      controller: summaryController,
                      maxLines: 3,
                      decoration: InputDecoration(
                        labelText: 'Résumé clinique & antécédents',
                        hintText: 'Ex: Traitement en cours, constantes et bilans récents...',
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
                    final ref = await _referralService.createReferral({
                      'targetTenantName': targetHospitalController.text.trim(),
                      'targetService': targetServiceController.text.trim(),
                      'priority': priority,
                      'clinicalReason': reasonController.text.trim().isEmpty
                          ? 'Transfert médical spécialisé'
                          : reasonController.text.trim(),
                      'medicalSummary': summaryController.text.trim().isEmpty
                          ? 'Dossier clinique transmis électroniquement.'
                          : summaryController.text.trim(),
                      'sourceTenantName': 'CHU Yalgado Ouédraogo',
                      'referringDoctorName': 'Dr. Amadou Ouédraogo',
                    });
                    if (!mounted) return;
                    setState(() {
                      _referrals.insert(0, ref);
                    });
                    messenger.showSnackBar(
                      const SnackBar(
                        content: Text('Orientation médicale transmise avec succès !'),
                        backgroundColor: AppColors.accentGreen,
                      ),
                    );
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.primary,
                    foregroundColor: Colors.white,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                  child: const Text('Envoyer l\'orientation'),
                ),
              ],
            );
          },
        );
      },
    );
  }

  void _showReferralDetail(MedicalReferral ref) {
    showModalBottomSheet(
      context: context,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      builder: (context) {
        return Padding(
          padding: const EdgeInsets.all(24),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    ref.referralCode,
                    style: const TextStyle(
                      fontFamily: 'Courier',
                      fontSize: 16,
                      fontWeight: FontWeight.w700,
                      color: AppColors.primary,
                    ),
                  ),
                  _buildPriorityPill(ref.priority),
                ],
              ),
              const SizedBox(height: 16),
              const Text(
                'Parcours d\'orientation inter-hospitalière (MOD-16) :',
                style: TextStyle(fontWeight: FontWeight.w700, fontSize: 14),
              ),
              const SizedBox(height: 10),
              _buildPathStep(
                title: 'Établissement d\'Origine',
                subtitle: '${ref.sourceTenantName} • ${ref.referringDoctorName}',
                icon: Icons.local_hospital_outlined,
                color: AppColors.textSecondary,
              ),
              const SizedBox(height: 8),
              _buildPathStep(
                title: 'Établissement & Service Cible',
                subtitle: '${ref.targetTenantName}\n${ref.targetService}',
                icon: Icons.double_arrow_rounded,
                color: AppColors.primary,
              ),
              const SizedBox(height: 14),
              const Divider(),
              const SizedBox(height: 10),
              const Text(
                'Motif Clinique :',
                style: TextStyle(fontWeight: FontWeight.w700, fontSize: 13),
              ),
              const SizedBox(height: 4),
              Text(
                ref.clinicalReason,
                style: const TextStyle(fontSize: 13.5, color: AppColors.textPrimary),
              ),
              const SizedBox(height: 10),
              const Text(
                'Résumé Médical Transmis :',
                style: TextStyle(fontWeight: FontWeight.w700, fontSize: 13),
              ),
              const SizedBox(height: 4),
              Text(
                ref.medicalSummary,
                style: const TextStyle(fontSize: 12.5, color: AppColors.textSecondary, height: 1.4),
              ),
              const SizedBox(height: 20),
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: () => Navigator.pop(context),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.primary,
                    foregroundColor: Colors.white,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                  child: const Text('Fermer'),
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _buildPathStep({
    required String title,
    required String subtitle,
    required IconData icon,
    required Color color,
  }) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Icon(icon, size: 20, color: color),
        const SizedBox(width: 10),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                title,
                style: TextStyle(fontSize: 11, fontWeight: FontWeight.w600, color: color),
              ),
              Text(
                subtitle,
                style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w600, color: AppColors.textPrimary),
              ),
            ],
          ),
        ),
      ],
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
          'Orientations & Redirections',
          style: AppTextStyles.headingMedium.copyWith(color: AppColors.textPrimary),
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh_rounded, color: AppColors.primary),
            onPressed: _loadReferrals,
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: _showNewReferralDialog,
        backgroundColor: AppColors.primary,
        icon: const Icon(Icons.share_location_rounded, color: Colors.white),
        label: const Text(
          'Nouvelle orientation',
          style: TextStyle(color: Colors.white, fontWeight: FontWeight.w600),
        ),
      ),
      body: Center(
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 520),
          child: Column(
            children: [
              // 1. Filtres
              Container(
                color: AppColors.surface,
                padding: const EdgeInsets.fromLTRB(16, 4, 16, 12),
                child: SingleChildScrollView(
                  scrollDirection: Axis.horizontal,
                  child: Row(
                    children: [
                      _buildFilterChip('ALL', 'Toutes les orientations'),
                      const SizedBox(width: 8),
                      _buildFilterChip('URGENT', 'Priorité Haute / Urgences'),
                      const SizedBox(width: 8),
                      _buildFilterChip('ACCEPTED', 'Acceptées'),
                      const SizedBox(width: 8),
                      _buildFilterChip('PENDING', 'En attente'),
                    ],
                  ),
                ),
              ),

              // 2. Bannière MOD-16
              Container(
                margin: const EdgeInsets.all(16),
                padding: const EdgeInsets.all(14),
                decoration: BoxDecoration(
                  gradient: const LinearGradient(
                    colors: [Color(0xFF0D9488), Color(0xFF14B8A6)],
                  ),
                  borderRadius: BorderRadius.circular(16),
                  boxShadow: const [
                    BoxShadow(
                      color: Color(0x1E0D9488),
                      blurRadius: 10,
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
                        Icons.swap_horiz_rounded,
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
                            'Continuité des Soins (MOD-16)',
                            style: TextStyle(
                              color: Colors.white,
                              fontSize: 15,
                              fontWeight: FontWeight.w700,
                            ),
                          ),
                          SizedBox(height: 3),
                          Text(
                            'Redirection inter-services et transfert inter-hospitalier sans rupture du dossier médical.',
                            style: TextStyle(
                              color: Color(0xFFCCFBF1),
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

              // 3. Liste
              Expanded(
                child: _isLoading
                    ? const Center(child: CircularProgressIndicator())
                    : _filteredReferrals.isEmpty
                        ? const Center(
                            child: Text(
                              'Aucune orientation enregistrée.',
                              style: TextStyle(color: AppColors.textSecondary),
                            ),
                          )
                        : RefreshIndicator(
                            onRefresh: _loadReferrals,
                            child: ListView.builder(
                              padding: const EdgeInsets.fromLTRB(16, 0, 16, 90),
                              itemCount: _filteredReferrals.length,
                              itemBuilder: (context, index) {
                                final ref = _filteredReferrals[index];
                                return _ReferralCard(
                                  referral: ref,
                                  onTap: () => _showReferralDetail(ref),
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
          color: isSelected ? const Color(0xFF0D9488) : AppColors.background,
          borderRadius: BorderRadius.circular(20),
          border: Border.all(
            color: isSelected ? const Color(0xFF0D9488) : AppColors.border,
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

  Widget _buildPriorityPill(String priority) {
    final isEmergency = priority == 'EMERGENCY';
    final isUrgent = priority == 'URGENT' || isEmergency;
    final color = isEmergency
        ? const Color(0xFFDC2626)
        : isUrgent
            ? const Color(0xFFEA580C)
            : AppColors.primary;
    final bg = isUrgent ? const Color(0xFFFEE2E2) : AppColors.softBlue;

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
      decoration: BoxDecoration(
        color: bg,
        borderRadius: BorderRadius.circular(8),
      ),
      child: Text(
        priority,
        style: TextStyle(
          color: color,
          fontSize: 11,
          fontWeight: FontWeight.w800,
        ),
      ),
    );
  }
}

class _ReferralCard extends StatelessWidget {
  const _ReferralCard({
    required this.referral,
    required this.onTap,
  });

  final MedicalReferral referral;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final isUrgent = referral.priority == 'URGENT' || referral.priority == 'EMERGENCY';
    final priorityColor = isUrgent ? const Color(0xFFDC2626) : AppColors.primary;

    return Container(
      margin: const EdgeInsets.only(bottom: 14),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(
          color: isUrgent ? priorityColor.withValues(alpha: 0.3) : AppColors.border.withValues(alpha: 0.8),
          width: isUrgent ? 1.5 : 1,
        ),
        boxShadow: const [
          BoxShadow(
            color: Color(0x080F172A),
            blurRadius: 10,
            offset: Offset(0, 3),
          ),
        ],
      ),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(20),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                    decoration: BoxDecoration(
                      color: isUrgent ? const Color(0xFFFEE2E2) : AppColors.softBlue,
                      borderRadius: BorderRadius.circular(6),
                    ),
                    child: Text(
                      referral.priority,
                      style: TextStyle(
                        color: priorityColor,
                        fontSize: 11,
                        fontWeight: FontWeight.w800,
                      ),
                    ),
                  ),
                  const SizedBox(width: 8),
                  Text(
                    referral.referralCode,
                    style: const TextStyle(
                      fontFamily: 'Courier',
                      fontSize: 12,
                      fontWeight: FontWeight.w700,
                      color: AppColors.textSecondary,
                    ),
                  ),
                  const Spacer(),
                  _buildStatusBadge(referral.status),
                ],
              ),
              const SizedBox(height: 12),
              Text(
                referral.clinicalReason,
                style: const TextStyle(
                  fontSize: 15,
                  fontWeight: FontWeight.w700,
                  color: AppColors.textPrimary,
                ),
              ),
              const SizedBox(height: 8),
              Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Icon(
                    Icons.trending_flat_rounded,
                    size: 16,
                    color: AppColors.primary,
                  ),
                  const SizedBox(width: 6),
                  Expanded(
                    child: Text(
                      'Vers : ${referral.targetTenantName} (${referral.targetService})',
                      style: const TextStyle(
                        fontSize: 13,
                        fontWeight: FontWeight.w600,
                        color: AppColors.primary,
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 4),
              Row(
                children: [
                  const Icon(
                    Icons.person_pin_rounded,
                    size: 14,
                    color: AppColors.textSecondary,
                  ),
                  const SizedBox(width: 6),
                  Text(
                    'Initié par : ${referral.referringDoctorName}',
                    style: const TextStyle(
                      fontSize: 12,
                      color: AppColors.textSecondary,
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildStatusBadge(String status) {
    Color bg;
    Color fg;
    String label;

    switch (status) {
      case 'ACCEPTED':
        bg = AppColors.softGreen;
        fg = AppColors.accentGreen;
        label = 'Acceptée';
        break;
      case 'REJECTED':
        bg = const Color(0xFFFEE2E2);
        fg = const Color(0xFFDC2626);
        label = 'Refusée';
        break;
      case 'COMPLETED':
        bg = AppColors.softBlue;
        fg = AppColors.primary;
        label = 'Terminée';
        break;
      case 'PENDING':
      default:
        bg = AppColors.softOrange;
        fg = AppColors.accentOrange;
        label = 'En attente';
    }

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: bg,
        borderRadius: BorderRadius.circular(6),
      ),
      child: Text(
        label,
        style: TextStyle(
          color: fg,
          fontSize: 11,
          fontWeight: FontWeight.w700,
        ),
      ),
    );
  }
}
