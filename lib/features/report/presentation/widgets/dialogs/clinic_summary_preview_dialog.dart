import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:forui/forui.dart';
import 'package:lucent_api/lucent_api.dart';
import 'package:luminous/core/analytics/product_event_service.dart';
import 'package:luminous/core/design/design.dart';
import 'package:luminous/core/errors/result.dart';
import 'package:luminous/core/errors/run_guarded.dart';
import 'package:luminous/core/feedback/toast.dart';
import 'package:luminous/core/network/api_paths.dart';
import 'package:luminous/core/network/client_providers.dart';
import 'package:luminous/core/widgets/common/dialog_shell.dart';
import 'package:luminous/features/report/presentation/providers/clinic_summary.dart';
import 'package:luminous/features/report/presentation/providers/dashboard.dart';
import 'package:luminous/features/report/presentation/utils/pdf_download.dart';
import 'package:luminous/features/report/presentation/widgets/shared/clinic_summary_content.dart';
import 'package:luminous/l10n/app_localizations.dart';
import 'package:share_plus/share_plus.dart';

/// Shows a dialog (desktop) or bottom sheet (mobile) that previews the
/// authenticated user's de-identified clinic summary.
///
/// The preview is fetched on-demand from
/// `POST /api/v1/user/reports/clinic-summary/preview`. The dialog includes
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
    shape: const RoundedRectangleBorder(
      borderRadius: BorderRadius.vertical(
        top: Radius.circular(RadiusTokens.level4),
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
  bool _isSharing = false;

  /// One previewed event per dialog presentation. Riverpod auto-retries a
  /// failed fetch with exponential backoff (invisible to the user), so
  /// without this flag a single failed preview would flood events; the first
  /// outcome of each dialog open is recorded, re-opening measures again.
  bool _previewMeasured = false;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final async = ref.watch(clinicSummaryPreviewProvider);

    // visit_summary_previewed 在服务端响应边界记录：AsyncData → success，
    // AsyncError → failure（失败不算 previewed）。每次对话框呈现只记一条
    // （自动重试与 rebuild 不重复计数）。
    ref.listen<AsyncValue<ClinicSummaryDto>>(clinicSummaryPreviewProvider, (
      _,
      next,
    ) {
      if (_previewMeasured) return;
      final service = ref.read(productEventServiceProvider);
      if (next.hasValue) {
        _previewMeasured = true;
        unawaited(
          service.trackVisitSummaryPreviewed(ProductEventResult.success),
        );
      } else if (next.hasError) {
        _previewMeasured = true;
        unawaited(
          service.trackVisitSummaryPreviewed(ProductEventResult.failure),
        );
      }
    });

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
                l10n.reportClinicSummaryLoading,
                style: TypographyToken.level3
                    .body(context)
                    .copyWith(color: context.theme.colors.mutedForeground),
              ),
            ],
          ),
        ),
      ),
      error: (e, _) => _ErrorView(
        message: l10n.reportClinicSummaryLoadFailed,
        onRetry: () => ref.invalidate(clinicSummaryPreviewProvider),
      ),
      data: (dto) => SingleChildScrollView(
        padding: const EdgeInsets.all(Spacing.level5),
        child: ClinicSummaryContent(
          dto: dto,
          onDownloadPdf: _downloadPdf,
          onShare: _share,
          isPdfDownloading: _isPdfDownloading,
          isSharing: _isSharing,
        ),
      ),
    );
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
        shareSubject: l10n.reportExportClinicShareTitle,
      );
      // visit_summary_exported 只在服务端响应边界记录：PDF 成功下载 →
      // success；空响应 / 失败 → failure，不得计为 exported。
      final service = ref.read(productEventServiceProvider);
      unawaited(
        service.trackVisitSummaryExported(
          result == PdfDownloadResult.success
              ? ProductEventResult.success
              : ProductEventResult.failure,
        ),
      );
      if (mounted) {
        switch (result) {
          case PdfDownloadResult.success:
            break;
          case PdfDownloadResult.empty:
            await Toast.show(context, l10n.reportClinicSummaryPdfEmpty);
          case PdfDownloadResult.failed:
            await Toast.show(context, l10n.reportClinicSummaryPdfFailed);
        }
      }
    } finally {
      if (mounted) {
        setState(() => _isPdfDownloading = false);
      }
    }
  }

  // ── Share ───────────────────────────────────────────────────────────────

  Future<void> _share() async {
    final l10n = AppLocalizations.of(context)!;
    final notifier = ref.read(clinicShareInFlightProvider.notifier);
    notifier.set(true);
    setState(() => _isSharing = true);
    try {
      final result = await runGuarded(
        ref: ref,
        tag: 'ClinicSummaryPreviewDialog._share',
        action: () async {
          final reportsApi = ref.read(lucentClientProvider).reports;
          // Empty request body: every field is optional and the server falls
          // back to the default last_30_days scope (legacy behavior).
          final response = await reportsApi
              .reportsControllerShareClinicSummaryV1(
                clinicSummaryRequestDto: ClinicSummaryRequestDto(),
              );
          final shareUrl = response.data!.shareUrl;
          if (shareUrl.isEmpty) {
            if (mounted) {
              await Toast.show(context, l10n.reportExportFailedToast);
            }
            return false;
          }
          await SharePlus.instance.share(
            ShareParams(
              text: shareUrl,
              subject: l10n.reportExportClinicShareTitle,
            ),
          );
          return true;
        },
      );
      switch (result) {
        case Success():
          break;
        case Failure(:final error):
          if (mounted) {
            await Toast.show(
              context,
              l10n.reportExportFailedWithReason(error.message),
            );
          }
      }
    } finally {
      notifier.set(false);
      if (mounted) {
        setState(() => _isSharing = false);
      }
    }
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
            style: TypographyToken.level4.body(context),
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
