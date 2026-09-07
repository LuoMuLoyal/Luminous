import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:forui/forui.dart';
import 'package:lucent_api/lucent_api.dart';
import 'package:luminous/core/analytics/product_event_service.dart';
import 'package:luminous/core/design/design.dart';
import 'package:luminous/core/feedback/toast.dart';
import 'package:luminous/core/logger/log_level.dart';
import 'package:luminous/core/network/client/client_providers.dart';
import 'package:luminous/core/network/contract/api_paths.dart';
import 'package:luminous/core/widgets/common/dialog/dialog_shell.dart';
import 'package:luminous/features/review/presentation/providers/clinic_summary.dart';
import 'package:luminous/features/review/presentation/providers/dashboard.dart';
import 'package:luminous/features/review/presentation/utils/clinic_summary_field_mapping.dart';
import 'package:luminous/features/review/presentation/utils/pdf_download.dart';
import 'package:luminous/features/review/presentation/widgets/dialogs/clinic_summary_error_state.dart';
import 'package:luminous/features/review/presentation/widgets/dialogs/clinic_summary_field_selection.dart';
import 'package:luminous/features/review/presentation/widgets/dialogs/clinic_summary_share_flow.dart';
import 'package:luminous/features/review/presentation/widgets/shared/clinic_summary_content.dart';
import 'package:luminous/l10n/app_localizations.dart';

/// Shows a dialog (desktop) or bottom sheet (mobile) that previews the
/// authenticated user's de-identified clinic summary.
///
/// The preview is fetched on-demand from
/// `POST /api/v1/user/reports/clinic-summary/preview`, with the field-level
/// privacy selection (event overview / symptom changes / medication slots /
/// water / sleep / notes) forwarded in the request. The dialog includes
/// [Download PDF] and [Share summary] action buttons — the summary is meant
/// to be used as needed during a visit, it does not imply a doctor will
/// view it.
Future<void> showClinicSummaryPreviewDialog(BuildContext context) {
  final isDesktop = MediaQuery.sizeOf(context).width >= Breakpoints.desktop;

  if (isDesktop) {
    return showFDialog<void>(
      context: context,
      builder: (dialogContext, _, __) => DialogShell(
        maxWidth: LayoutScaleResolver.wideDialogMaxWidthFor(
          MediaQuery.sizeOf(context).width,
        ),
        builder: (_) => const _ClinicSummaryPreviewContent(),
      ),
    );
  }

  return showModalBottomSheet<void>(
    context: context,
    isScrollControlled: true,
    shape: RoundedRectangleBorder(
      borderRadius: BorderRadius.vertical(
        top: context.theme.style.borderRadius.md.topLeft,
      ),
    ),
    builder: (_) => SafeArea(
      child: Padding(
        padding: EdgeInsets.only(
          bottom: MediaQuery.viewInsetsOf(context).bottom,
        ),
        child: const _ClinicSummaryPreviewContent(),
      ),
    ),
  );
}

// ── Content ─────────────────────────────────────────────────────────────────

class _ClinicSummaryPreviewContent extends ConsumerStatefulWidget {
  const _ClinicSummaryPreviewContent();

  @override
  ConsumerState<_ClinicSummaryPreviewContent> createState() =>
      _ClinicSummaryPreviewContentState();
}

