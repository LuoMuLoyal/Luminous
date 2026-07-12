import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:forui/forui.dart';
import 'package:go_router/go_router.dart';
import 'package:luminous/core/design/design.dart';
import 'package:luminous/core/widgets/common/state_views.dart';
import 'package:luminous/core/widgets/layout/responsive_content_frame.dart';
import 'package:luminous/features/auth/presentation/providers/session/session_provider.dart';
import 'package:luminous/features/auth/presentation/widgets/shared/required_dialog.dart';
import 'package:luminous/features/medicine/domain/entities/risk_check.dart';
import 'package:luminous/features/medicine/presentation/providers/risk_check.dart';
import 'package:luminous/features/medicine/presentation/widgets/risk/risk_coverage_issue_tile.dart';
import 'package:luminous/features/medicine/presentation/widgets/risk/risk_finding_tile.dart';
import 'package:luminous/features/medicine/presentation/widgets/risk/risk_metric_chip.dart';
import 'package:luminous/features/medicine/presentation/widgets/risk/risk_red_flag.dart';
import 'package:luminous/features/medicine/presentation/widgets/risk/risk_check_loading.dart';
import 'package:luminous/core/widgets/layout/page_scaffold.dart';
import 'package:luminous/l10n/app_localizations.dart';

class MedicineRiskCheckPage extends ConsumerWidget {
  const MedicineRiskCheckPage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = AppLocalizations.of(context)!;
    final session = ref.watch(authSessionProvider);
    final width = MediaQuery.sizeOf(context).width;

    final Widget bodyContent;
    if (!session.canAccessProtectedData) {
      bodyContent = session.isLoading
          ? const MedicineRiskCheckLoading()
          : AuthRequiredDialogGate(
              onLogin: () =>
                  context.push(loginRouteForCurrentLocation(context)),
            );
    } else {
      final resultAsync = ref.watch(medicineRiskCheckProvider);
      final redFlagAlertsAsync = ref.watch(redFlagAlertsProvider);
      bodyContent = resultAsync.when(
        data: (result) {
          final alerts = redFlagAlertsAsync.asData?.value ?? const [];
          return _MedicineRiskCheckBody(result: result, redFlagAlerts: alerts);
        },
        loading: () => const MedicineRiskCheckLoading(),
        error: (_, __) => AppStateErrorView(
          title: l10n.medicineErrorTitle,
          description: l10n.medicineErrorDescription,
          icon: FLucideIcons.shieldAlert,
          actionLabel: l10n.todayRetryAction,
          onAction: () => ref.invalidate(medicineRiskCheckProvider),
          tone: AppStateTone.warning,
        ),
      );
    }

    return PageScaffold(
      title: l10n.medicineRiskCheckPageTitle,
      child: SingleChildScrollView(
        child: ResponsiveContentFrame(
          child: Padding(
            padding: EdgeInsets.symmetric(
              vertical: width < Breakpoints.mobile ? 24 : 32,
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [bodyContent],
            ),
          ),
        ),
      ),
    );
  }
}

class _RiskCheckSectionCard extends StatelessWidget {
  const _RiskCheckSectionCard({required this.title, required this.child});

  final String title;
  final Widget child;

  @override
  Widget build(BuildContext context) {
    return FCard.raw(
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(title, style: TypographyToken.level6.body(context)),
            const SizedBox(height: 20),
            child,
          ],
        ),
      ),
    );
  }
}

/// A tier header banner with colored accent, icon, title, and optional body.
class _TierBanner extends StatelessWidget {
  const _TierBanner({
    required this.title,
    required this.icon,
    this.body,
    this.tone = AppStateTone.neutral,
  });

  final String title;
  final IconData icon;
  final String? body;
  final AppStateTone tone;

