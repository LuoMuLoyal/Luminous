import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:forui/forui.dart';
import 'package:go_router/go_router.dart';
import 'package:lucent_openapi/lucent_openapi.dart';
import 'package:luminous/core/design/app_design.dart';
import 'package:luminous/core/feedback/app_toast.dart';
import 'package:luminous/core/widgets/common/app_back_button.dart';
import 'package:luminous/core/widgets/common/app_state_views.dart';
import 'package:luminous/core/widgets/layout/page_scaffold_shell.dart';
import 'package:luminous/features/notification/presentation/providers/notification_providers.dart';
import 'package:luminous/features/notification/presentation/widgets/notification_list_item.dart';
import 'package:luminous/l10n/app_localizations.dart';

class NotificationListPage extends ConsumerWidget {
  const NotificationListPage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = AppLocalizations.of(context)!;
    final listAsync = ref.watch(notificationListControllerProvider);

    return PageScaffoldShell(
      leading: const AppBackButton(),
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
      children: [
        listAsync.when(
          data: (response) {
            final items = response.items;
            if (items.isEmpty) {
              return const _EmptyView();
            }
            final groups = _groupByRelativeDate(items);
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
                  const SizedBox(height: AppSpacingTokens.xs),
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
                          const SizedBox(height: AppSpacingTokens.sm),
                      ],
                    ],
                  ),
                  const SizedBox(height: AppSpacingTokens.md),
                ],
                if (hasMore) ...[
                  const SizedBox(height: AppSpacingTokens.md),
                  Center(
                    child: isLoadingMore
                        ? const SizedBox(
                            width: 24,
                            height: 24,
                            child: CircularProgressIndicator(strokeWidth: 2),
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
              padding: EdgeInsets.all(AppSpacingTokens.x5l),
              child: AppSkeletonShimmer(
                child: Column(
                  children: [
                    AppInlineSkeletonBlock(height: 64, widthFactor: 1),
                    SizedBox(height: AppSpacingTokens.md),
                    AppInlineSkeletonBlock(height: 64, widthFactor: 1),
                    SizedBox(height: AppSpacingTokens.md),
                    AppInlineSkeletonBlock(height: 64, widthFactor: 1),
                    SizedBox(height: AppSpacingTokens.md),
                    AppInlineSkeletonBlock(height: 64, widthFactor: 1),
                    SizedBox(height: AppSpacingTokens.md),
                    AppInlineSkeletonBlock(height: 64, widthFactor: 1),
                    SizedBox(height: AppSpacingTokens.md),
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
            onAction: () => ref.invalidate(notificationListControllerProvider),
          ),
        ),
      ],
    );
  }

  Map<String, List<NotificationListItemDto>> _groupByRelativeDate(
    List<NotificationListItemDto> items,
  ) {
    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);
    final yesterday = today.subtract(const Duration(days: 1));

    final groups = <String, List<NotificationListItemDto>>{};
    for (final item in items) {
      final createdAt = DateTime.tryParse(item.createdAt);
      String key;
      if (createdAt == null) {
        key = '更早';
      } else {
        final date = DateTime(createdAt.year, createdAt.month, createdAt.day);
        if (date == today) {
          key = '今天';
        } else if (date == yesterday) {
          key = '昨天';
        } else {
          key = '更早';
        }
      }
      groups.putIfAbsent(key, () => []).add(item);
    }

    final orderedKeys = <String>[];
    if (groups.containsKey('今天')) orderedKeys.add('今天');
    if (groups.containsKey('昨天')) orderedKeys.add('昨天');
    if (groups.containsKey('更早')) orderedKeys.add('更早');

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
    final textTheme = Theme.of(context).textTheme;

    return Padding(
      padding: const EdgeInsets.only(
        left: AppSpacingTokens.sm,
        top: AppSpacingTokens.sm,
      ),
      child: Text(
        title,
        style: textTheme.labelMedium?.copyWith(
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
      padding: const EdgeInsets.only(top: AppSpacingTokens.x5l),
      child: AppStateMessageView(
        title: l10n.notificationEmptyTitle,
        description: l10n.notificationEmptyDescription,
        icon: FLucideIcons.messageSquareMore,
        tone: AppStateTone.neutral,
      ),
    );
  }
}
