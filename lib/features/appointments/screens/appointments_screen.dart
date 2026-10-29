import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';

import '../../../core/routes/app_router.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_text_styles.dart';
import '../../../core/utils/id_generator.dart';
import '../../../models/message.dart';
import '../../../models/user.dart';
import '../../../providers/auth_provider.dart';
import '../../../services/message_service.dart';

class AppointmentsScreen extends StatefulWidget {
  final String? departmentFilter;

  const AppointmentsScreen({super.key, this.departmentFilter});

  @override
  State<AppointmentsScreen> createState() => _AppointmentsScreenState();
}

class _AppointmentsScreenState extends State<AppointmentsScreen> {
  int _selectedTab = 0; // 0: À venir / En attente, 1: Confirmés, 2: Tous

  // Liste des rendez-vous
  final List<Map<String, String>> _appointments = [
    {
      'id': 'a1111111-2222-3333-4444-555555555551',
      'doctor': 'Dr. Seydou Traoré',
      'patientName': 'Fatou Ouédraogo',
      'patientId': '99f10bda-a5e3-4ce6-a0bb-6cc09f2a280e',
      'speciality': 'Médecine Générale',
      'department': 'Médecine Générale',
      'date': '28 Octobre 2026',
      'time': '10:30',
      'location': 'CHU Yalgado Ouédraogo',
      'status': 'En attente',
    },
    {
      'id': 'a1111111-2222-3333-4444-555555555552',
      'doctor': 'Dr. Amadou Ouédraogo',
      'patientName': 'Fatou Ouédraogo',
      'patientId': '99f10bda-a5e3-4ce6-a0bb-6cc09f2a280e',
      'speciality': 'Pédiatrie',
      'department': 'Pédiatrie',
      'date': '30 Octobre 2026',
      'time': '09:00',
      'location': 'Clinique Philadelphie',
      'status': 'Confirmé',
    },
    {
      'id': 'a1111111-2222-3333-4444-555555555553',
      'doctor': 'Dr. Seydou Traoré',
      'patientName': 'Ibrahim Compaoré',
      'patientId': 'dababb25-8dc9-402c-b527-15d9a4b1f380',
      'speciality': 'Médecine Générale',
      'department': 'Médecine Générale',
      'date': '02 Novembre 2026',
      'time': '14:00',
      'location': 'Hôpital du District de Bogodogo',
      'status': 'Confirmé',
    },
  ];

  List<Map<String, String>> _filteredList(bool isDoctor, String userDepartment) {
    var list = _appointments;

    // Filtre de département si spécifié
    final activeDept = widget.departmentFilter;
    if (activeDept != null && activeDept.isNotEmpty && activeDept != 'Tous Départements') {
      list = list.where((a) => a['department'] == activeDept || a['speciality'] == activeDept).toList();
    }

    if (_selectedTab == 0) {
      return list.where((a) => a['status'] == 'En attente' || a['status'] == 'Confirmé').toList();
    } else if (_selectedTab == 1) {
      return list.where((a) => a['status'] == 'Confirmé').toList();
    }
    return list;
  }

