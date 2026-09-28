import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../../../core/routes/app_router.dart';

class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key});

  static const Color _primary = Color(0xFF1565C0);
  static const Color _background = Color(0xFFF4F7FB);
  static const Color _textDark = Color(0xFF1F2937);
  static const Color _textMuted = Color(0xFF6B7280);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: _background,
      appBar: AppBar(
        backgroundColor: _primary,
        foregroundColor: Colors.white,
        elevation: 0,
        toolbarHeight: 92,
        automaticallyImplyLeading: false,
        shape: const RoundedRectangleBorder(
          borderRadius: BorderRadius.vertical(bottom: Radius.circular(28)),
        ),
        titleSpacing: 20,
        title: Row(
          children: [
            const CircleAvatar(
              radius: 26,
              backgroundColor: Colors.white,
              child: Icon(Icons.person_outline, size: 30, color: _primary),
            ),
            const SizedBox(width: 14),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(
                    'Bonjour,',
                    style: TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.w400,
                      color: Colors.white.withAlpha(215),
                    ),
                  ),
                  const SizedBox(height: 2),
                  const Text(
                    'Bienvenue sur MedScan',
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.w700,
                      color: Colors.white,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
        actions: [
          Padding(
            padding: const EdgeInsets.only(right: 16),
            child: Container(
              decoration: BoxDecoration(
                color: Colors.white.withAlpha(40),
                shape: BoxShape.circle,
              ),
              child: IconButton(
                icon: const Icon(Icons.notifications_outlined),
                color: Colors.white,
                onPressed: () {},
              ),
            ),
          ),
        ],
      ),
      body: SafeArea(
        child: ListView(
          padding: const EdgeInsets.fromLTRB(20, 24, 20, 24),
          children: [
            _buildSectionTitle('Mon espace'),
            const SizedBox(height: 14),
            Row(
              children: [
                Expanded(
                  child: _buildQuickCard(
                    icon: Icons.medical_information_outlined,
                    title: 'Dossier médical',
                    subtitle: 'Mes informations de santé',
                    onTap: () {
                      context.push(AppRoutes.medicalRecord);
                    },
                  ),
                ),
                const SizedBox(width: 14),
                Expanded(
                  child: _buildQuickCard(
                    icon: Icons.person_outline,
                    title: 'Mon profil',
                    subtitle: 'Mes informations personnelles',
                    onTap: () {
                      context.push(AppRoutes.profile);
                    },
                  ),
                ),
              ],
            ),
            const SizedBox(height: 28),
            _buildSectionTitle('Services'),
            const SizedBox(height: 14),
            _buildServiceTile(
              icon: Icons.local_hospital_outlined,
              title: 'Établissements de santé',
              subtitle: 'Trouver un hôpital ou une clinique',
              onTap: () {},
            ),
            _buildServiceTile(
              icon: Icons.calendar_month_outlined,
              title: 'Mes rendez-vous',
              subtitle: 'Consulter mes rendez-vous médicaux',
              onTap: () {},
            ),
            _buildServiceTile(
              icon: Icons.message_outlined,
              title: 'Mes messages',
              subtitle: 'Échanger avec les professionnels de santé',
              onTap: () {},
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSectionTitle(String title) {
    return Text(
      title,
      style: const TextStyle(
        fontSize: 18,
        fontWeight: FontWeight.w700,
        color: _textDark,
      ),
    );
  }

  Widget _buildIconBadge(IconData icon) {
    return Container(
      width: 46,
      height: 46,
      decoration: BoxDecoration(
        color: _primary.withAlpha(25),
        borderRadius: BorderRadius.circular(14),
      ),
      child: Icon(icon, color: _primary, size: 24),
    );
  }

  Widget _buildQuickCard({
    required IconData icon,
    required String title,
    required String subtitle,
    required VoidCallback onTap,
  }) {
    return Material(
      color: Colors.white,
      elevation: 0,
      borderRadius: BorderRadius.circular(18),
      shadowColor: Colors.black12,
      child: InkWell(
        borderRadius: BorderRadius.circular(18),
        onTap: onTap,
        child: Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(18),
            border: Border.all(color: const Color(0xFFE5EAF2)),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _buildIconBadge(icon),
              const SizedBox(height: 14),
              Text(
                title,
                style: const TextStyle(
                  fontSize: 15,
                  fontWeight: FontWeight.w700,
                  color: _textDark,
                ),
              ),
              const SizedBox(height: 4),
              Text(
                subtitle,
                style: const TextStyle(
                  fontSize: 12.5,
                  height: 1.3,
                  color: _textMuted,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildServiceTile({
    required IconData icon,
    required String title,
    required String subtitle,
    required VoidCallback onTap,
  }) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Material(
        color: Colors.white,
        borderRadius: BorderRadius.circular(18),
        child: InkWell(
          borderRadius: BorderRadius.circular(18),
          onTap: onTap,
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(18),
              border: Border.all(color: const Color(0xFFE5EAF2)),
            ),
            child: Row(
              children: [
                _buildIconBadge(icon),
                const SizedBox(width: 14),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        title,
                        style: const TextStyle(
                          fontSize: 15,
                          fontWeight: FontWeight.w600,
                          color: _textDark,
                        ),
                      ),
                      const SizedBox(height: 3),
                      Text(
                        subtitle,
                        style: const TextStyle(
                          fontSize: 12.5,
                          color: _textMuted,
                        ),
                      ),
                    ],
                  ),
                ),
                const Icon(Icons.chevron_right, color: _textMuted),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
