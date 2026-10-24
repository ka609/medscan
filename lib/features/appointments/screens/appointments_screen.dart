import 'package:flutter/material.dart';

import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_text_styles.dart';
import '../widgets/appointment_card.dart';

class AppointmentsScreen extends StatefulWidget {
  const AppointmentsScreen({super.key});

  @override
  State<AppointmentsScreen> createState() => _AppointmentsScreenState();
}

class _AppointmentsScreenState extends State<AppointmentsScreen> {
  int _selectedTab = 0;

  final List<Map<String, String>> _appointments = [
    {
      'doctor': 'Dr. Amadou Ouédraogo',
      'speciality': 'Cardiologie',
      'date': '12 Octobre 2026',
      'time': '10:30',
      'location': 'CHU Yalgado Ouédraogo',
      'status': 'Confirmé',
    },
    {
      'doctor': 'Dr. Fatimata Sawadogo',
      'speciality': 'Médecine générale',
      'date': '15 Octobre 2026',
      'time': '09:00',
      'location': 'Clinique Philadelphie',
      'status': 'En attente',
    },
    {
      'doctor': 'Dr. Ibrahim Traoré',
      'speciality': 'Dermatologie',
      'date': '21 Octobre 2026',
      'time': '14:00',
      'location': 'Hôpital du District de Bogodogo',
      'status': 'Confirmé',
    },
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        backgroundColor: AppColors.background,
        elevation: 0,
        title: Text(
          'Mes rendez-vous',
          style: AppTextStyles.headingMedium.copyWith(
            color: AppColors.textPrimary,
          ),
        ),
        actions: [
          IconButton(
            onPressed: _createAppointment,
            icon: const Icon(Icons.add, color: AppColors.primary),
          ),
        ],
      ),
      body: Column(
        children: [
          _buildTabs(),

          const SizedBox(height: 20),

          Expanded(child: _buildAppointments()),
        ],
      ),
    );
  }

  Widget _buildTabs() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: Container(
        height: 48,
        padding: const EdgeInsets.all(4),
        decoration: BoxDecoration(
          color: AppColors.surface,
          borderRadius: BorderRadius.circular(14),
        ),
        child: Row(
          children: [
            Expanded(
              child: _TabButton(
                title: 'À venir',
                selected: _selectedTab == 0,
                onTap: () {
                  setState(() {
                    _selectedTab = 0;
                  });
                },
              ),
            ),
            Expanded(
              child: _TabButton(
                title: 'Terminés',
                selected: _selectedTab == 1,
                onTap: () {
                  setState(() {
                    _selectedTab = 1;
                  });
                },
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildAppointments() {
    if (_selectedTab == 1) {
      return _buildEmptyState();
    }

    return ListView.separated(
      padding: const EdgeInsets.fromLTRB(16, 0, 16, 30),
      itemCount: _appointments.length,
      separatorBuilder: (_, __) {
        return const SizedBox(height: 14);
      },
      itemBuilder: (context, index) {
        final appointment = _appointments[index];

        return AppointmentCard(
          doctorName: appointment['doctor']!,
          speciality: appointment['speciality']!,
          date: appointment['date']!,
          time: appointment['time']!,
          location: appointment['location']!,
          status: appointment['status']!,
          onTap: () {
            _showDetails(appointment);
          },
          onCancel: () {
            _cancelAppointment(index);
          },
        );
      },
    );
  }

  Widget _buildEmptyState() {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(30),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              width: 80,
              height: 80,
              decoration: BoxDecoration(
                color: AppColors.primary.withValues(alpha: 0.1),
                shape: BoxShape.circle,
              ),
              child: const Icon(
                Icons.calendar_month_outlined,
                color: AppColors.primary,
                size: 38,
              ),
            ),
            const SizedBox(height: 16),
            Text(
              'Aucun rendez-vous terminé',
              textAlign: TextAlign.center,
              style: AppTextStyles.bodyMedium.copyWith(
                color: AppColors.textPrimary,
                fontWeight: FontWeight.w600,
              ),
            ),
            const SizedBox(height: 6),
            Text(
              'Vos anciens rendez-vous apparaîtront ici.',
              textAlign: TextAlign.center,
              style: AppTextStyles.bodySmall.copyWith(
                color: AppColors.textSecondary,
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _createAppointment() {
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('Création de rendez-vous : bientôt disponible'),
      ),
    );
  }

  void _cancelAppointment(int index) {
    final appointment = _appointments[index];

    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: const Text('Annuler le rendez-vous'),
          content: Text(
            'Voulez-vous vraiment annuler le rendez-vous avec ${appointment['doctor']} ?',
          ),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.pop(context);
              },
              child: const Text('Non'),
            ),
            ElevatedButton(
              onPressed: () {
                Navigator.pop(context);

                setState(() {
                  _appointments.removeAt(index);
                });

                ScaffoldMessenger.of(this.context).showSnackBar(
                  const SnackBar(content: Text('Rendez-vous annulé')),
                );
              },
              child: const Text('Oui, annuler'),
            ),
          ],
        );
      },
    );
  }

  void _showDetails(Map<String, String> appointment) {
    showModalBottomSheet(
      context: context,
      showDragHandle: true,
      backgroundColor: AppColors.surface,
      builder: (context) {
        return Padding(
          padding: const EdgeInsets.fromLTRB(20, 10, 20, 30),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Détails du rendez-vous',
                style: AppTextStyles.headingMedium.copyWith(
                  color: AppColors.textPrimary,
                ),
              ),
              const SizedBox(height: 20),
              _DetailRow(
                icon: Icons.person_outline,
                label: 'Médecin',
                value: appointment['doctor']!,
              ),
              _DetailRow(
                icon: Icons.medical_services_outlined,
                label: 'Spécialité',
                value: appointment['speciality']!,
              ),
              _DetailRow(
                icon: Icons.calendar_month_outlined,
                label: 'Date',
                value: appointment['date']!,
              ),
              _DetailRow(
                icon: Icons.access_time_outlined,
                label: 'Heure',
                value: appointment['time']!,
              ),
              _DetailRow(
                icon: Icons.location_on_outlined,
                label: 'Lieu',
                value: appointment['location']!,
              ),
            ],
          ),
        );
      },
    );
  }
}

class _TabButton extends StatelessWidget {
  const _TabButton({
    required this.title,
    required this.selected,
    required this.onTap,
  });

  final String title;
  final bool selected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        alignment: Alignment.center,
        decoration: BoxDecoration(
          color: selected ? AppColors.primary : Colors.transparent,
          borderRadius: BorderRadius.circular(11),
        ),
        child: Text(
          title,
          style: AppTextStyles.bodySmall.copyWith(
            color: selected ? Colors.white : AppColors.textSecondary,
            fontWeight: FontWeight.w600,
          ),
        ),
      ),
    );
  }
}

class _DetailRow extends StatelessWidget {
  const _DetailRow({
    required this.icon,
    required this.label,
    required this.value,
  });

  final IconData icon;
  final String label;
  final String value;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 14),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(icon, size: 20, color: AppColors.primary),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  label,
                  style: AppTextStyles.bodySmall.copyWith(
                    color: AppColors.textSecondary,
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  value,
                  style: AppTextStyles.bodyMedium.copyWith(
                    color: AppColors.textPrimary,
                    fontWeight: FontWeight.w600,
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
