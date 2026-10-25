import 'package:flutter/material.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_text_styles.dart';
import '../../../models/grievance.dart';
import '../../../services/grievance_service.dart';

class GrievancesScreen extends StatefulWidget {
  const GrievancesScreen({super.key});

  @override
  State<GrievancesScreen> createState() => _GrievancesScreenState();
}

class _GrievancesScreenState extends State<GrievancesScreen> {
  final GrievanceService _grievanceService = GrievanceService();
  List<PatientGrievance> _grievances = [];
  bool _isLoading = true;
  int _selectedTabIndex = 0; // 0: Mes Réclamations, 1: Déposer un avis

  // Contrôleurs du formulaire
  final _formKey = GlobalKey<FormState>();
  final _doctorController = TextEditingController(text: 'Dr. Amadou Ouédraogo');
  final _hospitalController = TextEditingController(text: 'CHU Yalgado Ouédraogo');
  final _titleController = TextEditingController();
  final _descriptionController = TextEditingController();
  int _rating = 4;
  String _category = 'CARE_QUALITY';
  final String _severity = 'MEDIUM';
  String _grievanceType = 'FEEDBACK';

  @override
  void initState() {
    super.initState();
    _loadGrievances();
  }

  Future<void> _loadGrievances() async {
    setState(() => _isLoading = true);
    final items = await _grievanceService.getGrievances();
    if (mounted) {
      setState(() {
        _grievances = items;
        _isLoading = false;
      });
    }
  }

