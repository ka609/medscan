import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';
import '../../../core/routes/app_router.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_text_styles.dart';
import '../../../models/message.dart';
import '../../../providers/auth_provider.dart';
import '../../../services/message_service.dart';

class MessagingScreen extends StatefulWidget {
  const MessagingScreen({super.key});

  @override
  State<MessagingScreen> createState() => _MessagingScreenState();
}

class _MessagingScreenState extends State<MessagingScreen> {
  final MessageService _messageService = MessageService();
  List<ClinicalMessage> _messages = [];
  List<ClinicalAlert> _alerts = [];
  bool _isLoading = true;
  int _activeTab = 0; // 0: Chat, 1: Alertes Médicales

  final TextEditingController _messageInputController = TextEditingController();
  final ScrollController _scrollController = ScrollController();

  @override
  void initState() {
    super.initState();
    _loadData();
  }

  Future<void> _loadData() async {
    setState(() => _isLoading = true);
    final user = context.read<AuthProvider>().user;
    final isDoctor = user?.roles.any(
          (r) =>
              r.toUpperCase().contains('DOCTOR') ||
              r.toUpperCase().contains('PRATICIEN') ||
              r.toUpperCase().contains('MEDECIN'),
        ) ??
        false;
    final userId = user?.id.isNotEmpty == true ? user!.id : 'pat-001';

    final msgs = await _messageService.getMessages(
      userId: userId,
      isDoctor: isDoctor,
    );
    final alrts = await _messageService.getAlerts(userId: userId);

    if (mounted) {
      setState(() {
        _messages = msgs;
        _alerts = alrts;
        _isLoading = false;
      });
    }
  }

