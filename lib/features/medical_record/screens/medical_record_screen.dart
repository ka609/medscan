import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../../providers/patient_provider.dart';

class MedicalRecordScreen extends StatefulWidget {
  const MedicalRecordScreen({super.key});

  @override
  State<MedicalRecordScreen> createState() => _MedicalRecordScreenState();
}

class _MedicalRecordScreenState extends State<MedicalRecordScreen> {
  @override
  void initState() {
    super.initState();

    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<PatientProvider>().getMyRecord();
    });
  }

  @override
  Widget build(BuildContext context) {
    final provider = context.watch<PatientProvider>();

    return Scaffold(
      appBar: AppBar(title: const Text('Mon dossier médical')),
      body: _buildBody(provider),
    );
  }

  Widget _buildBody(PatientProvider provider) {
    if (provider.isLoading && provider.myRecord == null) {
      return const Center(child: CircularProgressIndicator());
    }

    if (provider.error != null && provider.myRecord == null) {
      return _buildError(provider.error!);
    }

    if (provider.myRecord == null) {
      return const Center(child: Text('Aucune donnée médicale disponible.'));
    }

    return RefreshIndicator(
      onRefresh: provider.getMyRecord,
      child: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          _buildPatientCard(),
          const SizedBox(height: 16),
          _buildSection(
            title: 'Informations médicales',
            icon: Icons.medical_information_outlined,
            child: _buildRecordData(provider.myRecord!),
          ),
        ],
      ),
    );
  }

  Widget _buildPatientCard() {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Row(
          children: [
            const CircleAvatar(radius: 32, child: Icon(Icons.person, size: 32)),
            const SizedBox(width: 16),
            Expanded(
              child: Text(
                'Mon dossier médical',
                style: Theme.of(
                  context,
                ).textTheme.titleLarge?.copyWith(fontWeight: FontWeight.bold),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSection({
    required String title,
    required IconData icon,
    required Widget child,
  }) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(icon),
                const SizedBox(width: 10),
                Text(
                  title,
                  style: Theme.of(context).textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),
            child,
          ],
        ),
      ),
    );
  }

  Widget _buildRecordData(Map<String, dynamic> record) {
    if (record.isEmpty) {
      return const Text('Aucune information disponible.');
    }

    return Column(
      children: record.entries.map((entry) {
        return Padding(
          padding: const EdgeInsets.symmetric(vertical: 6),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Expanded(
                flex: 2,
                child: Text(
                  _formatLabel(entry.key),
                  style: const TextStyle(fontWeight: FontWeight.w600),
                ),
              ),
              Expanded(flex: 3, child: Text(_formatValue(entry.value))),
            ],
          ),
        );
      }).toList(),
    );
  }

  Widget _buildError(String error) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Icon(Icons.error_outline, size: 48),
            const SizedBox(height: 16),
            Text(error, textAlign: TextAlign.center),
            const SizedBox(height: 16),
            ElevatedButton(
              onPressed: () {
                context.read<PatientProvider>().getMyRecord();
              },
              child: const Text('Réessayer'),
            ),
          ],
        ),
      ),
    );
  }

  String _formatLabel(String value) {
    final result = value.replaceAllMapped(
      RegExp(r'([A-Z])'),
      (match) => ' ${match.group(1)}',
    );

    if (result.isEmpty) {
      return result;
    }

    return result[0].toUpperCase() + result.substring(1);
  }

  String _formatValue(dynamic value) {
    if (value == null) {
      return '-';
    }

    if (value is List) {
      if (value.isEmpty) {
        return 'Aucun';
      }

      return value.join(', ');
    }

    if (value is Map) {
      return value.entries
          .map((entry) => '${entry.key}: ${entry.value}')
          .join(', ');
    }

    return value.toString();
  }
}
