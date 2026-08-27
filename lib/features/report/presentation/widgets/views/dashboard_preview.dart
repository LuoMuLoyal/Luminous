import 'package:flutter/material.dart';
import 'package:luminous/core/design/design.dart';
import 'package:luminous/core/widgets/common/state_views.dart';
import 'package:luminous/features/report/domain/entities/dashboard.dart';
import 'package:luminous/features/report/presentation/widgets/sections/export.dart';
import 'package:luminous/features/report/presentation/widgets/sections/review_preview_locked.dart';
import 'package:luminous/features/report/presentation/widgets/sections/trend.dart';
import 'package:luminous/features/settings/presentation/providers/data_export.dart';
import 'package:luminous/l10n/app_localizations.dart';

/// Preview layout for the report dashboard — shown when not signed in
/// or in preview mode. Contains mock trend data, locked sections, and
/// disabled export actions.
class ReportDashboardPreview extends StatelessWidget {
  const ReportDashboardPreview({
    super.key,
    required this.l10n,
    required this.dashboardQuery,
    this.onDashboardQueryChanged,
    required this.startDate,
    required this.onSignIn,
    required this.isDesktop,
  });

  final AppLocalizations l10n;
  final ReportDashboardQuery dashboardQuery;
  final ValueChanged<ReportDashboardQuery>? onDashboardQueryChanged;
  final String startDate;
  final VoidCallback? onSignIn;
  final bool isDesktop;

  static const _previewTrends = <ReportTrendSeries>[
    ReportTrendSeries(
      kind: ReportDataKind.medication,
      color: SemanticColor.primary,
      unit: '%',
      values: [],
      currentValue: '--',
    ),
    ReportTrendSeries(
      kind: ReportDataKind.water,
      color: SemanticColor.info,
      unit: 'L',
      values: [],
      currentValue: '--',
    ),
    ReportTrendSeries(
      kind: ReportDataKind.sleep,
      color: SemanticColor.warning,
      unit: 'h',
      values: [],
      currentValue: '--',
    ),
  ];

  static const _previewExportActions = <ReportExportAction>[
    ReportExportAction(
      kind: ReportExportKind.hospital,
      icon: SemanticIcons.medicineKit,
      color: SemanticColor.primary,
    ),
    ReportExportAction(
      kind: ReportExportKind.monthly,
      icon: SemanticIcons.tabReport,
      color: SemanticColor.primary,
    ),
    ReportExportAction(
      kind: ReportExportKind.print,
      icon: SemanticIcons.actionExport,
      color: SemanticColor.primary,
    ),
    ReportExportAction(
      kind: ReportExportKind.clinicShare,
      icon: SemanticIcons.actionShare,
      color: SemanticColor.primary,
    ),
  ];

  @override
  Widget build(BuildContext context) {
    final trendSection = ReportTrendSection(
      key: const Key('report-trend-section'),
      trends: _previewTrends,
      selectedQuery: dashboardQuery,
      onQueryChanged: onDashboardQueryChanged ?? (_) {},
      l10n: l10n,
      startDate: startDate,
      showRangePill: false,
    );

    final exportSection = ReportExportSection(
      key: const Key('report-export-section'),
      actions: _previewExportActions,
      latestRequest: null,
      requestInFlight: const DataExportRequestInFlightState(inFlight: false),
      l10n: l10n,
      onActionTap: null,
    );

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        SignInHintBanner(
          onSignIn: onSignIn,
          message: l10n.reportPreviewBannerMessage,
        ),
        const SizedBox(height: Spacing.level4),
        trendSection,
        const SizedBox(height: Spacing.level4),
        if (isDesktop)
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Expanded(
                child: ReviewPreviewLockedSection(
                  key: const Key('report-findings-preview-locked'),
                  icon: SemanticIcons.aiTip,
                  title: l10n.reportFindingsPreviewTitle,
                  body: l10n.reportFindingsPreviewBody,
                ),
              ),
              const SizedBox(width: Spacing.level4),
              Expanded(
                child: ReviewPreviewLockedSection(
                  key: const Key('report-suggestion-history-preview-locked'),
                  icon: SemanticIcons.reportHistory,
                  title: l10n.reportSuggestionHistoryPreviewTitle,
                  body: l10n.reportSuggestionHistoryPreviewBody,
                ),
              ),
            ],
          )
        else ...[
          ReviewPreviewLockedSection(
            key: const Key('report-findings-preview-locked'),
            icon: SemanticIcons.aiTip,
            title: l10n.reportFindingsPreviewTitle,
            body: l10n.reportFindingsPreviewBody,
          ),
          const SizedBox(height: Spacing.level4),
          ReviewPreviewLockedSection(
            key: const Key('report-suggestion-history-preview-locked'),
            icon: SemanticIcons.reportHistory,
            title: l10n.reportSuggestionHistoryPreviewTitle,
            body: l10n.reportSuggestionHistoryPreviewBody,
          ),
        ],
        const SizedBox(height: Spacing.level4),
        exportSection,
      ],
    );
  }
}
