import 'package:flutter/material.dart';

import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_text_styles.dart';

class ServiceItemData {
  const ServiceItemData({
    required this.icon,
    required this.title,
    this.badgeText,
    this.color = AppColors.primary,
    this.backgroundColor = AppColors.softBlue,
    this.onTap,
  });

  final IconData icon;
  final String title;
  final String? badgeText;
  final Color color;
  final Color backgroundColor;
  final VoidCallback? onTap;
}

class ServiceItem extends StatelessWidget {
  const ServiceItem({
    super.key,
    required this.item,
  });

  final ServiceItemData item;

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: item.onTap,
        borderRadius: BorderRadius.circular(16),
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 8),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Stack(
                clipBehavior: Clip.none,
                children: [
                  Container(
                    width: 58,
                    height: 58,
                    decoration: BoxDecoration(
                      color: item.backgroundColor,
                      borderRadius: BorderRadius.circular(18),
                      border: Border.all(
                        color: AppColors.primaryLight.withValues(alpha: 0.15),
                        width: 1,
                      ),
                    ),
                    child: Center(
                      child: Icon(
                        item.icon,
                        color: item.color,
                        size: 28,
                      ),
                    ),
                  ),
                  if (item.badgeText != null)
                    Positioned(
                      top: -4,
                      right: -6,
                      child: Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 6,
                          vertical: 2,
                        ),
                        decoration: BoxDecoration(
                          color: AppColors.primary,
                          borderRadius: BorderRadius.circular(10),
                          boxShadow: [
                            BoxShadow(
                              color: AppColors.primary.withValues(alpha: 0.3),
                              blurRadius: 4,
                              offset: const Offset(0, 2),
                            ),
                          ],
                        ),
                        child: Text(
                          item.badgeText!,
                          style: const TextStyle(
                            color: Colors.white,
                            fontSize: 9,
                            fontWeight: FontWeight.w700,
                          ),
                        ),
                      ),
                    ),
                ],
              ),
              const SizedBox(height: 8),
              Text(
                item.title,
                textAlign: TextAlign.center,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: AppTextStyles.bodySmall.copyWith(
                  color: AppColors.textPrimary,
                  fontWeight: FontWeight.w600,
                  fontSize: 12.5,
                  letterSpacing: -0.2,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
