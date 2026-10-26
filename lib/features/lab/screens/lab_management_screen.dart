import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';
import '../../../core/routes/app_router.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_text_styles.dart';
import '../../../core/utils/id_generator.dart';
import '../../../models/lab_order.dart';
import '../../../providers/auth_provider.dart';
import '../../../services/lab_service.dart';

class LabManagementScreen extends StatefulWidget {
  const LabManagementScreen({super.key});

  @override
  State<LabManagementScreen> createState() => _LabManagementScreenState();
}

class _LabManagementScreenState extends State<LabManagementScreen> {
  final LabService _labService = LabService();
  List<LabOrder> _orders = [];
  bool _isLoading = true;
  String _selectedFilter = 'ALL'; // ALL, PENDING, VALIDATED

  @override
  void initState() {
    super.initState();
    _loadOrders();
  }

  Future<void> _loadOrders() async {
    setState(() => _isLoading = true);
    final orders = await _labService.getOrders();
    if (mounted) {
      setState(() {
        _orders = orders;
        _isLoading = false;
      });
    }
  }

  List<LabOrder> get _filteredOrders {
    if (_selectedFilter == 'PENDING') {
      return _orders.where((o) => o.status != 'VALIDATED').toList();
    }
    if (_selectedFilter == 'VALIDATED') {
      return _orders.where((o) => o.status == 'VALIDATED').toList();
    }
    return _orders;
  }

