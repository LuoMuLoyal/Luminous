import 'dart:async';

import 'package:flutter/material.dart';
import 'package:luminous/core/design/design.dart';
import 'package:luminous/features/medicine/domain/entities/risk_check.dart';
import 'package:luminous/features/medicine/presentation/widgets/risk/coverage_tab_section.dart';
import 'package:luminous/features/medicine/presentation/widgets/risk/findings_tab_section.dart';
import 'package:luminous/features/medicine/presentation/widgets/risk/overview_tab_section.dart';
import 'package:luminous/features/medicine/presentation/widgets/risk/risk_red_flag.dart';
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
      unawaited(
        Scrollable.ensureVisible(
          ctx,
          duration: const Duration(milliseconds: 400),
          curve: MotionTokens.standard,
          alignment: 0.1,
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final l10n = widget.l10n;

    // LLM unavailable state.
    if (_isLlm && widget.llmUnavailable) {
      return LlmUnavailableState(l10n: l10n);
    }

    // No record yet.
    if (widget.record == null) {
      if (_isLlm) {
        return LlmEmptyState(
          l10n: l10n,
          onRun: widget.onRunCheck,
          isRunning: widget.isRunning,
        );
      }
      return NeverCheckedState(
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
          TabHeader(
            l10n: l10n,
            record: record,
            isLlm: _isLlm,
            onRun: widget.onRunCheck,
            isRunning: widget.isRunning,
          ),
          const SizedBox(height: Spacing.level4),
          // Stale banner (LLM only, when stale).
          if (_isLlm && record.stale) ...[
            StaleBanner(l10n: l10n),
            const SizedBox(height: Spacing.level4),
          ],
          // Risk score hero.
          RiskScoreHero(
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
          MetricGrid(
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
            FindingsTabSection(
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
            CoverageTabSection(
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
            SafeStateCard(l10n: l10n, result: result),
          ],
          // Overall recommendation (LLM only).
          if (_isLlm &&
              result.overallRecommendation != null &&
              result.overallRecommendation!.trim().isNotEmpty) ...[
            const SizedBox(height: Spacing.level5),
            OverallRecommendationCard(
              l10n: l10n,
              text: result.overallRecommendation!,
            ),
          ],
        ],
      ),
    );
  }
}
