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
import 'package:luminous/core/utils/date_format.dart';
import 'package:luminous/core/widgets/common/dialog/dialog_shell.dart';
import 'package:luminous/features/review/presentation/providers/clinic_summary.dart';
import 'package:luminous/features/review/presentation/providers/dashboard.dart';
import 'package:luminous/features/review/presentation/utils/pdf_download.dart';
import 'package:luminous/features/review/presentation/widgets/shared/clinic_summary_content.dart';
import 'package:luminous/features/review/presentation/widgets/shared/components.dart';
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

/// Share flow step shown inside the dialog after tapping [Share summary].
enum _ShareStep {
  /// Ask for confirmation, showing the expiry and the
  /// "anyone with the link can view" notice before creating.
  confirm,

  /// Link created — offer copy and revoke.
  created,

  /// Share revoked — the link no longer works.
  revoked,
}

class _ClinicSummaryPreviewContentState
    extends ConsumerState<_ClinicSummaryPreviewContent> {
  bool _isPdfDownloading = false;
  bool _isCreatingShare = false;
  bool _isRevokingShare = false;

  /// The current field-level privacy selection. Defaults to every field
  /// except the free-text notes (notes are off by default).
  List<ReportsControllerPreviewClinicSummaryV1RequestSelectedFieldsEnum>
  _selectedFields = kClinicSummaryDefaultFields;

  /// Active share flow step, or null when showing the summary content.
  _ShareStep? _shareStep;

  /// The created share — set once [_ShareStep.created] is reached.
  ClinicSummaryShareResponseDto? _shareResponse;

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
    ref.listen<AsyncValue<ClinicSummaryResponseDto>>(
      clinicSummaryPreviewProvider(_selectedFields),
      (_, next) {
        if (_previewMeasured) return;
        final service = ref.read(productEventServiceProvider);
        if (next.hasValue) {
          _previewMeasured = true;
          unawaited(
            service.trackVisitSummaryPreviewed(
              ProductEventsControllerRecordBatchV1RequestEventsInnerResultEnum
                  .success,
            ),
          );
        } else if (next.hasError) {
          _previewMeasured = true;
          unawaited(
            service.trackVisitSummaryPreviewed(
              ProductEventsControllerRecordBatchV1RequestEventsInnerResultEnum
                  .failure,
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
      error: (e, _) => _ErrorView(
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
            _FieldSelectionPanel(
              selectedFields: _selectedFields,
              // During the created/revoked steps the shown link is already
              // fixed — toggling must not silently re-run the preview behind
              // it. During the confirm step toggling stays enabled because it
              // affects the share being created.
              enabled: _shareStep == null || _shareStep == _ShareStep.confirm,
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
    List<ReportsControllerPreviewClinicSummaryV1RequestSelectedFieldsEnum> next,
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
        postBody: ReportsControllerPreviewClinicSummaryV1Request(
          selectedFields: _selectedFields,
        ).toJson(),
      );
      // visit_summary_exported 只在服务端响应边界记录：PDF 成功下载 →
      // success；空响应 / 失败 → failure，不得计为 exported。
      final service = ref.read(productEventServiceProvider);
      unawaited(
        service.trackVisitSummaryExported(
          result == PdfDownloadResult.success
              ? ProductEventsControllerRecordBatchV1RequestEventsInnerResultEnum
                    .success
              : ProductEventsControllerRecordBatchV1RequestEventsInnerResultEnum
                    .failure,
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
      _shareStep = _ShareStep.confirm;
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
      final response = await api.reportsControllerShareClinicSummaryV1(
        reportsControllerPreviewClinicSummaryV1Request:
            ReportsControllerPreviewClinicSummaryV1Request(
              selectedFields: _selectedFields,
            ),
      );
      final value = response.data!;
      // The share list is cached (keepAlive) — invalidate it so the
      // management sheet shows the newly created share on next open.
      ref.invalidate(clinicSummaryShareListProvider);
      if (mounted) {
        setState(() {
          _shareResponse = value;
          _shareStep = _ShareStep.created;
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
      await api.reportsControllerRevokeClinicSummaryShareV1(shareId: shareId);
      if (mounted) {
        setState(() => _shareStep = _ShareStep.revoked);
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
      _ShareStep.confirm => _ShareConfirmPanel(
        isCreating: _isCreatingShare,
        hasNotes: _selectedFields.contains(
          ReportsControllerPreviewClinicSummaryV1RequestSelectedFieldsEnum
              .notes,
        ),
        onCancel: _closeShareFlow,
        onConfirm: _createShare,
      ),
      _ShareStep.created => _ShareCreatedPanel(
        response: _shareResponse!,
        isRevoking: _isRevokingShare,
        onCopy: _copyLink,
        onRevoke: _revokeShare,
        onClose: _closeShareFlow,
      ),
      _ShareStep.revoked => _ShareRevokedPanel(onClose: _closeShareFlow),
    };
  }
}

// ── Field selection panel ───────────────────────────────────────────────────

/// Per-field privacy toggles: 事件概况 / 症状变化 / 用药槽位 / 饮水 / 睡眠 /
/// 备注. The free-text notes field defaults to off; the last remaining
/// selected field cannot be toggled off (an empty selection is impossible).
class _FieldSelectionPanel extends StatelessWidget {
  const _FieldSelectionPanel({
    required this.selectedFields,
    required this.enabled,
    required this.onChanged,
  });

  final List<ReportsControllerPreviewClinicSummaryV1RequestSelectedFieldsEnum>
  selectedFields;

  /// Whether the toggles can be changed. Disabled once the share link is
  /// created/revoked, so the preview cannot silently change behind the
  /// shown link.
  final bool enabled;

  final ValueChanged<
    List<ReportsControllerPreviewClinicSummaryV1RequestSelectedFieldsEnum>
  >
  onChanged;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final typography = context.theme.typography;
    return Column(
      mainAxisSize: MainAxisSize.min,
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          l10n.reviewClinicSummaryFieldSectionTitle,
          style: typography.body.sm.copyWith(fontWeight: FontWeight.w700),
        ),
        const SizedBox(height: Spacing.level2),
        for (final field in kClinicSummaryAllFields) ...[
          _FieldToggle(
            key: Key('clinic-summary-field-${field.value}'),
            label: _fieldLabel(l10n, field),
            selected: selectedFields.contains(field),
            // The last remaining selection cannot be disabled — an empty
            // field selection is rejected by the server.
            enabled:
                enabled &&
                (selectedFields.contains(field)
                    ? selectedFields.length > 1
                    : true),
            onChanged: (value) => onChanged(
              value
                  ? [...selectedFields, field]
                  : ([...selectedFields]..remove(field)),
            ),
          ),
          if (field != kClinicSummaryAllFields.last)
            const SizedBox(height: Spacing.level1),
        ],
        const SizedBox(height: Spacing.level2),
        Text(
          l10n.reviewClinicSummaryFieldPrivacyHint,
          style: typography.body.xs.copyWith(
            color: SemanticColor.neutral.solid(context),
          ),
        ),
      ],
    );
  }

  String _fieldLabel(
    AppLocalizations l10n,
    ReportsControllerPreviewClinicSummaryV1RequestSelectedFieldsEnum field,
  ) {
    return switch (field) {
      ReportsControllerPreviewClinicSummaryV1RequestSelectedFieldsEnum
          .eventOverview =>
        l10n.reviewClinicSummaryFieldEventOverview,
      ReportsControllerPreviewClinicSummaryV1RequestSelectedFieldsEnum
          .symptomChanges =>
        l10n.reviewClinicSummaryFieldSymptomChanges,
      ReportsControllerPreviewClinicSummaryV1RequestSelectedFieldsEnum
          .medicationSlots =>
        l10n.reviewClinicSummaryFieldMedicationSlots,
      ReportsControllerPreviewClinicSummaryV1RequestSelectedFieldsEnum.water =>
        l10n.reviewClinicSummaryFieldWater,
      ReportsControllerPreviewClinicSummaryV1RequestSelectedFieldsEnum.sleep =>
        l10n.reviewClinicSummaryFieldSleep,
      ReportsControllerPreviewClinicSummaryV1RequestSelectedFieldsEnum.notes =>
        l10n.reviewClinicSummaryFieldNotes,
      ReportsControllerPreviewClinicSummaryV1RequestSelectedFieldsEnum
          .unknownDefaultOpenApi =>
        field.value,
    };
  }
}

class _FieldToggle extends StatelessWidget {
  const _FieldToggle({
    super.key,
    required this.label,
    required this.selected,
    required this.enabled,
    required this.onChanged,
  });

  final String label;
  final bool selected;
  final bool enabled;
  final ValueChanged<bool> onChanged;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        FCheckbox(
          value: selected,
          enabled: enabled,
          // The visible label is a separate Text in the row — expose it to
          // screen readers via the checkbox semantics (register.dart
          // pattern).
          semanticsLabel: label,
          onChange: enabled ? onChanged : null,
        ),
        const SizedBox(width: Spacing.level3),
        Expanded(child: Text(label, style: context.theme.typography.body.sm)),
      ],
    );
  }
}

// ── Share flow panels ───────────────────────────────────────────────────────

/// Pre-creation confirmation: expiry + "anyone with the link can view".
class _ShareConfirmPanel extends StatelessWidget {
  const _ShareConfirmPanel({
    required this.isCreating,
    required this.hasNotes,
    required this.onCancel,
    required this.onConfirm,
  });

  final bool isCreating;

  /// Whether the notes field is currently selected — when true, an extra
  /// privacy warning is shown because notes appear in plain text to anyone
  /// with the share link (R-2).
  final bool hasNotes;

  final VoidCallback onCancel;
  final VoidCallback onConfirm;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    return Column(
      mainAxisSize: MainAxisSize.min,
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          l10n.reviewShareConfirmTitle,
          style: context.theme.typography.body.lg.copyWith(
            fontWeight: FontWeight.w700,
          ),
        ),
        const SizedBox(height: Spacing.level4),
        _NoticeRow(
          icon: SemanticIcons.safetyTiming,
          iconColor: SemanticColor.neutral.solid(context),
          text: l10n.reviewShareConfirmExpiryHint(7),
        ),
        const SizedBox(height: Spacing.level3),
        _NoticeRow(
          icon: SemanticIcons.safetySafe,
          iconColor: SemanticColor.primary.solid(context),
          text: l10n.reviewShareConfirmNotice,
        ),
        if (hasNotes) ...[
          const SizedBox(height: Spacing.level3),
          _NoticeRow(
            icon: SemanticIcons.statusWarning,
            iconColor: SemanticColor.warning.solid(context),
            text: l10n.reviewClinicSummaryNotesPrivacyWarning,
          ),
        ],
        const SizedBox(height: Spacing.level5),
        Row(
          children: [
            Expanded(
              child: FButton(
                variant: FButtonVariant.outline,
                onPress: isCreating ? null : onCancel,
                child: Text(l10n.commonCancel),
              ),
            ),
            const SizedBox(width: Spacing.level3),
            Expanded(
              child: FButton(
                variant: FButtonVariant.primary,
                onPress: isCreating ? null : onConfirm,
                child: isCreating
                    ? const SizedBox(
                        width: 18,
                        height: 18,
                        child: FCircularProgress(),
                      )
                    : Text(l10n.reviewShareConfirmAction),
              ),
            ),
          ],
        ),
      ],
    );
  }
}

/// Post-creation: the link itself with COPY and REVOKE actions.
class _ShareCreatedPanel extends StatelessWidget {
  const _ShareCreatedPanel({
    required this.response,
    required this.isRevoking,
    required this.onCopy,
    required this.onRevoke,
    required this.onClose,
  });

  final ClinicSummaryShareResponseDto response;
  final bool isRevoking;
  final VoidCallback onCopy;
  final VoidCallback onRevoke;
  final VoidCallback onClose;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final locale = Localizations.localeOf(context);
    final typography = context.theme.typography;

    return Column(
      mainAxisSize: MainAxisSize.min,
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          l10n.reviewShareCreatedTitle,
          style: typography.body.lg.copyWith(fontWeight: FontWeight.w700),
        ),
        const SizedBox(height: Spacing.level3),
        MetaRow(
          label: l10n.reviewShareCreatedExpiresAt,
          value: formatDateTimeFull(response.expiresAt, locale),
        ),
        const SizedBox(height: Spacing.level4),
        FCard(
          child: Padding(
            padding: const EdgeInsets.all(Spacing.level4),
            child: Text(
              response.shareUrl,
              style: typography.body.xs.copyWith(
                color: SemanticColor.neutral.solid(context),
              ),
            ),
          ),
        ),
        const SizedBox(height: Spacing.level4),
        Row(
          children: [
            Expanded(
              child: FButton(
                variant: FButtonVariant.outline,
                onPress: isRevoking ? null : onCopy,
                child: Text(l10n.reviewShareCopyAction),
              ),
            ),
            const SizedBox(width: Spacing.level3),
            Expanded(
              child: FButton(
                variant: FButtonVariant.outline,
                onPress: isRevoking ? null : onRevoke,
                child: isRevoking
                    ? const SizedBox(
                        width: 18,
                        height: 18,
                        child: FCircularProgress(),
                      )
                    : Text(l10n.reviewShareRevokeAction),
              ),
            ),
          ],
        ),
        const SizedBox(height: Spacing.level3),
        FButton(
          variant: FButtonVariant.ghost,
          onPress: isRevoking ? null : onClose,
          child: Text(l10n.commonClose),
        ),
      ],
    );
  }
}

