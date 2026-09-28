import 'package:flutter/material.dart';

import '../../core/theme/app_colors.dart';
import '../../core/theme/app_text_styles.dart';
import '../../core/theme/app_theme.dart';
import '../../core/widgets/app_text_field.dart';
import '../../core/widgets/avatar_circle.dart';
import '../../core/widgets/circle_icon_button.dart';
import '../../core/widgets/phone_chrome.dart';
import '../../data/mock/mock_data.dart';
import '../../data/models/conversation.dart';
import '../../data/models/message.dart';

/// 06 · Detalle de chat
///
/// Se abre desde la lista de Chats con
/// `Navigator.pushNamed(context, AppRoutes.chatDetail, arguments: conversation)`.
/// No es pestaña de [MainShell], así que dibuja su propia barra de estado y
/// home indicator.
class ChatDetailScreen extends StatefulWidget {
  const ChatDetailScreen({super.key, required this.conversation});

  final Conversation conversation;

  @override
  State<ChatDetailScreen> createState() => _ChatDetailScreenState();
}

class _ChatDetailScreenState extends State<ChatDetailScreen> {
  final _inputController = TextEditingController();
  final _scrollController = ScrollController();

  /// TODO(backend): cargar el historial real de la conversación.
  /// Un match recién hecho llega sin `lastMessage` y arranca vacío.
  late final List<Message> _messages = [
    ...MockData.messages[widget.conversation.id] ??
        [
          if (widget.conversation.lastMessage.isNotEmpty)
            Message(
              id: '${widget.conversation.id}-last',
              text: widget.conversation.lastMessage,
              time: widget.conversation.time,
              fromMe: false,
            ),
        ],
  ];

  @override
  void dispose() {
    _inputController.dispose();
    _scrollController.dispose();
    super.dispose();
  }

  /// Añade el mensaje en local para poder probar el flujo sin backend.
  ///
  /// TODO(backend): enviar el mensaje al API.
  void _send() {
    final text = _inputController.text.trim();
    if (text.isEmpty) return;

    final now = TimeOfDay.now();
    setState(() {
      _messages.add(
        Message(
          id: DateTime.now().microsecondsSinceEpoch.toString(),
          text: text,
          time:
              '${now.hour.toString().padLeft(2, '0')}:${now.minute.toString().padLeft(2, '0')}',
          fromMe: true,
        ),
      );
    });
    _inputController.clear();

    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!_scrollController.hasClients) return;
      _scrollController.animateTo(
        _scrollController.position.maxScrollExtent,
        duration: const Duration(milliseconds: 250),
        curve: Curves.easeOut,
      );
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Column(
        children: [
          const MockStatusBar(),
          _ChatHeader(conversation: widget.conversation),
          Expanded(
            child: _messages.isEmpty
                ? _EmptyChat(name: widget.conversation.name)
                : ListView.separated(
                    controller: _scrollController,
                    padding: const EdgeInsets.fromLTRB(
                      AppTheme.pagePadding,
                      16,
                      AppTheme.pagePadding,
                      16,
                    ),
                    itemCount: _messages.length,
                    separatorBuilder: (_, _) => const SizedBox(height: 8),
                    itemBuilder: (context, index) =>
                        _MessageBubble(message: _messages[index]),
                  ),
          ),
          _MessageInput(controller: _inputController, onSend: _send),
          const ColoredBox(
            color: AppColors.surface,
            child: SizedBox(width: double.infinity, child: HomeIndicator()),
          ),
        ],
      ),
    );
  }
}

class _ChatHeader extends StatelessWidget {
  const _ChatHeader({required this.conversation});

