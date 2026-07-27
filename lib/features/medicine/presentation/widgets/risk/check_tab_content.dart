import 'package:flutter/material.dart';
import 'package:forui/forui.dart';
import 'package:luminous/core/design/design.dart';
import 'package:luminous/features/medicine/domain/entities/risk_check.dart';
import 'package:luminous/features/medicine/presentation/widgets/risk/risk_coverage_issue_tile.dart';
import 'package:luminous/features/medicine/presentation/widgets/risk/risk_finding_tile.dart';
import 'package:luminous/features/medicine/presentation/widgets/risk/risk_metric_chip.dart';
import 'package:luminous/features/medicine/presentation/widgets/risk/risk_red_flag.dart';
import 'package:luminous/features/medicine/presentation/widgets/risk/risk_score_ring.dart';
import 'package:luminous/features/medicine/presentation/widgets/shared/copy.dart';
import 'package:luminous/l10n/app_localizations.dart';

/// The content shown inside each FTabs entry. Handles both static and LLM
/// check types, rendering the appropriate layout based on the available
/// [record] and [checkType].
class CheckTabContent extends StatefulWidget {
  const CheckTabContent({
    super.key,
    required this.record,
    required this.checkType,
    required this.l10n,
    required this.onRunCheck,
    required this.isRunning,
    this.llmUnavailable = false,
  });

  final MedicineRiskCheckRecord? record;
  final MedicineRiskCheckType checkType;
  final AppLocalizations l10n;
  final VoidCallback onRunCheck;
  final bool isRunning;
  final bool llmUnavailable;

  @override
  State<CheckTabContent> createState() => _CheckTabContentState();
}

class _CheckTabContentState extends State<CheckTabContent> {
  static const _foldThreshold = 5;
  bool _findingsExpanded = false;
  bool _coverageExpanded = false;
  final _findingsKey = GlobalKey();
  final _coverageKey = GlobalKey();

  bool get _isLlm => widget.checkType == MedicineRiskCheckType.llm;

  void _scrollToKey(GlobalKey key) {
    final ctx = key.currentContext;
    if (ctx != null) {
      Scrollable.ensureVisible(
        ctx,
        duration: const Duration(milliseconds: 400),
        curve: MotionTokens.standard,
        alignment: 0.1,
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final l10n = widget.l10n;

    // LLM unavailable state.
    if (_isLlm && widget.llmUnavailable) {
      return _LlmUnavailableState(l10n: l10n);
    }

    // No record yet.
    if (widget.record == null) {
      if (_isLlm) {
        return _LlmEmptyState(
          l10n: l10n,
          onRun: widget.onRunCheck,
          isRunning: widget.isRunning,
        );
      }
      return _NeverCheckedState(
        l10n: l10n,
        onRun: widget.onRunCheck,
        isRunning: widget.isRunning,
      );
    }

    // Running state — show content dimmed + loading indicator.
    final record = widget.record!;
    final result = record.result;

    return Padding(
      padding: const EdgeInsets.symmetric(
        horizontal: Spacing.level4,
        vertical: Spacing.level4,
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _TabHeader(
            l10n: l10n,
            record: record,
            isLlm: _isLlm,
            onRun: widget.onRunCheck,
            isRunning: widget.isRunning,
          ),
          const SizedBox(height: Spacing.level4),
          // Stale banner (LLM only, when stale).
          if (_isLlm && record.stale) ...[
            _StaleBanner(l10n: l10n),
            const SizedBox(height: Spacing.level4),
          ],
          // Risk score hero.
          _RiskScoreHero(
            l10n: l10n,
            score: record.riskScore,
            riskLevel: record.riskLevel,
            findingCount: result.findingCount,
          ),
          const SizedBox(height: Spacing.level5),
          // Red flags (if any).
          if (result.hasRedFlags) ...[
            RiskRedFlagSection(alerts: result.redFlags, l10n: l10n),
            const SizedBox(height: Spacing.level5),
          ],
          // Metric grid.
          _MetricGrid(
            l10n: l10n,
            result: result,
            onFindingsTap: result.hasFindings
                ? () => _scrollToKey(_findingsKey)
                : null,
            onCoverageTap: result.hasCoverageGaps
                ? () => _scrollToKey(_coverageKey)
                : null,
          ),
          const SizedBox(height: Spacing.level5),
          // Findings section.
          if (result.hasFindings)
            _FindingsSection(
              l10n: l10n,
              result: result,
              findingsKey: _findingsKey,
              expanded: _findingsExpanded,
              onToggle: () =>
                  setState(() => _findingsExpanded = !_findingsExpanded),
              foldThreshold: _foldThreshold,
            ),
          // Coverage section.
          if (result.hasCoverageGaps) ...[
            if (result.hasFindings) const SizedBox(height: Spacing.level5),
            _CoverageSection(
              l10n: l10n,
              result: result,
              coverageKey: _coverageKey,
              expanded: _coverageExpanded,
              onToggle: () =>
                  setState(() => _coverageExpanded = !_coverageExpanded),
              foldThreshold: _foldThreshold,
            ),
          ],
          // Safe state card (when no findings AND no coverage gaps).
          if (!result.hasFindings && !result.hasCoverageGaps) ...[
            _SafeStateCard(l10n: l10n, result: result),
          ],
          // Overall recommendation (LLM only).
          if (_isLlm &&
              result.overallRecommendation != null &&
              result.overallRecommendation!.trim().isNotEmpty) ...[
            const SizedBox(height: Spacing.level5),
            _OverallRecommendationCard(
              l10n: l10n,
              text: result.overallRecommendation!,
            ),
          ],
        ],
      ),
    );
  }
}

// ─── Tab header ───────────────────────────────────────────────────────────────

class _TabHeader extends StatelessWidget {
  const _TabHeader({
    required this.l10n,
    required this.record,
    required this.isLlm,
    required this.onRun,
    required this.isRunning,
  });