  Future<void> _submitGrievanceForm() async {
    if (!_formKey.currentState!.validate()) return;

    final newGrievance = await _grievanceService.submitGrievance({
      'grievanceType': _grievanceType,
      'category': _category,
      'rating': _rating,
      'severity': _severity,
      'title': _titleController.text.trim(),
      'description': _descriptionController.text.trim(),
      'doctorName': _doctorController.text.trim(),
      'hospitalName': _hospitalController.text.trim(),
      'patientName': 'Kaboré Souleymane',
    });

    setState(() {
      _grievances.insert(0, newGrievance);
      _selectedTabIndex = 0; // Retourner sur la liste
    });

    _titleController.clear();
    _descriptionController.clear();

    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Votre réclamation a été transmise à la Direction de l\'Hôpital !'),
          backgroundColor: AppColors.accentGreen,
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        backgroundColor: AppColors.surface,
        elevation: 0,
        title: Text(
          'Réclamations & Avis Médicaux',
          style: AppTextStyles.headingMedium.copyWith(color: AppColors.textPrimary),
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh_rounded, color: AppColors.primary),
            onPressed: _loadGrievances,
          ),
        ],
      ),
      body: Center(
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 520),
          child: Column(
            children: [
              // 1. Barre d'onglets (Mes Réclamations vs Nouveau Dépôt)
              Container(
                color: AppColors.surface,
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                child: Container(
                  height: 46,
                  padding: const EdgeInsets.all(4),
                  decoration: BoxDecoration(
                    color: AppColors.background,
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Row(
                    children: [
                      Expanded(
                        child: _buildSubTab(0, 'Mes Réclamations (${_grievances.length})'),
                      ),
                      Expanded(
                        child: _buildSubTab(1, 'Déposer un signalement'),
                      ),
                    ],
                  ),
                ),
              ),

              // 2. Bannière de déontologie
              Container(
                margin: const EdgeInsets.fromLTRB(16, 12, 16, 6),
                padding: const EdgeInsets.all(14),
                decoration: BoxDecoration(
                  gradient: const LinearGradient(
                    colors: [Color(0xFF8B5CF6), Color(0xFF6D28D9)],
                  ),
                  borderRadius: BorderRadius.circular(16),
                  boxShadow: const [
                    BoxShadow(
                      color: Color(0x1F8B5CF6),
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
                        Icons.rate_review_rounded,
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
                            'Écoute Usager & Déontologie',
                            style: TextStyle(
                              color: Colors.white,
                              fontSize: 14.5,
                              fontWeight: FontWeight.w700,
                            ),
                          ),
                          SizedBox(height: 3),
                          Text(
                            'Tout avis ou litige est directement instruit par la Direction Hospitalière (Admin) pour garantir la qualité des soins.',
                            style: TextStyle(
                              color: Color(0xFFEDE9FE),
                              fontSize: 11.5,
                              height: 1.35,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),

              // 3. Contenu de l'onglet actif
              Expanded(
                child: _selectedTabIndex == 0
                    ? _buildGrievancesList()
                    : _buildNewGrievanceForm(),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildSubTab(int index, String title) {
    final isSelected = _selectedTabIndex == index;
    return GestureDetector(
      onTap: () => setState(() => _selectedTabIndex = index),
      child: Container(
        decoration: BoxDecoration(
          color: isSelected ? AppColors.surface : Colors.transparent,
          borderRadius: BorderRadius.circular(8),
          boxShadow: isSelected
              ? const [
                  BoxShadow(
                    color: Color(0x0C000000),
                    blurRadius: 4,
                    offset: Offset(0, 1),
                  ),
                ]
              : null,
        ),
        alignment: Alignment.center,
        child: Text(
          title,
          style: TextStyle(
            fontSize: 12.5,
            fontWeight: isSelected ? FontWeight.w700 : FontWeight.w500,
            color: isSelected ? AppColors.primary : AppColors.textSecondary,
          ),
        ),
      ),
    );
  }

  Widget _buildGrievancesList() {
    if (_isLoading) {
      return const Center(child: CircularProgressIndicator());
    }

    if (_grievances.isEmpty) {
      return const Center(
        child: Text(
          'Aucune réclamation enregistrée.',
          style: TextStyle(color: AppColors.textSecondary),
        ),
      );
    }

    return RefreshIndicator(
      onRefresh: _loadGrievances,
      child: ListView.builder(
        padding: const EdgeInsets.all(16),
        itemCount: _grievances.length,
        itemBuilder: (context, index) {
          final grv = _grievances[index];
          return _GrievanceCard(grievance: grv);
        },
      ),
    );
  }

  Widget _buildNewGrievanceForm() {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Form(
        key: _formKey,
        child: Container(
          padding: const EdgeInsets.all(18),
          decoration: BoxDecoration(
            color: AppColors.surface,
            borderRadius: BorderRadius.circular(20),
            border: Border.all(color: AppColors.border),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text(
                'Type de déclaration',
                style: TextStyle(fontWeight: FontWeight.w700, fontSize: 13),
              ),
              const SizedBox(height: 8),
              Row(
                children: [
                  _buildTypeChip('FEEDBACK', 'Avis / Évaluation'),
                  const SizedBox(width: 8),
                  _buildTypeChip('COMPLAINT', 'Réclamation'),
                  const SizedBox(width: 8),
                  _buildTypeChip('INCIDENT', 'Incident'),
                ],
              ),
              const SizedBox(height: 16),

              const Text(
                'Note d\'appréciation globale',
                style: TextStyle(fontWeight: FontWeight.w700, fontSize: 13),
              ),
              const SizedBox(height: 6),
              Row(
                children: List.generate(5, (index) {
                  return IconButton(
                    padding: const EdgeInsets.symmetric(horizontal: 2),
                    constraints: const BoxConstraints(),
                    icon: Icon(
                      index < _rating ? Icons.star_rounded : Icons.star_outline_rounded,
                      color: AppColors.starGold,
                      size: 32,
                    ),
                    onPressed: () => setState(() => _rating = index + 1),
                  );
                }),
              ),
              const SizedBox(height: 14),

              const Text(
                'Catégorie de la réclamation',
                style: TextStyle(fontWeight: FontWeight.w700, fontSize: 13),
              ),
              const SizedBox(height: 6),
              DropdownButtonFormField<String>(
                initialValue: _category,
                items: const [
                  DropdownMenuItem(
                    value: 'CARE_QUALITY',
                    child: Text('Qualité des soins & prise en charge'),
                  ),
                  DropdownMenuItem(
                    value: 'DELAY_WAIT_TIME',
                    child: Text('Délai d\'attente excessif'),
                  ),
                  DropdownMenuItem(
                    value: 'BEHAVIOR_ETIQUETTE',
                    child: Text('Accueil & comportement du personnel'),
                  ),
                  DropdownMenuItem(
                    value: 'PRESCRIPTION_ISSUE',
                    child: Text('Ordonnance ou posologie contestée'),
                  ),
                  DropdownMenuItem(
                    value: 'ETHICAL_CONCERN',
                    child: Text('Déontologie & secret médical'),
                  ),
                  DropdownMenuItem(
                    value: 'OTHER',
                    child: Text('Autre motif'),
                  ),
                ],
                onChanged: (val) {
                  if (val != null) setState(() => _category = val);
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
              const SizedBox(height: 14),

              TextFormField(
                controller: _doctorController,
                decoration: InputDecoration(
                  labelText: 'Médecin concerné',
                  filled: true,
                  fillColor: AppColors.background,
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
                validator: (val) =>
                    val == null || val.trim().isEmpty ? 'Précisez le nom du médecin' : null,
              ),
              const SizedBox(height: 14),

              TextFormField(
                controller: _titleController,
                decoration: InputDecoration(
                  labelText: 'Titre ou objet du signalement',
                  hintText: 'Ex: Retard important en consultation',
                  filled: true,
                  fillColor: AppColors.background,
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
                validator: (val) =>
                    val == null || val.trim().isEmpty ? 'Précisez un titre' : null,
              ),
              const SizedBox(height: 14),

              TextFormField(
                controller: _descriptionController,
                maxLines: 4,
                decoration: InputDecoration(
                  labelText: 'Description détaillée des faits',
                  hintText: 'Détaillez avec précision ce qui s\'est passé lors de la consultation...',
                  filled: true,
                  fillColor: AppColors.background,
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
                validator: (val) =>
                    val == null || val.trim().length < 10 ? 'Description trop courte' : null,
              ),
              const SizedBox(height: 20),

              SizedBox(
                width: double.infinity,
                height: 50,
                child: ElevatedButton.icon(
                  onPressed: _submitGrievanceForm,
                  icon: const Icon(Icons.send_rounded, color: Colors.white),
                  label: const Text(
                    'Transmettre à la Direction',
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 15,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFF6D28D9),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(14),
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildTypeChip(String value, String label) {
    final isSelected = _grievanceType == value;
    return Expanded(
      child: GestureDetector(
        onTap: () => setState(() => _grievanceType = value),
        child: Container(
          padding: const EdgeInsets.symmetric(vertical: 8),
          decoration: BoxDecoration(
            color: isSelected ? const Color(0xFF8B5CF6) : AppColors.background,
            borderRadius: BorderRadius.circular(10),
            border: Border.all(
              color: isSelected ? const Color(0xFF6D28D9) : AppColors.border,
            ),
          ),
          alignment: Alignment.center,
          child: Text(
            label,
            textAlign: TextAlign.center,
            style: TextStyle(
              fontSize: 11.5,
              fontWeight: isSelected ? FontWeight.w700 : FontWeight.w500,
              color: isSelected ? Colors.white : AppColors.textSecondary,
            ),
          ),
        ),
      ),
    );
  }
}

class _GrievanceCard extends StatelessWidget {
  const _GrievanceCard({required this.grievance});

  final PatientGrievance grievance;

  @override
  Widget build(BuildContext context) {
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
                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                  decoration: BoxDecoration(
                    color: AppColors.softPurple,
                    borderRadius: BorderRadius.circular(6),
                  ),
                  child: Text(
                    grievance.categoryLabel,
                    style: const TextStyle(
                      color: Color(0xFF6D28D9),
                      fontSize: 11,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                ),
                const Spacer(),
                Text(
                  grievance.grievanceCode,
                  style: const TextStyle(
                    fontFamily: 'Courier',
                    fontSize: 11.5,
                    fontWeight: FontWeight.w700,
                    color: AppColors.textSecondary,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 10),
            Text(
              grievance.title,
              style: const TextStyle(
                fontSize: 15,
                fontWeight: FontWeight.w700,
                color: AppColors.textPrimary,
              ),
            ),
            const SizedBox(height: 4),
            Row(
              children: [
                Row(
                  children: List.generate(5, (index) {
                    return Icon(
                      index < grievance.rating ? Icons.star_rounded : Icons.star_outline_rounded,
                      color: AppColors.starGold,
                      size: 16,
                    );
                  }),
                ),
                const SizedBox(width: 8),
                Text(
                  '• ${grievance.doctorName}',
                  style: const TextStyle(
                    fontSize: 12,
                    fontWeight: FontWeight.w600,
                    color: AppColors.textSecondary,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 8),
            Text(
              grievance.description,
              style: const TextStyle(
                fontSize: 13,
                color: AppColors.textPrimary,
                height: 1.4,
              ),
            ),
            const SizedBox(height: 12),

            // Statut de traitement par la Direction
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: AppColors.background,
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: AppColors.border),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      const Icon(
                        Icons.admin_panel_settings_rounded,
                        size: 16,
                        color: Color(0xFF6D28D9),
                      ),
                      const SizedBox(width: 6),
                      Text(
                        'Statut Direction : ${grievance.statusLabel}',
                        style: const TextStyle(
                          fontSize: 12,
                          fontWeight: FontWeight.w700,
                          color: Color(0xFF6D28D9),
                        ),
                      ),
                    ],
                  ),
                  if (grievance.adminNotes != null) ...[
                    const SizedBox(height: 6),
                    Text(
                      'Avis de la Direction : ${grievance.adminNotes}',
                      style: const TextStyle(
                        fontSize: 12,
                        fontStyle: FontStyle.italic,
                        color: AppColors.textPrimary,
                      ),
                    ),
                  ],
                  if (grievance.adminActionTaken != null) ...[
                    const SizedBox(height: 4),
                    Text(
                      'Mesures prises : ${grievance.adminActionTaken}',
                      style: const TextStyle(
                        fontSize: 12,
                        fontWeight: FontWeight.w600,
                        color: AppColors.accentGreen,
                      ),
                    ),
                  ],
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
