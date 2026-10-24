import 'package:flutter/material.dart';
import '../theme/app_colors.dart';
import '../theme/app_text_styles.dart';

/// Reproduit le badge "★ 4.8 (456 Reviews)" des cartes hôpital / médecin.
class RatingBadge extends StatelessWidget {
  const RatingBadge({
    super.key,
    required this.rating,
    this.reviewCount,
    this.showBackground = false,
  });

  final double rating;
  final int? reviewCount;
  final bool showBackground;

  @override
  Widget build(BuildContext context) {
    final content = Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        const Icon(Icons.star_rounded, size: 16, color: AppColors.star),
        const SizedBox(width: 4),
        Text(
          rating.toStringAsFixed(1),
          style: AppTextStyles.bodyMedium.copyWith(
            fontWeight: FontWeight.w700,
            fontSize: 12.5,
          ),
        ),
        if (reviewCount != null) ...[
          const SizedBox(width: 4),
          Text(
            '($reviewCount avis)',
            style: AppTextStyles.caption.copyWith(fontSize: 11),
          ),
        ],
      ],
    );

    if (!showBackground) return content;

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: AppColors.badgeRatingBg,
        borderRadius: BorderRadius.circular(8),
      ),
      child: content,
    );
  }
}