  void _validateAppointment(Map<String, String> appt, User? user) {
    final doctorName = user?.displayTitle ?? appt['doctor'] ?? 'Dr. Seydou Traoré';

    setState(() {
      appt['status'] = 'Confirmé';
    });

    // Envoi de la notification spécifique au patient
    final patientId = appt['patientId'];
    if (patientId != null && patientId.isNotEmpty) {
      MessageService.addAlert(
        ClinicalAlert(
          id: IdGenerator.alertId(),
          recipientUserId: patientId,
          title: 'Rendez-vous validé et confirmé',
          message:
              'Votre rendez-vous du ${appt['date']} à ${appt['time']} avec le $doctorName (${appt['speciality']}) a été validé par le médecin.',
          type: 'APPOINTMENT',
          severity: 'INFO',
          timestamp: DateTime.now(),
          actionRoute: '/appointments',
        ),
      );
    }

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        backgroundColor: const Color(0xFF16A34A),
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        content: Text(
          'Rendez-vous de ${appt['patientName']} confirmé ! Le patient a reçu une notification.',
        ),
      ),
    );
  }

  void _updateAppointment(Map<String, String> appt, User? user) {
    final dateController = TextEditingController(text: appt['date']);
    final timeController = TextEditingController(text: appt['time']);
    final doctorName = user?.displayTitle ?? appt['doctor'] ?? 'Dr. Seydou Traoré';

    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        title: const Text('Mettre à jour le rendez-vous'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Patient : ${appt['patientName']}', style: const TextStyle(fontWeight: FontWeight.w700)),
            const SizedBox(height: 14),
            TextField(
              controller: dateController,
              decoration: InputDecoration(
                labelText: 'Nouvelle date',
                prefixIcon: const Icon(Icons.calendar_today),
                border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
              ),
            ),
            const SizedBox(height: 10),
            TextField(
              controller: timeController,
              decoration: InputDecoration(
                labelText: 'Nouvel horaire',
                prefixIcon: const Icon(Icons.access_time),
                border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
              ),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: const Text('Annuler'),
          ),
          ElevatedButton(
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.primary,
              foregroundColor: Colors.white,
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
            ),
            onPressed: () {
              Navigator.pop(ctx);
              setState(() {
                appt['date'] = dateController.text.trim();
                appt['time'] = timeController.text.trim();
              });

              // Notification patient
              final patientId = appt['patientId'];
              if (patientId != null && patientId.isNotEmpty) {
                MessageService.addAlert(
                  ClinicalAlert(
                    id: IdGenerator.alertId(),
                    recipientUserId: patientId,
                    title: 'Modification de votre rendez-vous',
                    message:
                        'Votre rendez-vous avec le $doctorName a été mis à jour. Nouvelle date : ${appt['date']} à ${appt['time']}.',
                    type: 'APPOINTMENT',
                    severity: 'WARNING',
                    timestamp: DateTime.now(),
                    actionRoute: '/appointments',
                  ),
                );
              }

              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(
                  backgroundColor: AppColors.primary,
                  content: Text('Rendez-vous mis à jour et patient notifié !'),
                ),
              );
            },
            child: const Text('Enregistrer'),
          ),
        ],
      ),
    );
  }

  void _cancelAppointment(Map<String, String> appt, User? user) {
    final reasonController = TextEditingController(text: 'Imprévu de service médical');
    final doctorName = user?.displayTitle ?? appt['doctor'] ?? 'Dr. Seydou Traoré';

    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        title: const Text('Annuler le rendez-vous'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Voulez-vous annuler le rendez-vous avec ${appt['patientName']} ?'),
            const SizedBox(height: 12),
            TextField(
              controller: reasonController,
              decoration: InputDecoration(
                labelText: 'Motif d\'annulation',
                border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
              ),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: const Text('Non'),
          ),
          ElevatedButton(
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color(0xFFDC2626),
              foregroundColor: Colors.white,
            ),
            onPressed: () {
              Navigator.pop(ctx);
              setState(() {
                appt['status'] = 'Annulé';
              });

              // Notification patient
              final patientId = appt['patientId'];
              if (patientId != null && patientId.isNotEmpty) {
                MessageService.addAlert(
                  ClinicalAlert(
                    id: IdGenerator.alertId(),
                    recipientUserId: patientId,
                    title: 'Rendez-vous annulé',
                    message:
                        'Votre rendez-vous du ${appt['date']} avec le $doctorName a été annulé. Motif : ${reasonController.text.trim()}.',
                    type: 'APPOINTMENT',
                    severity: 'WARNING',
                    timestamp: DateTime.now(),
                    actionRoute: '/appointments',
                  ),
                );
              }

              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text('Rendez-vous annulé. Le patient a été prévenu.')),
              );
            },
            child: const Text('Oui, annuler'),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final user = context.watch<AuthProvider>().user;
    final isHealthWorker = user.isHealthWorker;
    final userDept = user.department;
    final list = _filteredList(isHealthWorker, userDept);

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        backgroundColor: AppColors.surface,
        elevation: 0,
        title: Text(
          isHealthWorker
              ? (widget.departmentFilter != null
                  ? 'Planning : ${widget.departmentFilter}'
                  : 'Gestion des Rendez-vous (Praticien)')
              : 'Mes rendez-vous',
          style: AppTextStyles.headingMedium.copyWith(color: AppColors.textPrimary),
        ),
        actions: [
          // IMPORTANT : Seul le patient peut prendre rendez-vous ! Le docteur ne peut pas prendre RDV pour lui-même
          if (!isHealthWorker)
            IconButton(
              tooltip: 'Prendre un nouveau rendez-vous',
              onPressed: () => context.push(AppRoutes.bookAppointment),
              icon: const Icon(Icons.add, color: AppColors.primary),
            ),
        ],
      ),
      body: Center(
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 600),
          child: Column(
            children: [
              // Bandeau informatif praticien
              if (isHealthWorker)
                Container(
                  width: double.infinity,
                  margin: const EdgeInsets.fromLTRB(16, 12, 16, 0),
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: AppColors.softBlue,
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(color: AppColors.primary.withValues(alpha: 0.2)),
                  ),
                  child: Row(
                    children: [
                      const Icon(Icons.info_outline_rounded, color: AppColors.primary, size: 20),
                      const SizedBox(width: 10),
                      Expanded(
                        child: Text(
                          widget.departmentFilter != null
                              ? 'Département : ${widget.departmentFilter}. Vos actions de validation ou report notifient automatiquement les patients concernés.'
                              : 'Planning praticien : validez, reportez ou annulez les créneaux. Chaque modification notifie directement le patient.',
                          style: const TextStyle(
                            fontSize: 12,
                            color: AppColors.primary,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),

              const SizedBox(height: 12),
              _buildTabs(),
              const SizedBox(height: 14),

              Expanded(
                child: list.isEmpty
                    ? _buildEmptyState()
                    : ListView.builder(
                        padding: const EdgeInsets.fromLTRB(16, 0, 16, 30),
                        itemCount: list.length,
                        itemBuilder: (context, index) {
                          final appt = list[index];
                          return _buildAppointmentCard(appt, isHealthWorker, user);
                        },
                      ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildTabs() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: Container(
        height: 44,
        padding: const EdgeInsets.all(4),
        decoration: BoxDecoration(
          color: AppColors.surface,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: AppColors.border),
        ),
        child: Row(
          children: [
            Expanded(
              child: _buildTabButton('À venir', 0),
            ),
            Expanded(
              child: _buildTabButton('Confirmés', 1),
            ),
            Expanded(
              child: _buildTabButton('Tous', 2),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildTabButton(String title, int index) {
    final selected = _selectedTab == index;
    return GestureDetector(
      onTap: () => setState(() => _selectedTab = index),
      child: Container(
        decoration: BoxDecoration(
          color: selected ? AppColors.primary : Colors.transparent,
          borderRadius: BorderRadius.circular(9),
        ),
        alignment: Alignment.center,
        child: Text(
          title,
          style: TextStyle(
            fontSize: 12.5,
            fontWeight: selected ? FontWeight.w700 : FontWeight.w500,
            color: selected ? Colors.white : AppColors.textSecondary,
          ),
        ),
      ),
    );
  }

  Widget _buildAppointmentCard(
    Map<String, String> appt,
    bool isHealthWorker,
    User? user,
  ) {
    final status = appt['status'] ?? 'En attente';
    final isConfirmed = status == 'Confirmé';
    final isCancelled = status == 'Annulé';

    return Container(
      margin: const EdgeInsets.only(bottom: 14),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: isConfirmed
              ? const Color(0xFF16A34A).withValues(alpha: 0.3)
              : (isCancelled
                  ? const Color(0xFFDC2626).withValues(alpha: 0.3)
                  : AppColors.border),
        ),
        boxShadow: const [
          BoxShadow(color: Color(0x06000000), blurRadius: 6, offset: Offset(0, 2)),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                isHealthWorker ? 'Patient : ${appt['patientName']}' : appt['doctor']!,
                style: const TextStyle(fontWeight: FontWeight.w700, fontSize: 15),
              ),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                decoration: BoxDecoration(
                  color: isConfirmed
                      ? const Color(0xFFDCFCE7)
                      : (isCancelled ? const Color(0xFFFEE2E2) : const Color(0xFFFEF3C7)),
                  borderRadius: BorderRadius.circular(6),
                ),
                child: Text(
                  status,
                  style: TextStyle(
                    fontSize: 11,
                    fontWeight: FontWeight.w700,
                    color: isConfirmed
                        ? const Color(0xFF15803D)
                        : (isCancelled ? const Color(0xFFDC2626) : const Color(0xFFB45309)),
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 6),
          Text(
            '${appt['speciality']} • ${appt['location']}',
            style: const TextStyle(fontSize: 12.5, color: AppColors.textSecondary),
          ),
          const SizedBox(height: 10),
          Row(
            children: [
              const Icon(Icons.calendar_today_rounded, size: 14, color: AppColors.primary),
              const SizedBox(width: 6),
              Text(appt['date']!, style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w600)),
              const SizedBox(width: 14),
              const Icon(Icons.access_time_rounded, size: 14, color: AppColors.primary),
              const SizedBox(width: 6),
              Text(appt['time']!, style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w600)),
            ],
          ),

          // Actions réservées au docteur / infirmier
          if (isHealthWorker && !isCancelled) ...[
            const SizedBox(height: 14),
            const Divider(height: 1, color: AppColors.border),
            const SizedBox(height: 10),
            Wrap(
              spacing: 8,
              runSpacing: 6,
              children: [
                if (!isConfirmed)
                  ElevatedButton.icon(
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFF16A34A),
                      foregroundColor: Colors.white,
                      minimumSize: Size.zero,
                      tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 7),
                    ),
                    icon: const Icon(Icons.check_rounded, size: 16),
                    label: const Text('Valider RDV', style: TextStyle(fontSize: 12, fontWeight: FontWeight.w700)),
                    onPressed: () => _validateAppointment(appt, user),
                  ),
                OutlinedButton.icon(
                  style: OutlinedButton.styleFrom(
                    foregroundColor: AppColors.primary,
                    side: const BorderSide(color: AppColors.border),
                    minimumSize: Size.zero,
                    tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                    padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 7),
                  ),
                  icon: const Icon(Icons.edit_calendar_rounded, size: 16),
                  label: const Text('Modifier / Reporter', style: TextStyle(fontSize: 12)),
                  onPressed: () => _updateAppointment(appt, user),
                ),
                TextButton.icon(
                  style: TextButton.styleFrom(
                    foregroundColor: const Color(0xFFDC2626),
                    padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 7),
                  ),
                  icon: const Icon(Icons.cancel_outlined, size: 16),
                  label: const Text('Annuler', style: TextStyle(fontSize: 12)),
                  onPressed: () => _cancelAppointment(appt, user),
                ),
              ],
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildEmptyState() {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(32),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.calendar_month_outlined, size: 48, color: AppColors.primary.withValues(alpha: 0.3)),
            const SizedBox(height: 12),
            const Text(
              'Aucun rendez-vous trouvé',
              style: TextStyle(fontWeight: FontWeight.w700, fontSize: 15),
            ),
            const SizedBox(height: 4),
            const Text(
              'Les rendez-vous apparaîtront ici selon vos critères.',
              style: TextStyle(fontSize: 12.5, color: AppColors.textSecondary),
            ),
          ],
        ),
      ),
    );
  }
}