  final Conversation conversation;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.fromLTRB(
        AppTheme.pagePadding,
        4,
        AppTheme.pagePadding,
        12,
      ),
      decoration: const BoxDecoration(
        color: AppColors.surface,
        border: Border(bottom: BorderSide(color: AppColors.border)),
      ),
      child: Row(
        children: [
          CircleIconButton(
            icon: Icons.arrow_back_rounded,
            onTap: () => Navigator.of(context).maybePop(),
          ),
          const SizedBox(width: 12),
          AvatarCircle(
            size: 42,
            photoUrl: conversation.photoUrl,
            online: conversation.online,
          ),
          const SizedBox(width: 10),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  conversation.name,
                  overflow: TextOverflow.ellipsis,
                  style: AppTextStyles.sectionTitle,
                ),
                Text(
                  conversation.online ? 'En línea' : 'Desconectado',
                  style: AppTextStyles.caption,
                ),
              ],
            ),
          ),
          CircleIconButton(
            icon: Icons.more_horiz_rounded,
            // TODO(backend): opciones (ver perfil, silenciar, reportar).
            onTap: () {},
          ),
        ],
      ),
    );
  }
}

class _MessageBubble extends StatelessWidget {
  const _MessageBubble({required this.message});

  final Message message;

  @override
  Widget build(BuildContext context) {
    final mine = message.fromMe;
    const radius = Radius.circular(AppTheme.radiusCard);
    const tail = Radius.circular(6);

    return Align(
      alignment: mine ? Alignment.centerRight : Alignment.centerLeft,
      child: ConstrainedBox(
        constraints: BoxConstraints(
          maxWidth: MediaQuery.sizeOf(context).width * 0.72,
        ),
        child: Container(
          padding: const EdgeInsets.fromLTRB(14, 10, 14, 8),
          decoration: BoxDecoration(
            color: mine ? null : AppColors.surface,
            gradient: mine ? AppColors.primaryGradient : null,
            border: mine ? null : Border.all(color: AppColors.border),
            borderRadius: BorderRadius.only(
              topLeft: radius,
              topRight: radius,
              bottomLeft: mine ? radius : tail,
              bottomRight: mine ? tail : radius,
            ),
          ),
          child: Column(
            crossAxisAlignment: mine
                ? CrossAxisAlignment.end
                : CrossAxisAlignment.start,
            children: [
              Text(
                message.text,
                style: AppTextStyles.body.copyWith(
                  color: mine ? AppColors.textOnDark : AppColors.textPrimary,
                ),
              ),
              const SizedBox(height: 3),
              Text(
                message.time,
                style: AppTextStyles.caption.copyWith(
                  fontSize: 10.5,
                  color: mine
                      ? AppColors.textOnDark.withValues(alpha: 0.75)
                      : AppColors.textMuted,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _MessageInput extends StatelessWidget {
  const _MessageInput({required this.controller, required this.onSend});

  final TextEditingController controller;
  final VoidCallback onSend;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.fromLTRB(
        AppTheme.pagePadding,
        10,
        AppTheme.pagePadding,
        10,
      ),
      decoration: const BoxDecoration(
        color: AppColors.surface,
        border: Border(top: BorderSide(color: AppColors.border)),
      ),
      child: Row(
        children: [
          Expanded(
            child: AppTextField(
              controller: controller,
              hintText: 'Escribe un mensaje',
              onSubmitted: (_) => onSend(),
            ),
          ),
          const SizedBox(width: 10),
          Material(
            shape: const CircleBorder(),
            clipBehavior: Clip.antiAlias,
            child: Ink(
              decoration: const BoxDecoration(
                gradient: AppColors.primaryGradient,
                shape: BoxShape.circle,
              ),
              child: InkWell(
                onTap: onSend,
                child: const SizedBox(
                  width: 46,
                  height: 46,
                  child: Icon(
                    Icons.send_rounded,
                    size: 20,
                    color: AppColors.textOnDark,
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _EmptyChat extends StatelessWidget {
  const _EmptyChat({required this.name});

  final String name;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: AppTheme.pagePadding),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const Icon(
            Icons.waving_hand_rounded,
            size: 38,
            color: AppColors.primaryLight,
          ),
          const SizedBox(height: 12),
          Text('Salúdale a $name', style: AppTextStyles.sectionTitle),
          const SizedBox(height: 4),
          const Text(
            'Todavía no se han escrito. Rompe el hielo.',
            textAlign: TextAlign.center,
            style: AppTextStyles.bodyMuted,
          ),
        ],
      ),
    );
  }
}
