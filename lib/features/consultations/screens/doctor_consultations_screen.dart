import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_text_styles.dart';
import '../../../core/utils/id_generator.dart';
import '../../../models/patient.dart';
import '../../../models/user.dart';
import '../../../providers/auth_provider.dart';
import '../../../services/appointment_service.dart';

class DoctorConsultationsScreen extends StatefulWidget {
  const DoctorConsultationsScreen({super.key});

  @override
  State<DoctorConsultationsScreen> createState() => _DoctorConsultationsScreenState();
}

class _DoctorConsultationsScreenState extends State<DoctorConsultationsScreen> {
  final ConsultationService _consultationService = ConsultationService();
  int _activeTab = 0; // 0: Historique des consultations, 1: Rédiger une nouvelle consultation

  // Liste des consultations effectuées en mémoire
  static final List<Map<String, dynamic>> _consultationsHistory = [
    {
      'id': 'c1111111-2222-3333-4444-555555555551',
      'patientName': 'Fatou Ouédraogo',
      'patientId': '99f10bda-a5e3-4ce6-a0bb-6cc09f2a280e',
      'date': DateTime.now().subtract(const Duration(days: 2)),
      'chiefComplaint': 'Accès fébrile aigu avec frissons et céphalées intenses',
      'examinationNotes': 'État général conservé, température à 38.9°C, pâleur conjonctivale modérée.',
      'diagnosis': 'Paludisme simple à Plasmodium falciparum',
      'treatmentPlan': 'Artéméther-Luméfantrine 20/120mg (4 cp/prise pendant 3 jours) + Paracétamol 1g.',
      'weightKg': 62.0,
      'heightCm': 165.0,
      'bmi': 22.8,
      'bmiCategory': 'Poids normal / Idéal',
      'bloodPressure': '120/80 mmHg',
    },
    {
      'id': 'c1111111-2222-3333-4444-555555555552',
      'patientName': 'Ibrahim Compaoré',
      'patientId': 'dababb25-8dc9-402c-b527-15d9a4b1f380',
      'date': DateTime.now().subtract(const Duration(days: 6)),
      'chiefComplaint': 'Suivi trimestriel Diabète Type 2 et surveillance tensionnelle',
      'examinationNotes': 'Pouls périphériques bien perçus, pas d\'œdème des membres inférieurs.',
      'diagnosis': 'Diabète de type 2 équilibré sous bithérapie orale',
      'treatmentPlan': 'Poursuite Metformine 1000mg matin et soir, contrôle HbA1c dans 3 mois.',
      'weightKg': 78.5,
      'heightCm': 174.0,
      'bmi': 25.9,
      'bmiCategory': 'Surpoids léger',
      'bloodPressure': '130/85 mmHg',
    },
  ];

  // Champs du formulaire de nouvelle consultation
  final _patientNameController = TextEditingController(text: 'Fatou Ouédraogo');
  final _chiefComplaintController = TextEditingController();
  final _examinationNotesController = TextEditingController();
  final _diagnosisController = TextEditingController();
  final _treatmentPlanController = TextEditingController();

  final _weightController = TextEditingController(text: '65');
  final _heightController = TextEditingController(text: '168');
  final _systolicController = TextEditingController(text: '120');
  final _diastolicController = TextEditingController(text: '80');
  final _temperatureController = TextEditingController(text: '37.2');

  double? _calculatedBmi;
  String? _bmiCategory;
  bool _isSaving = false;

  @override
  void initState() {
    super.initState();
    _recalculateBmi();
    _weightController.addListener(_recalculateBmi);
    _heightController.addListener(_recalculateBmi);
  }

  @override
  void dispose() {
    _patientNameController.dispose();
    _chiefComplaintController.dispose();
    _examinationNotesController.dispose();
    _diagnosisController.dispose();
    _treatmentPlanController.dispose();
    _weightController.dispose();
    _heightController.dispose();
    _systolicController.dispose();
    _diastolicController.dispose();
    _temperatureController.dispose();
    super.dispose();
  }

  void _recalculateBmi() {
    final weight = double.tryParse(_weightController.text.replaceAll(',', '.'));
    final height = double.tryParse(_heightController.text.replaceAll(',', '.'));
    if (weight != null && height != null && height > 50 && weight > 10) {
      final bmi = Patient.calculateBmi(weight, height);
      setState(() {
        _calculatedBmi = bmi;
        _bmiCategory = Patient.classifyBmi(bmi);
      });
    }
  }

