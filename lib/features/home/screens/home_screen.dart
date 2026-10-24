import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';

import '../../../core/routes/app_router.dart';
import '../../../core/theme/app_colors.dart';
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
    await Future.wait([
      context.read<PatientProvider>().getMyRecord(),
    ]);
  }

  void _showFeatureNotice(String title, String description) {
    showModalBottomSheet(
      context: context,
      backgroundColor: AppColors.surface,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      builder: (context) {
        return SafeArea(
          child: Padding(
            padding: const EdgeInsets.fromLTRB(24, 16, 24, 28),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Center(
                  child: Container(
                    width: 44,
                    height: 5,
                    decoration: BoxDecoration(
                      color: AppColors.border,
                      borderRadius: BorderRadius.circular(3),
                    ),
                  ),
                ),
                const SizedBox(height: 20),
                Row(
                  children: [
                    Container(
                      padding: const EdgeInsets.all(10),
                      decoration: BoxDecoration(
                        color: AppColors.primaryContainer,
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: const Icon(
                        Icons.medical_services_rounded,
                        color: AppColors.primary,
                        size: 26,
                      ),
                    ),
                    const SizedBox(width: 14),
                    Expanded(
                      child: Text(
                        title,
                        style: const TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.w700,
                          color: AppColors.textPrimary,
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 14),
                Text(
                  description,
                  style: const TextStyle(
                    fontSize: 14,
                    color: AppColors.textSecondary,
                    height: 1.45,
                  ),
                ),
                const SizedBox(height: 22),
                SizedBox(
                  width: double.infinity,
                  height: 48,
                  child: ElevatedButton(
                    onPressed: () => Navigator.pop(context),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppColors.primary,
                      foregroundColor: Colors.white,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(14),
                      ),
                    ),
                    child: const Text('Compris'),
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    final user = context.watch<AuthProvider>().user;
    final userName = user?.displayName.isNotEmpty == true
        ? user!.displayName
        : (user?.username ?? 'Patient');
    final userRole = user?.roles.isNotEmpty == true ? user!.roles.first : 'PATIENT';

    return Scaffold(
      backgroundColor: AppColors.background,
      body: RefreshIndicator(
        onRefresh: _load,
        child: SingleChildScrollView(
          physics: const AlwaysScrollableScrollPhysics(),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // 1. En-tête bleu avec avatar, salutations et recherche
              HomeHeader(
                name: userName,
                userRole: userRole,
                notificationCount: 2,
                onProfileTap: () {
                  context.push(AppRoutes.profile);
                },
                onSearchTap: () {
                  _showFeatureNotice(
                    'Recherche Rapide',
                    'Recherchez des médecins par spécialité, des hôpitaux partenaires ou des types d\'actes médicaux.',
                  );
                },
                onNotificationTap: () {
                  _showFeatureNotice(
                    'Notifications & Alertes',
                    'Consultez vos rappels de rendez-vous, alertes de résultats de laboratoire et confirmations médicales.',
                  );
                },
              ),

              // 2. Grille des 6 services clés inspirée du template
              Transform.translate(
                offset: const Offset(0, -22),
                child: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 16),
                  child: ServicesCard(
                    services: [
                      ServiceItemData(
                        icon: Icons.monitor_weight_outlined,
                        title: 'Consultation & IMC',
                        badgeText: 'Live',
                        color: AppColors.primary,
                        backgroundColor: AppColors.softBlue,
                        onTap: () {
                          context.push(AppRoutes.medicalRecord);
                        },
                      ),
                      ServiceItemData(
                        icon: Icons.calendar_month_outlined,
                        title: 'Rendez-vous',
                        color: AppColors.primary,
                        backgroundColor: AppColors.softBlue,
                        onTap: () {
                          context.push(AppRoutes.appointments);
                        },
                      ),
                      ServiceItemData(
                        icon: Icons.video_camera_front_outlined,
                        title: 'Téléconsultation',
                        badgeText: 'Jitsi',
                        color: AppColors.accentGreen,
                        backgroundColor: AppColors.softGreen,
                        onTap: () {
                          _showFeatureNotice(
                            'Téléconsultation Jitsi Meet',
                            'Rejoignez votre consultation vidéo sécurisée chiffrée de bout en bout avec votre médecin traitant.',
                          );
                        },
                      ),
                      ServiceItemData(
                        icon: Icons.medication_outlined,
                        title: 'Pharmacie',
                        color: AppColors.accentOrange,
                        backgroundColor: AppColors.softOrange,
                        onTap: () {
                          context.push(AppRoutes.prescriptions);
                        },
                      ),
                      ServiceItemData(
                        icon: Icons.biotech_outlined,
                        title: 'Laboratoire',
                        color: AppColors.accentPurple,
                        backgroundColor: AppColors.softPurple,
                        onTap: () {
                          _showFeatureNotice(
                            'Laboratoire & Analyses FHIR',
                            'Consultez vos bilans sanguins, ordonnances de biologie et rapports d\'analyses certifiés.',
                          );
                        },
                      ),
                      ServiceItemData(
                        icon: Icons.verified_outlined,
                        title: 'Certificats & Cachet',
                        badgeText: 'Officiel',
                        color: AppColors.primary,
                        backgroundColor: AppColors.softBlue,
                        onTap: () {
                          _showFeatureNotice(
                            'Certificats Médicaux Officiels',
                            'Téléchargez vos arrêts maladie et dispenses avec cachet circulaire infalsifiable et empreinte SHA-256 de l\'hôpital.',
                          );
                        },
                      ),
                    ],
                  ),
                ),
              ),

              // 3. Départements médicaux avec carrousel horizontal
              Padding(
                padding: const EdgeInsets.fromLTRB(18, 4, 18, 12),
                child: SectionHeader(
                  title: 'Départements',
                  subtitle: 'Explorez nos pôles médicaux spécialisés',
                  actionText: 'Voir tout',
                  onActionTap: () {
                    _showFeatureNotice(
                      'Tous les Départements',
                      'Découvrez l\'ensemble des 18 spécialités cliniques disponibles dans le réseau MedScan.',
                    );
                  },
                ),
              ),

              SizedBox(
                height: 148,
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
                      onTap: () {
                        context.push(AppRoutes.appointments);
                      },
                    ),
                    const SizedBox(width: 12),
                    DepartmentCard(
                      name: 'Pédiatrie',
                      doctorCount: 524,
                      icon: Icons.child_care_rounded,
                      color: AppColors.accentRed,
                      backgroundColor: AppColors.softRed,
                      onTap: () {
                        context.push(AppRoutes.appointments);
                      },
                    ),
                    const SizedBox(width: 12),
                    DepartmentCard(
                      name: 'Cardiologie',
                      doctorCount: 438,
                      icon: Icons.favorite_rounded,
                      color: AppColors.accentPink,
                      backgroundColor: AppColors.softPink,
                      onTap: () {
                        context.push(AppRoutes.appointments);
                      },
                    ),
                    const SizedBox(width: 12),
                    DepartmentCard(
                      name: 'Radiologie & IA',
                      doctorCount: 182,
                      icon: Icons.document_scanner_rounded,
                      color: AppColors.accentPurple,
                      backgroundColor: AppColors.softPurple,
                      onTap: () {
                        context.push(AppRoutes.appointments);
                      },
                    ),
                  ],
                ),
              ),

              const SizedBox(height: 24),

              // 4. Établissements de santé (Top Hospital)
              Padding(
                padding: const EdgeInsets.fromLTRB(18, 0, 18, 12),
                child: SectionHeader(
                  title: 'Top Hôpitaux',
                  subtitle: 'Établissements partenaires conventionnés',
                  actionText: 'Voir tout',
                  onActionTap: () {
                    _showFeatureNotice(
                      'Réseau Hospitalier MedScan',
                      'Consultez la liste complète des hôpitaux, cliniques et laboratoires du réseau.',
                    );
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
                      rating: 4.9,
                      reviewCount: 512,
                      tagText: 'Urgences 24/7',
                      onTap: () {
                        context.push(AppRoutes.appointments);
                      },
                    ),
                    const SizedBox(height: 12),
                    OrganizationCard(
                      name: 'Hôpital de Bogodogo',
                      type: 'Hôpital de District',
                      address: 'Ouagadougou, Secteur 30',
                      rating: 4.8,
                      reviewCount: 342,
                      tagText: 'Chirurgie & Maternité',
                      onTap: () {
                        context.push(AppRoutes.appointments);
                      },
                    ),
                    const SizedBox(height: 12),
                    OrganizationCard(
                      name: 'Clinique Médicale Philadelphie',
                      type: 'Clinique Privée',
                      address: 'Ouagadougou, Zone du Bois',
                      rating: 4.7,
                      reviewCount: 215,
                      tagText: 'Cardiologie de pointe',
                      onTap: () {
                        context.push(AppRoutes.appointments);
                      },
                    ),
                    const SizedBox(height: 12),
                    OrganizationCard(
                      name: 'Clinique Les Genêts',
                      type: 'Centre Médico-chirurgical',
                      address: 'Ouagadougou, Ouaga 2000',
                      rating: 4.8,
                      reviewCount: 189,
                      tagText: 'Scanner & Télé-imagerie',
                      onTap: () {
                        context.push(AppRoutes.appointments);
                      },
                    ),
                  ],
                ),
              ),

              const SizedBox(height: 36),
            ],
          ),
        ),
      ),
    );
  }
}
