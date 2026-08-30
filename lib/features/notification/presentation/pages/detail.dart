import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:forui/forui.dart';
import 'package:go_router/go_router.dart';
import 'package:luminous/core/design/design.dart';
import 'package:luminous/core/errors/user_message.dart';
import 'package:luminous/core/feedback/toast.dart';
import 'package:luminous/core/logger/logger.dart';
import 'package:luminous/core/router/action_route_mapper.dart';
import 'package:luminous/core/utils/date_format_utils.dart';
import 'package:luminous/core/widgets/common/dialog_shell.dart';
import 'package:luminous/core/widgets/common/state_views.dart';
import 'package:luminous/core/widgets/layout/page_scaffold.dart';
import 'package:luminous/core/widgets/layout/responsive_content_frame.dart';
import 'package:luminous/features/notification/data/providers/unread_count.dart';
import 'package:luminous/features/notification/data/repositories/lucent.dart';
import 'package:luminous/features/notification/domain/entities/notification.dart';
import 'package:luminous/features/notification/presentation/providers/notification.dart';
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
          vertical: width < Breakpoints.mobile
              ? Spacing.level6
              : Spacing.level7,
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            detailAsync.when(
              data: (detail) {
                if (detail == null) {
                  return StateMessageView(
                    title: l10n.notificationNotFoundTitle,
                    description: l10n.notificationNotFoundDescription,
                    icon: SemanticIcons.statusBlocked,
                    tone: StateTone.neutral,
                  );
                }
                return _DetailBody(detail: detail);
              },
              loading: () => const Center(
                child: Padding(
                  padding: EdgeInsets.all(Spacing.level10),
                  child: SkeletonShimmer(
                    child: InlineSkeletonBlock(height: 120, widthFactor: 1),
                  ),
                ),
              ),
              error: (error, _) => StateErrorView(
                title: l10n.notificationErrorTitle,
                description: userMessageFromError(
                  error,
                  fallback: l10n.notificationErrorTitle,
                  l10n: l10n,
                ),
                icon: SemanticIcons.statusError,
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

class _DetailBody extends ConsumerStatefulWidget {
  const _DetailBody({required this.detail});

  final NotificationDetail detail;

  @override
  ConsumerState<_DetailBody> createState() => _DetailBodyState();
}

class _DetailBodyState extends ConsumerState<_DetailBody> {
  bool _autoMarkedRead = false;

  @override
  void initState() {
    super.initState();
    if (!widget.detail.isRead && !_autoMarkedRead) {
      _autoMarkedRead = true;
      WidgetsBinding.instance.addPostFrameCallback((_) => _autoMarkRead());
    }
  }

  Future<void> _autoMarkRead() async {
    if (!mounted) return;
    final repo = ref.read(notificationRepositoryProvider);
    try {
      final result = await repo.markAsRead(widget.detail.id).run();
      result.fold(
        (failure) {
          // 自动标记已读属 best-effort：失败仅记录日志，不打断详情页。
          appTalker.warning(
            'NotificationDetailPage auto-mark-read failed: $failure',
          );
        },
        (_) {
          ref.invalidate(notificationUnreadCountProvider);
          ref.invalidate(notificationListControllerProvider);
        },
      );
    } catch (e) {
      // 协议异常（非 problem+json 错误体）逃逸 .run()：自动标记已读仍属
      // best-effort，仅记录日志，不产生未处理异步异常（today 水目标同款）。
      appTalker.warning(
        'NotificationDetailPage auto-mark-read protocol error: $e',
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final colors = context.theme.colors;
    final detail = widget.detail;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _TypeChip(type: detail.type),
        const SizedBox(height: Spacing.level4),
        Text(
          detail.title,
          style: TypographyToken.level7
              .display(context)
              .copyWith(fontWeight: FontWeight.w700),
        ),
        const SizedBox(height: Spacing.level3),
        Text(
          _formatTime(context, detail.createdAt),
          style: TypographyToken.level3
              .body(context)
              .copyWith(color: colors.mutedForeground),
        ),
        const SizedBox(height: Spacing.level5),
        FCard(
          child: Padding(
            padding: const EdgeInsets.all(Spacing.level4),
            child: Text(
              detail.content,
              style: TypographyToken.level5.body(context).copyWith(height: 1.6),
            ),
          ),
        ),
        const SizedBox(height: Spacing.level7),
        _ActionBar(
          detail: detail,
          onNavigate: () => _handleAction(context, detail.action),
          onMarkRead: () async {
            final repo = ref.read(notificationRepositoryProvider);
            try {
              final result = await repo.markAsRead(detail.id).run();
              result.fold((failure) => throw failure, (_) {});
              ref.invalidate(notificationUnreadCountProvider);
              ref.invalidate(notificationListControllerProvider);
              ref.invalidate(notificationDetailProvider(detail.id));
              if (!context.mounted) return;
              unawaited(Toast.show(context, l10n.notificationMarkReadSuccess));
              context.pop();
            } catch (e) {
              // Left 投影为失败 toast；成功分支（成功 toast/pop）不执行。
              if (!context.mounted) return;
              unawaited(
                Toast.show(
                  context,
                  userMessageFromError(
                    e,
                    // 死路径兜底（LucentFailure.message 恒非空）：失败语义，
                    // 不再误用成功文案；l10n 无 mark 失败文案，故为空串。
                    fallback: '',
                    l10n: l10n,
                  ),
                ),
              );
            }
          },
          onMarkUnread: () async {
            final repo = ref.read(notificationRepositoryProvider);
            try {
              final result = await repo.markAsUnread(detail.id).run();
              result.fold((failure) => throw failure, (_) {});
              ref.invalidate(notificationUnreadCountProvider);
              ref.invalidate(notificationListControllerProvider);
              if (!context.mounted) return;
              unawaited(
                Toast.show(context, l10n.notificationMarkUnreadSuccess),
              );
              context.pop();
            } catch (e) {
              // Left 投影为失败 toast；成功分支（成功 toast/pop）不执行。
              if (!context.mounted) return;
              unawaited(
                Toast.show(
                  context,
                  userMessageFromError(
                    e,
                    // 死路径兜底（LucentFailure.message 恒非空）：失败语义，
                    // 不再误用成功文案；l10n 无 mark 失败文案，故为空串。
                    fallback: '',
                    l10n: l10n,
                  ),
                ),
              );
            }
          },
          onDelete: () async {
            final controller = ref.read(
              notificationListControllerProvider.notifier,
            );
            await controller.deleteNotification(detail.id);
            if (context.mounted) {
              unawaited(Toast.show(context, l10n.notificationDeleteSuccess));
              context.pop();
            }
          },
        ),
      ],
    );
  }

  String _formatTime(BuildContext context, String iso8601) {
    final locale = Localizations.localeOf(context);
    return formatDateTimeLabel(iso8601, locale, fallback: iso8601);
  }

  void _handleAction(BuildContext context, String? action) {
    final route = mapActionToRoute(action);
    if (route != null) {
      unawaited(context.push(route));
    }
  }
}

class _TypeChip extends StatelessWidget {
  const _TypeChip({required this.type});

  final NotificationType type;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final (label, color) = switch (type) {
      NotificationType.aiTodaySummary => (
        l10n.notificationTypeAiTodaySummary,
        SemanticColor.primary,
      ),
      NotificationType.aiWeeklyInsight => (
        l10n.notificationTypeAiWeeklyInsight,
        SemanticColor.primary,
      ),
      NotificationType.reportGenerated => (
        l10n.notificationTypeReportGenerated,
        SemanticColor.primary,
      ),
      NotificationType.passwordChanged => (
        l10n.notificationTypePasswordChanged,
        SemanticColor.destructive,
      ),
      NotificationType.aiProactiveSuggestion => (
        l10n.notificationTypeAiProactiveSuggestion,
        SemanticColor.primary,
      ),
      NotificationType.medicineMissedDose => (
        l10n.notificationTypeMedicineMissedDose,
        SemanticColor.destructive,
      ),
      NotificationType.medicineReminder => (
        l10n.notificationTypeMedicineReminder,
        SemanticColor.primary,
      ),
      NotificationType.systemAnnouncement => (
        l10n.notificationTypeSystemAnnouncement,
        SemanticColor.primary,
      ),
      NotificationType.oauthLogin => (
        l10n.notificationTypeOauthLogin,
        SemanticColor.destructive,
      ),
      NotificationType.identityLinked => (
        l10n.notificationTypeIdentityLinked,
        SemanticColor.primary,
      ),
      NotificationType.unknown => (
        l10n.notificationTypeUnknown,
        SemanticColor.neutral,
      ),
    };

    return DecoratedBox(
      decoration: BoxDecoration(
        color: color.muted(context),
        borderRadius: context.theme.style.borderRadius.xs,
      ),
      child: Padding(
        padding: const EdgeInsets.symmetric(
          horizontal: Spacing.level3,
          vertical: Spacing.level1,
        ),
        child: Text(
          label,
          style: TypographyToken.level4
              .body(context)
              .copyWith(
                color: color.solid(context),
                fontWeight: FontWeight.w600,
              ),
        ),
      ),
    );
  }
}

class _ActionBar extends StatelessWidget {
  const _ActionBar({
    required this.detail,
    required this.onNavigate,
    required this.onMarkRead,
    required this.onMarkUnread,
    required this.onDelete,
  });

  final NotificationDetail detail;
  final VoidCallback onNavigate;
  final VoidCallback onMarkRead;
  final VoidCallback onMarkUnread;
  final VoidCallback onDelete;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;

    final actions = <Widget>[
      if (detail.action?.isNotEmpty ?? false)
        FButton(
          onPress: onNavigate,
          prefix: const Icon(
            SemanticIcons.actionExternalLink,
            size: IconSizeTokens.level3,
          ),
          child: Text(l10n.notificationActionNavigate),
        ),
      if (detail.action?.isNotEmpty ?? false)
        const SizedBox(width: Spacing.level3),
      FButton(
        variant: FButtonVariant.outline,
        onPress: detail.isRead ? onMarkUnread : onMarkRead,
        prefix: Icon(
          detail.isRead
              ? SemanticIcons.notificationRead
              : SemanticIcons.statusAllDone,
          size: 18,
        ),
        child: Text(
          detail.isRead
              ? l10n.notificationActionMarkUnread
              : l10n.notificationActionMarkRead,
        ),
      ),
      const SizedBox(width: Spacing.level3),
      FButton(
        variant: FButtonVariant.destructive,
        onPress: () => _showDeleteConfirm(context, onDelete),
        prefix: const Icon(
          SemanticIcons.actionDelete,
          size: IconSizeTokens.level3,
        ),
        child: Text(l10n.notificationActionDelete),
      ),
    ];

    return Wrap(
      spacing: Spacing.level3,
      runSpacing: Spacing.level3,
      children: actions,
    );
  }

  void _showDeleteConfirm(BuildContext context, VoidCallback onDelete) {
    final l10n = AppLocalizations.of(context)!;
    unawaited(
      showAppDialog<void>(
        context: context,
        maxWidth: LayoutScaleResolver.wideDialogMaxWidthFor(
          MediaQuery.sizeOf(context).width,
        ),
        scrollable: false,
        builder: (context) => Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              l10n.notificationDeleteConfirmTitle,
              style: TypographyToken.level6.body(context),
            ),
            const SizedBox(height: Spacing.level3),
            Text(
              l10n.notificationDeleteConfirmDescription,
              style: TypographyToken.level4.body(context),
            ),
            const SizedBox(height: Spacing.level5),
            Row(
              mainAxisAlignment: MainAxisAlignment.end,
              children: [
                FButton(
                  variant: FButtonVariant.ghost,
                  onPress: () => Navigator.of(context).pop(),
                  child: Text(l10n.notificationDeleteConfirmCancel),
                ),
                const SizedBox(width: Spacing.level3),
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
      ),
    );
  }
}
