import 'package:flutter/material.dart';
import 'package:forui/forui.dart';
import 'package:luminous/core/design/design.dart';
import 'package:luminous/core/widgets/common/state_views.dart';
import 'package:luminous/features/assistant/domain/entities/models.dart';
import 'package:luminous/features/assistant/presentation/providers/conversation.dart';
import 'package:luminous/features/assistant/presentation/utils/ui_formatters.dart';
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
    required this.onRetry,
    required this.onSelect,
  });

  final AssistantState state;
  final String emptyTitle;
  final String emptyDescription;
  final VoidCallback onRetry;
  final ValueChanged<String> onSelect;

  @override
  Widget build(BuildContext context) {
    final items = state.recentConversations;

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

    if (items.isEmpty) {
      return StateMessageView(
        title: emptyTitle,
        description: emptyDescription,
        icon: SemanticIcons.actionMessage,
      );
    }

    final groups = _groupConversations(items, DateTime.now());

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
          onSelect: onSelect,
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
      if (updatedAt.isAfter(today)) {
        todayItems.add(item);
      } else if (updatedAt.isAfter(weekAgo)) {
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
    required this.onSelect,
  });

  final String title;
  final List<AssistantConversationSummary> items;
  final String? currentConversationId;
  final bool isOpeningConversation;
  final ValueChanged<String> onSelect;

  @override
  Widget build(BuildContext context) {
    final colors = context.theme.colors;
    final l10n = AppLocalizations.of(context)!;
    final groupTitle = _groupTitle(l10n, title);

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
        FTileGroup(
          children: [
            for (final item in items)
              FTile(
                key: Key('assistant-recent-conversation-${item.id}'),
                prefix: item.id == currentConversationId
                    ? Icon(
                        SemanticIcons.statusDone,
                        color: colors.primary,
                        size: 18,
                      )
                    : null,
                title: Text(
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
                suffix: item.id == currentConversationId
                    ? Text(
                        l10n.assistantRecentConversationCurrentLabel,
                        style: TypographyToken.level3
                            .body(context)
                            .copyWith(color: colors.primary),
                      )
                    : null,
                onPress: isOpeningConversation ? null : () => onSelect(item.id),
              ),
          ],
        ),
      ],
    );
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