  @override
  Widget build(BuildContext context) {
    final accent = switch (tone) {
      AppStateTone.neutral => SemanticColor.primary,
      AppStateTone.success => SemanticColor.primary,
      AppStateTone.warning => SemanticColor.destructive,
      AppStateTone.danger => SemanticColor.destructive,
    };

    return Container(
      padding: const EdgeInsets.all(Spacing.level4),
      decoration: BoxDecoration(
        color: accent.muted(context),
        borderRadius: BorderRadius.circular(RadiusTokens.level3),
        border: Border.all(color: accent.border(context)),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(icon, color: accent.solid(context), size: Spacing.level5),
          const SizedBox(width: Spacing.level3),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: TypographyToken.level5
                      .body(context)
                      .copyWith(
                        fontWeight: FontWeight.w800,
                        color: accent.solid(context),
                      ),
                ),
                if (body != null) ...[
                  const SizedBox(height: Spacing.level1),
                  Text(
                    body!,
                    style: TypographyToken.level3
                        .body(context)
                        .copyWith(color: SemanticColor.neutral.solid(context)),
                  ),
                ],
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _MedicineRiskCheckBody extends StatelessWidget {
  const _MedicineRiskCheckBody({
    required this.result,
    this.redFlagAlerts = const [],
  });

  final MedicineRiskCheckResult result;
  final List<RedFlagAlert> redFlagAlerts;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: Spacing.level4),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          // Red flag banner (always first if present)
          if (redFlagAlerts.isNotEmpty) ...[
            MedicineRiskRedFlagBanner(alerts: redFlagAlerts, l10n: l10n),
            const SizedBox(height: Spacing.level4),
          ],
          // Summary metrics card
          _RiskCheckSectionCard(
            title: l10n.medicineRiskCheckSummaryTitle,
            child: Wrap(
              spacing: Spacing.level3,
              runSpacing: Spacing.level3,
              children: [
                MedicineRiskMetricChip(
                  label: l10n.medicineRiskCheckCurrentMedicinesLabel,
                  value: result.currentMedicineCount.toString(),
                ),
                MedicineRiskMetricChip(
                  label: l10n.medicineRiskCheckCheckedMedicinesLabel,
                  value: result.checkedMedicineCount.toString(),
                ),
                MedicineRiskMetricChip(
                  label: l10n.medicineRiskCheckFindingsLabel,
                  value: result.findingCount.toString(),
                ),
                MedicineRiskMetricChip(
                  label: l10n.medicineRiskCheckCoverageLabel,
                  value: result.coverageCount.toString(),
                ),
              ],
            ),
          ),
          const SizedBox(height: Spacing.level4),
          // Three-tier display
          _buildThreeTierSection(context, l10n),
        ],
      ),
    );
  }

  Widget _buildThreeTierSection(BuildContext context, AppLocalizations l10n) {
    final hasFindings = result.hasFindings;
    final hasCoverageGaps = result.hasCoverageGaps;

    // Tier 1: Confirmed Risk (red) — findings exist
    // Tier 2: Confirmed Safe (green) — no findings AND no coverage gaps
    // Tier 3: Uncovered/Uncertain (yellow) — coverage gaps exist (with or without findings)

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        // Tier 1: Confirmed Risk
        if (hasFindings) ...[
          _TierBanner(
            title: l10n.medicineRiskCheckTierConfirmedRisk,
            icon: FLucideIcons.triangleAlert,
            tone: AppStateTone.danger,
          ),
          const SizedBox(height: Spacing.level3),
          _RiskCheckSectionCard(
            title: l10n.medicineRiskCheckFindingsTitle,
            child: Column(
              children: [
                for (var index = 0; index < result.findings.length; index += 1)
                  MedicineRiskFindingTile(
                    finding: result.findings[index],
                    isLast: index == result.findings.length - 1,
                    l10n: l10n,
                  ),
              ],
            ),
          ),
          const SizedBox(height: Spacing.level4),
        ],
        // Tier 2: Confirmed Safe (only when no findings AND no coverage gaps)
        if (!hasFindings && !hasCoverageGaps) ...[
          _TierBanner(
            title: l10n.medicineRiskCheckTierConfirmedSafe,
            icon: FLucideIcons.badgeCheck,
            body: l10n.medicineRiskCheckTierSafeBody(
              result.checkedMedicineCount,
            ),
            tone: AppStateTone.success,
          ),
          const SizedBox(height: Spacing.level3),
          Container(
            padding: const EdgeInsets.all(Spacing.level4),
            decoration: BoxDecoration(
              color: SemanticColor.primary.subtle(context),
              borderRadius: BorderRadius.circular(RadiusTokens.level3),
            ),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Icon(
                  FLucideIcons.info,
                  color: context.theme.colors.primary,
                  size: Spacing.level5,
                ),
                const SizedBox(width: Spacing.level3),
                Expanded(
                  child: Text(
                    l10n.medicineRiskCheckTierSafeDisclaimer,
                    style: TypographyToken.level3
                        .body(context)
                        .copyWith(color: context.theme.colors.mutedForeground),
                  ),
                ),
              ],
            ),
          ),
        ],
        // Tier 3: Uncovered/Uncertain (when coverage gaps exist)
        if (hasCoverageGaps) ...[
          if (!hasFindings) ...[
            // When no findings but coverage gaps exist, show the safe-but disclaimer too
            _TierBanner(
              title: l10n.medicineRiskCheckTierUncovered,
              icon: FLucideIcons.circleAlert,
              body: l10n.medicineRiskCheckTierUncoveredDisclaimer,
              tone: AppStateTone.warning,
            ),
            const SizedBox(height: Spacing.level3),
          ],
          if (result.coverageSummary.isNotEmpty) ...[
            Container(
              padding: const EdgeInsets.all(Spacing.level4),
              decoration: BoxDecoration(
                color: SemanticColor.neutral.muted(context),
                borderRadius: BorderRadius.circular(RadiusTokens.level3),
                border: Border.all(
                  color: SemanticColor.neutral.border(context),
                ),
              ),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Icon(
                    FLucideIcons.circleAlert,
                    color: context.theme.colors.secondary,
                    size: Spacing.level5,
                  ),
                  const SizedBox(width: Spacing.level3),
                  Expanded(
                    child: Text(
                      result.coverageSummary,
                      style: TypographyToken.level3
                          .body(context)
                          .copyWith(
                            color: context.theme.colors.mutedForeground,
                          ),
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: Spacing.level3),
          ],
          _RiskCheckSectionCard(
            title: l10n.medicineRiskCheckCoverageTitle,
            child: Column(
              children: [
                for (
                  var index = 0;
                  index < result.coverageIssues.length;
                  index += 1
                )
                  MedicineRiskCoverageIssueTile(
                    issue: result.coverageIssues[index],
                    isLast: index == result.coverageIssues.length - 1,
                    l10n: l10n,
                  ),
              ],
            ),
          ),
        ],
      ],
    );
  }
}