class _ClinicSummaryPreviewContentState
    extends ConsumerState<_ClinicSummaryPreviewContent> {
  bool _isPdfDownloading = false;
  bool _isCreatingShare = false;
  bool _isRevokingShare = false;

  /// The current field-level privacy selection. Defaults to every field
  /// except the free-text notes (notes are off by default).
  List<PreviewClinicSummaryRequestSelectedFieldsEnum> _selectedFields =
      kClinicSummaryDefaultFields;

  /// Active share flow step, or null when showing the summary content.
  ClinicSummaryShareStep? _shareStep;

  /// The created share — set once [ClinicSummaryShareStep.created] is reached.
  ClinicSummaryShareResponse? _shareResponse;

  /// One previewed event per dialog presentation. Riverpod auto-retries a
  /// failed fetch with exponential backoff (invisible to the user), so
  /// without this flag a single failed preview would flood events; the first
  /// outcome of each dialog open is recorded, re-opening measures again.
  /// Field toggles re-fetch the preview but do not re-measure.
  bool _previewMeasured = false;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final async = ref.watch(clinicSummaryPreviewProvider(_selectedFields));

    // visit_summary_previewed 在服务端响应边界记录：AsyncData → success，
    // AsyncError → failure（失败不算 previewed）。每次对话框呈现只记一条
    // （自动重试与 rebuild 不重复计数）。
    ref.listen<AsyncValue<ClinicSummaryResponse>>(
      clinicSummaryPreviewProvider(_selectedFields),
      (_, next) {
        if (_previewMeasured) return;
        final service = ref.read(productEventServiceProvider);
        if (next.hasValue) {
          _previewMeasured = true;
          unawaited(
            service.trackVisitSummaryPreviewed(
              RecordBatchRequestEventsResultEnum.success,
            ),
          );
        } else if (next.hasError) {
          _previewMeasured = true;
          unawaited(
            service.trackVisitSummaryPreviewed(
              RecordBatchRequestEventsResultEnum.failure,
            ),
          );
        }
      },
    );

    return async.when(
      loading: () => SizedBox(
        height: 200,
        child: Center(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const SizedBox(width: 24, height: 24, child: FCircularProgress()),
              const SizedBox(height: Spacing.level3),
              Text(
                l10n.reviewClinicSummaryLoading,
                style: context.theme.typography.body.xs.copyWith(
                  color: SemanticColor.neutral.solid(context),
                ),
              ),
            ],
          ),
        ),
      ),
      error: (e, _) => ClinicSummaryErrorView(
        message: l10n.reviewClinicSummaryLoadFailed,
        onRetry: () =>
            ref.invalidate(clinicSummaryPreviewProvider(_selectedFields)),
      ),
      data: (dto) => SingleChildScrollView(
        padding: const EdgeInsets.all(Spacing.level5),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            ClinicSummaryFieldSelectionPanel(
              selectedFields: _selectedFields,
              // During the created/revoked steps the shown link is already
              // fixed — toggling must not silently re-run the preview behind
              // it. During the confirm step toggling stays enabled because it
              // affects the share being created.
              enabled:
                  _shareStep == null ||
                  _shareStep == ClinicSummaryShareStep.confirm,
              onChanged: _updateSelection,
            ),
            const SizedBox(height: Spacing.level4),
            if (_shareStep == null)
              ClinicSummaryContent(
                dto: dto,
                onDownloadPdf: _downloadPdf,
                onShare: _openShareConfirm,
                isPdfDownloading: _isPdfDownloading,
              )
            else
              _buildShareStep(l10n),
          ],
        ),
      ),
    );
  }

  // ── Field selection ─────────────────────────────────────────────────────

  void _updateSelection(
    List<PreviewClinicSummaryRequestSelectedFieldsEnum> next,
  ) {
    // Empty selection is impossible: the panel disables the last remaining
    // toggle, and this guard keeps the state consistent either way.
    if (next.isEmpty) return;
    setState(() => _selectedFields = next);
  }

  // ── PDF download ────────────────────────────────────────────────────────

  Future<void> _downloadPdf() async {
    final l10n = AppLocalizations.of(context)!;
    final dio = ref.read(lucentDioClientProvider).dio;

    setState(() => _isPdfDownloading = true);
    try {
      final result = await downloadAndSharePdf(
        dio: dio,
        path: LucentApiPaths.clinicSummaryPreviewPdf,
        fileNamePrefix: 'clinic-summary',
        shareSubject: l10n.reviewExportClinicShareTitle,
        // 预览 PDF 是 POST 接口，请求体携带字段选择——未选择的字段不会
        // 出现在 PDF 里（与服务端 preview/share 同一过滤视图）。
        postBody: PreviewClinicSummaryRequest(
          selectedFields: _selectedFields,
        ).toJson(),
      );
      // visit_summary_exported 只在服务端响应边界记录：PDF 成功下载 →
      // success；空响应 / 失败 → failure，不得计为 exported。
      final service = ref.read(productEventServiceProvider);
      unawaited(
        service.trackVisitSummaryExported(
          result == PdfDownloadResult.success
              ? RecordBatchRequestEventsResultEnum.success
              : RecordBatchRequestEventsResultEnum.failure,
        ),
      );
      if (mounted) {
        switch (result) {
          case PdfDownloadResult.success:
            break;
          case PdfDownloadResult.empty:
            await Toast.show(context, l10n.reviewClinicSummaryPdfEmpty);
          case PdfDownloadResult.failed:
            await Toast.show(context, l10n.reviewClinicSummaryPdfFailed);
        }
      }
    } finally {
      if (mounted) {
        setState(() => _isPdfDownloading = false);
      }
    }
  }

  // ── Share ───────────────────────────────────────────────────────────────

  /// Opens the share confirmation step: expiry + "anyone with the link can
  /// view" are shown BEFORE the share is created, and the copy never implies
  /// a doctor received it.
  void _openShareConfirm() {
    setState(() {
      _shareStep = ClinicSummaryShareStep.confirm;
      _shareResponse = null;
    });
  }

  void _closeShareFlow() {
    setState(() => _shareStep = null);
  }

  Future<void> _createShare() async {
    final l10n = AppLocalizations.of(context)!;
    final notifier = ref.read(clinicShareInFlightProvider.notifier);
    notifier.set(true);
    setState(() => _isCreatingShare = true);
    try {
      // 生成客户端直接反序列化资源，无需再手动解包。
      // 请求体携带当前字段选择，未选择字段不会进入分享内容。
      // 创建失败（网络 / 服务端业务失败；空响应体的协议异常逃逸）统一
      // 提示失败，字段选择保持可重试（widget 不读 code/status）。
      final api = ref.read(lucentClientProvider).reports;
      // share 与 preview 请求在 per-op 化改造后是各自独立生成的枚举，成员
      // 与 wire 值一一对应，这里按 wire value 互转（UI 状态仍用 preview 枚举）。
      final body = ShareClinicSummaryRequest(
        selectedFields: mapPreviewFieldsToShare(_selectedFields),
      );
      final response = await api.shareClinicSummary(
        shareClinicSummaryRequest: body,
      );
      final value = response.data!;
      // The share list is cached (keepAlive) — invalidate it so the
      // management sheet shows the newly created share on next open.
      ref.invalidate(clinicSummaryShareListProvider);
      if (mounted) {
        setState(() {
          _shareResponse = value;
          _shareStep = ClinicSummaryShareStep.created;
        });
      }
    } catch (error) {
      // 创建失败（网络 / 服务端业务失败 / 协议异常逃逸）统一提示失败，
      // 字段选择保持可重试（widget 不读 code/status）。
      ref
          .read(talkerProvider)
          .error('ClinicSummaryPreviewDialog._createShare: failed: $error');
      if (mounted) {
        await Toast.show(context, l10n.reviewShareCreateFailed);
      }
    } finally {
      notifier.set(false);
      if (mounted) {
        setState(() => _isCreatingShare = false);
      }
    }
  }

  Future<void> _copyLink() async {
    final l10n = AppLocalizations.of(context)!;
    final url = _shareResponse?.shareUrl ?? '';
    if (url.isEmpty) return;
    await Clipboard.setData(ClipboardData(text: url));
    if (mounted) {
      await Toast.show(context, l10n.reviewShareCopiedToast);
    }
  }

  Future<void> _revokeShare() async {
    final l10n = AppLocalizations.of(context)!;
    final shareId = _shareResponse?.shareId;
    if (shareId == null || shareId.isEmpty) {
      if (mounted) {
        await Toast.show(context, l10n.reviewShareRevokeFailed);
      }
      return;
    }
    setState(() => _isRevokingShare = true);
    try {
      // 撤销失败（网络 / 服务端业务失败 / 协议异常逃逸）统一提示失败，
      // created 步骤保持可重试（widget 不读 code/status）。
      final api = ref.read(lucentClientProvider).reports;
      await api.revokeClinicSummaryShare(shareId: shareId);
      if (mounted) {
        setState(() => _shareStep = ClinicSummaryShareStep.revoked);
      }
    } catch (error) {
      // 撤销失败（网络 / 服务端业务失败 / 协议异常逃逸）统一提示失败，
      // created 步骤保持可重试（widget 不读 code/status）。
      ref
          .read(talkerProvider)
          .error('ClinicSummaryPreviewDialog._revokeShare: failed: $error');
      if (mounted) {
        await Toast.show(context, l10n.reviewShareRevokeFailed);
      }
    } finally {
      if (mounted) {
        setState(() => _isRevokingShare = false);
      }
    }
  }

  Widget _buildShareStep(AppLocalizations l10n) {
    return switch (_shareStep!) {
      ClinicSummaryShareStep.confirm => ClinicSummaryShareConfirmPanel(
        isCreating: _isCreatingShare,
        hasNotes: _selectedFields.contains(
          PreviewClinicSummaryRequestSelectedFieldsEnum.notes,
        ),
        onCancel: _closeShareFlow,
        onConfirm: _createShare,
      ),
      ClinicSummaryShareStep.created => ClinicSummaryShareCreatedPanel(
        response: _shareResponse!,
        isRevoking: _isRevokingShare,
        onCopy: _copyLink,
        onRevoke: _revokeShare,
        onClose: _closeShareFlow,
      ),
      ClinicSummaryShareStep.revoked => ClinicSummaryShareRevokedPanel(
        onClose: _closeShareFlow,
      ),
    };
  }
}
