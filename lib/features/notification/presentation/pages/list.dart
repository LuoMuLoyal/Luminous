import 'dart:async';

import 'package:clock/clock.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:forui/forui.dart';
import 'package:go_router/go_router.dart';
import 'package:luminous/core/design/design.dart';
import 'package:luminous/core/feedback/toast.dart';
import 'package:luminous/core/widgets/layout/page_scaffold.dart';
import 'package:luminous/core/widgets/common/state_views.dart';
import 'package:luminous/core/widgets/layout/responsive_content_frame.dart';
import 'package:luminous/features/notification/domain/entities/notification.dart';
import 'package:luminous/features/notification/presentation/providers/notification.dart';
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
        ),
      ],
      child: SingleChildScrollView(
        child: ResponsiveContentFrame(
          child: Padding(
            padding: const EdgeInsets.symmetric(vertical: 24),
            child: listAsync.when(
              data: (page) {
                final items = page.items;
                if (items.isEmpty) {
                  return const _EmptyView();
                }
                final groups = _groupByRelativeDate(items, l10n);
                final controller = ref.read(
                  notificationListControllerProvider.notifier,
                );
                final isLoadingMore = ref.watch(
                  notificationListLoadingMoreProvider,
                );
                final hasMore = controller.hasMore;
                return Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    for (final entry in groups.entries) ...[
                      _SectionHeader(title: entry.key),
                      const SizedBox(height: Spacing.level2),
                      Column(
                        children: [
                          for (
                            var index = 0;
                            index < entry.value.length;
                            index++
                          ) ...[
                            NotificationListItemWidget(
                              item: entry.value[index],
                              onTap: () => context.push(
                                '/notifications/${entry.value[index].id}',
                              ),
                              onDismiss: () async {
                                final controller = ref.read(
                                  notificationListControllerProvider.notifier,
                                );
                                await controller.deleteNotification(
                                  entry.value[index].id,
                                );
                                if (context.mounted) {
                                  unawaited(
                                    AppToast.show(
                                      context,
                                      l10n.notificationDeleteSuccess,
                                    ),
                                  );
                                }
                              },
                            ),
                            if (index < entry.value.length - 1)
                              const SizedBox(height: Spacing.level3),
                          ],
                        ],
                      ),
                      const SizedBox(height: Spacing.level4),
                    ],
                    if (hasMore) ...[
                      const SizedBox(height: Spacing.level4),
                      Center(
                        child: isLoadingMore
                            ? const SizedBox(
                                width: 24,
                                height: 24,
                                child: FCircularProgress(),
                              )
                            : FButton(
                                variant: FButtonVariant.outline,
                                onPress: () => controller.loadMore(),
                                child: Text(l10n.notificationLoadMore),
                              ),
                      ),
                    ],
                  ],
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
                description: error.toString(),
                icon: FLucideIcons.circleAlert,
                actionLabel: l10n.notificationRetryAction,
                onAction: () =>
                    ref.invalidate(notificationListControllerProvider),
              ),
            ),
          ),
        ),
      ),
    );
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

class _MarkAllReadButton extends StatelessWidget {
  const _MarkAllReadButton({required this.onPressed});

  final VoidCallback onPressed;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;

    return FButton(
      variant: FButtonVariant.ghost,
      size: FButtonSizeVariant.sm,
      onPress: onPressed,
      child: Text(l10n.notificationMarkAllRead),
    );
  }
}

class _SectionHeader extends StatelessWidget {
  const _SectionHeader({required this.title});

  final String title;

  @override
  Widget build(BuildContext context) {
    final colors = context.theme.colors;

    return Padding(
      padding: const EdgeInsets.only(left: Spacing.level3, top: Spacing.level3),
      child: Text(
        title,
        style: TypographyToken.level4
            .body(context)
            .copyWith(
              color: colors.mutedForeground,
              fontWeight: FontWeight.w600,
            ),
      ),
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
