// lib/shared/widgets/grid_menu.dart
import 'package:flutter/material.dart';
import '../../core/theme/app_colors.dart';
import '../../core/theme/app_text_styles.dart';

class GridMenuItem {
  final String label;
  final IconData icon;

  const GridMenuItem({required this.label, required this.icon});
}

class GridMenu extends StatelessWidget {
  final List<GridMenuItem> items;
  final ValueChanged<GridMenuItem> onTap;
  final int crossAxisCount;

  const GridMenu({
    super.key,
    required this.items,
    required this.onTap,
    this.crossAxisCount = 3, // comme la maquette : 3 colonnes
  });

  // Constantes de layout locales (centrées ici)
  static const double _radius = 18;
  static const double _crossSpacing = 10;
  static const double _mainSpacing = 10;
  static const double _paddingH = 6;
  static const double _paddingV = 10;
  static const double _iconSize = 46;
  static const double _labelGap = 8;

  @override
  Widget build(BuildContext context) {
    return GridView.builder(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      itemCount: items.length,
      gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: crossAxisCount,
        crossAxisSpacing: _crossSpacing,
        mainAxisSpacing: _mainSpacing,
        childAspectRatio: 0.82,
      ),
      itemBuilder: (context, index) {
        final item = items[index];

        return Material(
          color: AppColors.surface,
          borderRadius: BorderRadius.circular(_radius),
          child: InkWell(
            onTap: () => onTap(item),
            borderRadius: BorderRadius.circular(_radius),
            splashColor: AppColors.chipBackground,
            child: Container(
              padding: const EdgeInsets.symmetric(
                horizontal: _paddingH,
                vertical: _paddingV,
              ),
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(_radius),
                border: Border.all(color: AppColors.border),
                boxShadow: const [
                  BoxShadow(
                    color: AppColors.shadow,
                    blurRadius: 8,
                    offset: Offset(0, 2),
                  ),
                ],
              ),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Container(
                    width: _iconSize,
                    height: _iconSize,
                    decoration: const BoxDecoration(
                      color: AppColors.chipBackground,
                      shape: BoxShape.circle,
                    ),
                    child: const Icon(
                      Icons.medical_services_outlined, // placeholder
                      color: AppColors.primary,
                      size: 22,
                    ),
                  ),
                  const SizedBox(height: _labelGap),
                  Text(
                    item.label,
                    textAlign: TextAlign.center,
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                    style: AppTextStyles.labelMedium,
                  ),
                ],
              ),
            ),
          ),
        );
      },
    );
  }
}
