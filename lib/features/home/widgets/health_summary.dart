import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../../../core/routes/app_router.dart';
import '../../../providers/patient_provider.dart';
import '../../../shared/widgets/app_panel.dart';
import '../../../shared/widgets/icon_badge.dart';

class HealthSummary extends StatelessWidget {
  final PatientProvider provider;
  final VoidCallback onRetry;

  const HealthSummary({
    super.key,
    required this.provider,
    required this.onRetry,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final cs = theme.colorScheme;

    if (provider.isLoading && provider.myRecord == null) {
      return const AppPanel(
        child: SizedBox(
          height: 90,
          child: Center(child: CircularProgressIndicator()),
        ),
      );
    }

    if (provider.error != null && provider.myRecord == null) {
      return AppPanel(
        child: Row(
          children: [
            Icon(Icons.cloud_off_outlined, color: cs.error),
            const SizedBox(width: 12),
            Expanded(
              child: Text(
                'Impossible de charger votre dossier médical.',
                style: theme.textTheme.bodyMedium,
              ),
            ),
            TextButton(onPressed: onRetry, child: const Text('Réessayer')),
          ],
        ),
      );
    }

    final record = provider.myRecord;

    if (record == null || record.isEmpty) {
      return AppPanel(
        child: Row(
          children: [
            const IconBadge(icon: Icons.medical_information_outlined),
            const SizedBox(width: 14),
            Expanded(
              child: Text(
                'Aucune donnée médicale disponible.',
                style: theme.textTheme.bodyMedium?.copyWith(
                  color: cs.onSurfaceVariant,
                ),
              ),
            ),
          ],
        ),
      );
    }

    return AppPanel(
      child: Row(
        children: [
          const IconBadge(icon: Icons.medical_information_outlined),
          const SizedBox(width: 14),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Mon dossier médical',
                  style: theme.textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.w700,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  'Votre dossier médical est disponible.',
                  style: theme.textTheme.bodySmall?.copyWith(
                    color: cs.onSurfaceVariant,
                  ),
                ),
              ],
            ),
          ),
          IconButton(
            onPressed: () {
              context.push(AppRoutes.medicalRecord);
            },
            icon: const Icon(Icons.arrow_forward_ios),
            tooltip: 'Consulter',
          ),
        ],
      ),
    );
  }
}