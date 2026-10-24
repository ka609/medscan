import 'package:flutter/material.dart';

import '../../../core/theme/app_colors.dart';
import 'service_item.dart';

class ServicesCard extends StatelessWidget {
  const ServicesCard({
    super.key,
    required this.services,
  });

  final List<ServiceItemData> services;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 14),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(22),
        border: Border.all(color: AppColors.border.withValues(alpha: 0.8)),
        boxShadow: const [
          BoxShadow(
            color: Color(0x0C0F172A),
            blurRadius: 20,
            spreadRadius: 0,
            offset: Offset(0, 8),
          ),
        ],
      ),
      child: GridView.builder(
        shrinkWrap: true,
        physics: const NeverScrollableScrollPhysics(),
        itemCount: services.length,
        padding: EdgeInsets.zero,
        gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
          crossAxisCount: 3,
          crossAxisSpacing: 8,
          mainAxisSpacing: 10,
          childAspectRatio: 1.05,
        ),
        itemBuilder: (context, index) {
          final service = services[index];
          return ServiceItem(item: service);
        },
      ),
    );
  }
}
