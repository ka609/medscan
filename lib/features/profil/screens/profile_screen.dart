import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../../providers/auth_provider.dart';

class ProfileScreen extends StatefulWidget {
  const ProfileScreen({super.key});

  @override
  State<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  @override
  void initState() {
    super.initState();

    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<AuthProvider>().loadMe();
    });
  }

  @override
  Widget build(BuildContext context) {
    final provider = context.watch<AuthProvider>();
    final user = provider.user;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Mon profil'),
      ),
      body: RefreshIndicator(
        onRefresh: () => provider.loadMe(),
        child: ListView(
          padding: const EdgeInsets.all(20),
          children: [
            _buildHeader(context, user),
            const SizedBox(height: 24),
            _buildSection(
              context,
              title: 'Informations personnelles',
              children: [
                _buildInfo(
                  icon: Icons.person_outline,
                  label: 'Nom d’utilisateur',
                  value: user?.username ?? '-',
                ),
                _buildInfo(
                  icon: Icons.email_outlined,
                  label: 'Email',
                  value: user?.email ?? '-',
                ),
                _buildInfo(
                  icon: Icons.badge_outlined,
                  label: 'Rôle',
                  value: user?.roles.join(', ') ?? '-',
                ),
              ],
            ),
            const SizedBox(height: 16),
            _buildSection(
              context,
              title: 'Organisation',
              children: [
                _buildInfo(
                  icon: Icons.business_outlined,
                  label: 'Organisation',
                  value: user?.tenantCode ?? '-',
                ),
              ],
            ),
            if (provider.error != null) ...[
              const SizedBox(height: 20),
              _buildError(context, provider.error!),
            ],
          ],
        ),
      ),
    );
  }

  Widget _buildHeader(BuildContext context, dynamic user) {
    return Column(
      children: [
        CircleAvatar(
          radius: 44,
          child: Text(
            _initials(user?.displayName ?? user?.username ?? 'U'),
            style: const TextStyle(
              fontSize: 28,
              fontWeight: FontWeight.bold,
            ),
          ),
        ),
        const SizedBox(height: 12),
        Text(
          user?.displayName ?? 'Utilisateur',
          style: Theme.of(context).textTheme.titleLarge?.copyWith(
                fontWeight: FontWeight.bold,
              ),
          textAlign: TextAlign.center,
        ),
        const SizedBox(height: 4),
        Text(
          user?.username ?? '',
          style: Theme.of(context).textTheme.bodyMedium,
        ),
      ],
    );
  }

  Widget _buildSection(
    BuildContext context, {
    required String title,
    required List<Widget> children,
  }) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              title,
              style: Theme.of(context).textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
            ),
            const SizedBox(height: 12),
            ...children,
          ],
        ),
      ),
    );
  }

  Widget _buildInfo({
    required IconData icon,
    required String label,
    required String value,
  }) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: Row(
        children: [
          Icon(icon),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  label,
                  style: const TextStyle(
                    fontSize: 12,
                    color: Colors.grey,
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  value,
                  style: const TextStyle(
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildError(BuildContext context, String error) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Row(
          children: [
            const Icon(Icons.error_outline),
            const SizedBox(width: 12),
            Expanded(child: Text(error)),
          ],
        ),
      ),
    );
  }

  String _initials(String value) {
    final parts = value.trim().split(' ');

    if (parts.length >= 2) {
      return '${parts[0][0]}${parts[1][0]}'.toUpperCase();
    }

    return value.isNotEmpty ? value[0].toUpperCase() : 'U';
  }
}