  final AppLocalizations l10n;
  final MedicineRiskCheckRecord record;
  final bool isLlm;
  final VoidCallback onRun;
  final bool isRunning;

  @override
  Widget build(BuildContext context) {
    final timeStr = medicineRiskCheckFormatTime(record.updatedAt);

    return Row(
      children: [
        Icon(
          FLucideIcons.clock,
          size: IconSizeTokens.level2,
          color: context.theme.colors.mutedForeground,
        ),
        const SizedBox(width: Spacing.level1),
        Expanded(
          child: Text(
            l10n.medicineRiskCheckLastUpdated(timeStr),
            style: TypographyToken.level3
                .body(context)
                .copyWith(color: context.theme.colors.mutedForeground),
          ),
        ),
        if (isRunning)
          const SizedBox.square(
            dimension: IconSizeTokens.level3,
            child: FCircularProgress.loader(size: .sm),
          )
        else
          FButton(
            variant: FButtonVariant.ghost,
            size: .sm,
            onPress: onRun,
            child: Text(
              isLlm
                  ? l10n.medicineRiskCheckRunLlm
                  : l10n.medicineRiskCheckRunStatic,
            ),
          ),
      ],
    );
  }
}

// ─── Risk score hero ──────────────────────────────────────────────────────────

class _RiskScoreHero extends StatelessWidget {
  const _RiskScoreHero({
    required this.l10n,
    required this.score,
    required this.riskLevel,
    required this.findingCount,
  });

  final AppLocalizations l10n;
  final int score;
  final MedicineRiskLevel riskLevel;
  final int findingCount;

