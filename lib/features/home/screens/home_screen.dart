import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';

import '../../../core/routes/app_router.dart';
import '../../../core/theme/app_colors.dart';
import '../../../models/user.dart';
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
  final ScrollController _departmentController = ScrollController();

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _load();
    });
  }

  @override
  void dispose() {
    _departmentController.dispose();
    super.dispose();
  }

  Future<void> _load() async {
    try {
      await context.read<PatientProvider>().getMyRecord();
    } catch (_) {
      // Évite de bloquer l'affichage si le réseau met du temps
    }
  }

  @override
  Widget build(BuildContext context) {
    final user = context.watch<AuthProvider>().user;
    final isHealthWorker = user.isHealthWorker;
    final isLabTech = user.isLabTech;
    final isDoctor = user.isDoctor;
    final userDept = user.department;

    final userName = user?.displayName.isNotEmpty == true
        ? user!.displayName
        : (user?.username ?? 'Patient');
    final userRole = user?.position ?? (isDoctor ? 'Médecin' : (user.isNurse ? 'Infirmier' : (isLabTech ? 'Laborantin' : 'Patient')));

    // Construction dynamique de la grille des services selon le rôle
    List<ServiceItemData> services;
    if (isHealthWorker) {
      services = [
        ServiceItemData(
          icon: Icons.history_edu_rounded,
          title: 'Consultations',
          badgeText: 'Rédiger / Actes',
          color: AppColors.primary,
          backgroundColor: AppColors.softBlue,
          onTap: () => context.push(AppRoutes.doctorConsultations),
        ),
        ServiceItemData(
          icon: Icons.calendar_month_outlined,
          title: 'Rendez-vous',
          badgeText: 'Planning',
          color: AppColors.primary,
          backgroundColor: AppColors.softBlue,
          onTap: () => context.push(AppRoutes.appointments),
        ),
        ServiceItemData(
          icon: Icons.videocam_outlined,
          title: 'Téléconsult',
          badgeText: 'Jitsi',
          color: AppColors.accentGreen,
          backgroundColor: AppColors.softGreen,
          onTap: () => context.push(AppRoutes.teleconsult),
        ),
        ServiceItemData(
          icon: Icons.swap_horiz_rounded,
          title: 'Orientations',
          badgeText: 'Transfert',
          color: const Color(0xFF0D9488),
          backgroundColor: const Color(0xFFCCFBF1),
          onTap: () => context.push(AppRoutes.referrals),
        ),
        ServiceItemData(
          icon: Icons.verified_outlined,
          title: 'Certificats',
          badgeText: 'Émettre',
          color: AppColors.primary,
          backgroundColor: AppColors.softBlue,
          onTap: () => context.push(AppRoutes.certificates),
        ),
        ServiceItemData(
          icon: Icons.science_outlined,
          title: 'Laboratoire',
          badgeText: 'Biologie',
          color: const Color(0xFF8B5CF6),
          backgroundColor: const Color(0xFFF3E8FF),
          onTap: () => context.push(AppRoutes.labManagement),
        ),
      ];
    } else if (isLabTech) {
      services = [
        ServiceItemData(
          icon: Icons.science_outlined,
          title: 'Analyses Labo',
          badgeText: 'Dossiers',
          color: const Color(0xFF8B5CF6),
          backgroundColor: const Color(0xFFF3E8FF),
          onTap: () => context.push(AppRoutes.labManagement),
        ),
        ServiceItemData(
          icon: Icons.send_rounded,
          title: 'Transmettre',
          badgeText: 'Dr & Patient',
          color: const Color(0xFF16A34A),
          backgroundColor: const Color(0xFFDCFCE7),
          onTap: () => context.push(AppRoutes.labManagement),
        ),
        ServiceItemData(
          icon: Icons.add_task_rounded,
          title: 'Fixer RDV',
          badgeText: 'Prélèvement',
          color: AppColors.primary,
          backgroundColor: AppColors.softBlue,
          onTap: () => context.push(AppRoutes.labManagement),
        ),
        ServiceItemData(
          icon: Icons.chat_bubble_outline_rounded,
          title: 'Messagerie',
          badgeText: 'Échanges',
          color: AppColors.primary,
          backgroundColor: AppColors.softBlue,
          onTap: () => context.push(AppRoutes.messages),
        ),
        ServiceItemData(
          icon: Icons.videocam_outlined,
          title: 'Téléconsult',
          badgeText: 'Jitsi',
          color: AppColors.accentGreen,
          backgroundColor: AppColors.softGreen,
          onTap: () => context.push(AppRoutes.teleconsult),
        ),
        ServiceItemData(
          icon: Icons.folder_shared_outlined,
          title: 'Dossiers',
          badgeText: 'Suivi',
          color: AppColors.accentOrange,
          backgroundColor: AppColors.softOrange,
          onTap: () => context.push(AppRoutes.medicalRecord),
        ),
      ];
    } else {
      // Profil Patient
      services = [
        ServiceItemData(
          icon: Icons.description_outlined,
          title: 'Mon e-Carnet',
          badgeText: 'PDF',
          color: AppColors.primary,
          backgroundColor: AppColors.softBlue,
          onTap: () => context.push(AppRoutes.medicalRecord),
        ),
        ServiceItemData(
          icon: Icons.calendar_month_outlined,
          title: 'Prendre RDV',
          badgeText: 'Départements',
          color: AppColors.primary,
          backgroundColor: AppColors.softBlue,
          onTap: () => context.push(AppRoutes.bookAppointment),
        ),
        ServiceItemData(
          icon: Icons.videocam_outlined,
          title: 'Téléconsult',
          badgeText: 'Jitsi',
          color: AppColors.accentGreen,
          backgroundColor: AppColors.softGreen,
          onTap: () => context.push(AppRoutes.teleconsult),
        ),
        ServiceItemData(
          icon: Icons.medication_outlined,
          title: 'Pharmacie',
          badgeText: 'Ordonnances',
          color: AppColors.accentOrange,
          backgroundColor: AppColors.softOrange,
          onTap: () => context.push(AppRoutes.prescriptions),
        ),
        ServiceItemData(
          icon: Icons.swap_horiz_rounded,
          title: 'Orientations',
          badgeText: 'Transfert',
          color: const Color(0xFF0D9488),
          backgroundColor: const Color(0xFFCCFBF1),
          onTap: () => context.push(AppRoutes.referrals),
        ),
        ServiceItemData(
          icon: Icons.verified_outlined,
          title: 'Certificats',
          badgeText: 'Télécharger',
          color: AppColors.primary,
          backgroundColor: AppColors.softBlue,
          onTap: () => context.push(AppRoutes.certificates),
        ),
      ];
    }

    void onDepartmentTapped(String deptName) {
      if (isHealthWorker) {
        // Le docteur / infirmier accède à la liste de ses rendez-vous dans ce département et peut agir dessus
        context.push(AppRoutes.appointments);
      } else {
        // Le patient choisit le département pour prendre rendez-vous
        context.push(AppRoutes.bookAppointment);
      }
    }

    return Scaffold(
      backgroundColor: AppColors.background,
      body: Center(
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 520),
          child: RefreshIndicator(
            onRefresh: _load,
            child: SingleChildScrollView(
              physics: const AlwaysScrollableScrollPhysics(),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // 1. En-tête bleu compact avec avatar, salutations et actions
                  HomeHeader(
                    name: userName,
                    userRole: userRole,
                    notificationCount: 2,
                    onProfileTap: () {
                      context.push(AppRoutes.profile);
                    },
                    onSearchTap: () {
                      if (isHealthWorker) {
                        context.push(AppRoutes.appointments);
                      } else {
                        context.push(AppRoutes.bookAppointment);
                      }
                    },
                    onNotificationTap: () {
                      context.push(AppRoutes.messages);
                    },
                  ),

                  // 2. Grille des 6 services clés adaptée selon le rôle
                  Transform.translate(
                    offset: const Offset(0, -22),
                    child: Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 16),
                      child: ServicesCard(services: services),
                    ),
                  ),

                  // 3. Départements Médicaux
                  Padding(
                    padding: const EdgeInsets.fromLTRB(20, 2, 20, 14),
                    child: SectionHeader(
                      title: isHealthWorker ? 'Départements (Mon affectation : $userDept)' : 'Départements de Santé',
                      actionText: isHealthWorker ? 'Gérer RDV' : 'Prendre RDV',
                      onActionTap: () {
                        if (isHealthWorker) {
                          context.push(AppRoutes.appointments);
                        } else {
                          context.push(AppRoutes.bookAppointment);
                        }
                      },
                    ),
                  ),

                  SizedBox(
                    height: 146,
                    child: ListView(
                      controller: _departmentController,
                      scrollDirection: Axis.horizontal,
                      padding: const EdgeInsets.symmetric(horizontal: 16),
                      physics: const BouncingScrollPhysics(),
                      children: [
                        DepartmentCard(
                          name: 'Médecine Générale',
                          doctorCount: 647,
                          icon: Icons.medical_services_rounded,
                          color: AppColors.primary,
                          backgroundColor: AppColors.softBlue,
                          onTap: () => onDepartmentTapped('Médecine Générale'),
                        ),
                        const SizedBox(width: 12),
                        DepartmentCard(
                          name: 'Pédiatrie',
                          doctorCount: 524,
                          icon: Icons.child_care_rounded,
                          color: AppColors.accentRed,
                          backgroundColor: AppColors.softRed,
                          onTap: () => onDepartmentTapped('Pédiatrie'),
                        ),
                        const SizedBox(width: 12),
                        DepartmentCard(
                          name: 'Cardiologie',
                          doctorCount: 438,
                          icon: Icons.favorite_rounded,
                          color: AppColors.accentPink,
                          backgroundColor: AppColors.softPink,
                          onTap: () => onDepartmentTapped('Cardiologie'),
                        ),
                        const SizedBox(width: 12),
                        DepartmentCard(
                          name: 'Radiologie & IA',
                          doctorCount: 182,
                          icon: Icons.document_scanner_rounded,
                          color: AppColors.accentPurple,
                          backgroundColor: AppColors.softPurple,
                          onTap: () => onDepartmentTapped('Radiologie & IA'),
                        ),
                      ],
                    ),
                  ),

                  const SizedBox(height: 26),

                  // 4. Top Hôpitaux (Grandes cartes avec photos et détails)
                  Padding(
                    padding: const EdgeInsets.fromLTRB(20, 0, 20, 14),
                    child: SectionHeader(
                      title: 'Top Hôpitaux',
                      actionText: 'Voir tout',
                      onActionTap: () {
                        context.push(AppRoutes.bookAppointment);
                      },
                    ),
                  ),

                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 16),
                    child: Column(
                      children: [
                        OrganizationCard(
                          name: 'CHU Yalgado Ouédraogo',
                          type: 'Hôpital Universitaire',
                          address: 'Ouagadougou, Secteur 4',
                          imageUrl: 'https://images.unsplash.com/photo-1587351021759-3e566b6af7cc?w=600&auto=format&fit=crop&q=80',
                          rating: 4.9,
                          reviewCount: 512,
                          tagText: 'Urgences 24/7',
                          servicesCount: 18,
                          doctorsCount: 142,
                          onTap: () {
                            context.push(AppRoutes.bookAppointment);
                          },
                        ),
                        const SizedBox(height: 16),
                        OrganizationCard(
                          name: 'Hôpital du District de Bogodogo',
                          type: 'Hôpital Public',
                          address: 'Ouagadougou, Secteur 30',
                          imageUrl: 'https://images.unsplash.com/photo-1519494026892-80bbd2d6fd0d?w=600&auto=format&fit=crop&q=80',
                          rating: 4.8,
                          reviewCount: 342,
                          tagText: 'Pédiatrie & Chirurgie',
                          servicesCount: 12,
                          doctorsCount: 86,
                          onTap: () {
                            context.push(AppRoutes.bookAppointment);
                          },
                        ),
                        const SizedBox(height: 16),
                        OrganizationCard(
                          name: 'Clinique Médicale Philadelphie',
                          type: 'Clinique Spécialisée',
                          address: 'Ouagadougou, Zone du Bois',
                          imageUrl: 'https://images.unsplash.com/photo-1516549655169-df83a0774514?w=600&auto=format&fit=crop&q=80',
                          rating: 4.7,
                          reviewCount: 215,
                          tagText: 'Cardiologie & Soins Intensifs',
                          servicesCount: 8,
                          doctorsCount: 42,
                          onTap: () {
                            context.push(AppRoutes.bookAppointment);
                          },
                        ),
                      ],
                    ),
                  ),

                  const SizedBox(height: 24),

                  // 5. Qualité des Soins, Éthique & Réclamations
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 16),
                    child: Container(
                      padding: const EdgeInsets.all(18),
                      decoration: BoxDecoration(
                        color: AppColors.surface,
                        borderRadius: BorderRadius.circular(20),
                        border: Border.all(color: const Color(0xFF8B5CF6).withValues(alpha: 0.25)),
                        boxShadow: const [
                          BoxShadow(
                            color: Color(0x0C000000),
                            blurRadius: 12,
                            offset: Offset(0, 4),
                          ),
                        ],
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            children: [
                              Container(
                                padding: const EdgeInsets.all(8),
                                decoration: BoxDecoration(
                                  color: const Color(0xFFF3E8FF),
                                  borderRadius: BorderRadius.circular(10),
                                ),
                                child: const Icon(
                                  Icons.rate_review_rounded,
                                  color: Color(0xFF6D28D9),
                                  size: 22,
                                ),
                              ),
                              const SizedBox(width: 12),
                              const Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      'Avis & Réclamations Médicales',
                                      style: TextStyle(
                                        fontSize: 15,
                                        fontWeight: FontWeight.w700,
                                        color: AppColors.textPrimary,
                                      ),
                                    ),
                                    Text(
                                      'Suivi direct par la Direction Hospitalière',
                                      style: TextStyle(
                                        fontSize: 11.5,
                                        color: AppColors.textSecondary,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 12),
                          const Text(
                            'Exprimez vos retours sur la qualité de prise en charge, signalez un retard anormal ou un litige déontologique en toute confidentialité.',
                            style: TextStyle(
                              fontSize: 12.5,
                              color: AppColors.textSecondary,
                              height: 1.4,
                            ),
                          ),
                          const SizedBox(height: 14),
                          SizedBox(
                            width: double.infinity,
                            child: OutlinedButton.icon(
                              onPressed: () {
                                context.push(AppRoutes.grievances);
                              },
                              icon: const Icon(Icons.arrow_forward_rounded, size: 16),
                              label: const Text('Déposer un avis ou consulter mes réclamations'),
                              style: OutlinedButton.styleFrom(
                                foregroundColor: const Color(0xFF6D28D9),
                                side: const BorderSide(color: Color(0xFF8B5CF6)),
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(12),
                                ),
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),

                  const SizedBox(height: 36),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
