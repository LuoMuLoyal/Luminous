import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:lucent_openapi/lucent_openapi.dart';
import 'package:luminous/core/design/app_design.dart';
import 'package:luminous/core/theme/app_theme_extensions.dart';
import 'package:luminous/core/widgets/app_state_views.dart';
import 'package:luminous/features/auth/presentation/providers/auth_session_provider.dart';
import 'package:luminous/features/report/domain/entities/report_ai_summary.dart';
import 'package:luminous/features/report/domain/entities/report_dashboard.dart';
import 'package:luminous/features/report/presentation/widgets/report_components.dart';
import 'package:luminous/features/report/presentation/widgets/report_section_models.dart';
import 'package:luminous/l10n/app_localizations.dart';

class ReportAiSummarySection extends StatelessWidget {
  const ReportAiSummarySection({
    super.key,
    required this.dashboard,
    required this.authSession,
    required this.settingsAsync,
    required this.aiState,
    required this.selectedRange,
    this.onRangeChanged,
    this.onGenerate,
    required this.l10n,
    required this.typography,
    required this.surface,
  });

  final ReportDashboard dashboard;
  final AuthSessionState authSession;
  final AsyncValue<UserSettingsDataDto>? settingsAsync;
  final ReportAiSummaryCardState aiState;
  final ReportAiSummaryRange selectedRange;
  final ValueChanged<ReportAiSummaryRange>? onRangeChanged;
  final Future<void> Function()? onGenerate;
  final AppLocalizations l10n;
  final AppTypographyScale typography;
  final AppThemeSurface surface;

  @override
  Widget build(BuildContext context) {
    final content = buildReportAiSummaryContent(
      l10n: l10n,
      dashboard: dashboard,
      authSession: authSession,
      settingsAsync: settingsAsync,
      aiState: aiState,
      selectedRange: selectedRange,
    );
    final actionLabel = aiState.summary?.actionLabel;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            ReportIconBadge(
              icon: Icons.auto_awesome_rounded,
              color: ReportPalette.green,
              size: AppSpacingTokens.x3l,
              iconSize: AppSpacingTokens.lg,
              shape: BoxShape.circle,
            ),
            const SizedBox(width: AppSpacingTokens.md),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    l10n.reportAiSummaryTitle,
                    style: typography.bodyMdStrong.copyWith(
                      fontWeight: FontWeight.w800,
                      letterSpacing: 0,
                    ),
                  ),
                  const SizedBox(height: AppSpacingTokens.xxs),
                  Text(
                    content.subtitle,
                    style: typography.bodySm.copyWith(
                      color: surface.body,
                      letterSpacing: 0,
                    ),
                  ),
                  const SizedBox(height: AppSpacingTokens.sm),
                  Wrap(
                    spacing: AppSpacingTokens.sm,
                    runSpacing: AppSpacingTokens.sm,
                    crossAxisAlignment: WrapCrossAlignment.center,
                    children: [
                      SegmentedButton<ReportAiSummaryRange>(
                        key: const Key('report-ai-summary-range-toggle'),
                        segments: [
                          ButtonSegment(
                            value: ReportAiSummaryRange.last7Days,
                            label: Text(l10n.reportRangeLast7Days),
                          ),
                          ButtonSegment(
                            value: ReportAiSummaryRange.last30Days,
                            label: Text(l10n.reportRangeLast30Days),
                          ),
                        ],
                        selected: {selectedRange},
                        onSelectionChanged: onRangeChanged == null
                            ? null
                            : (selection) {
                                if (selection.isNotEmpty) {
                                  onRangeChanged!(selection.first);
                                }
                              },
                      ),
                      if (actionLabel != null)
                        OutlinedButton(
                          onPressed: () =>
                              showReportToast(context, actionLabel),
                          child: Text(actionLabel),
                        ),
                    ],
                  ),
                ],
              ),
            ),
          ],
        ),
        const SizedBox(height: AppSpacingTokens.md),
        Divider(height: 1, thickness: 1, color: surface.hairline),
        if (content.summaryText != null) ...[
          Padding(
            padding: const EdgeInsets.only(bottom: AppSpacingTokens.sm),
            child: AppSkeletonText(
              text: content.summaryText!,
              style: typography.bodyMdStrong.copyWith(
                fontWeight: FontWeight.w700,
                letterSpacing: 0,
              ),
              widthFactor: 0.94,
            ),
          ),
          Divider(height: 1, thickness: 1, color: surface.hairline),
        ],
        for (var index = 0; index < content.bullets.length; index += 1) ...[
          Padding(
            padding: const EdgeInsets.symmetric(vertical: AppSpacingTokens.sm),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Padding(
                  padding: const EdgeInsets.only(top: AppSpacingTokens.xs),
                  child: DecoratedBox(
                    decoration: BoxDecoration(
                      color: content.bullets[index].color,
                      shape: BoxShape.circle,
                    ),
                    child: const SizedBox.square(
                      dimension: AppSpacingTokens.xs,
                    ),
                  ),
                ),
                const SizedBox(width: AppSpacingTokens.sm),
                Expanded(
                  child: AppSkeletonText(
                    text: content.bullets[index].text,
                    style: typography.bodySm.copyWith(
                      color: surface.body,
                      letterSpacing: 0,
                    ),
                    widthFactor: 0.9,
                  ),
                ),
              ],
            ),
          ),
          if (index < content.bullets.length - 1)
            Divider(
              height: 1,
              thickness: 1,
              indent: AppSpacingTokens.lg,
              color: surface.hairline,
            ),
        ],
        if (content.footer != null) ...[
          const SizedBox(height: AppSpacingTokens.sm),
          Divider(height: 1, thickness: 1, color: surface.hairline),
          const SizedBox(height: AppSpacingTokens.sm),
          Text(
            content.footer!,
            style: typography.caption.copyWith(
              color: surface.body,
              letterSpacing: 0,
            ),
          ),
        ],
        if (content.showGenerateButton) ...[
          const SizedBox(height: AppSpacingTokens.md),
          Align(
            alignment: Alignment.centerLeft,
            child: FilledButton.icon(
              key: const Key('report-ai-summary-generate-action'),
              onPressed: aiState.isLoading || onGenerate == null
                  ? null
                  : () {
                      onGenerate!();
                    },
              icon: Icon(
                aiState.isLoading
                    ? Icons.hourglass_top_rounded
                    : Icons.auto_awesome_rounded,
              ),
              label: Text(
                aiState.isLoading
                    ? reportAiSummaryGeneratingLabel(l10n, selectedRange)
                    : l10n.reportGenerateAction,
              ),
            ),
          ),
        ],
      ],
    );
  }
}