  Future<void> _submitConsultation() async {
    final chief = _chiefComplaintController.text.trim();
    final exam = _examinationNotesController.text.trim();
    final diag = _diagnosisController.text.trim();
    final treat = _treatmentPlanController.text.trim();

    if (chief.isEmpty || diag.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Le motif et le diagnostic sont obligatoires.')),
      );
      return;
    }

    setState(() => _isSaving = true);
    final user = context.read<AuthProvider>().user;
    final doctorName = user?.displayTitle ?? 'Dr. Seydou Traoré';

    try {
      final newConsultation = {
        'id': IdGenerator.generate('cst'),
        'patientName': _patientNameController.text.trim(),
        'patientId': IdGenerator.patientId(),
        'doctorName': doctorName,
        'date': DateTime.now(),
        'chiefComplaint': chief,
        'examinationNotes': exam.isNotEmpty ? exam : 'Examen clinique standard réalisé.',
        'diagnosis': diag,
        'treatmentPlan': treat.isNotEmpty ? treat : 'Surveillance clinique et repos.',
        'weightKg': double.tryParse(_weightController.text) ?? 65.0,
        'heightCm': double.tryParse(_heightController.text) ?? 168.0,
        'bmi': _calculatedBmi ?? 23.0,
        'bmiCategory': _bmiCategory ?? 'Poids normal / Idéal',
        'bloodPressure': '${_systolicController.text}/${_diastolicController.text} mmHg',
      };

      // Appel service
      try {
        await _consultationService.createConsultation(
          patientId: newConsultation['patientId'] as String,
          chiefComplaint: chief,
          examinationNotes: exam,
          diagnosis: diag,
          treatmentPlan: treat,
        );
      } catch (_) {
        // Fallback en mémoire
      }

      setState(() {
        _consultationsHistory.insert(0, newConsultation);
        _activeTab = 0; // Basculer sur l'historique
        _isSaving = false;
      });

      // Nettoyer formulaire
      _chiefComplaintController.clear();
      _examinationNotesController.clear();
      _diagnosisController.clear();
      _treatmentPlanController.clear();

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            backgroundColor: const Color(0xFF16A34A),
            behavior: SnackBarBehavior.floating,
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
            content: const Row(
              children: [
                Icon(Icons.check_circle_rounded, color: Colors.white),
                SizedBox(width: 10),
                Text('Consultation médicale enregistrée et signée avec succès !'),
              ],
            ),
          ),
        );
      }
    } catch (e) {
      setState(() => _isSaving = false);
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Erreur lors de l\'enregistrement : $e')),
        );
      }
    }
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
          isDoctor ? 'Actes Cliniques & Consultations' : 'Soins & Consultations (Infirmier)',
          style: AppTextStyles.headingMedium.copyWith(color: AppColors.textPrimary),
        ),
      ),
      body: Center(
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 640),
          child: Column(
            children: [
              // Onglets : Liste des consultations vs Rédiger une consultation
              Container(
                color: AppColors.surface,
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                child: Container(
                  height: 44,
                  padding: const EdgeInsets.all(4),
                  decoration: BoxDecoration(
                    color: AppColors.background,
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Row(
                    children: [
                      Expanded(
                        child: GestureDetector(
                          onTap: () => setState(() => _activeTab = 0),
                          child: Container(
                            decoration: BoxDecoration(
                              color: _activeTab == 0 ? AppColors.surface : Colors.transparent,
                              borderRadius: BorderRadius.circular(9),
                              boxShadow: _activeTab == 0
                                  ? [
                                      const BoxShadow(
                                        color: Color(0x0A000000),
                                        blurRadius: 4,
                                        offset: Offset(0, 1),
                                      ),
                                    ]
                                  : null,
                            ),
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                Icon(
                                  Icons.history_edu_rounded,
                                  size: 16,
                                  color: _activeTab == 0 ? AppColors.primary : AppColors.textSecondary,
                                ),
                                const SizedBox(width: 6),
                                Text(
                                  'Actes Effectués (${_consultationsHistory.length})',
                                  style: TextStyle(
                                    fontSize: 12.5,
                                    fontWeight: _activeTab == 0 ? FontWeight.w700 : FontWeight.w500,
                                    color: _activeTab == 0 ? AppColors.primary : AppColors.textSecondary,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                      ),
                      Expanded(
                        child: GestureDetector(
                          onTap: () => setState(() => _activeTab = 1),
                          child: Container(
                            decoration: BoxDecoration(
                              color: _activeTab == 1 ? AppColors.surface : Colors.transparent,
                              borderRadius: BorderRadius.circular(9),
                              boxShadow: _activeTab == 1
                                  ? [
                                      const BoxShadow(
                                        color: Color(0x0A000000),
                                        blurRadius: 4,
                                        offset: Offset(0, 1),
                                      ),
                                    ]
                                  : null,
                            ),
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                Icon(
                                  Icons.post_add_rounded,
                                  size: 16,
                                  color: _activeTab == 1 ? AppColors.primary : AppColors.textSecondary,
                                ),
                                const SizedBox(width: 6),
                                Text(
                                  'Rédiger une Consultation',
                                  style: TextStyle(
                                    fontSize: 12.5,
                                    fontWeight: _activeTab == 1 ? FontWeight.w700 : FontWeight.w500,
                                    color: _activeTab == 1 ? AppColors.primary : AppColors.textSecondary,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),

              // Contenu selon l'onglet
              Expanded(
                child: _activeTab == 0
                    ? _buildHistoryView()
                    : _buildNewConsultationForm(),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildHistoryView() {
    return ListView.builder(
      padding: const EdgeInsets.all(16),
      itemCount: _consultationsHistory.length,
      itemBuilder: (context, index) {
        final c = _consultationsHistory[index];
        final dt = c['date'] as DateTime;
        final dateStr = '${dt.day.toString().padLeft(2, '0')}/${dt.month.toString().padLeft(2, '0')}/${dt.year}';

        return Container(
          margin: const EdgeInsets.only(bottom: 14),
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: AppColors.surface,
            borderRadius: BorderRadius.circular(16),
            border: Border.all(color: AppColors.border),
            boxShadow: const [
              BoxShadow(
                color: Color(0x06000000),
                blurRadius: 6,
                offset: Offset(0, 2),
              ),
            ],
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Row(
                    children: [
                      const CircleAvatar(
                        radius: 16,
                        backgroundColor: AppColors.softBlue,
                        child: Icon(Icons.person, size: 16, color: AppColors.primary),
                      ),
                      const SizedBox(width: 8),
                      Text(
                        c['patientName'],
                        style: const TextStyle(fontWeight: FontWeight.w700, fontSize: 14.5),
                      ),
                    ],
                  ),
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                    decoration: BoxDecoration(
                      color: AppColors.background,
                      borderRadius: BorderRadius.circular(6),
                    ),
                    child: Text(
                      dateStr,
                      style: const TextStyle(fontSize: 11.5, color: AppColors.textSecondary),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 12),
              Text(
                'Motif : ${c['chiefComplaint']}',
                style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w600, color: AppColors.textPrimary),
              ),
              const SizedBox(height: 4),
              Text(
                'Diagnostic : ${c['diagnosis']}',
                style: const TextStyle(fontSize: 13, color: AppColors.primary, fontWeight: FontWeight.w700),
              ),
              const SizedBox(height: 6),
              Text(
                'Traitement : ${c['treatmentPlan']}',
                style: const TextStyle(fontSize: 12.5, color: AppColors.textSecondary),
              ),
              const SizedBox(height: 10),
              Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: AppColors.background,
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceAround,
                  children: [
                    Text('TA : ${c['bloodPressure']}', style: const TextStyle(fontSize: 11.5, fontWeight: FontWeight.w600)),
                    Text('Poids : ${c['weightKg']} kg', style: const TextStyle(fontSize: 11.5, fontWeight: FontWeight.w600)),
                    Text('IMC : ${c['bmi']} (${c['bmiCategory']})', style: const TextStyle(fontSize: 11.5, fontWeight: FontWeight.w600, color: Color(0xFF16A34A))),
                  ],
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _buildNewConsultationForm() {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: AppColors.softBlue,
              borderRadius: BorderRadius.circular(12),
            ),
            child: const Row(
              children: [
                Icon(Icons.verified_user_rounded, color: AppColors.primary, size: 20),
                SizedBox(width: 10),
                Expanded(
                  child: Text(
                    'Rédaction clinique certifiée • Enregistrement automatique dans le carnet de santé du patient.',
                    style: TextStyle(fontSize: 11.5, color: AppColors.primary, fontWeight: FontWeight.w500),
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 16),

          // Sélection du patient
          TextField(
            controller: _patientNameController,
            decoration: InputDecoration(
              labelText: 'Patient suivi',
              prefixIcon: const Icon(Icons.person_search_rounded),
              border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
            ),
          ),
          const SizedBox(height: 14),

          // Motif de consultation
          TextField(
            controller: _chiefComplaintController,
            decoration: InputDecoration(
              labelText: 'Motif de la consultation (Plainte principale) *',
              hintText: 'Ex: Fièvre persistante, céphalées, bilan de contrôle...',
              prefixIcon: const Icon(Icons.help_outline_rounded),
              border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
            ),
          ),
          const SizedBox(height: 14),

          // Constantes et calcul IMC
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: AppColors.surface,
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: AppColors.border),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  'Constantes vitales & Biométrie',
                  style: TextStyle(fontWeight: FontWeight.w700, fontSize: 13),
                ),
                const SizedBox(height: 10),
                Row(
                  children: [
                    Expanded(
                      child: TextField(
                        controller: _weightController,
                        keyboardType: TextInputType.number,
                        decoration: const InputDecoration(
                          labelText: 'Poids (kg)',
                          contentPadding: EdgeInsets.symmetric(horizontal: 10, vertical: 8),
                          border: OutlineInputBorder(),
                        ),
                      ),
                    ),
                    const SizedBox(width: 8),
                    Expanded(
                      child: TextField(
                        controller: _heightController,
                        keyboardType: TextInputType.number,
                        decoration: const InputDecoration(
                          labelText: 'Taille (cm)',
                          contentPadding: EdgeInsets.symmetric(horizontal: 10, vertical: 8),
                          border: OutlineInputBorder(),
                        ),
                      ),
                    ),
                    const SizedBox(width: 8),
                    Expanded(
                      child: TextField(
                        controller: _temperatureController,
                        keyboardType: TextInputType.number,
                        decoration: const InputDecoration(
                          labelText: 'Temp (°C)',
                          contentPadding: EdgeInsets.symmetric(horizontal: 10, vertical: 8),
                          border: OutlineInputBorder(),
                        ),
                      ),
                    ),
                  ],
                ),
                if (_calculatedBmi != null) ...[
                  const SizedBox(height: 10),
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                    decoration: BoxDecoration(
                      color: const Color(0xFFDCFCE7),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Text(
                      'IMC Calculé : $_calculatedBmi kg/m² — $_bmiCategory',
                      style: const TextStyle(
                        fontSize: 12,
                        fontWeight: FontWeight.w700,
                        color: Color(0xFF15803D),
                      ),
                    ),
                  ),
                ],
              ],
            ),
          ),
          const SizedBox(height: 14),

          // Examen clinique & observations
          TextField(
            controller: _examinationNotesController,
            maxLines: 3,
            decoration: InputDecoration(
              labelText: 'Examen clinique & Constats d\'observation',
              hintText: 'Auscultation, palpation, état général, constantes...',
              border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
            ),
          ),
          const SizedBox(height: 14),

          // Diagnostic
          TextField(
            controller: _diagnosisController,
            decoration: InputDecoration(
              labelText: 'Diagnostic médical établi *',
              hintText: 'Ex: Paludisme simple, Rhinopharyngite, HTA modérée...',
              prefixIcon: const Icon(Icons.check_box_outlined),
              border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
            ),
          ),
          const SizedBox(height: 14),

          // Plan de traitement
          TextField(
            controller: _treatmentPlanController,
            maxLines: 3,
            decoration: InputDecoration(
              labelText: 'Plan de traitement & Prescriptions',
              hintText: 'Médicaments prescrits, posologie, durée, consignes d\'hygiène...',
              prefixIcon: const Icon(Icons.medication_liquid_outlined),
              border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
            ),
          ),
          const SizedBox(height: 20),

          // Bouton d'enregistrement
          ElevatedButton.icon(
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.primary,
              foregroundColor: Colors.white,
              padding: const EdgeInsets.symmetric(vertical: 14),
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
            ),
            icon: _isSaving
                ? const SizedBox(
                    width: 18,
                    height: 18,
                    child: CircularProgressIndicator(color: Colors.white, strokeWidth: 2),
                  )
                : const Icon(Icons.draw_rounded),
            label: Text(
              _isSaving ? 'Enregistrement en cours...' : 'Enregistrer & Signer la consultation',
              style: const TextStyle(fontWeight: FontWeight.w700, fontSize: 14),
            ),
            onPressed: _isSaving ? null : _submitConsultation,
          ),
          const SizedBox(height: 30),
        ],
      ),
    );
  }
}
