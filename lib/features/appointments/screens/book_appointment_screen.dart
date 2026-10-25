import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../../../core/routes/app_router.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_text_styles.dart';
import '../../../core/widgets/primary_button.dart';
import '../../../core/widgets/rating_badge.dart';

class BookAppointmentScreen extends StatefulWidget {
  const BookAppointmentScreen({super.key});

  @override
  State<BookAppointmentScreen> createState() => _BookAppointmentScreenState();
}

class _BookAppointmentScreenState extends State<BookAppointmentScreen> {
  int _currentStep = 1; // 1 à 5

  // Données sélectionnées
  String? _selectedService = 'Médecine Générale';
  String? _selectedHospital = 'CHU Yalgado Ouédraogo';
  final String _assignedDoctor = 'Assigné automatiquement par l\'administration';
  final String _assignedDoctorSpeciality = 'Médecin spécialiste selon planning';
  DateTime _selectedDate = DateTime.now().add(const Duration(days: 1));
  String _selectedTimeSlot = '10:00 - 11:00';

  // Informations patient & Biométrie (Étape 4)
  final _firstNameController = TextEditingController(text: 'Kala');
  final _lastNameController = TextEditingController(text: 'Pham');
  final _phoneController = TextEditingController(text: '+226 70 12 34 56');
  final _weightController = TextEditingController(text: '72');
  final _heightController = TextEditingController(text: '178');
  String _selectedGender = 'Masculin';
  String _selectedBloodGroup = 'O+';

  // Champs personnalisés dynamiques (clé: valeur)
  final List<MapEntry<TextEditingController, TextEditingController>> _customFields = [
    MapEntry(
      TextEditingController(text: 'Tour de taille'),
      TextEditingController(text: '84 cm'),
    ),
  ];

  // IMC calculé dynamiquement
  double? _bmi;
  String? _bmiCategory;
  Color _bmiColor = AppColors.success;

  @override
  void initState() {
    super.initState();
    _recalculateBmi();
    _weightController.addListener(_recalculateBmi);
    _heightController.addListener(_recalculateBmi);
  }

  @override
  void dispose() {
    _firstNameController.dispose();
    _lastNameController.dispose();
    _phoneController.dispose();
    _weightController.dispose();
    _heightController.dispose();
    for (final field in _customFields) {
      field.key.dispose();
      field.value.dispose();
    }
    super.dispose();
  }

  void _recalculateBmi() {
    final weight = double.tryParse(_weightController.text.replaceAll(',', '.'));
    final height = double.tryParse(_heightController.text.replaceAll(',', '.'));

    if (weight != null && height != null && height > 50 && weight > 10) {
      final heightInMeters = height / 100.0;
      final calculatedBmi = weight / (heightInMeters * heightInMeters);

      setState(() {
        _bmi = double.parse(calculatedBmi.toStringAsFixed(1));

        if (_bmi! < 18.5) {
          _bmiCategory = 'Insuffisance pondérale';
          _bmiColor = AppColors.warning;
        } else if (_bmi! < 25.0) {
          _bmiCategory = 'Poids normal / Idéal';
          _bmiColor = AppColors.success;
        } else if (_bmi! < 30.0) {
          _bmiCategory = 'Surpoids';
          _bmiColor = AppColors.warning;
        } else {
          _bmiCategory = 'Obésité clinique';
          _bmiColor = AppColors.error;
        }
      });
    } else {
      setState(() {
        _bmi = null;
        _bmiCategory = null;
      });
    }
  }

  void _addCustomField() {
    setState(() {
      _customFields.add(
        MapEntry(
          TextEditingController(),
          TextEditingController(),
        ),
      );
    });
  }

  void _removeCustomField(int index) {
    setState(() {
      _customFields[index].key.dispose();
      _customFields[index].value.dispose();
      _customFields.removeAt(index);
    });
  }

  void _nextStep() {
    if (_currentStep < 5) {
      setState(() {
        _currentStep++;
      });
    } else {
      _showSuccessDialog();
    }
  }

  void _prevStep() {
    if (_currentStep > 1) {
      setState(() {
        _currentStep--;
      });
    } else {
      Navigator.pop(context);
    }
  }

