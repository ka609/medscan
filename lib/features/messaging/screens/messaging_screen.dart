import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_text_styles.dart';
import '../../../core/utils/id_generator.dart';
import '../../../models/conversation.dart';
import '../../../models/message.dart';
import '../../../models/user.dart';
import '../../../providers/auth_provider.dart';
import '../../../services/message_service.dart';
import '../widgets/chat_detail_view.dart';
import '../widgets/conversation_tile.dart';
import '../widgets/new_conversation_sheet.dart';

class MessagingScreen extends StatefulWidget {
  const MessagingScreen({super.key});

  @override
  State<MessagingScreen> createState() => _MessagingScreenState();
}

class _MessagingScreenState extends State<MessagingScreen> {
  final MessageService _messageService = MessageService();

  List<Conversation> _conversations = [];
  List<Conversation> _filteredConversations = [];
  List<ClinicalAlert> _alerts = [];
  bool _isLoading = true;
  int _activeTab = 0; // 0: Discussions, 1: Alertes Médicales

  Conversation? _selectedConversation;
  final TextEditingController _searchController = TextEditingController();

  @override
  void initState() {
    super.initState();
    _loadData();
    _searchController.addListener(_filterConversations);
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  Future<void> _loadData() async {
    setState(() => _isLoading = true);
    final user = context.read<AuthProvider>().user;
    final isDoctor = user.isDoctor;
    final userId = user?.id.isNotEmpty == true ? user!.id : '';

    final convs = await _messageService.getConversations(
      userId: userId,
      isDoctor: isDoctor,
    );
    final alrts = await _messageService.getAlerts(userId: userId);

    if (mounted) {
      setState(() {
        _conversations = convs;
        _alerts = alrts;
        _isLoading = false;
      });
      _filterConversations();
    }
  }

  void _filterConversations() {
    final query = _searchController.text.trim().toLowerCase();
    setState(() {
      if (query.isEmpty) {
        _filteredConversations = _conversations;
      } else {
        _filteredConversations = _conversations.where((c) {
          final nameMatch = c.participantName.toLowerCase().contains(query);
          final msgMatch =
              c.lastMessage?.content.toLowerCase().contains(query) ?? false;
          return nameMatch || msgMatch;
        }).toList();
      }
    });
  }

  void _openNewConversationModal(User? user, bool isDoctor) {
    final userId = user?.id.isNotEmpty == true ? user!.id : IdGenerator.patientId();

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (ctx) => NewConversationSheet(
        userId: userId,
        isDoctor: isDoctor,
        onContactSelected: (contact) {
          _startOrOpenConversation(contact, user, isDoctor);
        },
      ),
    );
  }

