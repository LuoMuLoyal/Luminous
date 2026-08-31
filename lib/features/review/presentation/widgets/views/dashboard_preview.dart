import 'package:flutter/material.dart';
import 'package:luminous/core/design/design.dart';
import 'package:luminous/core/widgets/common/state_views.dart';
import 'package:luminous/features/review/domain/entities/dashboard.dart';
import 'package:luminous/features/review/presentation/widgets/sections/preview/export.dart';
import 'package:luminous/features/review/presentation/widgets/sections/preview/trend.dart';
import 'package:luminous/features/review/presentation/widgets/sections/preview_locked.dart';
import 'package:luminous/features/settings/presentation/providers/data_export.dart';
import 'package:luminous/l10n/app_localizations.dart';

/// Preview layout for the report dashboard — shown when not signed in
/// or in preview mode. Contains mock trend data, locked sections, and
/// disabled export actions.
class ReviewDashboardPreview extends StatelessWidget {
  const ReviewDashboardPreview({
    super.key,
    required this.l10n,
    required this.dashboardQuery,
    this.onDashboardQueryChanged,
    required this.startDate,
    required this.onSignIn,
    required this.isDesktop,
  });

  final AppLocalizations l10n;
  final ReviewDashboardQuery dashboardQuery;
  final ValueChanged<ReviewDashboardQuery>? onDashboardQueryChanged;
  final String startDate;
  final VoidCallback? onSignIn;
  final bool isDesktop;

  static const _previewTrends = <ReviewTrendSeries>[
    ReviewTrendSeries(
      kind: ReviewDataKind.medication,
      color: SemanticColor.primary,
      unit: '%',
      values: [],
      currentValue: '--',
    ),
    ReviewTrendSeries(
      kind: ReviewDataKind.water,
      color: SemanticColor.info,
      unit: 'L',
      values: [],
      currentValue: '--',
    ),
    ReviewTrendSeries(
      kind: ReviewDataKind.sleep,
      color: SemanticColor.warning,
      unit: 'h',
      values: [],
      currentValue: '--',
    ),
  ];

  static const _previewExportActions = <ReviewExportAction>[
    ReviewExportAction(
      kind: ReviewExportKind.hospital,
      icon: SemanticIcons.medicineKit,
      color: SemanticColor.primary,
    ),
    ReviewExportAction(
      kind: ReviewExportKind.monthly,
      icon: SemanticIcons.tabReview,
      color: SemanticColor.primary,
    ),
    ReviewExportAction(
      kind: ReviewExportKind.print,
      icon: SemanticIcons.actionExport,
      color: SemanticColor.primary,
    ),
    ReviewExportAction(
      kind: ReviewExportKind.clinicShare,
      icon: SemanticIcons.actionShare,
      color: SemanticColor.primary,
    ),
  ];

  @override
  Widget build(BuildContext context) {
    final trendSection = ReviewTrendSection(
      key: const Key('report-trend-section'),
      trends: _previewTrends,
      selectedQuery: dashboardQuery,
      onQueryChanged: onDashboardQueryChanged ?? (_) {},
      l10n: l10n,
      startDate: startDate,
      showRangePill: false,
    );

    final exportSection = ReviewExportSection(
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
          message: l10n.reviewPreviewBannerMessage,
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
                  title: l10n.reviewFindingsPreviewTitle,
                  body: l10n.reviewFindingsPreviewBody,
                ),
              ),
              const SizedBox(width: Spacing.level4),
              Expanded(
                child: ReviewPreviewLockedSection(
                  key: const Key('report-suggestion-history-preview-locked'),
                  icon: SemanticIcons.reportHistory,
                  title: l10n.reviewSuggestionHistoryPreviewTitle,
                  body: l10n.reviewSuggestionHistoryPreviewBody,
                ),
              ),
            ],
          )
        else ...[
          ReviewPreviewLockedSection(
            key: const Key('report-findings-preview-locked'),
            icon: SemanticIcons.aiTip,
            title: l10n.reviewFindingsPreviewTitle,
            body: l10n.reviewFindingsPreviewBody,
          ),
          const SizedBox(height: Spacing.level4),
          ReviewPreviewLockedSection(
            key: const Key('report-suggestion-history-preview-locked'),
            icon: SemanticIcons.reportHistory,
            title: l10n.reviewSuggestionHistoryPreviewTitle,
            body: l10n.reviewSuggestionHistoryPreviewBody,
          ),
        ],
        const SizedBox(height: Spacing.level4),
        exportSection,
      ],
    );
  }
}