  Future<void> _dispatchResults(LabOrder order) async {
    try {
      await _labService.dispatchResultsToDoctorAndPatient(order);
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            backgroundColor: const Color(0xFF16A34A),
            behavior: SnackBarBehavior.floating,
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
            content: Row(
              children: [
                const Icon(Icons.check_circle_rounded, color: Colors.white),
                const SizedBox(width: 12),
                Expanded(
                  child: Text(
                    'Résultats transmis avec succès au ${order.prescriberName} et à ${order.patientName} !',
                    style: const TextStyle(fontWeight: FontWeight.w600),
                  ),
                ),
              ],
            ),
          ),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Erreur lors de la transmission : $e')),
        );
      }
    }
  }

  void _openValidationDialog(LabOrder order) {
    final user = context.read<AuthProvider>().user;
    final techId = user?.id.isNotEmpty == true ? user!.id : IdGenerator.generate('usr');
    final techName = user?.displayName.isNotEmpty == true ? user!.displayName : 'Technicien Laborantin';

    final textController = TextEditingController(
      text: order.results.isNotEmpty ? order.results.first.displayValue : 'Négatif',
    );
    bool isCritical = order.isCriticalAlert;

    showDialog(
      context: context,
      builder: (ctx) => StatefulBuilder(
        builder: (context, setModalState) => AlertDialog(
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
          title: Text(
            'Saisie & Validation Biologique',
            style: AppTextStyles.headingMedium.copyWith(color: AppColors.textPrimary),
          ),
          content: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  '${order.testName} (${order.orderCode})',
                  style: const TextStyle(fontWeight: FontWeight.w700, color: AppColors.primary),
                ),
                Text(
                  'Patient(e) : ${order.patientName}',
                  style: const TextStyle(fontSize: 13, color: AppColors.textSecondary),
                ),
                const SizedBox(height: 16),
                const Text(
                  'Résultat d\'analyse constaté :',
                  style: TextStyle(fontSize: 12.5, fontWeight: FontWeight.w600),
                ),
                const SizedBox(height: 6),
                TextField(
                  controller: textController,
                  decoration: InputDecoration(
                    hintText: 'Ex: POSITIF, 1.25 g/L, 12500 trophozoïtes/µL...',
                    border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                    contentPadding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
                  ),
                ),
                const SizedBox(height: 14),
                SwitchListTile(
                  contentPadding: EdgeInsets.zero,
                  title: const Text(
                    'Valeur biologique critique (Alerte rouge)',
                    style: TextStyle(fontSize: 13, fontWeight: FontWeight.w600),
                  ),
                  subtitle: const Text(
                    'Déclenchera une alerte prioritaire auprès du médecin.',
                    style: TextStyle(fontSize: 11, color: AppColors.textSecondary),
                  ),
                  value: isCritical,
                  activeThumbColor: const Color(0xFFDC2626),
                  onChanged: (val) {
                    setModalState(() => isCritical = val);
                  },
                ),
              ],
            ),
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
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
              ),
              onPressed: () async {
                Navigator.pop(ctx);
                final updatedResult = LabResultItem(
                  testCode: 'RESULT_MAIN',
                  testName: order.testName,
                  valueText: textController.text.trim(),
                  isAbnormal: isCritical,
                  isCritical: isCritical,
                  interpretation: isCritical ? 'Résultat critique nécessitant prise en charge' : 'Résultat conforme',
                );

                await _labService.validateResults(
                  orderId: order.id,
                  results: [updatedResult],
                  technicianId: techId,
                  technicianName: techName,
                  isCritical: isCritical,
                );

                await _loadOrders();
              },
              child: const Text('Valider l\'analyse'),
            ),
          ],
        ),
      ),
    );
  }

  void _openBookLabAppointmentModal() {
    final patientNameController = TextEditingController(text: 'Fatou Ouédraogo');
    final testNameController = TextEditingController(text: 'Prélèvement Sanguin & NFS');
    DateTime selectedDate = DateTime.now().add(const Duration(days: 1));
    String selectedSlot = '08:30 - 09:00';

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      builder: (ctx) => StatefulBuilder(
        builder: (context, setModalState) => Padding(
          padding: EdgeInsets.fromLTRB(20, 20, 20, MediaQuery.of(context).viewInsets.bottom + 24),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Text(
                'Fixer un rendez-vous d\'analyse médicale',
                style: AppTextStyles.headingMedium.copyWith(color: AppColors.textPrimary),
              ),
              const SizedBox(height: 6),
              const Text(
                'Planifiez le créneau de prélèvement pour le patient. Une notification lui sera envoyée.',
                style: TextStyle(fontSize: 12.5, color: AppColors.textSecondary),
              ),
              const SizedBox(height: 16),
              TextField(
                controller: patientNameController,
                decoration: InputDecoration(
                  labelText: 'Nom du patient',
                  prefixIcon: const Icon(Icons.person_outline),
                  border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                ),
              ),
              const SizedBox(height: 12),
              TextField(
                controller: testNameController,
                decoration: InputDecoration(
                  labelText: 'Nature de l\'analyse',
                  prefixIcon: const Icon(Icons.science_outlined),
                  border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                ),
              ),
              const SizedBox(height: 12),
              ListTile(
                contentPadding: EdgeInsets.zero,
                leading: const Icon(Icons.calendar_month, color: AppColors.primary),
                title: Text(
                  'Date : ${selectedDate.day}/${selectedDate.month}/${selectedDate.year}',
                  style: const TextStyle(fontWeight: FontWeight.w600, fontSize: 13.5),
                ),
                trailing: const Icon(Icons.arrow_forward_ios, size: 14),
                onTap: () async {
                  final picked = await showDatePicker(
                    context: context,
                    initialDate: selectedDate,
                    firstDate: DateTime.now(),
                    lastDate: DateTime.now().add(const Duration(days: 60)),
                  );
                  if (picked != null) {
                    setModalState(() => selectedDate = picked);
                  }
                },
              ),
              const SizedBox(height: 16),
              ElevatedButton.icon(
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.primary,
                  foregroundColor: Colors.white,
                  padding: const EdgeInsets.symmetric(vertical: 14),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
                ),
                icon: const Icon(Icons.check_circle_outline),
                label: const Text(
                  'Confirmer et notifier le patient',
                  style: TextStyle(fontWeight: FontWeight.w700),
                ),
                onPressed: () async {
                  final messenger = ScaffoldMessenger.of(context);
                  Navigator.pop(ctx);
                  await _labService.bookLabAppointment(
                    patientId: IdGenerator.patientId(),
                    patientName: patientNameController.text.trim(),
                    testName: testNameController.text.trim(),
                    date: selectedDate,
                    slot: selectedSlot,
                  );

                  if (mounted) {
                    messenger.showSnackBar(
                      SnackBar(
                        backgroundColor: AppColors.primary,
                        behavior: SnackBarBehavior.floating,
                        content: Text(
                          'Rendez-vous fixé pour ${patientNameController.text.trim()} le ${selectedDate.day}/${selectedDate.month} !',
                        ),
                      ),
                    );
                  }
                },
              ),
            ],
          ),
        ),
      ),
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
          'Laboratoire & Analyses (Laborantin)',
          style: AppTextStyles.headingMedium.copyWith(color: AppColors.textPrimary),
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh_rounded, color: AppColors.primary),
            onPressed: _loadOrders,
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton.extended(
        backgroundColor: AppColors.primary,
        icon: const Icon(Icons.add_task_rounded, color: Colors.white),
        label: const Text(
          'Fixer un rendez-vous',
          style: TextStyle(color: Colors.white, fontWeight: FontWeight.w700),
        ),
        onPressed: _openBookLabAppointmentModal,
      ),
      body: Center(
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 600),
          child: Column(
            children: [
              // 1. Filtres d'état des analyses
              Container(
                color: AppColors.surface,
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
                child: Row(
                  children: [
                    _buildFilterChip('Toutes', 'ALL'),
                    const SizedBox(width: 8),
                    _buildFilterChip('À analyser / En cours', 'PENDING'),
                    const SizedBox(width: 8),
                    _buildFilterChip('Validées', 'VALIDATED'),
                  ],
                ),
              ),

              // 2. Liste des analyses
              Expanded(
                child: _isLoading
                    ? const Center(child: CircularProgressIndicator())
                    : _filteredOrders.isEmpty
                        ? const Center(
                            child: Padding(
                              padding: EdgeInsets.all(32.0),
                              child: Text(
                                'Aucun dossier d\'analyse dans cette catégorie.',
                                style: TextStyle(color: AppColors.textSecondary),
                              ),
                            ),
                          )
                        : ListView.builder(
                            padding: const EdgeInsets.fromLTRB(16, 12, 16, 80),
                            itemCount: _filteredOrders.length,
                            itemBuilder: (context, index) {
                              final order = _filteredOrders[index];
                              return _buildLabOrderCard(order);
                            },
                          ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildFilterChip(String label, String value) {
    final isSelected = _selectedFilter == value;
    return GestureDetector(
      onTap: () => setState(() => _selectedFilter = value),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 7),
        decoration: BoxDecoration(
          color: isSelected ? AppColors.primary : AppColors.background,
          borderRadius: BorderRadius.circular(10),
          border: Border.all(
            color: isSelected ? AppColors.primary : AppColors.border,
          ),
        ),
        child: Text(
          label,
          style: TextStyle(
            fontSize: 12,
            fontWeight: isSelected ? FontWeight.w700 : FontWeight.w500,
            color: isSelected ? Colors.white : AppColors.textPrimary,
          ),
        ),
      ),
    );
  }

  Widget _buildLabOrderCard(LabOrder order) {
    final isValidated = order.isValidated;
    final isCritical = order.isCriticalAlert;

    return Container(
      margin: const EdgeInsets.only(bottom: 14),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: isCritical
              ? const Color(0xFFDC2626).withValues(alpha: 0.4)
              : AppColors.border,
          width: isCritical ? 1.5 : 1.0,
        ),
        boxShadow: const [
          BoxShadow(
            color: Color(0x06000000),
            blurRadius: 8,
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
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                decoration: BoxDecoration(
                  color: AppColors.softBlue,
                  borderRadius: BorderRadius.circular(6),
                ),
                child: Text(
                  order.orderCode,
                  style: const TextStyle(
                    fontSize: 11,
                    fontWeight: FontWeight.w700,
                    color: AppColors.primary,
                  ),
                ),
              ),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                decoration: BoxDecoration(
                  color: isValidated
                      ? const Color(0xFFDCFCE7)
                      : const Color(0xFFFEF3C7),
                  borderRadius: BorderRadius.circular(6),
                ),
                child: Text(
                  isValidated ? 'Validé' : 'En cours',
                  style: TextStyle(
                    fontSize: 11,
                    fontWeight: FontWeight.w700,
                    color: isValidated
                        ? const Color(0xFF15803D)
                        : const Color(0xFFB45309),
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 10),
          Text(
            order.testName,
            style: const TextStyle(
              fontSize: 15,
              fontWeight: FontWeight.w700,
              color: AppColors.textPrimary,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            'Patient(e) : ${order.patientName} • Prescrit par ${order.prescriberName}',
            style: const TextStyle(fontSize: 12.5, color: AppColors.textSecondary),
          ),
          if (order.clinicalIndication != null) ...[
            const SizedBox(height: 4),
            Text(
              'Indication : ${order.clinicalIndication}',
              style: const TextStyle(fontSize: 11.5, fontStyle: FontStyle.italic, color: AppColors.textSecondary),
            ),
          ],
          const SizedBox(height: 12),

          // Aperçu des résultats
          if (order.results.isNotEmpty) ...[
            Container(
              padding: const EdgeInsets.all(10),
              decoration: BoxDecoration(
                color: AppColors.background,
                borderRadius: BorderRadius.circular(10),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: order.results.map((r) {
                  return Padding(
                    padding: const EdgeInsets.symmetric(vertical: 2.0),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          r.testName,
                          style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w600),
                        ),
                        Text(
                          r.displayValue,
                          style: TextStyle(
                            fontSize: 12,
                            fontWeight: FontWeight.w700,
                            color: r.isCritical
                                ? const Color(0xFFDC2626)
                                : AppColors.textPrimary,
                          ),
                        ),
                      ],
                    ),
                  );
                }).toList(),
              ),
            ),
            const SizedBox(height: 12),
          ],

          // Barre d'actions du laborantin
          Wrap(
            spacing: 8,
            runSpacing: 8,
            children: [
              if (!isValidated)
                ElevatedButton.icon(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.primary,
                    foregroundColor: Colors.white,
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                    padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
                  ),
                  icon: const Icon(Icons.edit_note_rounded, size: 16),
                  label: const Text('Saisir & Valider'),
                  onPressed: () => _openValidationDialog(order),
                ),
              if (isValidated)
                ElevatedButton.icon(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFF16A34A),
                    foregroundColor: Colors.white,
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                    padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
                  ),
                  icon: const Icon(Icons.send_rounded, size: 16),
                  label: const Text('Déclencher l\'envoi au Dr & Patient'),
                  onPressed: () => _dispatchResults(order),
                ),
              OutlinedButton.icon(
                style: OutlinedButton.styleFrom(
                  foregroundColor: AppColors.primary,
                  side: const BorderSide(color: AppColors.border),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                  padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                ),
                icon: const Icon(Icons.chat_bubble_outline_rounded, size: 16),
                label: const Text('Écrire au docteur/patient'),
                onPressed: () {
                  context.push(AppRoutes.messages);
                },
              ),
            ],
          ),
        ],
      ),
    );
  }
}
