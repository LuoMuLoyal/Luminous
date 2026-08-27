import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:luminous/core/design/design.dart';
import 'package:luminous/core/errors/lucent_failure.dart';
import 'package:luminous/core/feedback/toast.dart';
import 'package:luminous/core/network/api_paths.dart';
import 'package:luminous/core/network/client_providers.dart';
import 'package:luminous/core/network/error_mapper.dart';
import 'package:luminous/core/widgets/common/state_views.dart';
import 'package:luminous/core/widgets/layout/page_scaffold.dart';
import 'package:luminous/features/review/presentation/providers/clinic_summary.dart';
import 'package:luminous/features/review/presentation/utils/pdf_download.dart';
import 'package:luminous/features/review/presentation/widgets/shared/clinic_summary_content.dart';
import 'package:luminous/l10n/app_localizations.dart';

/// Public page that displays a shared clinic summary by token.
///
/// Accessible without authentication at `/report/clinic-summary/:token`.
/// The page fetches the shared summary via
/// `GET /api/v1/user/reports/clinic-summary/shared/{token}` and renders
/// the same [ClinicSummaryContent] used by the preview dialog, but with
/// only a [Download PDF] button (no share button).
class ClinicSummarySharedPage extends ConsumerStatefulWidget {
  const ClinicSummarySharedPage({super.key, required this.token});

  final String token;

  @override
  ConsumerState<ClinicSummarySharedPage> createState() =>
      _ClinicSummarySharedPageState();
}

class _ClinicSummarySharedPageState
    extends ConsumerState<ClinicSummarySharedPage> {
  bool _isPdfDownloading = false;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final async = ref.watch(clinicSummarySharedProvider(widget.token));

    return PageScaffold(
      title: l10n.reviewClinicSummarySharedTitle,
      child: async.when(
        loading: () => const StateSkeletonView(
          blocks: [
            StateSkeletonBlock(height: 16, widthFactor: 0.5),
            StateSkeletonBlock(height: 16, widthFactor: 0.7),
            StateSkeletonBlock(height: 28, widthFactor: 0.9),
            StateSkeletonBlock(height: 16, widthFactor: 0.6),
            StateSkeletonBlock(height: 16, widthFactor: 0.8),
            StateSkeletonBlock(height: 28, widthFactor: 0.9),
            StateSkeletonBlock(height: 16, widthFactor: 0.4),
          ],
        ),
        error: (error, _) {
          final failure = LucentErrorMapper.fromObject(error);
          final isNetworkError = failure.kind == LucentFailureKind.network;

          return StateErrorView(
            title: isNetworkError
                ? l10n.reviewClinicSummarySharedNetworkError
                : l10n.reviewClinicSummarySharedExpired,
            description: l10n.reviewClinicSummaryLoadFailed,
            icon: isNetworkError
                ? SemanticIcons.statusUnavailable
                : SemanticIcons.statusWarning,
            tone: StateTone.warning,
            actionLabel: isNetworkError ? l10n.todayRetryAction : null,
            onAction: isNetworkError
                ? () =>
                      ref.invalidate(clinicSummarySharedProvider(widget.token))
                : null,
          );
        },
        data: (dto) => SingleChildScrollView(
          padding: const EdgeInsets.all(Spacing.level5),
          child: ClinicSummaryContent(
            dto: dto,
            onDownloadPdf: _downloadPdf,
            isPdfDownloading: _isPdfDownloading,
          ),
        ),
      ),
    );
  }

  // ── PDF download (public endpoint, no auth) ──────────────────────────────

  Future<void> _downloadPdf() async {
    final l10n = AppLocalizations.of(context)!;
    final dio = ref.read(lucentDioClientProvider).dio;

    setState(() => _isPdfDownloading = true);
    try {
      final result = await downloadAndSharePdf(
        dio: dio,
        path: LucentApiPaths.clinicSummarySharedPdf(widget.token),
        fileNamePrefix: 'clinic-summary-shared',
        shareSubject: l10n.reviewClinicSummarySharedTitle,
        skipAuth: true,
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
}
