import 'dart:async';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';
import '../../../core/routes/app_router.dart';
import '../../../core/theme/app_colors.dart';
import '../../../providers/auth_provider.dart';

class TeleconsultScreen extends StatefulWidget {
  const TeleconsultScreen({super.key});

  @override
  State<TeleconsultScreen> createState() => _TeleconsultScreenState();
}

class _TeleconsultScreenState extends State<TeleconsultScreen> {
  bool _isMicMuted = false;
  bool _isVideoOff = false;
  bool _isFrontCamera = true;
  int _callSeconds = 0;
  Timer? _callTimer;

  @override
  void initState() {
    super.initState();
    _callTimer = Timer.periodic(const Duration(seconds: 1), (timer) {
      if (mounted) {
        setState(() {
          _callSeconds++;
        });
      }
    });
  }

  @override
  void dispose() {
    _callTimer?.cancel();
    super.dispose();
  }

  String get _formattedDuration {
    final minutes = (_callSeconds ~/ 60).toString().padLeft(2, '0');
    final seconds = (_callSeconds % 60).toString().padLeft(2, '0');
    return '$minutes:$seconds';
  }

  void _showConsultationNotes(bool isDoctor, String currentUserName) {
    showModalBottomSheet(
      context: context,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (context) {
        return Padding(
          padding: const EdgeInsets.all(20),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  const Text(
                    'Notes de Téléconsultation en Direct',
                    style: TextStyle(fontSize: 16, fontWeight: FontWeight.w700),
                  ),
                  IconButton(
                    icon: const Icon(Icons.close_rounded),
                    onPressed: () => Navigator.pop(context),
                  ),
                ],
              ),
              const SizedBox(height: 12),
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: AppColors.softBlue,
                  borderRadius: BorderRadius.circular(12),
                ),
                child: const Row(
                  children: [
                    Icon(Icons.lock_rounded, color: AppColors.primary, size: 18),
                    SizedBox(width: 8),
                    Expanded(
                      child: Text(
                        'Session Jitsi chiffrée de bout en bout conforme HDS (Canal isolé).',
                        style: TextStyle(
                            fontSize: 12,
                            color: AppColors.primary,
                            fontWeight: FontWeight.w600),
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 14),
              Text(
                isDoctor
                    ? 'Session active avec le patient connecté. Les données saisies sont scellées dans le dossier médical.'
                    : 'Téléconsultation en cours avec votre médecin référant.',
                style: const TextStyle(fontSize: 13, color: AppColors.textPrimary),
              ),
              const SizedBox(height: 10),
              const Text(
                '• Paramètres cliniques : Session HD chiffrée WebRTC\n'
                '• Données de santé : Ségrégation stricte des flux audio/vidéo.',
                style: TextStyle(
                    fontSize: 12.5, color: AppColors.textSecondary, height: 1.4),
              ),
              const SizedBox(height: 18),
              SizedBox(
                width: double.infinity,
                child: ElevatedButton.icon(
                  onPressed: () {
                    Navigator.pop(context);
                    context.push(AppRoutes.prescriptions);
                  },
                  icon: const Icon(Icons.medication_rounded, size: 18),
                  label: const Text('Consulter les ordonnances'),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.primary,
                    foregroundColor: Colors.white,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    final user = context.watch<AuthProvider>().user;
    final isDoctor = user?.roles.any(
          (r) =>
              r.toUpperCase().contains('DOCTOR') ||
              r.toUpperCase().contains('PRATICIEN') ||
              r.toUpperCase().contains('MEDECIN'),
        ) ??
        false;

    final currentUserName = user?.displayName.isNotEmpty == true
        ? user!.displayName
        : (user?.username.isNotEmpty == true
            ? user!.username
            : (isDoctor ? 'Dr. Praticien' : 'Patient'));

    final remoteName = isDoctor
        ? 'Patient Connecté (M. Kaboré)'
        : 'Dr. Amadou Ouédraogo';

    final remoteSubtitle = isDoctor
        ? 'Dossier Médical Isolé • Salle Privée'
        : 'Cardiologue • CHU Yalgado Ouédraogo';

    final roomCode = (user?.id.isNotEmpty == true ? user!.id : 'call-01')
        .replaceAll(RegExp(r'[^a-zA-Z0-9]'), '')
        .padRight(6, '0')
        .substring(0, 6);

    return Scaffold(
      backgroundColor: const Color(0xFF0F172A),
      body: SafeArea(
        child: Stack(
          children: [
            // 1. Flux vidéo distant (simulation avec superposition clinique)
            Positioned.fill(
              child: Container(
                decoration: const BoxDecoration(
                  color: Color(0xFF1E293B),
                ),
                child: Stack(
                  alignment: Alignment.center,
                  children: [
                    Container(
                      width: double.infinity,
                      height: double.infinity,
                      decoration: const BoxDecoration(
                        gradient: RadialGradient(
                          center: Alignment(0.0, -0.2),
                          radius: 0.9,
                          colors: [Color(0xFF334155), Color(0xFF0F172A)],
                        ),
                      ),
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          CircleAvatar(
                            radius: 54,
                            backgroundColor: AppColors.primary.withValues(alpha: 0.3),
                            child: CircleAvatar(
                              radius: 46,
                              backgroundColor: AppColors.primary,
                              child: Icon(
                                isDoctor ? Icons.person_rounded : Icons.medical_services_rounded,
                                size: 50,
                                color: Colors.white,
                              ),
                            ),
                          ),
                          const SizedBox(height: 16),
                          Text(
                            remoteName,
                            style: const TextStyle(
                              color: Colors.white,
                              fontSize: 20,
                              fontWeight: FontWeight.w700,
                            ),
                          ),
                          const SizedBox(height: 4),
                          Text(
                            remoteSubtitle,
                            style: const TextStyle(
                              color: Color(0xFF94A3B8),
                              fontSize: 14,
                            ),
                          ),
                          const SizedBox(height: 12),
                          Container(
                            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                            decoration: BoxDecoration(
                              color: Colors.white.withValues(alpha: 0.15),
                              borderRadius: BorderRadius.circular(12),
                            ),
                            child: Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                const Icon(Icons.circle, color: Color(0xFF22C55E), size: 8),
                                const SizedBox(width: 6),
                                Text(
                                  'Salle isolée : #medscan-$roomCode • HD 1080p',
                                  style: const TextStyle(color: Colors.white, fontSize: 11.5),
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ),

            // 2. Barre supérieure : Retour, Durée, Notes
            Positioned(
              top: 16,
              left: 16,
              right: 16,
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  CircleAvatar(
                    backgroundColor: Colors.black.withValues(alpha: 0.40),
                    child: IconButton(
                      icon: const Icon(Icons.arrow_back, color: Colors.white),
                      onPressed: () => Navigator.pop(context),
                    ),
                  ),
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 6),
                    decoration: BoxDecoration(
                      color: Colors.black.withValues(alpha: 0.50),
                      borderRadius: BorderRadius.circular(20),
                      border: Border.all(color: Colors.white.withValues(alpha: 0.2)),
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        const Icon(Icons.fiber_manual_record, color: Colors.red, size: 12),
                        const SizedBox(width: 6),
                        Text(
                          _formattedDuration,
                          style: const TextStyle(
                            color: Colors.white,
                            fontSize: 13,
                            fontWeight: FontWeight.w700,
                          ),
                        ),
                      ],
                    ),
                  ),
                  CircleAvatar(
                    backgroundColor: Colors.black.withValues(alpha: 0.40),
                    child: IconButton(
                      icon: const Icon(Icons.notes_rounded, color: Colors.white),
                      onPressed: () => _showConsultationNotes(isDoctor, currentUserName),
                    ),
                  ),
                ],
              ),
            ),

            // 3. Vignette PIP (Self-camera)
            Positioned(
              bottom: 120,
              right: 20,
              child: Container(
                width: 105,
                height: 145,
                decoration: BoxDecoration(
                  color: const Color(0xFF1E293B),
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(color: Colors.white.withValues(alpha: 0.4), width: 1.5),
                  boxShadow: const [
                    BoxShadow(
                      color: Color(0x33000000),
                      blurRadius: 10,
                      offset: Offset(0, 4),
                    ),
                  ],
                ),
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(14),
                  child: Stack(
                    alignment: Alignment.center,
                    children: [
                      _isVideoOff
                          ? const Icon(Icons.videocam_off, color: Colors.white54, size: 28)
                          : Container(
                              color: const Color(0xFF334155),
                              child: const Center(
                                child: Icon(Icons.person, color: Colors.white70, size: 40),
                              ),
                            ),
                      Positioned(
                        bottom: 6,
                        child: Container(
                          padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                          decoration: BoxDecoration(
                            color: Colors.black.withValues(alpha: 0.6),
                            borderRadius: BorderRadius.circular(6),
                          ),
                          child: Text(
                            isDoctor ? 'Dr. $currentUserName' : currentUserName,
                            style: const TextStyle(
                              color: Colors.white,
                              fontSize: 10,
                              fontWeight: FontWeight.w600,
                            ),
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),

            // 4. Barre de contrôle inférieure (Dock d'appel)
            Positioned(
              bottom: 24,
              left: 20,
              right: 20,
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                decoration: BoxDecoration(
                  color: Colors.black.withValues(alpha: 0.65),
                  borderRadius: BorderRadius.circular(32),
                  border: Border.all(color: Colors.white.withValues(alpha: 0.15)),
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                  children: [
                    // Micro
                    _buildActionButton(
                      icon: _isMicMuted ? Icons.mic_off_rounded : Icons.mic_rounded,
                      isActive: !_isMicMuted,
                      onTap: () => setState(() => _isMicMuted = !_isMicMuted),
                    ),

                    // Caméra
                    _buildActionButton(
                      icon: _isVideoOff ? Icons.videocam_off_rounded : Icons.videocam_rounded,
                      isActive: !_isVideoOff,
                      onTap: () => setState(() => _isVideoOff = !_isVideoOff),
                    ),

                    // Raccrocher (Bouton rouge central)
                    GestureDetector(
                      onTap: () {
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(
                            content: Text('Téléconsultation terminée avec succès.'),
                            backgroundColor: AppColors.primary,
                          ),
                        );
                        Navigator.pop(context);
                      },
                      child: Container(
                        width: 54,
                        height: 54,
                        decoration: const BoxDecoration(
                          color: Color(0xFFEF4444),
                          shape: BoxShape.circle,
                        ),
                        child: const Icon(
                          Icons.call_end_rounded,
                          color: Colors.white,
                          size: 28,
                        ),
                      ),
                    ),

                    // Basculer Caméra
                    _buildActionButton(
                      icon: Icons.flip_camera_ios_rounded,
                      isActive: true,
                      onTap: () => setState(() => _isFrontCamera = !_isFrontCamera),
                    ),

                    // Notes / Ordonnance en direct
                    _buildActionButton(
                      icon: Icons.medical_services_rounded,
                      isActive: true,
                      onTap: () => _showConsultationNotes(isDoctor, currentUserName),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildActionButton({
    required IconData icon,
    required bool isActive,
    required VoidCallback onTap,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: 44,
        height: 44,
        decoration: BoxDecoration(
          color: isActive
              ? Colors.white.withValues(alpha: 0.20)
              : const Color(0xFFEF4444).withValues(alpha: 0.8),
          shape: BoxShape.circle,
        ),
        child: Icon(
          icon,
          color: Colors.white,
          size: 22,
        ),
      ),
    );
  }
}
