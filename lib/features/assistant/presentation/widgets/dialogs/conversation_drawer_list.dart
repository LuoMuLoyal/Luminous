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
/// Conversations are grouped one [FTileGroup] per calendar day, labelled with
/// that day (see [conversationDayGroupLabel]). The current conversation is
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
        icon: SemanticIcons.actionSearchConversationDrawerList,
      );
    }

    if (items.isEmpty) {
      return StateMessageView(
        title: emptyTitle,
        description: emptyDescription,
        icon: SemanticIcons.actionMessage,
      );
    }

    final days = _groupByDay(visibleItems);

    return ListView.builder(
      key: const Key('assistant-recent-conversation-list'),
      itemCount: days.length,
      itemBuilder: (context, index) => _ConversationDayGroup(
        day: days[index].day,
        items: days[index].items,
        currentConversationId: state.conversationId,
        isOpeningConversation: state.isOpeningConversation,
        isClearingConversation: state.isClearingConversation,
        onSelect: onSelect,
        onRename: onRename,
        onDelete: onDelete,
      ),
    );
  }
}

/// Buckets conversations into their local calendar day, newest day first.
///
/// Within a day the incoming (server) order is kept. Days are ordered by value
/// rather than by first appearance so a payload that is not strictly sorted by
/// `updatedAt` still renders as a descending timeline.
List<_ConversationDayGroupData> _groupByDay(
  List<AssistantConversationSummary> items,
) {
  final buckets = <DateTime, List<AssistantConversationSummary>>{};
  for (final item in items) {
    final local = item.updatedAt.toLocal();
    final day = DateTime(local.year, local.month, local.day);
    buckets.putIfAbsent(day, () => []).add(item);
  }

  final days = buckets.keys.toList()..sort((a, b) => b.compareTo(a));
  return [
    for (final day in days)
      _ConversationDayGroupData(day: day, items: buckets[day]!),
  ];
}

class _ConversationDayGroupData {
  const _ConversationDayGroupData({required this.day, required this.items});

  final DateTime day;
  final List<AssistantConversationSummary> items;
}

/// One calendar day's conversations, rendered as a single labelled tile group.
class _ConversationDayGroup extends StatelessWidget {
  const _ConversationDayGroup({
    required this.day,
    required this.items,
    required this.currentConversationId,
    required this.isOpeningConversation,
    required this.isClearingConversation,
    required this.onSelect,
    this.onRename,
    this.onDelete,
  });

  final DateTime day;
  final List<AssistantConversationSummary> items;
  final String? currentConversationId;
  final bool isOpeningConversation;
  final bool isClearingConversation;
  final ValueChanged<String> onSelect;
  final ValueChanged<String>? onRename;
  final ValueChanged<String>? onDelete;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final hasMenu = onRename != null || onDelete != null;

    // Built through `FTileGroup.builder` rather than `FTileGroup(children:)`
    // because the long-press menu wrapper is not an `FTileMixin` and so cannot
    // be a plain child. The builder variant still wraps every tile in the
    // group's item data (dividers, first/last corners). `count` keeps the
    // group's lazily-built sliver bounded inside the drawer's own list.
    return FTileGroup.builder(
      label: Text(conversationDayGroupLabel(context, day)),
      count: items.length,
      tileBuilder: (context, index) {
        // The last-item probe calls the builder with `index == items.length`.
        if (index >= items.length) return null;

        final item = items[index];
        final tile = _buildTile(context, item);
        if (!hasMenu) return tile;

        // With rename/delete wired, each conversation gets its own
        // long-press / right-click context menu (see _buildTile).
        return FContextMenu.tiles(
          menu: _buildMenu(context, l10n, item.id),
          child: tile,
        );
      },
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
    final l10n = AppLocalizations.of(context)!;
    final isCurrent = item.id == currentConversationId;
    final isUntitled = _isUntitled(item);
    final typography = context.theme.typography;

    return FTile(
      key: Key('assistant-recent-conversation-${item.id}'),
      prefix: isCurrent
          ? Icon(
              SemanticIcons.statusDone,
              color: SemanticColor.primary.solid(context),
              size: 18,
            )
          : null,
      title: isUntitled
          ? Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(
                  SemanticIcons.actionEdit,
                  size: 14,
                  color: SemanticColor.primary.solid(context),
                ),
                const SizedBox(width: Spacing.sm),
                Text(
                  l10n.assistantConversationTapToName,
                  style: typography.body.xs.copyWith(
                    color: SemanticColor.primary.solid(context),
                  ),
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
        style: typography.body.xs2.copyWith(
          color: SemanticColor.neutral.solid(context),
        ),
      ),
      suffix: isCurrent
          ? Text(
              isClearingConversation
                  ? l10n.assistantClearingConversationLabel
                  : l10n.assistantRecentConversationCurrentLabel,
              style: typography.body.xs.copyWith(
                color: SemanticColor.primary.solid(context),
              ),
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
}
