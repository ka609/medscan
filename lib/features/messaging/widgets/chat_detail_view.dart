import 'package:flutter/material.dart';
import '../../../core/theme/app_colors.dart';
import '../../../models/conversation.dart';
import '../../../models/message.dart';
import '../../../services/message_service.dart';

class ChatDetailView extends StatefulWidget {
  final Conversation conversation;
  final String currentUserId;
  final String currentUserName;
  final String currentUserRole;
  final bool isDoctor;
  final VoidCallback onBack;
  final VoidCallback onMessageSent;

  const ChatDetailView({
    super.key,
    required this.conversation,
    required this.currentUserId,
    required this.currentUserName,
    required this.currentUserRole,
    required this.isDoctor,
    required this.onBack,
    required this.onMessageSent,
  });

  @override
  State<ChatDetailView> createState() => _ChatDetailViewState();
}

class _ChatDetailViewState extends State<ChatDetailView> {
  final MessageService _messageService = MessageService();
  final TextEditingController _inputController = TextEditingController();
  final ScrollController _scrollController = ScrollController();

  List<ClinicalMessage> _messages = [];
  bool _isLoading = true;
  bool _isUrgent = false;

  @override
  void initState() {
    super.initState();
    _loadMessages();
  }

  @override
  void dispose() {
    _inputController.dispose();
    _scrollController.dispose();
    super.dispose();
  }

  Future<void> _loadMessages() async {
    setState(() => _isLoading = true);
    final msgs = await _messageService.getMessages(
      conversationId: widget.conversation.id,
      userId: widget.currentUserId,
      isDoctor: widget.isDoctor,
    );

    if (mounted) {
      setState(() {
        _messages = msgs;
        _isLoading = false;
      });
      _scrollToBottom();
    }
  }

