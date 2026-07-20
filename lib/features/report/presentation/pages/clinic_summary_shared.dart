import 'dart:io';

import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:forui/forui.dart';
import 'package:path_provider/path_provider.dart';
import 'package:share_plus/share_plus.dart';

import 'package:luminous/core/design/design.dart';
import 'package:luminous/core/feedback/toast.dart';
import 'package:luminous/core/network/api_paths.dart';
import 'package:luminous/core/network/network_providers.dart';
import 'package:luminous/core/widgets/common/state_views.dart';
import 'package:luminous/core/widgets/layout/page_scaffold.dart';
import 'package:luminous/features/report/presentation/providers/clinic_summary.dart';
import 'package:luminous/features/report/presentation/widgets/shared/clinic_summary_content.dart';
import 'package:luminous/l10n/app_localizations.dart';

/// Public page that displays a shared clinic summary by token.
///
/// Accessible without authentication at `/report/clinic-summary/:token`.
/// The page fetches the shared summary via
/// `GET /api/v1/user/reports/clinic-summary/shared/{token}` and renders
/// the same [ClinicSummaryContent] used by the preview dialog, but with
/// only a [下载 PDF] button (no share button).
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
      title: l10n.reportClinicSummarySharedTitle,
      child: async.when(
        loading: () => const Center(child: FCircularProgress()),
        error: (_, __) => AppStateErrorView(
          title: l10n.reportClinicSummarySharedExpired,
          description: l10n.reportClinicSummaryLoadFailed,
          icon: FLucideIcons.triangleAlert,
          tone: AppStateTone.warning,
        ),
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
      final response = await dio.get<List<int>>(
        LucentApiPaths.clinicSummarySharedPdf(widget.token),
        options: Options(
          responseType: ResponseType.bytes,
          extra: const {'skipAuthorization': true},
        ),
      );
      final bytes = response.data ?? <int>[];
      if (bytes.isEmpty) {
        if (mounted) {
          await AppToast.show(context, l10n.reportClinicSummaryPdfEmpty);
        }
        return;
      }

      final dir = await getTemporaryDirectory();
      final file = File(
        '${dir.path}/clinic-summary-shared-${DateTime.now().millisecondsSinceEpoch}.pdf',
      );
      await file.writeAsBytes(bytes);

      await SharePlus.instance.share(
        ShareParams(
          files: [XFile(file.path)],
          subject: l10n.reportClinicSummarySharedTitle,
        ),
      );
    } catch (e) {
      if (mounted) {
        await AppToast.show(context, l10n.reportClinicSummaryPdfFailed);
      }
    } finally {
      if (mounted) {
        setState(() => _isPdfDownloading = false);
      }
    }
  }
}
