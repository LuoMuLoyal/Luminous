import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:lucent_openapi/lucent_openapi.dart';
import 'package:luminous/core/design/app_design.dart';
import 'package:luminous/core/feedback/app_toast.dart';
import 'package:luminous/core/theme/app_theme_extensions.dart';
import 'package:luminous/core/widgets/app_state_views.dart';
import 'package:luminous/core/widgets/page_scaffold_shell.dart';
import 'package:luminous/core/network/lucent_network_providers.dart';
import 'package:luminous/features/notification/presentation/providers/notification_providers.dart';
import 'package:luminous/l10n/app_localizations.dart';

class NotificationDetailPage extends ConsumerWidget {
  const NotificationDetailPage({super.key, required this.notificationId});

  final String notificationId;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = AppLocalizations.of(context)!;
    final theme = Theme.of(context);
    final surface = theme.extension<AppThemeSurface>()!;
    final typography = AppTypographyTokens.mobile(theme.colorScheme.onSurface);
    final detailAsync = ref.watch(notificationDetailProvider(notificationId));

    return PageScaffoldShell(
      title: l10n.notificationDetailTitle,
      leading: IconButton(
        onPressed: () => context.pop(),
        icon: const Icon(Icons.arrow_back_rounded),
      ),
      children: [
        detailAsync.when(
          data: (detail) {
            if (detail == null) {
              return AppStateMessageView(
                title: l10n.notificationNotFoundTitle,
                description: l10n.notificationNotFoundDescription,
                icon: Icons.notifications_off_outlined,
                tone: AppStateTone.neutral,
              );
            }
            return _DetailBody(
              detail: detail,
              typography: typography,
              surface: surface,
              theme: theme,
            );
          },
          loading: () => const Center(
            child: Padding(
              padding: EdgeInsets.all(AppSpacingTokens.x5l),
              child: AppSkeletonShimmer(
                child: AppInlineSkeletonBlock(height: 120, widthFactor: 1),
              ),
            ),
          ),
          error: (error, _) => AppStateErrorView(
            title: l10n.notificationErrorTitle,
            description: error.toString(),
            icon: Icons.error_outline_rounded,
            actionLabel: l10n.notificationRetryAction,
            onAction: () =>
                ref.invalidate(notificationDetailProvider(notificationId)),
          ),
        ),
      ],
    );
  }
}

class _DetailBody extends ConsumerWidget {
  const _DetailBody({
    required this.detail,
    required this.typography,
    required this.surface,
    required this.theme,
  });

  final NotificationDetailDto detail;
  final AppTypographyScale typography;
  final AppThemeSurface surface;
  final ThemeData theme;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = AppLocalizations.of(context)!;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _TypeChip(type: detail.type),
        const SizedBox(height: AppSpacingTokens.md),
        Text(
          detail.title,
          style: typography.displaySm.copyWith(fontWeight: FontWeight.w700),
        ),
        const SizedBox(height: AppSpacingTokens.sm),
        Text(
          _formatTime(detail.createdAt),
          style: typography.caption.copyWith(
            color: theme.colorScheme.onSurfaceVariant,
          ),
        ),
        const SizedBox(height: AppSpacingTokens.lg),
        Container(
          padding: const EdgeInsets.all(AppSpacingTokens.md),
          decoration: BoxDecoration(
            color: surface.canvasSoft,
            borderRadius: BorderRadius.circular(AppRadiusTokens.md),
            border: Border.all(color: surface.hairline),
          ),
          child: Text(
            detail.content,
            style: typography.bodyMd.copyWith(height: 1.6),
          ),
        ),
        const SizedBox(height: AppSpacingTokens.x2l),
        _ActionBar(
          detail: detail,
          onNavigate: () => _handleAction(context, detail.action),
          onMarkUnread: () async {
            final api = ref.read(lucentNotificationsApiProvider);
            await api.notificationsControllerMarkAsUnreadV1(id: detail.id);
            ref.invalidate(notificationUnreadCountProvider);
            ref.invalidate(notificationListControllerProvider);
            if (context.mounted) {
              AppToast.show(context, l10n.notificationMarkUnreadSuccess);
              context.pop();
            }
          },
          onDelete: () async {
            final controller = ref.read(
              notificationListControllerProvider.notifier,
            );
            await controller.deleteNotification(detail.id);
            if (context.mounted) {
              AppToast.show(context, l10n.notificationDeleteSuccess);
              context.pop();
            }
          },
        ),
      ],
    );
  }

  String _formatTime(String iso8601) {
    final dt = DateTime.tryParse(iso8601);
    if (dt == null) return iso8601;
    return '${dt.year}-${dt.month.toString().padLeft(2, '0')}-${dt.day.toString().padLeft(2, '0')} '
        '${dt.hour.toString().padLeft(2, '0')}:${dt.minute.toString().padLeft(2, '0')}';
  }

  void _handleAction(BuildContext context, String? action) {
    if (action == null || action.isEmpty) return;

    final route = switch (action) {
      'today' => '/',
      'report' => '/report',
      'assistant' => '/assistant',
      'medicine' => '/medicine',
      'record' => '/record',
      'mine' => '/mine',
      'settings' => '/settings',
      _ => action.startsWith('/') ? action : null,
    };

    if (route != null) {
      context.push(route);
    }
  }
}