  void _showSuccessDialog() {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) {
        return Dialog(
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
          child: Padding(
            padding: const EdgeInsets.all(24),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Container(
                  width: 80,
                  height: 80,
                  decoration: const BoxDecoration(
                    color: AppColors.softBlue,
                    shape: BoxShape.circle,
                  ),
                  child: const Center(
                    child: Icon(
                      Icons.event_available_rounded,
                      color: AppColors.primary,
                      size: 44,
                    ),
                  ),
                ),
                const SizedBox(height: 20),
                Text(
                  'Rendez-vous Confirmé !',
                  textAlign: TextAlign.center,
                  style: AppTextStyles.h2.copyWith(fontSize: 20),
                ),
                const SizedBox(height: 8),
                Text(
                  'Votre demande de consultation en $_selectedService est confirmée au $_selectedHospital le ${_formatDate(_selectedDate)} à $_selectedTimeSlot.\n\nPraticien : $_assignedDoctor selon le planning de régulation web.',
                  textAlign: TextAlign.center,
                  style: AppTextStyles.bodyRegular.copyWith(
                    color: AppColors.textSecondary,
                  ),
                ),
                const SizedBox(height: 20),
                Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: AppColors.primaryContainer,
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      const Icon(Icons.verified_rounded, color: AppColors.primary, size: 20),
                      const SizedBox(width: 8),
                      Text(
                        'Sceau officiel de l\'hôpital apposé',
                        style: AppTextStyles.bodySmall.copyWith(
                          color: AppColors.primary,
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 24),
                PrimaryButton(
                  label: 'Ajouter au calendrier',
                  onPressed: () {
                    Navigator.pop(context);
                    context.go(AppRoutes.appointments);
                  },
                ),
                const SizedBox(height: 10),
                TextButton(
                  onPressed: () {
                    Navigator.pop(context);
                    context.go(AppRoutes.main);
                  },
                  child: Text(
                    'Fermer',
                    style: AppTextStyles.buttonLabel.copyWith(
                      color: AppColors.textSecondary,
                    ),
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
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        backgroundColor: AppColors.surface,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_new_rounded, color: AppColors.textPrimary, size: 18),
          onPressed: _prevStep,
        ),
        title: Text(
          _getStepTitle(),
          style: AppTextStyles.stepTitle,
        ),
        centerTitle: true,
        actions: [
          IconButton(
            icon: const Icon(Icons.home_outlined, color: AppColors.primary, size: 22),
            onPressed: () => context.go(AppRoutes.main),
          ),
        ],
        bottom: PreferredSize(
          preferredSize: const Size.fromHeight(4),
          child: LinearProgressIndicator(
            value: _currentStep / 5.0,
            backgroundColor: AppColors.border,
            valueColor: const AlwaysStoppedAnimation<Color>(AppColors.primary),
            minHeight: 4,
          ),
        ),
      ),
      body: SafeArea(
        child: Column(
          children: [
            Expanded(
              child: SingleChildScrollView(
                padding: const EdgeInsets.all(20),
                child: _buildCurrentStepContent(),
              ),
            ),
            _buildBottomBar(),
          ],
        ),
      ),
    );
  }

  String _getStepTitle() {
    switch (_currentStep) {
      case 1:
        return 'Étape 1 sur 5 : Choisir le service';
      case 2:
        return 'Étape 2 sur 5 : Choisir l\'hôpital';
      case 3:
        return 'Étape 3 sur 5 : Date & Créneau souhaité';
      case 4:
        return 'Étape 4 sur 5 : Patient & Biométrie';
      case 5:
        return 'Étape 5 sur 5 : Confirmation';
      default:
        return 'Rendez-vous';
    }
  }

  Widget _buildCurrentStepContent() {
    switch (_currentStep) {
      case 1:
        return _buildStep1Services();
      case 2:
        return _buildStep2Hospital();
      case 3:
        return _buildStep3Schedule();
      case 4:
        return _buildStep4PatientAndBmi();
      case 5:
        return _buildStep5Confirmation();
      default:
        return const SizedBox();
    }
  }

  // --- ÉTAPE 1 : CHOISIR LE SERVICE ---
  Widget _buildStep1Services() {
    final services = [
      {
        'title': 'Médecine Générale',
        'price': '5 000 - 15 000 FCFA',
        'available': 'Aujourd\'hui à 10:30',
        'icon': Icons.medical_services_rounded,
        'color': AppColors.primary,
      },
      {
        'title': 'Pédiatrie & Santé Enfant',
        'price': '8 000 - 20 000 FCFA',
        'available': 'Demain à 09:00',
        'icon': Icons.child_care_rounded,
        'color': AppColors.accentRed,
      },
      {
        'title': 'Cardiologie Spécialisée',
        'price': '15 000 - 35 000 FCFA',
        'available': '28 Octobre à 14:00',
        'icon': Icons.favorite_rounded,
        'color': AppColors.accentPink,
      },
      {
        'title': 'Radiologie & Télé-imagerie',
        'price': '12 000 - 45 000 FCFA',
        'available': 'Disponible 24h/24',
        'icon': Icons.document_scanner_rounded,
        'color': AppColors.accentPurple,
      },
      {
        'title': 'Biologie Médicale & Labo',
        'price': '6 000 - 18 000 FCFA',
        'available': 'Sans rendez-vous',
        'icon': Icons.biotech_rounded,
        'color': AppColors.accentGreen,
      },
    ];

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _buildSearchField('Rechercher un acte ou un service...'),
        const SizedBox(height: 20),
        Text('Services Cliniques Disponibles', style: AppTextStyles.h3),
        const SizedBox(height: 14),
        ...services.map((s) {
          final isSelected = _selectedService == s['title'];
          return Padding(
            padding: const EdgeInsets.only(bottom: 12),
            child: InkWell(
              onTap: () {
                setState(() {
                  _selectedService = s['title'] as String;
                });
              },
              borderRadius: BorderRadius.circular(16),
              child: Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: AppColors.surface,
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(
                    color: isSelected ? AppColors.primary : AppColors.border,
                    width: isSelected ? 2 : 1,
                  ),
                  boxShadow: const [
                    BoxShadow(
                      color: AppColors.shadowLight,
                      blurRadius: 10,
                      offset: Offset(0, 3),
                    ),
                  ],
                ),
                child: Row(
                  children: [
                    Container(
                      width: 50,
                      height: 50,
                      decoration: BoxDecoration(
                        color: (s['color'] as Color).withValues(alpha: 0.12),
                        borderRadius: BorderRadius.circular(14),
                      ),
                      child: Icon(s['icon'] as IconData, color: s['color'] as Color, size: 26),
                    ),
                    const SizedBox(width: 14),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            s['title'] as String,
                            style: AppTextStyles.bodyMedium.copyWith(
                              fontWeight: FontWeight.w700,
                              fontSize: 15,
                            ),
                          ),
                          const SizedBox(height: 4),
                          Text(
                            s['price'] as String,
                            style: AppTextStyles.price.copyWith(fontSize: 12.5),
                          ),
                          const SizedBox(height: 2),
                          Text(
                            'Disponible : ${s['available']}',
                            style: AppTextStyles.caption.copyWith(fontSize: 11.5),
                          ),
                        ],
                      ),
                    ),
                    Icon(
                      isSelected ? Icons.check_circle_rounded : Icons.radio_button_off_rounded,
                      color: isSelected ? AppColors.primary : AppColors.border,
                      size: 24,
                    ),
                  ],
                ),
              ),
            ),
          );
        }),
      ],
    );
  }

  // --- ÉTAPE 2 : CHOISIR L'HÔPITAL ---
  Widget _buildStep2Hospital() {
    final hospitals = [
      {
        'name': 'CHU Yalgado Ouédraogo',
        'address': 'Ouagadougou, Secteur 4',
        'rating': 4.9,
        'reviews': 512,
        'rooms': 140,
        'doctors': 124,
        'tag': 'Urgences 24/7',
      },
      {
        'name': 'Hôpital de Bogodogo',
        'address': 'Ouagadougou, Secteur 30',
        'rating': 4.8,
        'reviews': 342,
        'rooms': 95,
        'doctors': 86,
        'tag': 'Chirurgie & Pédiatrie',
      },
      {
        'name': 'Clinique Médicale Philadelphie',
        'address': 'Ouagadougou, Zone du Bois',
        'rating': 4.7,
        'reviews': 215,
        'rooms': 32,
        'doctors': 42,
        'tag': 'Cardiologie Spécialisée',
      },
      {
        'name': 'Clinique Les Genêts',
        'address': 'Ouagadougou, Ouaga 2000',
        'rating': 4.8,
        'reviews': 189,
        'rooms': 28,
        'doctors': 35,
        'tag': 'Scanner & Télé-imagerie',
      },
    ];

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _buildSearchField('Rechercher un établissement...'),
        const SizedBox(height: 20),
        Text('Établissements Hospitaliers', style: AppTextStyles.h3),
        const SizedBox(height: 14),
        ...hospitals.map((h) {
          final isSelected = _selectedHospital == h['name'];
          return Padding(
            padding: const EdgeInsets.only(bottom: 14),
            child: InkWell(
              onTap: () {
                setState(() {
                  _selectedHospital = h['name'] as String;
                });
              },
              borderRadius: BorderRadius.circular(18),
              child: Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: AppColors.surface,
                  borderRadius: BorderRadius.circular(18),
                  border: Border.all(
                    color: isSelected ? AppColors.primary : AppColors.border,
                    width: isSelected ? 2 : 1,
                  ),
                  boxShadow: const [
                    BoxShadow(
                      color: AppColors.shadowLight,
                      blurRadius: 10,
                      offset: Offset(0, 3),
                    ),
                  ],
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Container(
                          width: 48,
                          height: 48,
                          decoration: BoxDecoration(
                            color: AppColors.primaryContainer,
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: const Icon(
                            Icons.local_hospital_rounded,
                            color: AppColors.primary,
                            size: 26,
                          ),
                        ),
                        const SizedBox(width: 14),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                h['name'] as String,
                                style: AppTextStyles.bodyMedium.copyWith(
                                  fontWeight: FontWeight.w700,
                                  fontSize: 15.5,
                                ),
                              ),
                              const SizedBox(height: 3),
                              Text(
                                h['address'] as String,
                                style: AppTextStyles.caption.copyWith(fontSize: 12),
                              ),
                            ],
                          ),
                        ),
                        Icon(
                          isSelected ? Icons.check_circle_rounded : Icons.radio_button_off_rounded,
                          color: isSelected ? AppColors.primary : AppColors.border,
                          size: 22,
                        ),
                      ],
                    ),
                    const SizedBox(height: 12),
                    const Divider(height: 1, color: AppColors.borderLight),
                    const SizedBox(height: 10),
                    Row(
                      children: [
                        RatingBadge(
                          rating: h['rating'] as double,
                          reviewCount: h['reviews'] as int,
                        ),
                        const Spacer(),
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                          decoration: BoxDecoration(
                            color: AppColors.softGreen,
                            borderRadius: BorderRadius.circular(8),
                          ),
                          child: Text(
                            h['tag'] as String,
                            style: const TextStyle(
                              color: AppColors.accentGreen,
                              fontSize: 11,
                              fontWeight: FontWeight.w700,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ),
          );
        }),
      ],
    );
  }

  // --- ÉTAPE 3 : PLANIFICATION & ATTRIBUTION AUTOMATIQUE DU MÉDECIN ---
  Widget _buildStep3Schedule() {
    final timeSlots = [
      '08:00 - 09:00',
      '09:00 - 10:00',
      '10:00 - 11:00',
      '11:30 - 12:30',
      '14:00 - 15:00',
      '15:30 - 16:30',
      '17:00 - 18:00',
    ];

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Carte d'attribution automatique par l'administration hospitalière
        Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            gradient: const LinearGradient(
              colors: [Color(0xFFEEF5FF), Color(0xFFF3F8FF)],
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
            ),
            borderRadius: BorderRadius.circular(20),
            border: Border.all(color: AppColors.primary.withValues(alpha: 0.25)),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Container(
                    padding: const EdgeInsets.all(10),
                    decoration: BoxDecoration(
                      color: AppColors.primary,
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: const Icon(
                      Icons.admin_panel_settings_rounded,
                      color: Colors.white,
                      size: 24,
                    ),
                  ),
                  const SizedBox(width: 14),
                  const Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Régulation Hospitalière',
                          style: TextStyle(
                            fontSize: 15,
                            fontWeight: FontWeight.w700,
                            color: AppColors.primaryDark,
                          ),
                        ),
                        Text(
                          'Assignation automatique du praticien',
                          style: TextStyle(
                            fontSize: 12,
                            color: AppColors.textSecondary,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 12),
              Text(
                'Selon le protocole de l\'établissement ($_selectedHospital), vous ne choisissez pas directement votre médecin. Le praticien disponible et qualifié vous est automatiquement assigné selon le planning de garde validé par l\'administration web de l\'hôpital.',
                style: const TextStyle(
                  fontSize: 12.5,
                  color: AppColors.textPrimary,
                  height: 1.4,
                ),
              ),
              const SizedBox(height: 12),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(10),
                  border: Border.all(color: AppColors.border),
                ),
                child: Row(
                  children: [
                    const Icon(Icons.sync_rounded, size: 16, color: AppColors.accentGreen),
                    const SizedBox(width: 8),
                    Expanded(
                      child: Text(
                        'Service : $_selectedService • Attribution synchronisée Web Admin',
                        style: const TextStyle(
                          fontSize: 11.5,
                          fontWeight: FontWeight.w600,
                          color: AppColors.textSecondary,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),

        const SizedBox(height: 24),
        Text('Choisir la Date de Consultation', style: AppTextStyles.h3),
        const SizedBox(height: 6),
        Text(
          'Sélectionnez le jour qui vous convient',
          style: AppTextStyles.caption,
        ),
        const SizedBox(height: 14),

        // Sélecteur horizontal de jours
        SizedBox(
          height: 80,
          child: ListView.builder(
            scrollDirection: Axis.horizontal,
            itemCount: 7,
            itemBuilder: (context, index) {
              final day = DateTime.now().add(Duration(days: index));
              final isDaySelected = _selectedDate.day == day.day && _selectedDate.month == day.month;

              return Padding(
                padding: const EdgeInsets.only(right: 10),
                child: InkWell(
                  onTap: () {
                    setState(() {
                      _selectedDate = day;
                    });
                  },
                  borderRadius: BorderRadius.circular(16),
                  child: Container(
                    width: 65,
                    padding: const EdgeInsets.symmetric(vertical: 10),
                    decoration: BoxDecoration(
                      color: isDaySelected ? AppColors.primary : AppColors.surface,
                      borderRadius: BorderRadius.circular(16),
                      border: Border.all(
                        color: isDaySelected ? AppColors.primary : AppColors.border,
                      ),
                    ),
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Text(
                          _getDayShort(day.weekday),
                          style: TextStyle(
                            color: isDaySelected ? Colors.white.withValues(alpha: 0.85) : AppColors.textSecondary,
                            fontSize: 12,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          '${day.day}',
                          style: TextStyle(
                            color: isDaySelected ? Colors.white : AppColors.textPrimary,
                            fontSize: 18,
                            fontWeight: FontWeight.w700,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              );
            },
          ),
        ),

        const SizedBox(height: 22),
        Text('Créneaux Horaires Disponibles', style: AppTextStyles.bodyMedium.copyWith(fontWeight: FontWeight.w700)),
        const SizedBox(height: 12),

        Wrap(
          spacing: 10,
          runSpacing: 10,
          children: timeSlots.map((slot) {
            final isSlotSelected = _selectedTimeSlot == slot;
            return ChoiceChip(
              label: Text(slot),
              selected: isSlotSelected,
              onSelected: (selected) {
                if (selected) {
                  setState(() {
                    _selectedTimeSlot = slot;
                  });
                }
              },
              selectedColor: AppColors.primary,
              backgroundColor: AppColors.surface,
              labelStyle: TextStyle(
                color: isSlotSelected ? Colors.white : AppColors.textPrimary,
                fontWeight: isSlotSelected ? FontWeight.w700 : FontWeight.w500,
                fontSize: 12.5,
              ),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
                side: BorderSide(color: isSlotSelected ? AppColors.primary : AppColors.border),
              ),
            );
          }).toList(),
        ),
      ],
    );
  }

  // --- ÉTAPE 4 : INFORMATIONS PATIENT & CALCUL DYNAMIQUE IMC ---
  Widget _buildStep4PatientAndBmi() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text('Informations du Patient', style: AppTextStyles.h3),
        const SizedBox(height: 4),
        Text(
          'Données médicales et calcul automatique de l\'IMC en direct',
          style: AppTextStyles.caption,
        ),
        const SizedBox(height: 18),

        Row(
          children: [
            Expanded(
              child: _buildTextField(
                controller: _firstNameController,
                label: 'Prénom',
                icon: Icons.person_outline,
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: _buildTextField(
                controller: _lastNameController,
                label: 'Nom',
                icon: Icons.person_outline,
              ),
            ),
          ],
        ),

        const SizedBox(height: 14),

        Row(
          children: [
            Expanded(
              child: DropdownButtonFormField<String>(
                initialValue: _selectedGender,
                decoration: InputDecoration(
                  labelText: 'Sexe',
                  prefixIcon: const Icon(Icons.person_outline_rounded, color: AppColors.primary),
                  filled: true,
                  fillColor: AppColors.surface,
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(14),
                    borderSide: const BorderSide(color: AppColors.border),
                  ),
                ),
                items: ['Masculin', 'Féminin']
                    .map((g) => DropdownMenuItem(value: g, child: Text(g)))
                    .toList(),
                onChanged: (val) {
                  if (val != null) {
                    setState(() {
                      _selectedGender = val;
                    });
                  }
                },
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: DropdownButtonFormField<String>(
                initialValue: _selectedBloodGroup,
                decoration: InputDecoration(
                  labelText: 'Groupe Sanguin',
                  prefixIcon: const Icon(Icons.bloodtype_outlined, color: AppColors.accentRed),
                  filled: true,
                  fillColor: AppColors.surface,
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(14),
                    borderSide: const BorderSide(color: AppColors.border),
                  ),
                ),
                items: ['A+', 'A-', 'B+', 'B-', 'AB+', 'AB-', 'O+', 'O-']
                    .map((bg) => DropdownMenuItem(value: bg, child: Text(bg)))
                    .toList(),
                onChanged: (val) {
                  if (val != null) {
                    setState(() {
                      _selectedBloodGroup = val;
                    });
                  }
                },
              ),
            ),
          ],
        ),

        const SizedBox(height: 22),

        // Carte biométrique avec calcul en temps réel de l'IMC
        Container(
          padding: const EdgeInsets.all(18),
          decoration: BoxDecoration(
            color: AppColors.surface,
            borderRadius: BorderRadius.circular(20),
            border: Border.all(color: AppColors.border),
            boxShadow: const [
              BoxShadow(
                color: AppColors.shadowLight,
                blurRadius: 14,
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
                      color: AppColors.primaryContainer,
                      borderRadius: BorderRadius.circular(10),
                    ),
                    child: const Icon(
                      Icons.monitor_weight_rounded,
                      color: AppColors.primary,
                      size: 22,
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Biométrie & Indice de Masse Corporelle (IMC)',
                          style: AppTextStyles.bodyMedium.copyWith(
                            fontWeight: FontWeight.w700,
                          ),
                        ),
                        Text(
                          'Calcul automatique pendant la consultation',
                          style: AppTextStyles.caption,
                        ),
                      ],
                    ),
                  ),
                ],
              ),

              const SizedBox(height: 18),

              Row(
                children: [
                  Expanded(
                    child: _buildTextField(
                      controller: _weightController,
                      label: 'Poids (kg)',
                      icon: Icons.scale_rounded,
                      keyboardType: TextInputType.number,
                      hint: 'Ex: 72',
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: _buildTextField(
                      controller: _heightController,
                      label: 'Taille (cm)',
                      icon: Icons.height_rounded,
                      keyboardType: TextInputType.number,
                      hint: 'Ex: 178',
                    ),
                  ),
                ],
              ),

              const SizedBox(height: 16),

              // Résultat de l'IMC en temps réel avec classification
              if (_bmi != null)
                Container(
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: _bmiColor.withValues(alpha: 0.10),
                    borderRadius: BorderRadius.circular(14),
                    border: Border.all(color: _bmiColor.withValues(alpha: 0.3)),
                  ),
                  child: Row(
                    children: [
                      Container(
                        padding: const EdgeInsets.all(12),
                        decoration: BoxDecoration(
                          color: _bmiColor,
                          shape: BoxShape.circle,
                        ),
                        child: Text(
                          _bmi.toString(),
                          style: const TextStyle(
                            color: Colors.white,
                            fontSize: 16,
                            fontWeight: FontWeight.w800,
                          ),
                        ),
                      ),
                      const SizedBox(width: 14),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              'IMC : $_bmi kg/m²',
                              style: TextStyle(
                                color: _bmiColor,
                                fontWeight: FontWeight.w800,
                                fontSize: 15,
                              ),
                            ),
                            const SizedBox(height: 2),
                            Text(
                              'Classification : $_bmiCategory',
                              style: AppTextStyles.bodySmall.copyWith(
                                color: AppColors.textPrimary,
                                fontWeight: FontWeight.w600,
                              ),
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

        const SizedBox(height: 24),

        // Section champs personnalisés dynamiques
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text('Champs Personnalisés', style: AppTextStyles.h3),
            TextButton.icon(
              onPressed: _addCustomField,
              icon: const Icon(Icons.add_rounded, size: 18),
              label: const Text('Ajouter'),
              style: TextButton.styleFrom(
                foregroundColor: AppColors.primary,
                textStyle: const TextStyle(fontWeight: FontWeight.w700),
              ),
            ),
          ],
        ),

        const SizedBox(height: 6),
        Text(
          'Ajoutez des champs sur-mesure selon le patient (ex: Antécédents, Allergies, Régime)',
          style: AppTextStyles.caption,
        ),
        const SizedBox(height: 12),

        ..._customFields.asMap().entries.map((entry) {
          final index = entry.key;
          final field = entry.value;

          return Padding(
            padding: const EdgeInsets.only(bottom: 10),
            child: Row(
              children: [
                Expanded(
                  flex: 2,
                  child: TextField(
                    controller: field.key,
                    decoration: InputDecoration(
                      hintText: 'Clé (ex: Tour de taille)',
                      filled: true,
                      fillColor: AppColors.surface,
                      contentPadding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                        borderSide: const BorderSide(color: AppColors.border),
                      ),
                    ),
                  ),
                ),
                const SizedBox(width: 8),
                Expanded(
                  flex: 3,
                  child: TextField(
                    controller: field.value,
                    decoration: InputDecoration(
                      hintText: 'Valeur (ex: 84 cm)',
                      filled: true,
                      fillColor: AppColors.surface,
                      contentPadding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                        borderSide: const BorderSide(color: AppColors.border),
                      ),
                    ),
                  ),
                ),
                IconButton(
                  icon: const Icon(Icons.delete_outline_rounded, color: AppColors.accentRed, size: 20),
                  onPressed: () => _removeCustomField(index),
                ),
              ],
            ),
          );
        }),
      ],
    );
  }

  // --- ÉTAPE 5 : CONFIRMATION & RÉSUMÉ ---
  Widget _buildStep5Confirmation() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text('Résumé du Rendez-vous', style: AppTextStyles.h3),
        const SizedBox(height: 6),
        Text(
          'Vérifiez les détails avant validation officielle',
          style: AppTextStyles.caption,
        ),
        const SizedBox(height: 16),

        Container(
          padding: const EdgeInsets.all(20),
          decoration: BoxDecoration(
            color: AppColors.surface,
            borderRadius: BorderRadius.circular(20),
            border: Border.all(color: AppColors.border),
            boxShadow: const [
              BoxShadow(
                color: AppColors.shadowLight,
                blurRadius: 14,
                offset: Offset(0, 4),
              ),
            ],
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _buildSummaryRow(
                icon: Icons.local_hospital_rounded,
                title: 'Établissement',
                value: _selectedHospital ?? '-',
              ),
              const Divider(height: 24, color: AppColors.borderLight),
              _buildSummaryRow(
                icon: Icons.medical_services_rounded,
                title: 'Service & Spécialité',
                value: '$_selectedService ($_assignedDoctorSpeciality)',
              ),
              const Divider(height: 24, color: AppColors.borderLight),
              _buildSummaryRow(
                icon: Icons.assignment_ind_rounded,
                title: 'Médecin Praticien',
                value: _assignedDoctor,
              ),
              const Divider(height: 24, color: AppColors.borderLight),
              _buildSummaryRow(
                icon: Icons.calendar_month_rounded,
                title: 'Date & Créneau',
                value: '${_formatDate(_selectedDate)} à $_selectedTimeSlot',
              ),
              const Divider(height: 24, color: AppColors.borderLight),
              _buildSummaryRow(
                icon: Icons.badge_rounded,
                title: 'Patient',
                value: '${_firstNameController.text} ${_lastNameController.text} ($_selectedGender, GS: $_selectedBloodGroup)',
              ),
              if (_bmi != null) ...[
                const Divider(height: 24, color: AppColors.borderLight),
                _buildSummaryRow(
                  icon: Icons.monitor_weight_rounded,
                  title: 'IMC Calculé',
                  value: '$_bmi kg/m² ($_bmiCategory)',
                  highlightColor: _bmiColor,
                ),
              ],
            ],
          ),
        ),

        const SizedBox(height: 20),

        // Carte Sceau Numérique Officiel
        Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            gradient: const LinearGradient(
              colors: [AppColors.softBlue, Color(0xFFF3F8FF)],
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
            ),
            borderRadius: BorderRadius.circular(18),
            border: Border.all(color: AppColors.primary.withValues(alpha: 0.2)),
          ),
          child: Row(
            children: [
              Container(
                width: 50,
                height: 50,
                decoration: const BoxDecoration(
                  color: AppColors.primary,
                  shape: BoxShape.circle,
                ),
                child: const Icon(
                  Icons.verified_user_rounded,
                  color: Colors.white,
                  size: 28,
                ),
              ),
              const SizedBox(width: 14),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      'Sceau Numérique Hospitalier',
                      style: TextStyle(
                        color: AppColors.primaryDark,
                        fontWeight: FontWeight.w700,
                        fontSize: 14,
                      ),
                    ),
                    const SizedBox(height: 3),
                    Text(
                      'Authentifié par MedScan avec empreinte cryptographique SHA-256',
                      style: AppTextStyles.caption.copyWith(fontSize: 11.5),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildSummaryRow({
    required IconData icon,
    required String title,
    required String value,
    Color? highlightColor,
  }) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Icon(icon, color: highlightColor ?? AppColors.primary, size: 22),
        const SizedBox(width: 12),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(title, style: AppTextStyles.caption),
              const SizedBox(height: 3),
              Text(
                value,
                style: AppTextStyles.bodyMedium.copyWith(
                  fontWeight: FontWeight.w700,
                  color: highlightColor ?? AppColors.textPrimary,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildTextField({
    required TextEditingController controller,
    required String label,
    required IconData icon,
    TextInputType keyboardType = TextInputType.text,
    String? hint,
  }) {
    return TextField(
      controller: controller,
      keyboardType: keyboardType,
      decoration: InputDecoration(
        labelText: label,
        hintText: hint,
        prefixIcon: Icon(icon, color: AppColors.primary, size: 20),
        filled: true,
        fillColor: AppColors.surface,
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(14),
          borderSide: const BorderSide(color: AppColors.border),
        ),
      ),
    );
  }

  Widget _buildSearchField(String hint) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 4),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppColors.border),
      ),
      child: TextField(
        decoration: InputDecoration(
          hintText: hint,
          prefixIcon: const Icon(Icons.search_rounded, color: AppColors.primary),
          border: InputBorder.none,
          enabledBorder: InputBorder.none,
          focusedBorder: InputBorder.none,
          filled: false,
        ),
      ),
    );
  }

  Widget _buildBottomBar() {
    return Container(
      padding: const EdgeInsets.fromLTRB(20, 14, 20, 16),
      decoration: const BoxDecoration(
        color: AppColors.surface,
        border: Border(top: BorderSide(color: AppColors.borderLight)),
        boxShadow: [
          BoxShadow(
            color: Color(0x0A0F172A),
            blurRadius: 10,
            offset: Offset(0, -3),
          ),
        ],
      ),
      child: PrimaryButton(
        label: _currentStep == 5 ? 'Confirmer le Rendez-vous' : 'Continuer',
        onPressed: _nextStep,
      ),
    );
  }

  String _formatDate(DateTime d) {
    return '${d.day.toString().padLeft(2, '0')}/${d.month.toString().padLeft(2, '0')}/${d.year}';
  }

  String _getDayShort(int weekday) {
    switch (weekday) {
      case DateTime.monday:
        return 'Lun';
      case DateTime.tuesday:
        return 'Mar';
      case DateTime.wednesday:
        return 'Mer';
      case DateTime.thursday:
        return 'Jeu';
      case DateTime.friday:
        return 'Ven';
      case DateTime.saturday:
        return 'Sam';
      case DateTime.sunday:
        return 'Dim';
      default:
        return '';
    }
  }
}
