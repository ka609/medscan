import 'dart:async';

import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';

import '../../../core/routes/app_router.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_text_styles.dart';
import '../../../providers/auth_provider.dart';
import '../../../providers/patient_provider.dart';
import '../widgets/department_card.dart';
import '../widgets/home_header.dart';
import '../widgets/organization_card.dart';
import '../widgets/section_header.dart';
import '../widgets/service_item.dart';
import '../widgets/services_card.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  Timer? _departmentTimer;
  final ScrollController _departmentController = ScrollController();

  @override
  void initState() {
    super.initState();

    WidgetsBinding.instance.addPostFrameCallback((_) {
      _load();
      _startDepartmentAutoScroll();
    });
  }

  @override
  void dispose() {
    _departmentTimer?.cancel();
    _departmentController.dispose();
    super.dispose();
  }

  Future<void> _load() async {
    await Future.wait([
      context.read<PatientProvider>().getPatientPortal(),
      context.read<PatientProvider>().getMyRecord(),
    ]);
  }

  void _startDepartmentAutoScroll() {
    _departmentTimer = Timer.periodic(const Duration(milliseconds: 80), (_) {
      if (!_departmentController.hasClients) {
        return;
      }

      final maxScroll = _departmentController.position.maxScrollExtent;

      if (maxScroll <= 0) {
        return;
      }

      final current = _departmentController.offset;

      if (current >= maxScroll) {
        _departmentController.jumpTo(0);
        return;
      }

      _departmentController.jumpTo(current + 1);
    });
  }

  void _comingSoon(String feature) {
    ScaffoldMessenger.of(context)
      ..hideCurrentSnackBar()
      ..showSnackBar(SnackBar(content: Text('$feature : bientôt disponible')));
  }

  @override
  Widget build(BuildContext context) {
    final user = context.watch<AuthProvider>().user;
    final userName = user?.displayName ?? 'Patient';

    return Scaffold(
      backgroundColor: AppColors.background,
      body: RefreshIndicator(
        onRefresh: _load,
        child: CustomScrollView(
          physics: const AlwaysScrollableScrollPhysics(),
          slivers: [
            SliverPadding(
              padding: const EdgeInsets.fromLTRB(16, 20, 16, 32),
              sliver: SliverList(
                delegate: SliverChildListDelegate([
                  // En-tête
                  Stack(
                    clipBehavior: Clip.none,
                    children: [
                      HomeHeader(
                        name: userName,
                        notificationCount: 3,
                        onProfileTap: () {
                          context.go(AppRoutes.profile);
                        },
                        onSearchTap: () {
                          _comingSoon('Recherche');
                        },
                        onNotificationTap: () {
                          _comingSoon('Notifications');
                        },
                      ),

                      Positioned(
                        top: 170,
                        left: 30,
                        right: 30,
                        child: ServicesCard(
                          services: [
                            ServiceItemData(
                              icon: Icons.calendar_month_outlined,
                              title: 'Rendez-vous',
                              color: AppColors.primary,
                              onTap: () {
                                context.push(AppRoutes.appointments);
                              },
                            ),
                            ServiceItemData(
                              icon: Icons.folder_shared_outlined,
                              title: 'Dossier médical',
                              color: Colors.blue,
                              onTap: () {
                                context.push(AppRoutes.medicalRecord);
                              },
                            ),
                            ServiceItemData(
                              icon: Icons.medication_outlined,
                              title: 'Ordonnances',
                              color: Colors.orange,
                              onTap: () {
                                _comingSoon('Ordonnances');
                              },
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),

                  const SizedBox(height: 300),

                  // Départements
                  SectionHeader(
                    title: 'Départements',
                    subtitle: 'Explorez les services médicaux',
                    actionText: 'Voir tout',
                    onActionTap: () {
                      _comingSoon('Départements');
                    },
                  ),

                  const SizedBox(height: 12),

                  SizedBox(
                    height: 185,
                    child: ListView(
                      scrollDirection: Axis.horizontal,
                      children: [
                        DepartmentCard(
                          name: 'Médecine générale',
                          description: '647 Doctors',
                          icon: Icons.medical_services_outlined,
                          color: AppColors.primary,
                          onTap: () {
                            _comingSoon('Médecine générale');
                          },
                        ),
                        const SizedBox(width: 12),
                        DepartmentCard(
                          name: 'Pédiatrie',
                          description: '524 Doctors',
                          icon: Icons.child_care_outlined,
                          color: Colors.red,
                          onTap: () {
                            _comingSoon('Pédiatrie');
                          },
                        ),
                        const SizedBox(width: 12),
                        DepartmentCard(
                          name: 'Cardiologie',
                          description: '647 Doctors',
                          icon: Icons.favorite_outline,
                          color: Colors.pink,
                          onTap: () {
                            _comingSoon('Cardiologie');
                          },
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 28),

                  // Organisations de santé
                  SectionHeader(
                    title: 'Organisations de santé',
                    subtitle: 'Établissements disponibles',
                    actionText: 'Voir tout',
                    onActionTap: () {
                      _comingSoon('Liste des établissements');
                    },
                  ),

                  const SizedBox(height: 12),

                  OrganizationCard(
                    name: 'Hôpital Yalgado Ouédraogo',
                    type: 'Hôpital',
                    address: 'Ouagadougou',
                    onTap: () {
                      _comingSoon('Hôpital Yalgado Ouédraogo');
                    },
                  ),

                  const SizedBox(height: 12),

                  OrganizationCard(
                    name: 'Hôpital du District de Bogodogo',
                    type: 'Hôpital',
                    address: 'Ouagadougou',
                    onTap: () {
                      _comingSoon('Hôpital du District de Bogodogo');
                    },
                  ),

                  const SizedBox(height: 12),

                  OrganizationCard(
                    name: 'Clinique Philadelphie',
                    type: 'Clinique',
                    address: 'Ouagadougou',
                    onTap: () {
                      _comingSoon('Clinique Philadelphie');
                    },
                  ),

                  const SizedBox(height: 12),

                  OrganizationCard(
                    name: 'Clinique Les Genêts',
                    type: 'Clinique',
                    address: 'Ouagadougou',
                    onTap: () {
                      _comingSoon('Clinique Les Genêts');
                    },
                  ),

                  const SizedBox(height: 28),

                  // Autres services
                  SectionHeader(
                    title: 'Autres services',
                    subtitle: 'Les fonctionnalités de MedScan',
                  ),

                  const SizedBox(height: 12),

                  _ServiceListItem(
                    icon: Icons.local_hospital_outlined,
                    title: 'Établissements de santé',
                    subtitle: 'Trouver un hôpital ou une clinique',
                    onTap: () {
                      _comingSoon('Établissements de santé');
                    },
                  ),

                  const SizedBox(height: 10),

                  _ServiceListItem(
                    icon: Icons.calendar_month_outlined,
                    title: 'Mes rendez-vous',
                    subtitle: 'Consulter mes rendez-vous médicaux',
                    onTap: () {
                      _comingSoon('Rendez-vous');
                    },
                  ),

                  const SizedBox(height: 10),

                  _ServiceListItem(
                    icon: Icons.chat_bubble_outline,
                    title: 'Mes messages',
                    subtitle: 'Échanger avec les professionnels de santé',
                    onTap: () {
                      _comingSoon('Messagerie');
                    },
                  ),

                  const SizedBox(height: 10),

                  _ServiceListItem(
                    icon: Icons.notifications_none_outlined,
                    title: 'Notifications',
                    subtitle: 'Consulter mes notifications',
                    onTap: () {
                      _comingSoon('Notifications');
                    },
                  ),

                  const SizedBox(height: 24),

                  Center(
                    child: Text(
                      'Vos données de santé sont protégées.',
                      textAlign: TextAlign.center,
                      style: AppTextStyles.bodySmall.copyWith(
                        color: AppColors.textSecondary,
                      ),
                    ),
                  ),
                ]),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _ServiceListItem extends StatelessWidget {
  const _ServiceListItem({
    required this.icon,
    required this.title,
    required this.subtitle,
    required this.onTap,
  });

  final IconData icon;
  final String title;
  final String subtitle;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(16),
        child: Ink(
          padding: const EdgeInsets.all(14),
          decoration: BoxDecoration(
            color: AppColors.surface,
            borderRadius: BorderRadius.circular(16),
            border: Border.all(color: AppColors.border.withValues(alpha: 0.7)),
          ),
          child: Row(
            children: [
              Container(
                width: 46,
                height: 46,
                decoration: BoxDecoration(
                  color: AppColors.primary.withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(14),
                ),
                child: Icon(icon, color: AppColors.primary, size: 24),
              ),
              const SizedBox(width: 14),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      title,
                      style: AppTextStyles.bodyMedium.copyWith(
                        color: AppColors.textPrimary,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      subtitle,
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                      style: AppTextStyles.bodySmall.copyWith(
                        color: AppColors.textSecondary,
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(width: 8),
              const Icon(
                Icons.arrow_forward_ios,
                size: 15,
                color: AppColors.textSecondary,
              ),
            ],
          ),
        ),
      ),
    );
  }
}
