import 'package:flutter/material.dart';

import '../../core/theme/app_colors.dart';
import '../../core/theme/app_text_styles.dart';
import '../../core/theme/app_theme.dart';
import '../../core/widgets/app_text_field.dart';
import '../../core/widgets/avatar_circle.dart';
import '../../core/widgets/avatar_strip.dart';
import '../../core/widgets/circle_icon_button.dart';
import '../../data/mock/mock_data.dart';
import '../../data/models/conversation.dart';

/// 04 · Chats
class ChatsScreen extends StatefulWidget {
  const ChatsScreen({super.key});

  @override
  State<ChatsScreen> createState() => _ChatsScreenState();
}

class _ChatsScreenState extends State<ChatsScreen> {
  final _searchController = TextEditingController();

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  /// Filtrado en memoria sobre los datos de ejemplo.
  ///
  /// TODO(backend): sustituir por la búsqueda del API.
  List<Conversation> get _visibleConversations {
    final query = _searchController.text.trim().toLowerCase();
    if (query.isEmpty) return MockData.conversations;
    return MockData.conversations
        .where((c) =>
            c.name.toLowerCase().contains(query) ||
            c.lastMessage.toLowerCase().contains(query))
        .toList();
  }

  @override
  Widget build(BuildContext context) {
    final conversations = _visibleConversations;

    return SingleChildScrollView(
      padding: const EdgeInsets.only(bottom: 16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: const EdgeInsets.symmetric(
              horizontal: AppTheme.pagePadding,
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                Row(
                  children: [
                    const Flexible(
                      child: Text(
                        'Chats',
                        overflow: TextOverflow.ellipsis,
                        style: AppTextStyles.title,
                      ),
                    ),
                    const Spacer(),
                    CircleIconButton(
                      icon: Icons.filter_list_rounded,
                      // TODO(backend): filtros de conversaciones.
                      onTap: () {},
                    ),
                  ],
                ),
                const SizedBox(height: 14),
                AppTextField(
                  controller: _searchController,
                  hintText: 'Buscar conversación',
                  prefixIcon: Icons.search_rounded,
                  onChanged: (_) => setState(() {}),
                ),
              ],
            ),
          ),
          const SizedBox(height: 22),
          AvatarStrip(
            title: 'Nuevos matches',
            profiles: MockData.newMatches,
            onAction: () {},
            onTapProfile: (_) {},
          ),
          const SizedBox(height: 22),
          const Padding(
            padding: EdgeInsets.symmetric(horizontal: AppTheme.pagePadding),
            child: Text('Mensajes', style: AppTextStyles.sectionTitle),
          ),
          const SizedBox(height: 12),
          if (conversations.isEmpty)
            const _EmptySearch()
          else
            ListView.separated(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              padding: const EdgeInsets.symmetric(
                horizontal: AppTheme.pagePadding,
              ),
              itemCount: conversations.length,
              separatorBuilder: (_, _) => const SizedBox(height: 10),
              itemBuilder: (context, index) => _ConversationTile(
                conversation: conversations[index],
                // TODO(backend): abrir el detalle de la conversación.
                onTap: () {},
              ),
            ),
        ],
      ),
    );
  }
}

class _ConversationTile extends StatelessWidget {
  const _ConversationTile({required this.conversation, this.onTap});

  final Conversation conversation;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    final unread = conversation.hasUnread;

    return Material(
      color: AppColors.surface,
      borderRadius: BorderRadius.circular(AppTheme.radiusCard),
      child: InkWell(
        borderRadius: BorderRadius.circular(AppTheme.radiusCard),
        onTap: onTap,
        child: Container(
          padding: const EdgeInsets.all(12),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(AppTheme.radiusCard),
            border: Border.all(color: AppColors.border),
          ),
          child: Row(
            children: [
              AvatarCircle(
                size: 52,
                photoUrl: conversation.photoUrl,
                online: conversation.online,
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Expanded(
                          child: Text(
                            conversation.name,
                            overflow: TextOverflow.ellipsis,
                            style: AppTextStyles.body.copyWith(
                              fontSize: 15,
                              fontWeight:
                                  unread ? FontWeight.w800 : FontWeight.w700,
                            ),
                          ),
                        ),
                        const SizedBox(width: 8),
                        Text(
                          conversation.time,
                          style: AppTextStyles.caption.copyWith(
                            fontSize: 11.5,
                            color: unread
                                ? AppColors.primary
                                : AppColors.textMuted,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 5),
                    Row(
                      children: [
                        Expanded(
                          child: Text(
                            conversation.lastMessage,
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                            style: AppTextStyles.bodyMuted.copyWith(
                              fontSize: 13,
                              color: unread
                                  ? AppColors.textPrimary
                                  : AppColors.textSecondary,
                              fontWeight:
                                  unread ? FontWeight.w600 : FontWeight.w400,
                            ),
                          ),
                        ),
                        if (unread) ...[
                          const SizedBox(width: 8),
                          Container(
                            constraints: const BoxConstraints(minWidth: 20),
                            height: 20,
                            padding: const EdgeInsets.symmetric(horizontal: 6),
                            decoration: BoxDecoration(
                              color: AppColors.primary,
                              borderRadius: BorderRadius.circular(10),
                            ),
                            child: Center(
                              widthFactor: 1,
                              child: Text(
                                '${conversation.unread}',
                                style: const TextStyle(
                                  fontSize: 11,
                                  fontWeight: FontWeight.w700,
                                  color: AppColors.textOnDark,
                                ),
                              ),
                            ),
                          ),
                        ],
                      ],
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _EmptySearch extends StatelessWidget {
  const _EmptySearch();

  @override
  Widget build(BuildContext context) {
    return const Padding(
      padding: EdgeInsets.symmetric(
        horizontal: AppTheme.pagePadding,
        vertical: 36,
      ),
      child: Column(
        children: [
          Icon(
            Icons.search_off_rounded,
            size: 38,
            color: AppColors.textMuted,
          ),
          SizedBox(height: 10),
          Text(
            'No encontramos esa conversación',
            style: AppTextStyles.bodyMuted,
          ),
        ],
      ),
    );
  }
}
