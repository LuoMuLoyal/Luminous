import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:forui/forui.dart';
import 'package:go_router/go_router.dart';
import 'package:lucent_openapi/lucent_openapi.dart';
import 'package:luminous/core/design/app_design.dart';
import 'package:luminous/core/feedback/app_toast.dart';
import 'package:luminous/core/network/lucent_network_providers.dart';
import 'package:luminous/core/router/action_route_mapper.dart';
import 'package:luminous/core/widgets/layout/page_scaffold.dart';
import 'package:luminous/core/widgets/common/app_dialog_shell.dart';
import 'package:luminous/core/widgets/common/app_state_views.dart';
import 'package:luminous/core/design/app_breakpoints.dart';
import 'package:luminous/core/widgets/layout/responsive_content_frame.dart';
import 'package:luminous/features/notification/presentation/providers/notification_providers.dart';
import 'package:luminous/l10n/app_localizations.dart';

class NotificationDetailPage extends ConsumerWidget {
  const NotificationDetailPage({super.key, required this.notificationId});

  final String notificationId;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = AppLocalizations.of(context)!;
    final detailAsync = ref.watch(notificationDetailProvider(notificationId));

    final width = MediaQuery.sizeOf(context).width;
    final content = ResponsiveContentFrame(
      child: Padding(
        padding: EdgeInsets.symmetric(
          vertical: width < AppBreakpoints.mobile ? 24 : 32,
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            detailAsync.when(
              data: (detail) {
                if (detail == null) {
                  return AppStateMessageView(
                    title: l10n.notificationNotFoundTitle,
                    description: l10n.notificationNotFoundDescription,
                    icon: FLucideIcons.bellOff,
                    tone: AppStateTone.neutral,
                  );
                }
                return _DetailBody(detail: detail);
              },
              loading: () => const Center(
                child: Padding(
                  padding: EdgeInsets.all(AppSpacingTokens.level10),
                  child: AppSkeletonShimmer(
                    child: AppInlineSkeletonBlock(height: 120, widthFactor: 1),
                  ),
                ),
              ),
              error: (error, _) => AppStateErrorView(
                title: l10n.notificationErrorTitle,
                description: error.toString(),
                icon: FLucideIcons.circleAlert,
                actionLabel: l10n.notificationRetryAction,
                onAction: () =>
                    ref.invalidate(notificationDetailProvider(notificationId)),
              ),
            ),
          ],
        ),
      ),
    );

    return PageScaffold(
      title: l10n.notificationDetailTitle,
      centerTitle: false,
      child: SingleChildScrollView(child: content),
    );
  }
}

class _DetailBody extends ConsumerWidget {
  const _DetailBody({required this.detail});