  @override
  Widget build(BuildContext context) {
    final palette = medicineRiskLevelColor(riskLevel).palette(context);

    return DecoratedBox(
      decoration: ShapeDecoration(
        gradient: GradientTokens.tintFade(
          palette.muted,
          context.theme.colors.background,
        ),
        shape: RoundedSuperellipseBorder(
          borderRadius: BorderRadius.circular(RadiusTokens.level5),
          side: BorderSide(color: palette.border),
        ),
      ),
      child: Padding(
        padding: const EdgeInsets.all(Spacing.level6),
        child: Row(
          children: [
            RiskScoreRing(score: score, riskLevel: riskLevel),
            const SizedBox(width: Spacing.level6),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    l10n.medicineRiskScoreTitle,
                    style: TypographyToken.level3
                        .body(context)
                        .copyWith(color: context.theme.colors.mutedForeground),
                  ),
                  const SizedBox(height: Spacing.level1),
                  Text(
                    medicineRiskLevelLabel(l10n, riskLevel),
                    style: TypographyToken.level7
                        .display(context)
                        .copyWith(
                          fontWeight: FontWeight.w800,
                          letterSpacing: 0,
                          color: palette.solid,
                        ),
                  ),
                  const SizedBox(height: Spacing.level2),
                  Text(
                    medicineRiskLevelDescription(l10n, riskLevel, findingCount),
                    style: TypographyToken.level3
                        .body(context)
                        .copyWith(color: context.theme.colors.foreground),
                    maxLines: 3,
                    overflow: TextOverflow.ellipsis,
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// ─── Metric grid ──────────────────────────────────────────────────────────────

class _MetricGrid extends StatelessWidget {
  const _MetricGrid({
    required this.l10n,
    required this.result,
    this.onFindingsTap,
    this.onCoverageTap,
  });

  final AppLocalizations l10n;
  final MedicineRiskCheckResult result;
  final VoidCallback? onFindingsTap;
  final VoidCallback? onCoverageTap;

  @override
  Widget build(BuildContext context) {
    return DecoratedBox(
      decoration: ShapeDecoration(
        color: SemanticColor.neutral.subtle(context),
        shape: RoundedSuperellipseBorder(
          borderRadius: BorderRadius.circular(RadiusTokens.level4),
        ),
      ),
      child: IntrinsicHeight(
        child: Row(
          children: [
            RiskMetricCell(
              label: l10n.medicineRiskCheckCurrentMedicinesLabel,
              value: '${result.currentMedicineCount}',
              color: SemanticColor.neutral,
            ),
            RiskMetricCell(
              label: l10n.medicineRiskCheckCheckedMedicinesLabel,
              value: '${result.checkedMedicineCount}',
              color: SemanticColor.neutral,
            ),
            RiskMetricCell(
              label: l10n.medicineRiskCheckFindingsLabel,
              value: '${result.findingCount}',
              color: result.findingCount > 0
                  ? SemanticColor.destructive
                  : SemanticColor.success,
              onTap: onFindingsTap,
            ),
            RiskMetricCell(
              label: l10n.medicineRiskCheckCoverageLabel,
              value: '${result.coverageCount}',
              color: result.coverageCount > 0
                  ? SemanticColor.warning
                  : SemanticColor.success,
              onTap: onCoverageTap,
              showRightDivider: false,
            ),
          ],
        ),
      ),
    );
  }
}

// ─── Findings section ─────────────────────────────────────────────────────────

class _FindingsSection extends StatelessWidget {
  const _FindingsSection({
    required this.l10n,
    required this.result,
    required this.findingsKey,
    required this.expanded,
    required this.onToggle,
    required this.foldThreshold,
  });

  final AppLocalizations l10n;
  final MedicineRiskCheckResult result;
  final GlobalKey findingsKey;
  final bool expanded;
  final VoidCallback onToggle;
  final int foldThreshold;

  @override
  Widget build(BuildContext context) {
    final visibleCount = expanded
        ? result.findings.length
        : result.findings.length.clamp(0, foldThreshold);

    return Column(
      key: findingsKey,
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          l10n.medicineRiskCheckFindingsTitle,
          style: TypographyToken.level6
              .body(context)
              .copyWith(fontWeight: FontWeight.w800),
        ),
        const SizedBox(height: Spacing.level3),
        for (var i = 0; i < visibleCount; i += 1)
          RiskFindingItem(
            finding: result.findings[i],
            isLast: i == visibleCount - 1,
            l10n: l10n,
          ),
        if (result.findings.length > foldThreshold) ...[
          const SizedBox(height: Spacing.level3),
          Center(
            child: FButton(
              variant: FButtonVariant.ghost,
              size: .sm,
              onPress: onToggle,
              child: Text(
                expanded
                    ? l10n.medicineRiskCheckCollapse
                    : l10n.medicineRiskCheckShowAll(result.findings.length),
              ),
            ),
          ),
        ],
      ],
    );
  }
}

// ─── Coverage section ─────────────────────────────────────────────────────────

class _CoverageSection extends StatelessWidget {
  const _CoverageSection({
    required this.l10n,
    required this.result,
    required this.coverageKey,
    required this.expanded,
    required this.onToggle,
    required this.foldThreshold,
  });

  final AppLocalizations l10n;
  final MedicineRiskCheckResult result;
  final GlobalKey coverageKey;
  final bool expanded;
  final VoidCallback onToggle;
  final int foldThreshold;

  @override
  Widget build(BuildContext context) {
    final visibleCount = expanded
        ? result.coverageIssues.length
        : result.coverageIssues.length.clamp(0, foldThreshold);

    return Column(
      key: coverageKey,
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          l10n.medicineRiskCheckCoverageTitle,
          style: TypographyToken.level6
              .body(context)
              .copyWith(fontWeight: FontWeight.w800),
        ),
        const SizedBox(height: Spacing.level3),
        for (var i = 0; i < visibleCount; i += 1)
          RiskCoverageItem(
            issue: result.coverageIssues[i],
            isLast: i == visibleCount - 1,
            l10n: l10n,
          ),
        if (result.coverageIssues.length > foldThreshold) ...[
          const SizedBox(height: Spacing.level3),
          Center(
            child: FButton(
              variant: FButtonVariant.ghost,
              size: .sm,
              onPress: onToggle,
              child: Text(
                expanded
                    ? l10n.medicineRiskCheckCollapse
                    : l10n.medicineRiskCheckShowAll(
                        result.coverageIssues.length,
                      ),
              ),
            ),
          ),
        ],
      ],
    );
  }
}

// ─── Safe state card ──────────────────────────────────────────────────────────

class _SafeStateCard extends StatelessWidget {
  const _SafeStateCard({required this.l10n, required this.result});

  final AppLocalizations l10n;
  final MedicineRiskCheckResult result;

  @override
  Widget build(BuildContext context) {
    return DecoratedBox(
      decoration: ShapeDecoration(
        color: SemanticColor.success.subtle(context),
        shape: RoundedSuperellipseBorder(
          borderRadius: BorderRadius.circular(RadiusTokens.level4),
        ),
      ),
      child: Padding(
        padding: const EdgeInsets.all(Spacing.level5),
        child: Row(
          children: [
            Container(
              width: Spacing.level8,
              height: Spacing.level8,
              decoration: ShapeDecoration(
                color: SemanticColor.success.muted(context),
                shape: const CircleBorder(),
              ),
              child: Icon(
                FLucideIcons.badgeCheck,
                color: SemanticColor.success.solid(context),
                size: IconSizeTokens.level4,
              ),
            ),
            const SizedBox(width: Spacing.level3),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    l10n.medicineRiskCheckTierConfirmedSafe,
                    style: TypographyToken.level5
                        .body(context)
                        .copyWith(fontWeight: FontWeight.w800),
                  ),
                  const SizedBox(height: Spacing.level1),
                  Text(
                    l10n.medicineRiskCheckTierSafeBody(
                      result.checkedMedicineCount,
                    ),
                    style: TypographyToken.level3
                        .body(context)
                        .copyWith(color: context.theme.colors.mutedForeground),
                  ),
                  const SizedBox(height: Spacing.level1),
                  Text(
                    l10n.medicineRiskCheckTierSafeDisclaimer,
                    style: TypographyToken.level3
                        .body(context)
                        .copyWith(color: context.theme.colors.mutedForeground),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// ─── LLM empty state ──────────────────────────────────────────────────────────

class _LlmEmptyState extends StatelessWidget {
  const _LlmEmptyState({
    required this.l10n,
    required this.onRun,
    required this.isRunning,
  });

  final AppLocalizations l10n;
  final VoidCallback onRun;
  final bool isRunning;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(Spacing.level6),
      child: Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              FLucideIcons.sparkles,
              size: IconSizeTokens.level5,
              color: context.theme.colors.mutedForeground,
            ),
            const SizedBox(height: Spacing.level4),
            Text(
              l10n.medicineRiskCheckLlmEmptyTitle,
              style: TypographyToken.level5
                  .body(context)
                  .copyWith(fontWeight: FontWeight.w800),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: Spacing.level2),
            Text(
              l10n.medicineRiskCheckLlmEmptyBody,
              style: TypographyToken.level3
                  .body(context)
                  .copyWith(color: context.theme.colors.mutedForeground),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: Spacing.level5),
            FButton(
              onPress: isRunning ? null : onRun,
              child: isRunning
                  ? Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        const SizedBox.square(
                          dimension: IconSizeTokens.level2,
                          child: FCircularProgress.loader(size: .sm),
                        ),
                        const SizedBox(width: Spacing.level2),
                        Text(l10n.medicineRiskCheckRunLlm),
                      ],
                    )
                  : Text(l10n.medicineRiskCheckRunLlm),
            ),
          ],
        ),
      ),
    );
  }
}

// ─── Never checked state (static tab) ─────────────────────────────────────────

class _NeverCheckedState extends StatelessWidget {
  const _NeverCheckedState({
    required this.l10n,
    required this.onRun,
    required this.isRunning,
  });

