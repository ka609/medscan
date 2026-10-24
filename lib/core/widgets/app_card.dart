import 'package:flutter/material.dart';
import '../theme/app_colors.dart';

class AppCard extends StatelessWidget {
  const AppCard({
    super.key,
    required this.child,
    this.padding = const EdgeInsets.all(16),
    this.borderRadius = 18,
    this.hasShadow = true,
    this.hasBorder = true,
    this.backgroundColor = AppColors.surface,
    this.onTap,
  });

  final Widget child;
  final EdgeInsetsGeometry padding;
  final double borderRadius;
  final bool hasShadow;
  final bool hasBorder;
  final Color backgroundColor;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: backgroundColor,
        borderRadius: BorderRadius.circular(borderRadius),
        border: hasBorder ? Border.all(color: AppColors.border, width: 1) : null,
        boxShadow: hasShadow
            ? const [
                BoxShadow(
                  color: AppColors.shadow,
                  blurRadius: 16,
                  offset: Offset(0, 4),
                ),
              ]
            : null,
      ),
      child: Material(
        color: Colors.transparent,
        borderRadius: BorderRadius.circular(borderRadius),
        child: InkWell(
          onTap: onTap,
          borderRadius: BorderRadius.circular(borderRadius),
          child: Padding(
            padding: padding,
            child: child,
          ),
        ),
      ),
    );
  }
}
