import 'package:flutter/material.dart';
import '../theme/app_colors.dart';
import '../theme/app_text_styles.dart';

/// Reproduit le badge "★ 4.8 (456 Reviews)" vu sur les cards
/// hôpital / médecin des maquettes.
class RatingBadge extends StatelessWidget {
  const RatingBadge({
    super.key,
    required this.rating,
    this.reviewCount,
  });

  final double rating;
  final int? reviewCount;

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        const Icon(Icons.star_rounded, size: 16, color: AppColors.star),
        const SizedBox(width: 4),
        Text(rating.toStringAsFixed(1), style: AppTextStyles.bodyMedium),
        if (reviewCount != null) ...[
          const SizedBox(width: 4),
          Text('($reviewCount Reviews)', style: AppTextStyles.caption),
        ],
      ],
    );
  }
}
