import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:lucent_openapi/lucent_openapi.dart';
import 'package:luminous/core/design/app_design.dart';
import 'package:luminous/core/feedback/app_toast.dart';
import 'package:luminous/core/widgets/app_state_views.dart';
import 'package:luminous/core/widgets/page_scaffold_shell.dart';
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
      title: l10n.notificationListTitle,
      actions: [
        _MarkAllReadButton(
          onPressed: () async {
            final controller = ref.read(
              notificationListControllerProvider.notifier,
            );
            await controller.markAllAsRead();
            if (context.mounted) {
              AppToast.show(context, l10n.notificationMarkAllReadSuccess);
            }
          },
        ),
      ],
      children: [
        listAsync.when(
          data: (response) {
            final items = response.items;
            if (items.isEmpty) {
              return _EmptyView();
            }
            final groups = _groupByRelativeDate(items);
            return Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                for (final entry in groups.entries) ...[
                  _SectionHeader(title: entry.key),
                  const SizedBox(height: AppSpacingTokens.xs),
                  ...entry.value.map((item) {
                    return NotificationListItemWidget(
                      item: item,
                      onTap: () => context.push('/notifications/${item.id}'),
                      onDismiss: () async {
                        final controller = ref.read(
                          notificationListControllerProvider.notifier,
                        );
                        await controller.deleteNotification(item.id);
                        if (context.mounted) {
                          AppToast.show(
                            context,
                            l10n.notificationDeleteSuccess,
                          );
                        }
                      },
                    );
                  }),
                  const SizedBox(height: AppSpacingTokens.md),
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
            icon: Icons.error_outline_rounded,
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

    // Sort keys: today first, then yesterday, then older
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
    final theme = Theme.of(context);

    return TextButton(
      onPressed: onPressed,
      child: Text(
        l10n.notificationMarkAllRead,
        style: TextStyle(
          color: theme.colorScheme.primary,
          fontWeight: FontWeight.w600,
        ),
      ),
    );
  }
}

class _SectionHeader extends StatelessWidget {
  const _SectionHeader({required this.title});

  final String title;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final typography = AppTypographyTokens.mobile(theme.colorScheme.onSurface);

    return Padding(
      padding: const EdgeInsets.only(
        left: AppSpacingTokens.sm,
        top: AppSpacingTokens.sm,
      ),
      child: Text(
        title,
        style: typography.bodySmStrong.copyWith(
          color: theme.colorScheme.onSurfaceVariant,
        ),
      ),
    );
  }
}

class _EmptyView extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    return Padding(
      padding: const EdgeInsets.only(top: AppSpacingTokens.x5l),
      child: AppStateMessageView(
        title: l10n.notificationEmptyTitle,
        description: l10n.notificationEmptyDescription,
        icon: Icons.notifications_none_rounded,
        tone: AppStateTone.neutral,
      ),
    );
  }
}