  Future<void> _handleSendMessage() async {
    final text = _messageInputController.text.trim();
    if (text.isEmpty) return;

    final user = context.read<AuthProvider>().user;
    final isDoctor = user?.roles.any(
          (r) =>
              r.toUpperCase().contains('DOCTOR') ||
              r.toUpperCase().contains('PRATICIEN') ||
              r.toUpperCase().contains('MEDECIN'),
        ) ??
        false;
    final userId = user?.id.isNotEmpty == true ? user!.id : 'pat-001';
    final userName = user?.displayName.isNotEmpty == true
        ? user!.displayName
        : (user?.username.isNotEmpty == true ? user!.username : (isDoctor ? 'Dr. Praticien' : 'Patient'));

    _messageInputController.clear();

    final newMsg = await _messageService.sendMessage({
      'content': text,
      'senderId': userId,
      'senderName': isDoctor ? 'Dr. $userName' : userName,
      'senderRole': isDoctor ? 'DOCTOR' : 'PATIENT',
      'recipientId': isDoctor ? 'pat-001' : 'doc-001',
      'recipientName': isDoctor ? 'M. Kaboré Souleymane' : 'Dr. Amadou Ouédraogo',
      'recipientRole': isDoctor ? 'PATIENT' : 'DOCTOR',
      'patientId': isDoctor ? 'pat-001' : userId,
      'conversationId': 'conv-$userId',
    });

    if (mounted) {
      setState(() {
        _messages.add(newMsg);
      });

      // Auto-scroll to bottom
      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (_scrollController.hasClients) {
          _scrollController.animateTo(
            _scrollController.position.maxScrollExtent,
            duration: const Duration(milliseconds: 300),
            curve: Curves.easeOut,
          );
        }
      });
    }
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

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        backgroundColor: AppColors.surface,
        elevation: 0,
        title: Text(
          isDoctor ? 'Messagerie Clinique (Praticien)' : 'Messagerie & Alertes',
          style: AppTextStyles.headingMedium.copyWith(color: AppColors.textPrimary),
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh_rounded, color: AppColors.primary),
            onPressed: _loadData,
          ),
        ],
      ),
      body: Center(
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 520),
          child: Column(
            children: [
              // 1. Onglets segmentés : Chat vs Alertes
              Container(
                color: AppColors.surface,
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                child: Container(
                  height: 44,
                  padding: const EdgeInsets.all(4),
                  decoration: BoxDecoration(
                    color: AppColors.background,
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Row(
                    children: [
                      Expanded(
                        child: _buildTabButton(
                          0,
                          isDoctor ? 'Patient Suivi' : 'Médecin Traitant',
                          Icons.chat_bubble_outline,
                        ),
                      ),
                      Expanded(
                        child: _buildTabButton(
                          1,
                          'Alertes (${_alerts.where((a) => !a.isRead).length})',
                          Icons.notifications_active_outlined,
                        ),
                      ),
                    ],
                  ),
                ),
              ),

              // 2. Contenu actif
              Expanded(
                child: _isLoading
                    ? const Center(child: CircularProgressIndicator())
                    : _activeTab == 0
                        ? _buildChatView(isDoctor)
                        : _buildAlertsView(),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildTabButton(int index, String label, IconData icon) {
    final isSelected = _activeTab == index;
    return GestureDetector(
      onTap: () => setState(() => _activeTab = index),
      child: Container(
        decoration: BoxDecoration(
          color: isSelected ? AppColors.surface : Colors.transparent,
          borderRadius: BorderRadius.circular(8),
          boxShadow: isSelected
              ? const [
                  BoxShadow(
                    color: Color(0x0C000000),
                    blurRadius: 4,
                    offset: Offset(0, 1),
                  ),
                ]
              : null,
        ),
        alignment: Alignment.center,
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              icon,
              size: 16,
              color: isSelected ? AppColors.primary : AppColors.textSecondary,
            ),
            const SizedBox(width: 6),
            Text(
              label,
              style: TextStyle(
                fontSize: 12,
                fontWeight: isSelected ? FontWeight.w700 : FontWeight.w500,
                color: isSelected ? AppColors.primary : AppColors.textSecondary,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildChatView(bool isDoctor) {
    return Column(
      children: [
        // En-tête de session isolée
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
          color: AppColors.softBlue,
          child: Row(
            children: [
              CircleAvatar(
                radius: 18,
                backgroundColor: AppColors.primary,
                child: Icon(
                  isDoctor ? Icons.person_outline : Icons.local_hospital_rounded,
                  color: Colors.white,
                  size: 20,
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      isDoctor
                          ? 'Dossier Patient : M. Kaboré Souleymane'
                          : 'Dr. Amadou Ouédraogo (Cardiologue référant)',
                      style: const TextStyle(
                        fontSize: 13,
                        fontWeight: FontWeight.w700,
                        color: AppColors.textPrimary,
                      ),
                    ),
                    const Text(
                      'Canal sécurisé • Discussion isolée et chiffrée HDS',
                      style: TextStyle(
                        fontSize: 11,
                        color: AppColors.accentGreen,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ],
                ),
              ),
              IconButton(
                tooltip: 'Démarrer une téléconsultation isolée',
                icon: const Icon(Icons.videocam_rounded, color: AppColors.primary),
                onPressed: () {
                  context.push(AppRoutes.teleconsult);
                },
              ),
            ],
          ),
        ),

        // Fil de discussion isolé
        Expanded(
          child: _messages.isEmpty
              ? Center(
                  child: Padding(
                    padding: const EdgeInsets.all(28.0),
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Container(
                          padding: const EdgeInsets.all(16),
                          decoration: const BoxDecoration(
                            color: AppColors.softBlue,
                            shape: BoxShape.circle,
                          ),
                          child: const Icon(Icons.lock_rounded,
                              size: 36, color: AppColors.primary),
                        ),
                        const SizedBox(height: 16),
                        const Text(
                          'Fil de Discussion Confidentiel & Isolé',
                          style: TextStyle(
                              fontWeight: FontWeight.w700, fontSize: 15.5),
                        ),
                        const SizedBox(height: 8),
                        Text(
                          isDoctor
                              ? 'Aucun message dans ce fil. Les échanges entre praticien et patient sont confidentiels et strictement cloisonnés.'
                              : 'Aucun message pour le moment. Vos discussions avec votre médecin sont strictement isolées de tout autre utilisateur.',
                          textAlign: TextAlign.center,
                          style: const TextStyle(
                              color: AppColors.textSecondary,
                              fontSize: 12.5,
                              height: 1.4),
                        ),
                      ],
                    ),
                  ),
                )
              : ListView.builder(
                  controller: _scrollController,
                  padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                  itemCount: _messages.length,
                  itemBuilder: (context, index) {
                    final msg = _messages[index];
                    final user = context.read<AuthProvider>().user;
                    final userId = user?.id ?? '';
                    final isMe = msg.senderId == userId ||
                        (isDoctor
                            ? msg.senderRole == 'DOCTOR'
                            : msg.senderRole == 'PATIENT' ||
                                msg.senderId == 'current-user');
                    return _buildMessageBubble(msg, isMe);
                  },
                ),
        ),

        // Barre d'envoi
        Container(
          padding: const EdgeInsets.fromLTRB(16, 8, 16, 20),
          decoration: BoxDecoration(
            color: AppColors.surface,
            boxShadow: const [
              BoxShadow(
                color: Color(0x0A000000),
                blurRadius: 8,
                offset: Offset(0, -2),
              ),
            ],
          ),
          child: Row(
            children: [
              Expanded(
                child: TextField(
                  controller: _messageInputController,
                  decoration: InputDecoration(
                    hintText: isDoctor
                        ? 'Écrire une consigne médicale au patient...'
                        : 'Écrire un message à votre médecin...',
                    filled: true,
                    fillColor: AppColors.background,
                    contentPadding: const EdgeInsets.symmetric(
                      horizontal: 16,
                      vertical: 12,
                    ),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(24),
                      borderSide: BorderSide.none,
                    ),
                  ),
                  onSubmitted: (_) => _handleSendMessage(),
                ),
              ),
              const SizedBox(width: 8),
              CircleAvatar(
                radius: 22,
                backgroundColor: AppColors.primary,
                child: IconButton(
                  icon: const Icon(Icons.send_rounded, color: Colors.white, size: 18),
                  onPressed: _handleSendMessage,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildMessageBubble(ClinicalMessage msg, bool isMe) {
    return Align(
      alignment: isMe ? Alignment.centerRight : Alignment.centerLeft,
      child: Container(
        margin: const EdgeInsets.only(bottom: 10),
        constraints: BoxConstraints(
          maxWidth: MediaQuery.of(context).size.width * 0.75,
        ),
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
        decoration: BoxDecoration(
          color: isMe ? AppColors.primary : AppColors.surface,
          borderRadius: BorderRadius.only(
            topLeft: const Radius.circular(16),
            topRight: const Radius.circular(16),
            bottomLeft: Radius.circular(isMe ? 16 : 4),
            bottomRight: Radius.circular(isMe ? 4 : 16),
          ),
          border: isMe ? null : Border.all(color: AppColors.border),
          boxShadow: const [
            BoxShadow(
              color: Color(0x06000000),
              blurRadius: 4,
              offset: Offset(0, 2),
            ),
          ],
        ),
        child: Column(
          crossAxisAlignment: isMe ? CrossAxisAlignment.end : CrossAxisAlignment.start,
          children: [
            if (!isMe)
              Padding(
                padding: const EdgeInsets.only(bottom: 4),
                child: Text(
                  msg.senderName,
                  style: const TextStyle(
                    fontSize: 11,
                    fontWeight: FontWeight.w700,
                    color: AppColors.primary,
                  ),
                ),
              ),
            if (msg.isUrgent)
              Container(
                margin: const EdgeInsets.only(bottom: 4),
                padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                decoration: BoxDecoration(
                  color: isMe
                      ? Colors.white.withValues(alpha: 0.20)
                      : const Color(0xFFFEE2E2),
                  borderRadius: BorderRadius.circular(4),
                ),
                child: Text(
                  'PRIORITÉ : URGENT',
                  style: TextStyle(
                    fontSize: 9.5,
                    fontWeight: FontWeight.w800,
                    color: isMe ? Colors.white : const Color(0xFFDC2626),
                  ),
                ),
              ),
            Text(
              msg.content,
              style: TextStyle(
                fontSize: 13.5,
                height: 1.35,
                color: isMe ? Colors.white : AppColors.textPrimary,
              ),
            ),
            const SizedBox(height: 4),
            Text(
              '${msg.sentAt.hour.toString().padLeft(2, '0')}:${msg.sentAt.minute.toString().padLeft(2, '0')}',
              style: TextStyle(
                fontSize: 10,
                color: isMe
                    ? Colors.white.withValues(alpha: 0.75)
                    : AppColors.textSecondary,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildAlertsView() {
    if (_alerts.isEmpty) {
      return const Center(
        child: Padding(
          padding: EdgeInsets.all(24.0),
          child: Text(
            'Aucune alerte médicale pour le moment.',
            style: TextStyle(color: AppColors.textSecondary),
          ),
        ),
      );
    }

    return ListView.builder(
      padding: const EdgeInsets.all(16),
      itemCount: _alerts.length,
      itemBuilder: (context, index) {
        final alert = _alerts[index];
        final isCritical = alert.severity == 'CRITICAL';
        return Container(
          margin: const EdgeInsets.only(bottom: 12),
          padding: const EdgeInsets.all(14),
          decoration: BoxDecoration(
            color: AppColors.surface,
            borderRadius: BorderRadius.circular(16),
            border: Border.all(
              color: isCritical
                  ? const Color(0xFFDC2626).withValues(alpha: 0.4)
                  : AppColors.border,
            ),
            boxShadow: const [
              BoxShadow(
                color: Color(0x06000000),
                blurRadius: 6,
                offset: Offset(0, 2),
              ),
            ],
          ),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Container(
                padding: const EdgeInsets.all(10),
                decoration: BoxDecoration(
                  color: isCritical ? const Color(0xFFFEE2E2) : AppColors.softBlue,
                  shape: BoxShape.circle,
                ),
                child: Icon(
                  isCritical ? Icons.warning_amber_rounded : Icons.notifications_rounded,
                  color: isCritical ? const Color(0xFFDC2626) : AppColors.primary,
                  size: 20,
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      alert.title,
                      style: const TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.w700,
                        color: AppColors.textPrimary,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      alert.message,
                      style: const TextStyle(
                        fontSize: 12.5,
                        color: AppColors.textSecondary,
                        height: 1.35,
                      ),
                    ),
                    if (alert.actionRoute != null) ...[
                      const SizedBox(height: 8),
                      GestureDetector(
                        onTap: () => context.push(alert.actionRoute!),
                        child: const Text(
                          'Ouvrir le document associé →',
                          style: TextStyle(
                            fontSize: 12,
                            fontWeight: FontWeight.w700,
                            color: AppColors.primary,
                          ),
                        ),
                      ),
                    ],
                  ],
                ),
              ),
            ],
          ),
        );
      },
    );
  }
}
