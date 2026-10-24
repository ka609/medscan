import 'package:flutter/material.dart';

import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_text_styles.dart';

class DepartmentCard extends StatelessWidget {
  const DepartmentCard({
    super.key,
    required this.name,
    required this.icon,
    this.doctorCount,
    this.color,
    this.backgroundColor,
    this.onTap,
  });

  final String name;
  final IconData icon;
  final int? doctorCount;
  final Color? color;
  final Color? backgroundColor;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    final primaryCol = color ?? AppColors.primary;
    final bgCol = backgroundColor ?? primaryCol.withValues(alpha: 0.10);

    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(20),
        child: Container(
          width: 114,
          padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 14),
          decoration: BoxDecoration(
            color: AppColors.surface,
            borderRadius: BorderRadius.circular(20),
            border: Border.all(color: AppColors.border.withValues(alpha: 0.8)),
            boxShadow: const [
              BoxShadow(
                color: Color(0x060F172A),
                blurRadius: 10,
                offset: Offset(0, 3),
              ),
            ],
          ),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              // Cercle moderne avec icône
              Container(
                width: 58,
                height: 58,
                decoration: BoxDecoration(
                  color: bgCol,
                  shape: BoxShape.circle,
                ),
                child: Center(
                  child: Container(
                    width: 44,
                    height: 44,
                    decoration: BoxDecoration(
                      color: primaryCol.withValues(alpha: 0.16),
                      shape: BoxShape.circle,
                    ),
                    child: Icon(
                      icon,
                      color: primaryCol,
                      size: 24,
                    ),
                  ),
                ),
              ),

              const SizedBox(height: 10),

              // Nom
              Text(
                name,
                textAlign: TextAlign.center,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: AppTextStyles.bodySmall.copyWith(
                  color: AppColors.textPrimary,
                  fontWeight: FontWeight.w700,
                  fontSize: 12.5,
                ),
              ),

              // Nombre de praticiens
              if (doctorCount != null) ...[
                const SizedBox(height: 4),
                Text(
                  '$doctorCount médecins',
                  textAlign: TextAlign.center,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: AppTextStyles.caption.copyWith(
                    color: AppColors.textSecondary,
                    fontSize: 10.5,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }
}