  final AppLocalizations l10n;
  final VoidCallback onRun;
  final bool isRunning;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(Spacing.level6),
      child: Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              FLucideIcons.shieldCheck,
              size: IconSizeTokens.level5,
              color: context.theme.colors.mutedForeground,
            ),
            const SizedBox(height: Spacing.level4),
            Text(
              l10n.medicineRiskCheckNeverChecked,
              style: TypographyToken.level5
                  .body(context)
                  .copyWith(fontWeight: FontWeight.w800),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: Spacing.level5),
            FButton(
              onPress: isRunning ? null : onRun,
              child: isRunning
                  ? Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        const SizedBox.square(
                          dimension: IconSizeTokens.level2,
                          child: FCircularProgress.loader(size: .sm),
                        ),
                        const SizedBox(width: Spacing.level2),
                        Text(l10n.medicineRiskCheckRunStatic),
                      ],
                    )
                  : Text(l10n.medicineRiskCheckRunStatic),
            ),
          ],
        ),
      ),
    );
  }
}

// ─── Stale banner (LLM only) ──────────────────────────────────────────────────

class _StaleBanner extends StatelessWidget {
  const _StaleBanner({required this.l10n});

  final AppLocalizations l10n;

  @override
  Widget build(BuildContext context) {
    return DecoratedBox(
      decoration: ShapeDecoration(
        color: SemanticColor.warning.subtle(context),
        shape: RoundedSuperellipseBorder(
          borderRadius: BorderRadius.circular(RadiusTokens.level4),
          side: BorderSide(color: SemanticColor.warning.border(context)),
        ),
      ),
      child: Padding(
        padding: const EdgeInsets.all(Spacing.level4),
        child: Row(
          children: [
            Icon(
              FLucideIcons.circleAlert,
              color: SemanticColor.warning.solid(context),
              size: IconSizeTokens.level3,
            ),
            const SizedBox(width: Spacing.level3),
            Expanded(
              child: Text(
                l10n.medicineRiskCheckStaleBanner,
                style: TypographyToken.level3
                    .body(context)
                    .copyWith(color: context.theme.colors.foreground),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// ─── Overall recommendation card (LLM only) ──────────────────────────────────

class _OverallRecommendationCard extends StatelessWidget {
  const _OverallRecommendationCard({required this.l10n, required this.text});

  final AppLocalizations l10n;
  final String text;

  @override
  Widget build(BuildContext context) {
    return DecoratedBox(
      decoration: ShapeDecoration(
        color: SemanticColor.primary.subtle(context),
        shape: RoundedSuperellipseBorder(
          borderRadius: BorderRadius.circular(RadiusTokens.level4),
          side: BorderSide(color: SemanticColor.primary.border(context)),
        ),
      ),
      child: Padding(
        padding: const EdgeInsets.all(Spacing.level5),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(
                  FLucideIcons.lightbulb,
                  color: SemanticColor.primary.solid(context),
                  size: IconSizeTokens.level3,
                ),
                const SizedBox(width: Spacing.level2),
                Text(
                  l10n.medicineRiskOverallRecommendation,
                  style: TypographyToken.level5
                      .body(context)
                      .copyWith(fontWeight: FontWeight.w800),
                ),
              ],
            ),
            const SizedBox(height: Spacing.level3),
            Text(
              text,
              style: TypographyToken.level3
                  .body(context)
                  .copyWith(color: context.theme.colors.foreground),
            ),
          ],
        ),
      ),
    );
  }
}

// ─── LLM unavailable state ────────────────────────────────────────────────────

class _LlmUnavailableState extends StatelessWidget {
  const _LlmUnavailableState({required this.l10n});

  final AppLocalizations l10n;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(Spacing.level6),
      child: Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              FLucideIcons.ban,
              size: IconSizeTokens.level5,
              color: SemanticColor.neutral.solid(context),
            ),
            const SizedBox(height: Spacing.level4),
            Text(
              l10n.medicineRiskCheckLlmUnavailable,
              style: TypographyToken.level5
                  .body(context)
                  .copyWith(fontWeight: FontWeight.w800),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }
}
