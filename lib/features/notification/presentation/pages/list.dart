import 'dart:async';

import 'package:clock/clock.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:forui/forui.dart';
import 'package:luminous/core/design/design.dart';
import 'package:luminous/core/errors/user_message.dart';
import 'package:luminous/core/feedback/toast.dart';
import 'package:luminous/core/widgets/layout/page_scaffold.dart';
import 'package:luminous/core/widgets/common/state_views.dart';
import 'package:luminous/core/widgets/layout/responsive_content_frame.dart';
import 'package:luminous/features/notification/domain/entities/notification.dart';
import 'package:luminous/features/notification/presentation/providers/notification.dart';
import 'package:luminous/features/notification/presentation/routes.dart';
import 'package:luminous/features/notification/presentation/widgets/shared/list_item.dart';
import 'package:luminous/l10n/app_localizations.dart';

class NotificationListPage extends ConsumerWidget {
  const NotificationListPage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = AppLocalizations.of(context)!;
    final listAsync = ref.watch(notificationListControllerProvider);

    return PageScaffold(
      title: l10n.notificationListTitle,
      actions: [
        _MarkAllReadButton(
          onPressed: () async {
            final controller = ref.read(
              notificationListControllerProvider.notifier,
            );
            await controller.markAllAsRead();
            if (context.mounted) {
              unawaited(
                AppToast.show(context, l10n.notificationMarkAllReadSuccess),
              );
            }
          },
          hasUnread: listAsync.maybeWhen(
            data: (page) => page.items.any((item) => !item.isRead),
            orElse: () => false,
          ),
        ),
      ],
      child: listAsync.when(
        data: (page) {
          final items = page.items;
          if (items.isEmpty) {
            return const _EmptyView();
          }
          return RefreshIndicator(
            onRefresh: () =>
                ref.read(notificationListControllerProvider.notifier).refresh(),
            child: ResponsiveContentFrame(
              child: _GroupedNotificationList(
                items: items,
                l10n: l10n,
                onTap: (item) async {
                  final controller = ref.read(
                    notificationListControllerProvider.notifier,
                  );
                  if (!item.isRead) {
                    await controller.markAsRead(item.id);
                  }
                  if (context.mounted) {
                    unawaited(
                      NotificationDetailRoute(id: item.id).push(context),
                    );
                  }
                },
                onDismiss: (item) async {
                  final controller = ref.read(
                    notificationListControllerProvider.notifier,
                  );
                  await controller.deleteNotification(item.id);
                  if (context.mounted) {
                    unawaited(
                      AppToast.show(context, l10n.notificationDeleteSuccess),
                    );
                  }
                },
                onToggleRead: (item) async {
                  final controller = ref.read(
                    notificationListControllerProvider.notifier,
                  );
                  await controller.toggleReadStatus(item.id);
                  if (context.mounted) {
                    unawaited(
                      AppToast.show(
                        context,
                        item.isRead
                            ? l10n.notificationMarkUnreadSuccess
                            : l10n.notificationMarkReadSuccess,
                      ),
                    );
                  }
                },
                hasMore: ref
                    .read(notificationListControllerProvider.notifier)
                    .hasMore,
                isLoadingMore: ref.watch(notificationListLoadingMoreProvider),
                onLoadMore: () => ref
                    .read(notificationListControllerProvider.notifier)
                    .loadMore(),
                loadMoreLabel: l10n.notificationLoadMore,
              ),
            ),
          );
        },
        loading: () => const Center(
          child: Padding(
            padding: EdgeInsets.all(Spacing.level10),
            child: AppSkeletonShimmer(
              child: Column(
                children: [
                  AppInlineSkeletonBlock(height: 64, widthFactor: 1),
                  SizedBox(height: Spacing.level4),
                  AppInlineSkeletonBlock(height: 64, widthFactor: 1),
                  SizedBox(height: Spacing.level4),
                  AppInlineSkeletonBlock(height: 64, widthFactor: 1),
                  SizedBox(height: Spacing.level4),
                  AppInlineSkeletonBlock(height: 64, widthFactor: 1),
                  SizedBox(height: Spacing.level4),
                  AppInlineSkeletonBlock(height: 64, widthFactor: 1),
                  SizedBox(height: Spacing.level4),
                  AppInlineSkeletonBlock(height: 64, widthFactor: 1),
                ],
              ),
            ),
          ),
        ),
        error: (error, _) => AppStateErrorView(
          title: l10n.notificationErrorTitle,
          description: userMessageFromError(
            error,
            fallback: l10n.notificationErrorTitle,
          ),
          icon: FLucideIcons.circleAlert,
          actionLabel: l10n.notificationRetryAction,
          onAction: () => ref.invalidate(notificationListControllerProvider),
        ),
      ),
    );
  }
}

class _GroupedNotificationList extends StatelessWidget {
  const _GroupedNotificationList({
    required this.items,
    required this.l10n,
    required this.onTap,
    required this.onDismiss,
    required this.onToggleRead,
    required this.hasMore,
    required this.isLoadingMore,
    required this.onLoadMore,
    required this.loadMoreLabel,
  });

  final List<NotificationItem> items;
  final AppLocalizations l10n;
  final void Function(NotificationItem) onTap;
  final void Function(NotificationItem) onDismiss;
  final void Function(NotificationItem) onToggleRead;
  final bool hasMore;
  final bool isLoadingMore;
  final VoidCallback onLoadMore;
  final String loadMoreLabel;

