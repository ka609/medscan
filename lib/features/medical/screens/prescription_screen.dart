import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../../providers/prescription_provider.dart';

class PrescriptionScreen extends StatefulWidget {
  const PrescriptionScreen({super.key});

  @override
  State<PrescriptionScreen> createState() => _PrescriptionScreenState();
}

class _PrescriptionScreenState extends State<PrescriptionScreen> {
  final _codeController = TextEditingController();

  @override
  void dispose() {
    _codeController.dispose();
    super.dispose();
  }

  Future<void> _search() async {
    final code = _codeController.text.trim();

    if (code.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Veuillez saisir le code de la prescription.'),
        ),
      );
      return;
    }

    await context.read<PrescriptionProvider>().getPrescription(code);
  }

  @override
  Widget build(BuildContext context) {
    final provider = context.watch<PrescriptionProvider>();

    return Scaffold(
      appBar: AppBar(title: const Text('Prescription')),
      body: ListView(
        padding: const EdgeInsets.all(20),
        children: [
          const Icon(Icons.receipt_long_outlined, size: 56),

          const SizedBox(height: 16),

          const Text(
            'Consulter une prescription',
            textAlign: TextAlign.center,
            style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold),
          ),

          const SizedBox(height: 8),

          const Text(
            'Saisissez le code de votre prescription.',
            textAlign: TextAlign.center,
          ),

          const SizedBox(height: 28),

          TextField(
            controller: _codeController,
            textInputAction: TextInputAction.search,
            decoration: const InputDecoration(
              labelText: 'Code de prescription',
              hintText: 'Exemple : RX-2026-001',
              prefixIcon: Icon(Icons.qr_code_2_outlined),
              border: OutlineInputBorder(),
            ),
            onSubmitted: (_) => _search(),
          ),

          const SizedBox(height: 16),

          SizedBox(
            height: 50,
            child: ElevatedButton.icon(
              onPressed: provider.isLoading ? null : _search,
              icon: provider.isLoading
                  ? const SizedBox(
                      width: 20,
                      height: 20,
                      child: CircularProgressIndicator(strokeWidth: 2),
                    )
                  : const Icon(Icons.search),
              label: const Text('Consulter'),
            ),
          ),

          if (provider.error != null) ...[
            const SizedBox(height: 20),
            _ErrorCard(message: provider.error!, onRetry: _search),
          ],

          if (provider.prescription != null) ...[
            const SizedBox(height: 24),
            _PrescriptionCard(prescription: provider.prescription!),
          ],
        ],
      ),
    );
  }
}

class _PrescriptionCard extends StatelessWidget {
  final dynamic prescription;

  const _PrescriptionCard({required this.prescription});

  @override
  Widget build(BuildContext context) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(18),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                const Icon(Icons.medication_outlined),
                const SizedBox(width: 10),
                Text(
                  'Prescription',
                  style: Theme.of(
                    context,
                  ).textTheme.titleLarge?.copyWith(fontWeight: FontWeight.bold),
                ),
              ],
            ),

            const Divider(height: 28),

            _InfoRow(
              label: 'Code',
              value: prescription.code?.toString() ?? '-',
            ),

            _InfoRow(
              label: 'Médicament',
              value: prescription.medicationName?.toString() ?? '-',
            ),

            _InfoRow(
              label: 'Dosage',
              value: prescription.dosage?.toString() ?? '-',
            ),

            _InfoRow(
              label: 'Fréquence',
              value: prescription.frequency?.toString() ?? '-',
            ),

            _InfoRow(
              label: 'Durée',
              value: prescription.durationDays?.toString() ?? '-',
            ),

            _InfoRow(
              label: 'Instructions',
              value: prescription.instructions?.toString() ?? '-',
            ),
          ],
        ),
      ),
    );
  }
}

class _InfoRow extends StatelessWidget {
  final String label;
  final String value;

  const _InfoRow({required this.label, required this.value});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(label, style: const TextStyle(fontWeight: FontWeight.w600)),
          const SizedBox(height: 3),
          Text(value),
        ],
      ),
    );
  }
}

class _ErrorCard extends StatelessWidget {
  final String message;
  final VoidCallback onRetry;

  const _ErrorCard({required this.message, required this.onRetry});

  @override
  Widget build(BuildContext context) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            const Icon(Icons.error_outline, size: 40),
            const SizedBox(height: 8),
            Text(message, textAlign: TextAlign.center),
            const SizedBox(height: 12),
            TextButton(onPressed: onRetry, child: const Text('Réessayer')),
          ],
        ),
      ),
    );
  }
}