  final NotificationDetailDto detail;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = AppLocalizations.of(context)!;
    final colors = context.theme.colors;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _TypeChip(type: detail.type),
        const SizedBox(height: AppSpacingTokens.level4),
        Text(
          detail.title,
          style: AppTypographyToken.level7
              .display(context)
              .copyWith(fontWeight: FontWeight.w700),
        ),
        const SizedBox(height: AppSpacingTokens.level3),
        Text(
          _formatTime(detail.createdAt),
          style: AppTypographyToken.level3
              .body(context)
              .copyWith(color: colors.mutedForeground),
        ),
        const SizedBox(height: AppSpacingTokens.level5),
        FCard.raw(
          child: Padding(
            padding: const EdgeInsets.all(AppSpacingTokens.level4),
            child: Text(
              detail.content,
              style: AppTypographyToken.level5
                  .body(context)
                  .copyWith(height: 1.6),
            ),
          ),
        ),
        const SizedBox(height: AppSpacingTokens.level7),
        _ActionBar(
          detail: detail,
          onNavigate: () => _handleAction(context, detail.action),
          onMarkUnread: () async {
            final api = ref.read(lucentNotificationsApiProvider);
            await api.notificationsControllerMarkAsUnreadV1(id: detail.id);
            ref.invalidate(notificationUnreadCountProvider);
            ref.invalidate(notificationListControllerProvider);
            if (context.mounted) {
              unawaited(
                AppToast.show(context, l10n.notificationMarkUnreadSuccess),
              );
              context.pop();
            }
          },
          onDelete: () async {
            final controller = ref.read(
              notificationListControllerProvider.notifier,
            );
            await controller.deleteNotification(detail.id);
            if (context.mounted) {
              unawaited(AppToast.show(context, l10n.notificationDeleteSuccess));
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
    final route = mapActionToRoute(action);
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
    final colors = context.theme.colors;
    final (label, color) = switch (type) {
      UserNotificationType.aiTodaySummary => ('AI 总结', colors.primary),
      UserNotificationType.reportGenerated => ('报告', colors.primary),
      UserNotificationType.passwordChanged => ('安全', colors.destructive),
      UserNotificationType.aiProactiveSuggestion => ('AI 建议', colors.primary),
      UserNotificationType.medicineMissedDose => ('用药', colors.destructive),
      UserNotificationType.medicineReminder => ('提醒', colors.primary),
      UserNotificationType.systemAnnouncement => ('系统', colors.primary),
      UserNotificationType.unknownDefaultOpenApi => (
        '通知',
        colors.mutedForeground,
      ),
    };

    return DecoratedBox(
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.12),
        borderRadius: BorderRadius.circular(AppRadiusTokens.level2),
      ),
      child: Padding(
        padding: const EdgeInsets.symmetric(
          horizontal: AppSpacingTokens.level3,
          vertical: AppSpacingTokens.level1,
        ),
        child: Text(
          label,
          style: AppTypographyToken.level4
              .body(context)
              .copyWith(color: color, fontWeight: FontWeight.w600),
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

    final actions = <Widget>[
      if (detail.action != null && detail.action!.isNotEmpty)
        Expanded(
          child: FButton(
            onPress: onNavigate,
            prefix: const Icon(FLucideIcons.externalLink, size: 18),
            child: Text(l10n.notificationActionNavigate),
          ),
        ),
      if (detail.action != null && detail.action!.isNotEmpty)
        const SizedBox(width: AppSpacingTokens.level3),
      Expanded(
        child: FButton(
          variant: FButtonVariant.outline,
          onPress: onMarkUnread,
          prefix: Icon(
            detail.isRead ? FLucideIcons.mailMinus : FLucideIcons.checkCheck,
            size: 18,
          ),
          child: Text(
            detail.isRead
                ? l10n.notificationActionMarkUnread
                : l10n.notificationActionMarkRead,
          ),
        ),
      ),
      const SizedBox(width: AppSpacingTokens.level3),
      Expanded(
        child: FButton(
          variant: FButtonVariant.destructive,
          onPress: () => _showDeleteConfirm(context, onDelete),
          prefix: const Icon(FLucideIcons.trash2, size: 18),
          child: Text(l10n.notificationActionDelete),
        ),
      ),
    ];

    return Row(children: actions);
  }

  void _showDeleteConfirm(BuildContext context, VoidCallback onDelete) {
    final l10n = AppLocalizations.of(context)!;
    showAppDialog<void>(
      context: context,
      maxWidth: 420,
      scrollable: false,
      builder: (context) => Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            l10n.notificationDeleteConfirmTitle,
            style: AppTypographyToken.level6.body(context),
          ),
          const SizedBox(height: AppSpacingTokens.level3),
          Text(
            l10n.notificationDeleteConfirmDescription,
            style: AppTypographyToken.level4.body(context),
          ),
          const SizedBox(height: AppSpacingTokens.level5),
          Row(
            mainAxisAlignment: MainAxisAlignment.end,
            children: [
              FButton(
                variant: FButtonVariant.ghost,
                onPress: () => Navigator.of(context).pop(),
                child: Text(l10n.notificationDeleteConfirmCancel),
              ),
              const SizedBox(width: AppSpacingTokens.level3),
              FButton(
                variant: FButtonVariant.destructive,
                onPress: () {
                  Navigator.of(context).pop();
                  onDelete();
                },
                child: Text(l10n.notificationDeleteConfirmConfirm),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