/// Terminal state after revocation: the link no longer works.
class _ShareRevokedPanel extends StatelessWidget {
  const _ShareRevokedPanel({required this.onClose});

  final VoidCallback onClose;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final typography = context.theme.typography;
    return Column(
      mainAxisSize: MainAxisSize.min,
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Icon(
          SemanticIcons.statusWarning,
          size: 28,
          color: SemanticColor.neutral.solid(context),
        ),
        const SizedBox(height: Spacing.level3),
        Text(
          l10n.reviewShareRevokedTitle,
          style: typography.body.lg.copyWith(fontWeight: FontWeight.w700),
        ),
        const SizedBox(height: Spacing.level2),
        Text(
          l10n.reviewShareRevokedBody,
          style: typography.body.xs.copyWith(
            color: SemanticColor.neutral.solid(context),
          ),
        ),
        const SizedBox(height: Spacing.level5),
        FButton(
          variant: FButtonVariant.primary,
          onPress: onClose,
          child: Text(l10n.commonClose),
        ),
      ],
    );
  }
}

class _NoticeRow extends StatelessWidget {
  const _NoticeRow({
    required this.icon,
    required this.iconColor,
    required this.text,
  });

  final IconData icon;
  final Color iconColor;
  final String text;

  @override
  Widget build(BuildContext context) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.only(top: 2),
          child: Icon(icon, size: 16, color: iconColor),
        ),
        const SizedBox(width: Spacing.level3),
        Expanded(child: Text(text, style: context.theme.typography.body.xs)),
      ],
    );
  }
}

// ── Error view ──────────────────────────────────────────────────────────────

class _ErrorView extends StatelessWidget {
  const _ErrorView({required this.message, required this.onRetry});

  final String message;
  final VoidCallback onRetry;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;

    return Padding(
      padding: const EdgeInsets.all(Spacing.level5),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(
            SemanticIcons.statusWarning,
            size: 32,
            color: SemanticColor.warning.solid(context),
          ),
          const SizedBox(height: Spacing.level3),
          Text(
            message,
            style: context.theme.typography.body.sm,
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: Spacing.level4),
          FButton(
            variant: FButtonVariant.outline,
            onPress: onRetry,
            child: Text(l10n.todayRetryAction),
          ),
        ],
      ),
    );
  }
}
