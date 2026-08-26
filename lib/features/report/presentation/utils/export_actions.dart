import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:lucent_api/lucent_api.dart';
import 'package:luminous/app/router.dart';
import 'package:luminous/core/analytics/product_event_service.dart';
import 'package:luminous/core/auth/session_provider.dart';
import 'package:luminous/core/errors/lucent_failure.dart';
import 'package:luminous/core/errors/user_message.dart';
import 'package:luminous/core/feedback/toast.dart';
import 'package:luminous/core/logger/logger.dart';
import 'package:luminous/core/providers/sensitive_action_password.dart';
import 'package:luminous/core/router/external_url_launcher.dart';
import 'package:luminous/features/auth/presentation/widgets/shared/required_dialog.dart';
import 'package:luminous/features/report/domain/entities/dashboard.dart';
import 'package:luminous/features/report/presentation/widgets/dialogs/clinic_summary_preview_dialog.dart';
import 'package:luminous/features/report/presentation/widgets/shared/section_models.dart';
import 'package:luminous/features/settings/presentation/providers/data_export.dart';
import 'package:luminous/features/settings/presentation/providers/user_settings.dart';
import 'package:luminous/l10n/app_localizations.dart';

/// 导出/分享动作的统一处理（Task 8：从旧 dashboard 页装配提取，供
/// Review 页 More sheet 与 legacy 兼容 dashboard 复用）。
///
/// 行为与旧 `ReportPage._handleExportAction` 完全一致，不改变任何后端
/// API 调用与数据流：
/// - `clinicShare` 先打开诊所摘要预览弹窗，分享在弹窗内触发；
/// - 其余 kind 走 security elevation（PIN 验证）→ `POST` data-export
///   request → 打开下载链接 / 状态 toast。
Future<void> handleReportExportAction(
  BuildContext context,
  WidgetRef ref,
  ReportExportKind kind,
) async {
  final l10n = AppLocalizations.of(context)!;
  final session = ref.read(authSessionProvider);
  if (!session.canAccessProtectedData) {
    unawaited(pushAuthRequiredRoute(context, '/report'));
    return;
  }

  // 就诊摘要（旧 clinicShare）：先弹预览，分享在预览内触发。
  if (kind == ReportExportKind.clinicShare) {
    await showClinicSummaryPreviewDialog(context);
    return;
  }

  final input = reportExportInputForKind(kind);
  if (input == null) return;

  // Task 8: account password re-authentication replaces Security PIN elevation.
  // If the server says password re-auth is not required, skip the dialog.
  final settings = ref.read(userSettingsControllerProvider).value;
  final requiresPassword = settings?.passwordReauthenticationRequired ?? true;
  final String? password;
  if (requiresPassword) {
    password = await ref.read(sensitiveActionPasswordPromptProvider)(context);
    if (password == null || !context.mounted) return;
  } else {
    password = '';
  }

  final controller = ref.read(dataExportControllerProvider.notifier);
  final launcher = ref.read(externalUrlLauncherProvider);

  final DataExportRequestDataDto? value;
  try {
    value = await controller.requestExport(input, password: password);
  } catch (error) {
    // 请求抛错（网络 / 服务端业务失败，LucentFailure；协议 FormatException
    // 逃逸亦在此捕获）：失败不计为 exported，talker 记录 + toast 提示。
    ref
        .read(talkerProvider)
        .error('ReportExportActions: export failed: $error');
    unawaited(
      ref
          .read(productEventServiceProvider)
          .trackVisitSummaryExported(ProductEventResult.failure),
    );
    if (!context.mounted) return;
    // S-2: If the user has no local password (OAuth-only), provide an
    // actionable toast that deep-links to the account settings page.
    final failure = error is LucentFailure ? error : null;
    if (failure != null && failure.isPasswordNotSet) {
      await Toast.showWithAction(
        context,
        l10n.authPasswordNotSetToast,
        l10n.authPasswordNotSetAction,
        () => context.go(Routes.account),
      );
      return;
    }
    await Toast.show(
      context,
      '${l10n.reportExportFailedToast}: ${userMessageFromError(error, l10n: l10n)}',
    );
    return;
  }
  // visit_summary_exported 只在服务端成功响应后记录（More sheet 的
  // PDF/打印导出与 legacy 导出卡同走此路径）；HTTP 成功但请求本身处于
  // 失败/闲置状态（_handleExportResult 对它们显示失败 toast）时记录
  // failure，不得计为 exported。requested/processing 表示服务端已受理
  // 导出（异步产物），与 completed 一样按 success 记录。
  final uiStatus = dataExportUiStatusForRequest(value);
  final exported = switch (uiStatus) {
    DataExportUiStatus.idle ||
    DataExportUiStatus.failed ||
    DataExportUiStatus.unavailable => ProductEventResult.failure,
    DataExportUiStatus.requested ||
    DataExportUiStatus.processing ||
    DataExportUiStatus.completed ||
    DataExportUiStatus.completedLinkMissing => ProductEventResult.success,
  };
  unawaited(
    ref.read(productEventServiceProvider).trackVisitSummaryExported(exported),
  );
  if (!context.mounted) return;
  await _handleExportResult(
    context: context,
    ref: ref,
    launcher: launcher,
    request: value,
  );
}

Future<void> _handleExportResult({
  required BuildContext context,
  required WidgetRef ref,
  required ExternalUrlLauncher launcher,
  required DataExportRequestDataDto? request,
}) async {
  final l10n = AppLocalizations.of(context)!;
  switch (dataExportUiStatusForRequest(request)) {
    case DataExportUiStatus.idle:
      await Toast.show(context, l10n.reportExportFailedToast);
      return;
    case DataExportUiStatus.completed:
    case DataExportUiStatus.completedLinkMissing:
      final latest = await ref
          .read(dataExportControllerProvider.notifier)
          .refresh();
      if (!context.mounted) {
        return;
      }
      final completedRequest = latest ?? request;
      if (completedRequest == null) {
        await Toast.show(context, l10n.reportExportFailedToast);
        return;
      }
      final downloadUrl = completedRequest.downloadUrl;
      if (downloadUrl == null || downloadUrl.isEmpty) {
        await Toast.show(context, l10n.reportExportLinkMissingToast);
        return;
      }

      final opened = await launcher.open(Uri.parse(downloadUrl));
      if (!context.mounted) {
        return;
      }
      await Toast.show(
        context,
        opened ? l10n.reportExportReadyToast : l10n.reportExportOpenFailedToast,
      );
      return;
    case DataExportUiStatus.requested:
      await Toast.show(context, l10n.reportExportRequestedToast);
      return;
    case DataExportUiStatus.processing:
      await Toast.show(context, l10n.reportExportProcessingToast);
      return;
    case DataExportUiStatus.failed:
    case DataExportUiStatus.unavailable:
      await Toast.show(
        context,
        request?.errorMessage?.isNotEmpty == true
            ? request?.errorMessage ?? ''
            : dataExportUiStatusForRequest(request) ==
                  DataExportUiStatus.unavailable
            ? l10n.reportExportUnavailableToast
            : l10n.reportExportFailedToast,
      );
      return;
  }
}
