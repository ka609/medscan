import 'package:flutter/material.dart';

import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_text_styles.dart';

class HomeHeader extends StatelessWidget {
  const HomeHeader({
    super.key,
    required this.name,
    this.userRole,
    this.onProfileTap,
    this.onSearchTap,
    this.onNotificationTap,
    this.notificationCount = 0,
  });

  final String name;
  final String? userRole;
  final VoidCallback? onProfileTap;
  final VoidCallback? onSearchTap;
  final VoidCallback? onNotificationTap;
  final int notificationCount;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.fromLTRB(20, 24, 20, 28),
      decoration: const BoxDecoration(
        gradient: LinearGradient(
          colors: [
            AppColors.primaryGradientStart,
            AppColors.primaryGradientEnd,
          ],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.vertical(
          bottom: Radius.circular(32),
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              // Avatar
              GestureDetector(
                onTap: onProfileTap,
                child: Container(
                  width: 52,
                  height: 52,
                  decoration: BoxDecoration(
                    color: Colors.white,
                    shape: BoxShape.circle,
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withValues(alpha: 0.12),
                        blurRadius: 10,
                        offset: const Offset(0, 3),
                      ),
                    ],
                  ),
                  child: Center(
                    child: Text(
                      _getInitials(name),
                      style: const TextStyle(
                        color: AppColors.primary,
                        fontSize: 20,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                  ),
                ),
              ),

              const SizedBox(width: 14),

              // Informations utilisateur
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Bonjour,',
                      style: AppTextStyles.bodySmall.copyWith(
                        color: Colors.white.withValues(alpha: 0.85),
                        fontWeight: FontWeight.w400,
                        fontSize: 13,
                      ),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      name,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: AppTextStyles.userName.copyWith(
                        fontSize: 19,
                        letterSpacing: -0.3,
                      ),
                    ),
                    if (userRole != null && userRole!.isNotEmpty) ...[
                      const SizedBox(height: 2),
                      Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 8,
                          vertical: 2,
                        ),
                        decoration: BoxDecoration(
                          color: Colors.white.withValues(alpha: 0.20),
                          borderRadius: BorderRadius.circular(6),
                        ),
                        child: Text(
                          userRole!,
                          style: const TextStyle(
                            color: Colors.white,
                            fontSize: 11,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ),
                    ],
                  ],
                ),
              ),

              // Boutons d'action modernes
              Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  _HeaderIconButton(
                    icon: Icons.search_rounded,
                    tooltip: 'Recherche',
                    onTap: onSearchTap,
                  ),
                  const SizedBox(width: 8),
                  _HeaderNotificationButton(
                    count: notificationCount,
                    onTap: onNotificationTap,
                  ),
                ],
              ),
            ],
          ),

          const SizedBox(height: 20),

          // Barre de recherche intégrée moderne
          InkWell(
            onTap: onSearchTap,
            borderRadius: BorderRadius.circular(16),
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 13),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(16),
                boxShadow: const [
                  BoxShadow(
                    color: Color(0x140F172A),
                    blurRadius: 14,
                    offset: Offset(0, 4),
                  ),
                ],
              ),
              child: Row(
                children: [
                  const Icon(
                    Icons.search_rounded,
                    color: AppColors.primary,
                    size: 22,
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Text(
                      'Rechercher un médecin, hôpital, analyse...',
                      style: AppTextStyles.bodyRegular.copyWith(
                        color: AppColors.textMuted,
                        fontSize: 13.5,
                      ),
                    ),
                  ),
                  Container(
                    padding: const EdgeInsets.all(6),
                    decoration: BoxDecoration(
                      color: AppColors.primaryContainer,
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: const Icon(
                      Icons.tune_rounded,
                      color: AppColors.primary,
                      size: 16,
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  String _getInitials(String value) {
    final parts = value.trim().split(' ');
    if (parts.length >= 2) {
      return '${parts[0][0]}${parts[1][0]}'.toUpperCase();
    }
    return value.isNotEmpty ? value[0].toUpperCase() : 'M';
  }
}

class _HeaderIconButton extends StatelessWidget {
  const _HeaderIconButton({
    required this.icon,
    required this.tooltip,
    this.onTap,
  });

  final IconData icon;
  final String tooltip;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.white.withValues(alpha: 0.18),
      shape: const CircleBorder(),
      child: InkWell(
        customBorder: const CircleBorder(),
        onTap: onTap,
        child: Padding(
          padding: const EdgeInsets.all(10),
          child: Icon(icon, color: Colors.white, size: 21),
        ),
      ),
    );
  }
}

class _HeaderNotificationButton extends StatelessWidget {
  const _HeaderNotificationButton({
    required this.count,
    this.onTap,
  });

  final int count;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    return Stack(
      clipBehavior: Clip.none,
      children: [
        Material(
          color: Colors.white.withValues(alpha: 0.18),
          shape: const CircleBorder(),
          child: InkWell(
            customBorder: const CircleBorder(),
            onTap: onTap,
            child: const Padding(
              padding: EdgeInsets.all(10),
              child: Icon(
                Icons.notifications_none_rounded,
                color: Colors.white,
                size: 21,
              ),
            ),
          ),
        ),
        if (count > 0)
          Positioned(
            right: 0,
            top: 0,
            child: Container(
              padding: const EdgeInsets.all(4),
              decoration: BoxDecoration(
                color: AppColors.accentRed,
                shape: BoxShape.circle,
                border: Border.all(color: Colors.white, width: 2),
              ),
              constraints: const BoxConstraints(minWidth: 18, minHeight: 18),
              child: Center(
                child: Text(
                  count > 9 ? '9+' : '$count',
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 9.5,
                    fontWeight: FontWeight.w700,
                    height: 1,
                  ),
                ),
              ),
            ),
          ),
      ],
    );
  }
}