class _TypeChip extends StatelessWidget {
  const _TypeChip({required this.type});

  final UserNotificationType type;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final typography = AppTypographyTokens.mobile(theme.colorScheme.onSurface);

    final (label, color) = switch (type) {
      UserNotificationType.aiTodaySummary => ('AI 总结', Colors.teal),
      UserNotificationType.reportGenerated => ('报告', Colors.blue),
      UserNotificationType.passwordChanged => ('安全', Colors.orange),
      UserNotificationType.aiProactiveSuggestion => ('AI 建议', Colors.purple),
      UserNotificationType.medicineMissedDose => ('用药', Colors.red),
      UserNotificationType.medicineReminder => ('提醒', Colors.green),
      UserNotificationType.systemAnnouncement => ('系统', Colors.indigo),
      UserNotificationType.unknownDefaultOpenApi => ('通知', Colors.grey),
    };

    return Container(
      padding: const EdgeInsets.symmetric(
        horizontal: AppSpacingTokens.sm,
        vertical: AppSpacingTokens.xxs,
      ),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.12),
        borderRadius: BorderRadius.circular(AppRadiusTokens.sm),
      ),
      child: Text(
        label,
        style: typography.caption.copyWith(
          color: color,
          fontWeight: FontWeight.w600,
        ),
      ),
    );
  }
}

class _ActionBar extends StatelessWidget {
  const _ActionBar({
    required this.detail,
    required this.onNavigate,
    required this.onMarkUnread,
    required this.onDelete,
  });

  final NotificationDetailDto detail;
  final VoidCallback onNavigate;
  final VoidCallback onMarkUnread;
  final VoidCallback onDelete;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final theme = Theme.of(context);

    final children = <Widget>[
      if (detail.action != null && detail.action!.isNotEmpty)
        Expanded(
          child: FilledButton.icon(
            onPressed: onNavigate,
            icon: const Icon(Icons.open_in_new_rounded, size: 18),
            label: Text(l10n.notificationActionNavigate),
          ),
        ),
      if (detail.action != null && detail.action!.isNotEmpty)
        const SizedBox(width: AppSpacingTokens.sm),
      Expanded(
        child: OutlinedButton.icon(
          onPressed: onMarkUnread,
          icon: Icon(
            detail.isRead ? Icons.mark_email_unread_outlined : Icons.done_all,
            size: 18,
          ),
          label: Text(
            detail.isRead
                ? l10n.notificationActionMarkUnread
                : l10n.notificationActionMarkRead,
          ),
          style: OutlinedButton.styleFrom(
            foregroundColor: theme.colorScheme.onSurface,
            side: BorderSide(color: theme.colorScheme.outline),
          ),
        ),
      ),
      const SizedBox(width: AppSpacingTokens.sm),
      Expanded(
        child: OutlinedButton.icon(
          onPressed: () => _showDeleteConfirm(context, onDelete),
          icon: const Icon(Icons.delete_outline, size: 18),
          label: Text(l10n.notificationActionDelete),
          style: OutlinedButton.styleFrom(
            foregroundColor: theme.colorScheme.error,
            side: BorderSide(color: theme.colorScheme.error),
          ),
        ),
      ),
    ];

    if (detail.action == null || detail.action!.isEmpty) {
      return Row(
        children: [
          Expanded(
            child: OutlinedButton.icon(
              onPressed: onMarkUnread,
              icon: Icon(
                detail.isRead
                    ? Icons.mark_email_unread_outlined
                    : Icons.done_all,
                size: 18,
              ),
              label: Text(
                detail.isRead
                    ? l10n.notificationActionMarkUnread
                    : l10n.notificationActionMarkRead,
              ),
              style: OutlinedButton.styleFrom(
                foregroundColor: theme.colorScheme.onSurface,
                side: BorderSide(color: theme.colorScheme.outline),
              ),
            ),
          ),
          const SizedBox(width: AppSpacingTokens.sm),
          Expanded(
            child: OutlinedButton.icon(
              onPressed: () => _showDeleteConfirm(context, onDelete),
              icon: const Icon(Icons.delete_outline, size: 18),
              label: Text(l10n.notificationActionDelete),
              style: OutlinedButton.styleFrom(
                foregroundColor: theme.colorScheme.error,
                side: BorderSide(color: theme.colorScheme.error),
              ),
            ),
          ),
        ],
      );
    }

    return Row(children: children);
  }

  void _showDeleteConfirm(BuildContext context, VoidCallback onDelete) {
    final l10n = AppLocalizations.of(context)!;
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(l10n.notificationDeleteConfirmTitle),
        content: Text(l10n.notificationDeleteConfirmDescription),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: Text(l10n.notificationDeleteConfirmCancel),
          ),
          FilledButton(
            onPressed: () {
              Navigator.of(context).pop();
              onDelete();
            },
            child: Text(l10n.notificationDeleteConfirmConfirm),
          ),
        ],
      ),
    );
  }
}