  @override
  Widget build(BuildContext context) {
    // Flatten the grouped notifications into a single list of entries so a
    // `ListView.builder` can lazily build only the visible rows. This replaces
    // the previous `ListView(shrinkWrap: true)` + for-loop which eagerly built
    // every item and defeated the purpose of a scrollable list.
    final entries = _buildEntries();
    final colors = context.theme.colors;

    return ListView.builder(
      physics: const AlwaysScrollableScrollPhysics(),
      padding: const EdgeInsets.symmetric(vertical: Spacing.level6),
      itemCount: entries.length,
      itemBuilder: (context, index) {
        final entry = entries[index];
        return switch (entry) {
          _HeaderEntry(:final title, :final isFirst) => Padding(
            padding: EdgeInsets.only(
              top: isFirst ? Spacing.level3 : Spacing.level4,
              bottom: Spacing.level2,
              left: Spacing.level3,
            ),
            child: Text(
              title,
              style: TypographyToken.level4
                  .body(context)
                  .copyWith(
                    color: colors.mutedForeground,
                    fontWeight: FontWeight.w600,
                  ),
            ),
          ),
          _ItemEntry(
            :final item,
            :final onTap,
            :final onDismiss,
            :final onToggleRead,
          ) =>
            Padding(
              padding: const EdgeInsets.only(bottom: Spacing.level3),
              child: NotificationListItemWidget(
                item: item,
                onTap: onTap,
                onDismiss: onDismiss,
                onToggleRead: onToggleRead,
              ),
            ),
          _LoadMoreEntry() => Padding(
            padding: const EdgeInsets.only(top: Spacing.level4),
            child: Center(
              child: isLoadingMore
                  ? const SizedBox(
                      width: 24,
                      height: 24,
                      child: FCircularProgress(),
                    )
                  : FButton(
                      variant: FButtonVariant.outline,
                      onPress: onLoadMore,
                      child: Text(loadMoreLabel),
                    ),
            ),
          ),
        };
      },
    );
  }

  List<_ListEntry> _buildEntries() {
    final groups = _groupByRelativeDate(items, l10n);
    final entries = <_ListEntry>[];
    var isFirst = true;
    for (final groupEntry in groups.entries) {
      entries.add(_HeaderEntry(groupEntry.key, isFirst: isFirst));
      isFirst = false;
      for (final item in groupEntry.value) {
        entries.add(
          _ItemEntry(
            item,
            onTap: () => onTap(item),
            onDismiss: () => onDismiss(item),
            onToggleRead: () => onToggleRead(item),
          ),
        );
      }
    }
    if (hasMore) {
      entries.add(const _LoadMoreEntry());
    }
    return entries;
  }

  Map<String, List<NotificationItem>> _groupByRelativeDate(
    List<NotificationItem> items,
    AppLocalizations l10n,
  ) {
    final now = clock.now();
    final today = DateTime(now.year, now.month, now.day);
    final yesterday = today.subtract(const Duration(days: 1));

    final todayKey = l10n.notificationGroupToday;
    final yesterdayKey = l10n.notificationGroupYesterday;
    final earlierKey = l10n.notificationGroupEarlier;

    final groups = <String, List<NotificationItem>>{};
    for (final item in items) {
      final createdAt = DateTime.tryParse(item.createdAt);
      String key;
      if (createdAt == null) {
        key = earlierKey;
      } else {
        final date = DateTime(createdAt.year, createdAt.month, createdAt.day);
        if (date == today) {
          key = todayKey;
        } else if (date == yesterday) {
          key = yesterdayKey;
        } else {
          key = earlierKey;
        }
      }
      groups.putIfAbsent(key, () => []).add(item);
    }

    final orderedKeys = <String>[];
    if (groups.containsKey(todayKey)) orderedKeys.add(todayKey);
    if (groups.containsKey(yesterdayKey)) orderedKeys.add(yesterdayKey);
    if (groups.containsKey(earlierKey)) orderedKeys.add(earlierKey);

    return {for (final k in orderedKeys) k: groups[k]!};
  }
}

/// Discriminated union for the flattened notification list. Using a sealed
/// class lets `ListView.builder` pattern-match on the entry kind without
/// building off-screen rows.
sealed class _ListEntry {
  const _ListEntry();
}

class _HeaderEntry extends _ListEntry {
  const _HeaderEntry(this.title, {required this.isFirst});
  final String title;
  final bool isFirst;
}

class _ItemEntry extends _ListEntry {
  const _ItemEntry(
    this.item, {
    required this.onTap,
    required this.onDismiss,
    required this.onToggleRead,
  });
  final NotificationItem item;
  final VoidCallback onTap;
  final VoidCallback onDismiss;
  final VoidCallback onToggleRead;
}

class _LoadMoreEntry extends _ListEntry {
  const _LoadMoreEntry();
}

class _MarkAllReadButton extends StatelessWidget {
  const _MarkAllReadButton({required this.onPressed, this.hasUnread = true});

  final VoidCallback onPressed;
  final bool hasUnread;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;

    return FButton(
      variant: FButtonVariant.ghost,
      size: FButtonSizeVariant.sm,
      onPress: hasUnread ? onPressed : null,
      child: Text(l10n.notificationMarkAllRead),
    );
  }
}

class _EmptyView extends StatelessWidget {
  const _EmptyView();

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    return Padding(
      padding: const EdgeInsets.only(top: Spacing.level10),
      child: AppStateMessageView(
        title: l10n.notificationEmptyTitle,
        description: l10n.notificationEmptyDescription,
        icon: FLucideIcons.messageSquareMore,
        tone: AppStateTone.neutral,
      ),
    );
  }
}