  void _startOrOpenConversation(
    MessagingContact contact,
    User? user,
    bool isDoctor,
  ) {
    final userId = user?.id.isNotEmpty == true ? user!.id : IdGenerator.patientId();
    final existingIndex = _conversations.indexWhere(
      (c) => c.participantId == contact.id || c.participantName == contact.name,
    );

    if (existingIndex >= 0) {
      setState(() {
        _selectedConversation = _conversations[existingIndex];
      });
    } else {
      final newConvId = IdGenerator.conversationId(userId, contact.id);
      final newConv = Conversation(
        id: newConvId,
        participantId: contact.id,
        participantName: contact.name,
        participantRole: contact.role,
        lastMessage: null,
        unreadCount: 0,
      );

      setState(() {
        _conversations.insert(0, newConv);
        _filterConversations();
        _selectedConversation = newConv;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final user = context.watch<AuthProvider>().user;
    final isDoctor = user.isDoctor;
    final userId = user?.id.isNotEmpty == true ? user!.id : IdGenerator.patientId();
    final userName = user?.displayName.isNotEmpty == true
        ? user!.displayName
        : (user?.username.isNotEmpty == true
            ? user!.username
            : (isDoctor ? (user?.displayTitle ?? 'Praticien') : 'Patient'));
    final userRole = isDoctor ? 'DOCTOR' : 'PATIENT';

    // Si une conversation est sélectionnée, afficher directement la vue détaillée du chat
    if (_selectedConversation != null) {
      return ChatDetailView(
        conversation: _selectedConversation!,
        currentUserId: userId,
        currentUserName: userName,
        currentUserRole: userRole,
        isDoctor: isDoctor,
        onBack: () {
          setState(() => _selectedConversation = null);
          _loadData();
        },
        onMessageSent: () {
          _loadData();
        },
      );
    }

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
      floatingActionButton: _activeTab == 0
          ? FloatingActionButton.extended(
              backgroundColor: AppColors.primary,
              icon: const Icon(Icons.edit_note_rounded, color: Colors.white),
              label: Text(
                isDoctor ? 'Nouveau patient' : 'Nouveau message',
                style: const TextStyle(
                  color: Colors.white,
                  fontWeight: FontWeight.w700,
                  fontSize: 13,
                ),
              ),
              onPressed: () => _openNewConversationModal(user, isDoctor),
            )
          : null,
      body: Center(
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 560),
          child: Column(
            children: [
              // 1. Onglets segmentés : Discussions vs Alertes
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
                        child: GestureDetector(
                          onTap: () => setState(() => _activeTab = 0),
                          child: Container(
                            decoration: BoxDecoration(
                              color: _activeTab == 0
                                  ? AppColors.surface
                                  : Colors.transparent,
                              borderRadius: BorderRadius.circular(9),
                              boxShadow: _activeTab == 0
                                  ? [
                                      const BoxShadow(
                                        color: Color(0x0A000000),
                                        blurRadius: 4,
                                        offset: Offset(0, 1),
                                      ),
                                    ]
                                  : null,
                            ),
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                Icon(
                                  Icons.chat_bubble_rounded,
                                  size: 15,
                                  color: _activeTab == 0
                                      ? AppColors.primary
                                      : AppColors.textSecondary,
                                ),
                                const SizedBox(width: 6),
                                Text(
                                  'Discussions',
                                  style: TextStyle(
                                    fontSize: 13,
                                    fontWeight: _activeTab == 0
                                        ? FontWeight.w700
                                        : FontWeight.w500,
                                    color: _activeTab == 0
                                        ? AppColors.primary
                                        : AppColors.textSecondary,
                                  ),
                                ),
                                if (_conversations.isNotEmpty) ...[
                                  const SizedBox(width: 5),
                                  Container(
                                    padding: const EdgeInsets.symmetric(
                                        horizontal: 5, vertical: 1),
                                    decoration: BoxDecoration(
                                      color: _activeTab == 0
                                          ? AppColors.primary.withValues(alpha: 0.15)
                                          : AppColors.border,
                                      borderRadius: BorderRadius.circular(10),
                                    ),
                                    child: Text(
                                      '${_conversations.length}',
                                      style: TextStyle(
                                        fontSize: 10,
                                        fontWeight: FontWeight.w700,
                                        color: _activeTab == 0
                                            ? AppColors.primary
                                            : AppColors.textSecondary,
                                      ),
                                    ),
                                  ),
                                ],
                              ],
                            ),
                          ),
                        ),
                      ),
                      Expanded(
                        child: GestureDetector(
                          onTap: () => setState(() => _activeTab = 1),
                          child: Container(
                            decoration: BoxDecoration(
                              color: _activeTab == 1
                                  ? AppColors.surface
                                  : Colors.transparent,
                              borderRadius: BorderRadius.circular(9),
                              boxShadow: _activeTab == 1
                                  ? [
                                      const BoxShadow(
                                        color: Color(0x0A000000),
                                        blurRadius: 4,
                                        offset: Offset(0, 1),
                                      ),
                                    ]
                                  : null,
                            ),
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                Icon(
                                  Icons.notifications_active_rounded,
                                  size: 15,
                                  color: _activeTab == 1
                                      ? AppColors.primary
                                      : AppColors.textSecondary,
                                ),
                                const SizedBox(width: 6),
                                Text(
                                  'Alertes Médicales',
                                  style: TextStyle(
                                    fontSize: 13,
                                    fontWeight: _activeTab == 1
                                        ? FontWeight.w700
                                        : FontWeight.w500,
                                    color: _activeTab == 1
                                        ? AppColors.primary
                                        : AppColors.textSecondary,
                                  ),
                                ),
                                if (_alerts.isNotEmpty) ...[
                                  const SizedBox(width: 5),
                                  Container(
                                    padding: const EdgeInsets.symmetric(
                                        horizontal: 5, vertical: 1),
                                    decoration: BoxDecoration(
                                      color: const Color(0xFFDC2626),
                                      borderRadius: BorderRadius.circular(10),
                                    ),
                                    child: Text(
                                      '${_alerts.length}',
                                      style: const TextStyle(
                                        fontSize: 10,
                                        fontWeight: FontWeight.w700,
                                        color: Colors.white,
                                      ),
                                    ),
                                  ),
                                ],
                              ],
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),

              // 2. Contenu principal
              Expanded(
                child: _isLoading
                    ? const Center(child: CircularProgressIndicator())
                    : _activeTab == 0
                        ? _buildConversationsView(user, isDoctor)
                        : _buildAlertsView(),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildConversationsView(User? user, bool isDoctor) {
    return Column(
      children: [
        // Champ de recherche
        Padding(
          padding: const EdgeInsets.fromLTRB(16, 12, 16, 8),
          child: TextField(
            controller: _searchController,
            decoration: InputDecoration(
              hintText: 'Rechercher une personne ou un message...',
              hintStyle: const TextStyle(fontSize: 13, color: AppColors.textSecondary),
              prefixIcon: const Icon(Icons.search_rounded, size: 20, color: AppColors.textSecondary),
              filled: true,
              fillColor: AppColors.surface,
              contentPadding: const EdgeInsets.symmetric(vertical: 0, horizontal: 14),
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
                borderSide: const BorderSide(color: AppColors.border),
              ),
              enabledBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
                borderSide: const BorderSide(color: AppColors.border),
              ),
            ),
          ),
        ),

        // Liste des conversations ou État vide
        Expanded(
          child: _filteredConversations.isEmpty
              ? Center(
                  child: Padding(
                    padding: const EdgeInsets.all(32.0),
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(
                          Icons.mark_chat_unread_outlined,
                          size: 54,
                          color: AppColors.primary.withValues(alpha: 0.35),
                        ),
                        const SizedBox(height: 16),
                        Text(
                          _conversations.isEmpty
                              ? 'Aucune discussion en cours'
                              : 'Aucun résultat trouvé',
                          style: const TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.w700,
                            color: AppColors.textPrimary,
                          ),
                        ),
                        const SizedBox(height: 8),
                        Text(
                          _conversations.isEmpty
                              ? (isDoctor
                                  ? 'Cliquez ci-dessous pour initier un échange avec un patient que vous avez reçu en consultation.'
                                  : 'Cliquez sur le bouton ci-dessous pour contacter un praticien qui vous a déjà reçu en consultation.')
                              : 'Essayez un autre mot-clé ou effacez la recherche.',
                          textAlign: TextAlign.center,
                          style: const TextStyle(
                            fontSize: 13,
                            color: AppColors.textSecondary,
                            height: 1.4,
                          ),
                        ),
                        if (_conversations.isEmpty) ...[
                          const SizedBox(height: 20),
                          ElevatedButton.icon(
                            style: ElevatedButton.styleFrom(
                              backgroundColor: AppColors.primary,
                              foregroundColor: Colors.white,
                              padding: const EdgeInsets.symmetric(
                                horizontal: 18,
                                vertical: 12,
                              ),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(12),
                              ),
                            ),
                            icon: const Icon(Icons.add_rounded, size: 18),
                            label: Text(
                              isDoctor ? 'Écrire à un patient' : 'Écrire à un docteur',
                              style: const TextStyle(fontWeight: FontWeight.w700),
                            ),
                            onPressed: () => _openNewConversationModal(user, isDoctor),
                          ),
                        ],
                      ],
                    ),
                  ),
                )
              : ListView.builder(
                  padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                  itemCount: _filteredConversations.length,
                  itemBuilder: (context, index) {
                    final conv = _filteredConversations[index];
                    return ConversationTile(
                      conversation: conv,
                      onTap: () {
                        setState(() => _selectedConversation = conv);
                      },
                    );
                  },
                ),
        ),
      ],
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