  void _scrollToBottom() {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (_scrollController.hasClients) {
        _scrollController.animateTo(
          _scrollController.position.maxScrollExtent + 60,
          duration: const Duration(milliseconds: 300),
          curve: Curves.easeOut,
        );
      }
    });
  }

  Future<void> _sendMessage() async {
    final text = _inputController.text.trim();
    if (text.isEmpty) return;

    _inputController.clear();

    final newMsg = await _messageService.sendMessage({
      'conversationId': widget.conversation.id,
      'senderId': widget.currentUserId,
      'senderName': widget.currentUserName,
      'senderRole': widget.currentUserRole,
      'recipientId': widget.conversation.participantId,
      'recipientName': widget.conversation.participantName,
      'recipientRole': widget.conversation.participantRole,
      'patientId': widget.isDoctor
          ? widget.conversation.participantId
          : widget.currentUserId,
      'subject': 'Échange clinique sécurisé',
      'content': text,
      'priority': _isUrgent ? 'URGENT' : 'ROUTINE',
    });

    if (mounted) {
      setState(() {
        _messages.add(newMsg);
        _isUrgent = false; // Réinitialiser après envoi
      });
      _scrollToBottom();
      widget.onMessageSent();
    }
  }

  @override
  Widget build(BuildContext context) {
    final isPartnerDoctor = widget.conversation.participantRole
            .toUpperCase()
            .contains('DOCTOR') ||
        widget.conversation.participantRole
            .toUpperCase()
            .contains('PRATICIEN') ||
        widget.conversation.participantRole
            .toUpperCase()
            .contains('MEDECIN');

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        backgroundColor: AppColors.surface,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_rounded, color: AppColors.textPrimary),
          onPressed: widget.onBack,
        ),
        titleSpacing: 0,
        title: Row(
          children: [
            CircleAvatar(
              radius: 18,
              backgroundColor: isPartnerDoctor
                  ? AppColors.softBlue
                  : const Color(0xFFF0FDF4),
              child: Icon(
                isPartnerDoctor
                    ? Icons.medical_services_rounded
                    : Icons.person_rounded,
                size: 18,
                color: isPartnerDoctor
                    ? AppColors.primary
                    : const Color(0xFF16A34A),
              ),
            ),
            const SizedBox(width: 10),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    widget.conversation.participantName,
                    style: const TextStyle(
                      fontSize: 14.5,
                      fontWeight: FontWeight.w700,
                      color: AppColors.textPrimary,
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                  Row(
                    children: [
                      Container(
                        width: 7,
                        height: 7,
                        decoration: const BoxDecoration(
                          color: Color(0xFF10B981),
                          shape: BoxShape.circle,
                        ),
                      ),
                      const SizedBox(width: 5),
                      Text(
                        isPartnerDoctor
                            ? 'Praticien référent • 🔒 Chiffré'
                            : 'Patient suivi • 🔒 Chiffré',
                        style: const TextStyle(
                          fontSize: 11,
                          color: AppColors.textSecondary,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ],
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh_rounded, color: AppColors.primary),
            onPressed: _loadMessages,
          ),
        ],
      ),
      body: Center(
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 600),
          child: Column(
            children: [
              // Bandeau de traçabilité médicale
              Container(
                width: double.infinity,
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
                color: AppColors.softBlue.withValues(alpha: 0.5),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    const Icon(Icons.lock_rounded, size: 12, color: AppColors.primary),
                    const SizedBox(width: 6),
                    Text(
                      'Canal conforme HDS & déontologie médicale • Horodaté certifié',
                      style: TextStyle(
                        fontSize: 10.5,
                        fontWeight: FontWeight.w600,
                        color: AppColors.primary.withValues(alpha: 0.9),
                      ),
                    ),
                  ],
                ),
              ),

              // Liste des messages
              Expanded(
                child: _isLoading
                    ? const Center(child: CircularProgressIndicator())
                    : _messages.isEmpty
                        ? Center(
                            child: Padding(
                              padding: const EdgeInsets.all(24.0),
                              child: Column(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  Icon(
                                    Icons.chat_bubble_outline_rounded,
                                    size: 48,
                                    color: AppColors.textSecondary.withValues(alpha: 0.4),
                                  ),
                                  const SizedBox(height: 12),
                                  Text(
                                    'Discussion avec ${widget.conversation.participantName}',
                                    style: const TextStyle(
                                      fontWeight: FontWeight.w700,
                                      color: AppColors.textPrimary,
                                    ),
                                  ),
                                  const SizedBox(height: 4),
                                  const Text(
                                    'Posez votre question ou transmettez vos consignes médicales ci-dessous.',
                                    textAlign: TextAlign.center,
                                    style: TextStyle(
                                      fontSize: 12,
                                      color: AppColors.textSecondary,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          )
                        : ListView.builder(
                            controller: _scrollController,
                            padding: const EdgeInsets.symmetric(
                              horizontal: 16,
                              vertical: 14,
                            ),
                            itemCount: _messages.length,
                            itemBuilder: (context, index) {
                              final msg = _messages[index];
                              final isMe = msg.senderId == widget.currentUserId ||
                                  (widget.isDoctor && msg.senderRole == 'DOCTOR') ||
                                  (!widget.isDoctor && msg.senderRole == 'PATIENT');
                              return _buildMessageBubble(msg, isMe);
                            },
                          ),
              ),

              // Barre de saisie
              _buildInputBar(),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildMessageBubble(ClinicalMessage msg, bool isMe) {
    return Align(
      alignment: isMe ? Alignment.centerRight : Alignment.centerLeft,
      child: Container(
        margin: const EdgeInsets.only(bottom: 10),
        constraints: BoxConstraints(
          maxWidth: MediaQuery.of(context).size.width * 0.78,
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
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.04),
              blurRadius: 4,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: Column(
          crossAxisAlignment:
              isMe ? CrossAxisAlignment.end : CrossAxisAlignment.start,
          children: [
            if (msg.isUrgent)
              Container(
                margin: const EdgeInsets.only(bottom: 6),
                padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                decoration: BoxDecoration(
                  color: isMe
                      ? Colors.white.withValues(alpha: 0.22)
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
            Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  '${msg.sentAt.hour.toString().padLeft(2, '0')}:${msg.sentAt.minute.toString().padLeft(2, '0')}',
                  style: TextStyle(
                    fontSize: 10,
                    color: isMe
                        ? Colors.white.withValues(alpha: 0.75)
                        : AppColors.textSecondary,
                  ),
                ),
                if (isMe) ...[
                  const SizedBox(width: 4),
                  Icon(
                    Icons.done_all_rounded,
                    size: 12,
                    color: Colors.white.withValues(alpha: 0.8),
                  ),
                ],
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildInputBar() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
      decoration: const BoxDecoration(
        color: AppColors.surface,
        border: Border(top: BorderSide(color: AppColors.border)),
      ),
      child: SafeArea(
        top: false,
        child: Row(
          children: [
            // Bouton de priorité Urgent
            IconButton(
              icon: Icon(
                _isUrgent
                    ? Icons.warning_amber_rounded
                    : Icons.outlined_flag_rounded,
                color: _isUrgent ? const Color(0xFFDC2626) : AppColors.textSecondary,
              ),
              tooltip: _isUrgent ? 'Priorité Urgent active' : 'Marquer comme urgent',
              onPressed: () {
                setState(() => _isUrgent = !_isUrgent);
              },
            ),

            // Champ de texte
            Expanded(
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 14),
                decoration: BoxDecoration(
                  color: AppColors.background,
                  borderRadius: BorderRadius.circular(22),
                  border: Border.all(
                    color: _isUrgent
                        ? const Color(0xFFDC2626).withValues(alpha: 0.5)
                        : AppColors.border,
                  ),
                ),
                child: TextField(
                  controller: _inputController,
                  maxLines: 4,
                  minLines: 1,
                  textInputAction: TextInputAction.send,
                  onSubmitted: (_) => _sendMessage(),
                  decoration: InputDecoration(
                    hintText: _isUrgent
                        ? 'Message prioritaire / urgent...'
                        : 'Écrire un message sécurisé...',
                    hintStyle: const TextStyle(
                      fontSize: 13,
                      color: AppColors.textSecondary,
                    ),
                    border: InputBorder.none,
                  ),
                ),
              ),
            ),
            const SizedBox(width: 8),

            // Bouton d'envoi
            CircleAvatar(
              radius: 20,
              backgroundColor: AppColors.primary,
              child: IconButton(
                icon: const Icon(
                  Icons.send_rounded,
                  color: Colors.white,
                  size: 18,
                ),
                onPressed: _sendMessage,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
