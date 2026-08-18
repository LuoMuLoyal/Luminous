import 'package:flutter/material.dart';
import 'package:forui/forui.dart';
import 'package:luminous/core/design/design.dart';
import 'package:luminous/core/widgets/common/state_views.dart';
import 'package:luminous/features/assistant/domain/entities/models.dart';
import 'package:luminous/features/assistant/presentation/utils/ui_formatters.dart';
import 'package:luminous/features/assistant/presentation/widgets/dialogs/conversation_drawer_state.dart';
import 'package:luminous/l10n/app_localizations.dart';

/// The grouped conversation list used inside the assistant conversation drawer.
///
/// Groups are: today, last 7 days, older. The current conversation is
/// highlighted with a checkmark prefix and a "current" suffix label.
class AssistantConversationDrawerList extends StatelessWidget {
  const AssistantConversationDrawerList({
    super.key,
    required this.state,
    required this.emptyTitle,
    required this.emptyDescription,
    required this.searchQuery,
    required this.searchEmptyTitle,
    required this.searchEmptyDescription,
    required this.onRetry,
    required this.onSelect,
    this.onRename,
    this.onDelete,
  });

  final AssistantDrawerState state;
  final String emptyTitle;
  final String emptyDescription;
  final String searchQuery;
  final String searchEmptyTitle;
  final String searchEmptyDescription;
  final VoidCallback onRetry;
  final ValueChanged<String> onSelect;

  /// Opens the rename dialog for a conversation. When null the per-tile
  /// long-press menu and the tap-to-name entry are hidden.
  final ValueChanged<String>? onRename;

  /// Opens the delete confirmation for a conversation. When null the per-tile
  /// long-press menu is hidden.
  final ValueChanged<String>? onDelete;

  @override
  Widget build(BuildContext context) {
    final items = state.recentConversations;
    final query = searchQuery.trim().toLowerCase();
    final visibleItems = query.isEmpty
        ? items
        : items
              .where(
                (item) => conversationTitle(
                  context,
                  item,
                ).toLowerCase().contains(query),
              )
              .toList(growable: false);

    if (state.isLoadingRecentConversations && items.isEmpty) {
      return const StateSkeletonView(
        blocks: <StateSkeletonBlock>[
          StateSkeletonBlock(height: 56),
          StateSkeletonBlock(height: 56),
          StateSkeletonBlock(height: 56),
        ],
      );
    }

    if (state.recentConversationError != null && items.isEmpty) {
      return StateMessageView(
        title: emptyTitle,
        description: state.recentConversationError!,
        icon: SemanticIcons.actionTimeSlot,
        tone: StateTone.warning,
        actionLabel: AppLocalizations.of(context)!.todayRetryAction,
        onAction: onRetry,
      );
    }

    if (query.isNotEmpty && visibleItems.isEmpty) {
      return StateMessageView(
        title: searchEmptyTitle,
        description: searchEmptyDescription,
        icon: SemanticIcons.actionSearch,
      );
    }

    if (items.isEmpty) {
      return StateMessageView(
        title: emptyTitle,
        description: emptyDescription,
        icon: SemanticIcons.actionMessage,
      );
    }

    final groups = _groupConversations(visibleItems, DateTime.now());

    return ListView.builder(
      key: const Key('assistant-recent-conversation-list'),
      itemCount: groups.length,
      itemBuilder: (context, index) {
        final group = groups[index];
        if (group.items.isEmpty) return const SizedBox.shrink();
        return _ConversationGroup(
          title: group.title,
          items: group.items,
          currentConversationId: state.conversationId,
          isOpeningConversation: state.isOpeningConversation,
          isClearingConversation: state.isClearingConversation,
          onSelect: onSelect,
          onRename: onRename,
          onDelete: onDelete,
        );
      },
    );
  }

  List<_ConversationGroupData> _groupConversations(
    List<AssistantConversationSummary> items,
    DateTime now,
  ) {
    final today = DateTime(now.year, now.month, now.day);
    final weekAgo = today.subtract(const Duration(days: 7));

    final todayItems = <AssistantConversationSummary>[];
    final thisWeekItems = <AssistantConversationSummary>[];
    final olderItems = <AssistantConversationSummary>[];

    for (final item in items) {
      final updatedAt = item.updatedAt;
      // `!isBefore` (i.e. "is after or equal to") so a conversation updated
      // exactly at 00:00:00 lands in the current group instead of "older".
      if (!updatedAt.isBefore(today)) {
        todayItems.add(item);
      } else if (!updatedAt.isBefore(weekAgo)) {
        thisWeekItems.add(item);
      } else {
        olderItems.add(item);
      }
    }

    return [
      _ConversationGroupData(title: 'today', items: todayItems),
      _ConversationGroupData(title: 'thisWeek', items: thisWeekItems),
      _ConversationGroupData(title: 'older', items: olderItems),
    ];
  }
}

