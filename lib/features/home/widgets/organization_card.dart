import 'package:flutter/material.dart';

import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_text_styles.dart';
import '../../../core/widgets/rating_badge.dart';

class OrganizationCard extends StatelessWidget {
  const OrganizationCard({
    super.key,
    required this.name,
    required this.type,
    this.address,
    this.imageUrl,
    this.rating = 4.8,
    this.reviewCount = 342,
    this.tagText = 'Urgences 24/7',
    this.onTap,
  });

  final String name;
  final String type;
  final String? address;
  final String? imageUrl;
  final double rating;
  final int reviewCount;
  final String tagText;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: AppColors.border.withValues(alpha: 0.8)),
        boxShadow: const [
          BoxShadow(
            color: Color(0x0A0F172A),
            blurRadius: 16,
            offset: Offset(0, 4),
          ),
        ],
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: onTap,
          borderRadius: BorderRadius.circular(20),
          child: Padding(
            padding: const EdgeInsets.all(14),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Illustration ou image de l'hôpital
                _buildThumbnail(),

                const SizedBox(width: 14),

                // Informations
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          Container(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 8,
                              vertical: 3,
                            ),
                            decoration: BoxDecoration(
                              color: AppColors.primaryContainer,
                              borderRadius: BorderRadius.circular(6),
                            ),
                            child: Text(
                              type.toUpperCase(),
                              style: const TextStyle(
                                color: AppColors.primary,
                                fontSize: 9.5,
                                fontWeight: FontWeight.w700,
                                letterSpacing: 0.4,
                              ),
                            ),
                          ),
                          const Spacer(),
                          Text(
                            tagText,
                            style: const TextStyle(
                              color: AppColors.accentGreen,
                              fontSize: 10.5,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ],
                      ),

                      const SizedBox(height: 6),

                      Text(
                        name,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: AppTextStyles.bodyMedium.copyWith(
                          color: AppColors.textPrimary,
                          fontWeight: FontWeight.w700,
                          fontSize: 15,
                        ),
                      ),

                      if (address != null) ...[
                        const SizedBox(height: 4),
                        Row(
                          children: [
                            const Icon(
                              Icons.location_on_outlined,
                              size: 14,
                              color: AppColors.textSecondary,
                            ),
                            const SizedBox(width: 4),
                            Expanded(
                              child: Text(
                                address!,
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                                style: AppTextStyles.caption.copyWith(
                                  fontSize: 12,
                                ),
                              ),
                            ),
                          ],
                        ),
                      ],

                      const SizedBox(height: 8),

                      // Note & bouton Détail
                      Row(
                        children: [
                          RatingBadge(
                            rating: rating,
                            reviewCount: reviewCount,
                          ),
                          const Spacer(),
                          Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Text(
                                'Détail',
                                style: AppTextStyles.bodySmall.copyWith(
                                  color: AppColors.primary,
                                  fontWeight: FontWeight.w700,
                                  fontSize: 12,
                                ),
                              ),
                              const SizedBox(width: 3),
                              const Icon(
                                Icons.arrow_forward_ios_rounded,
                                size: 10,
                                color: AppColors.primary,
                              ),
                            ],
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildThumbnail() {
    return Container(
      width: 78,
      height: 78,
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [
            AppColors.primaryContainer,
            AppColors.softBlue,
          ],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: AppColors.primary.withValues(alpha: 0.12),
          width: 1,
        ),
      ),
      child: Center(
        child: Container(
          width: 46,
          height: 46,
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(12),
            boxShadow: const [
              BoxShadow(
                color: Color(0x100F172A),
                blurRadius: 6,
                offset: Offset(0, 2),
              ),
            ],
          ),
          child: const Icon(
            Icons.local_hospital_rounded,
            color: AppColors.primary,
            size: 26,
          ),
        ),
      ),
    );
  }
}