class _ConversationGroupData {
  const _ConversationGroupData({required this.title, required this.items});

  final String title;
  final List<AssistantConversationSummary> items;
}

class _ConversationGroup extends StatelessWidget {
  const _ConversationGroup({
    required this.title,
    required this.items,
    required this.currentConversationId,
    required this.isOpeningConversation,
    required this.isClearingConversation,
    required this.onSelect,
    this.onRename,
    this.onDelete,
  });

  final String title;
  final List<AssistantConversationSummary> items;
  final String? currentConversationId;
  final bool isOpeningConversation;
  final bool isClearingConversation;
  final ValueChanged<String> onSelect;
  final ValueChanged<String>? onRename;
  final ValueChanged<String>? onDelete;

  @override
  Widget build(BuildContext context) {
    final colors = context.theme.colors;
    final l10n = AppLocalizations.of(context)!;
    final groupTitle = _groupTitle(l10n, title);
    final hasMenu = onRename != null || onDelete != null;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.only(
            top: Spacing.level3,
            bottom: Spacing.level2,
          ),
          child: Text(
            groupTitle,
            style: TypographyToken.level2
                .body(context)
                .copyWith(color: colors.mutedForeground),
          ),
        ),
        if (hasMenu)
          // With rename/delete wired, each conversation gets its own
          // long-press / right-click context menu (see _buildTile); the
          // single-tile FTileGroup keeps the rounded-card look.
          Column(
            children: [
              for (final item in items)
                FContextMenu.tiles(
                  menu: _buildMenu(context, l10n, item.id),
                  child: FTileGroup(children: [_buildTile(context, item)]),
                ),
            ],
          )
        else
          FTileGroup(
            children: [for (final item in items) _buildTile(context, item)],
          ),
      ],
    );
  }

  /// Builds one conversation tile.
  ///
  /// The long-press / right-click menu (rename + delete) uses Forui's
  /// [FContextMenu.tiles], which handles long-press on touch and secondary
  /// press on desktop out of the box; each menu entry routes through the
  /// drawer's [onRename] / [onDelete] callbacks. Untitled conversations show a
  /// "tap to name" title that reuses the rename path.
  FTile _buildTile(BuildContext context, AssistantConversationSummary item) {
    final colors = context.theme.colors;
    final l10n = AppLocalizations.of(context)!;
    final isCurrent = item.id == currentConversationId;
    final isUntitled = _isUntitled(item);

    return FTile(
      key: Key('assistant-recent-conversation-${item.id}'),
      prefix: isCurrent
          ? Icon(SemanticIcons.statusDone, color: colors.primary, size: 18)
          : null,
      title: isUntitled
          ? Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(SemanticIcons.actionEdit, size: 14, color: colors.primary),
                const SizedBox(width: Spacing.level2),
                Text(
                  l10n.assistantConversationTapToName,
                  style: TypographyToken.level3
                      .body(context)
                      .copyWith(color: colors.primary),
                ),
              ],
            )
          : Text(
              conversationTitle(context, item),
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
            ),
      subtitle: Text(
        conversationTimestampLabel(context, item),
        style: TypographyToken.level2
            .body(context)
            .copyWith(color: colors.mutedForeground),
      ),
      suffix: isCurrent
          ? Text(
              isClearingConversation
                  ? l10n.assistantClearingConversationLabel
                  : l10n.assistantRecentConversationCurrentLabel,
              style: TypographyToken.level3
                  .body(context)
                  .copyWith(color: colors.primary),
            )
          : null,
      onPress: isOpeningConversation
          ? null
          : () {
              // Untitled conversations open the rename dialog instead of
              // activating the conversation ("tap to name").
              if (isUntitled && onRename != null) {
                onRename!(item.id);
                return;
              }
              onSelect(item.id);
            },
    );
  }

  List<FTileGroup> _buildMenu(
    BuildContext context,
    AppLocalizations l10n,
    String conversationId,
  ) {
    return [
      FTileGroup(
        children: [
          if (onRename != null)
            FTile(
              key: Key('assistant-conversation-rename-$conversationId'),
              title: Text(l10n.assistantConversationRenameAction),
              onPress: () => onRename!(conversationId),
            ),
          if (onDelete != null)
            FTile(
              key: Key('assistant-conversation-delete-$conversationId'),
              title: Text(l10n.assistantConversationDeleteAction),
              onPress: () => onDelete!(conversationId),
            ),
        ],
      ),
    ];
  }

  bool _isUntitled(AssistantConversationSummary item) {
    final title = item.title?.trim();
    return title == null || title.isEmpty;
  }

  String _groupTitle(AppLocalizations l10n, String key) {
    switch (key) {
      case 'today':
        return l10n.assistantConversationTodayGroup;
      case 'thisWeek':
        return l10n.assistantConversationThisWeekGroup;
      case 'older':
        return l10n.assistantConversationOlderGroup;
    }
    return key;
  }
}
