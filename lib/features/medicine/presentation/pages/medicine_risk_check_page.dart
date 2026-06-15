import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:luminous/core/design/app_design.dart';
import 'package:luminous/core/theme/app_theme_extensions.dart';
import 'package:luminous/core/widgets/app_state_views.dart';
import 'package:luminous/core/widgets/page_scaffold_shell.dart';
import 'package:luminous/features/auth/presentation/providers/auth_session_provider.dart';
import 'package:luminous/features/auth/presentation/widgets/auth_required_dialog.dart';
import 'package:luminous/features/medicine/domain/entities/medicine_risk_check.dart';
import 'package:luminous/features/medicine/presentation/providers/medicine_risk_check_provider.dart';
import 'package:luminous/features/medicine/presentation/widgets/medicine_copy.dart';
import 'package:luminous/features/settings/presentation/widgets/settings_components.dart';
import 'package:luminous/l10n/app_localizations.dart';

class MedicineRiskCheckPage extends ConsumerWidget {
  const MedicineRiskCheckPage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = AppLocalizations.of(context)!;
    final session = ref.watch(authSessionProvider);

    if (!session.canAccessProtectedData) {
      return PageScaffoldShell(
        title: l10n.medicineRiskCheckPageTitle,
        centerTitle: true,
        leading: const SettingsBackButton(),
        children: [
          session.isLoading
              ? const _MedicineRiskCheckLoading()
              : AuthRequiredDialogGate(
                  onLogin: () =>
                      context.push(loginRouteForCurrentLocation(context)),
                ),
        ],
      );
    }

    final resultAsync = ref.watch(medicineRiskCheckProvider);
    return PageScaffoldShell(
      title: l10n.medicineRiskCheckPageTitle,
      centerTitle: true,
      leading: const SettingsBackButton(),
      children: [
        resultAsync.when(
          data: (result) => _MedicineRiskCheckBody(result: result),
          loading: () => const _MedicineRiskCheckLoading(),
          error: (_, __) => AppStateErrorView(
            title: l10n.medicineErrorTitle,
            description: l10n.medicineErrorDescription,
            icon: Icons.health_and_safety_outlined,
            actionLabel: l10n.todayRetryAction,
            onAction: () => ref.invalidate(medicineRiskCheckProvider),
            tone: AppStateTone.warning,
          ),
        ),
      ],
    );
  }
}

class _MedicineRiskCheckBody extends StatelessWidget {
  const _MedicineRiskCheckBody({required this.result});

  final MedicineRiskCheckResult result;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final theme = Theme.of(context);
    final surface = theme.extension<AppThemeSurface>()!;
    final typography = AppTypographyTokens.mobile(theme.colorScheme.onSurface);

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: AppSpacingTokens.md),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          PageSectionCard(
            title: l10n.medicineRiskCheckSummaryTitle,
            child: Wrap(
              spacing: AppSpacingTokens.sm,
              runSpacing: AppSpacingTokens.sm,
              children: [
                _RiskMetricChip(
                  label: l10n.medicineRiskCheckCurrentMedicinesLabel,
                  value: result.currentMedicineCount.toString(),
                ),
                _RiskMetricChip(
                  label: l10n.medicineRiskCheckCheckedMedicinesLabel,
                  value: result.checkedMedicineCount.toString(),
                ),
                _RiskMetricChip(
                  label: l10n.medicineRiskCheckFindingsLabel,
                  value: result.findingCount.toString(),
                ),
                _RiskMetricChip(
                  label: l10n.medicineRiskCheckCoverageLabel,
                  value: result.coverageCount.toString(),
                ),
              ],
            ),
          ),
          if (result.coverageSummary.isNotEmpty) ...[
            const SizedBox(height: AppSpacingTokens.md),
            Container(
              padding: const EdgeInsets.all(AppSpacingTokens.md),
              decoration: BoxDecoration(
                color: AppColorTokens.warningSoft.withValues(alpha: 0.42),
                borderRadius: BorderRadius.circular(AppRadiusTokens.md),
              ),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Icon(
                    Icons.info_outline_rounded,
                    color: AppColorTokens.warningDeep,
                    size: AppSpacingTokens.lg,
                  ),
                  const SizedBox(width: AppSpacingTokens.sm),
                  Expanded(
                    child: Text(
                      result.coverageSummary,
                      style: typography.bodySm.copyWith(color: surface.body),
                    ),
                  ),
                ],
              ),
            ),
          ],
          const SizedBox(height: AppSpacingTokens.md),
          if (result.findings.isEmpty)
            AppStateMessageView(
              title: l10n.medicineRiskCheckNoFindingsTitle,
              description: l10n.medicineRiskCheckNoFindingsBody,
              icon: Icons.verified_outlined,
              tone: AppStateTone.success,
              padding: const EdgeInsets.all(AppSpacingTokens.lg),
            )
          else
            PageSectionCard(
              title: l10n.medicineRiskCheckFindingsTitle,
              child: Column(
                children: [
                  for (var index = 0; index < result.findings.length; index += 1)
                    _RiskFindingTile(
                      finding: result.findings[index],
                      isLast: index == result.findings.length - 1,
                      typography: typography,
                      surface: surface,
                      l10n: l10n,
                    ),
                ],
              ),
            ),
          const SizedBox(height: AppSpacingTokens.md),
          if (result.coverageIssues.isNotEmpty)
            PageSectionCard(
              title: l10n.medicineRiskCheckCoverageTitle,
              child: Column(
                children: [
                  for (
                    var index = 0;
                    index < result.coverageIssues.length;
                    index += 1
                  )
                    _CoverageIssueTile(
                      issue: result.coverageIssues[index],
                      isLast: index == result.coverageIssues.length - 1,
                      typography: typography,
                      surface: surface,
                      l10n: l10n,
                    ),
                ],
              ),
            ),
        ],
      ),
    );
  }
}

class _RiskMetricChip extends StatelessWidget {
  const _RiskMetricChip({required this.label, required this.value});

  final String label;
  final String value;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final surface = theme.extension<AppThemeSurface>()!;
    final typography = AppTypographyTokens.mobile(theme.colorScheme.onSurface);

    return DecoratedBox(
      decoration: BoxDecoration(
        color: surface.canvasSoft,
        borderRadius: BorderRadius.circular(AppRadiusTokens.md),
        border: Border.all(color: surface.hairline),
      ),
      child: Padding(
        padding: const EdgeInsets.symmetric(
          horizontal: AppSpacingTokens.md,
          vertical: AppSpacingTokens.sm,
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              label,
              style: typography.bodySm.copyWith(color: surface.mute),
            ),
            const SizedBox(height: AppSpacingTokens.xxs),
            Text(
              value,
              style: typography.bodyLg.copyWith(fontWeight: FontWeight.w800),
            ),
          ],
        ),
      ),
    );
  }
}

class _RiskFindingTile extends StatelessWidget {
  const _RiskFindingTile({
    required this.finding,
    required this.isLast,
    required this.typography,
    required this.surface,
    required this.l10n,
  });

  final MedicineRiskFinding finding;
  final bool isLast;
  final AppTypographyScale typography;
  final AppThemeSurface surface;
  final AppLocalizations l10n;

  @override
  Widget build(BuildContext context) {
    final color = medicineRiskSeverityColor(finding.severity);
    final contextLabel = medicineRiskContextLabel(l10n, finding.context);

    final tile = Padding(
      padding: const EdgeInsets.symmetric(vertical: AppSpacingTokens.sm),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          DecoratedBox(
            decoration: BoxDecoration(
              color: medicineRiskSeveritySoftColor(
                finding.severity,
              ).withValues(alpha: 0.56),
              shape: BoxShape.circle,
            ),
            child: SizedBox.square(
              dimension: AppSpacingTokens.x4l,
              child: Icon(
                medicineRiskFindingIcon(finding),
                color: color,
                size: AppSpacingTokens.lg,
              ),
            ),
          ),
          const SizedBox(width: AppSpacingTokens.sm),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  medicineRiskFindingTitle(l10n, finding),
                  style: typography.bodyMdStrong.copyWith(
                    fontWeight: FontWeight.w800,
                  ),
                ),
                const SizedBox(height: AppSpacingTokens.xxs),
                Text(
                  medicineRiskFindingBody(l10n, finding),
                  style: typography.bodySm.copyWith(color: surface.body),
                ),
                const SizedBox(height: AppSpacingTokens.xxs),
                Text(
                  medicineRiskFindingEvidence(l10n, finding),
                  style: typography.caption.copyWith(color: surface.mute),
                ),
              ],
            ),
          ),
          const SizedBox(width: AppSpacingTokens.sm),
          Column(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              _TagPill(
                label: medicineRiskSeverityLabel(l10n, finding.severity),
                color: color,
              ),
              if (contextLabel.isNotEmpty) ...[
                const SizedBox(height: AppSpacingTokens.xxs),
                _TagPill(label: contextLabel, color: surface.mute),
              ],
            ],
          ),
        ],
      ),
    );

    if (isLast) return tile;
    return Column(
      children: [
        tile,
        Divider(height: 1, color: surface.hairline),
      ],
    );
  }
}

class _CoverageIssueTile extends StatelessWidget {
  const _CoverageIssueTile({
    required this.issue,
    required this.isLast,
    required this.typography,
    required this.surface,
    required this.l10n,
  });

  final MedicineRiskCoverageIssue issue;
  final bool isLast;
  final AppTypographyScale typography;
  final AppThemeSurface surface;
  final AppLocalizations l10n;

  @override
  Widget build(BuildContext context) {
    final tile = Padding(
      padding: const EdgeInsets.symmetric(vertical: AppSpacingTokens.sm),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Icon(
            Icons.info_outline_rounded,
            color: AppColorTokens.warningDeep,
            size: AppSpacingTokens.lg,
          ),
          const SizedBox(width: AppSpacingTokens.sm),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  issue.medicineName,
                  style: typography.bodyMdStrong.copyWith(
                    fontWeight: FontWeight.w800,
                  ),
                ),
                const SizedBox(height: AppSpacingTokens.xxs),
                Text(
                  medicineRiskCoverageReasonLabel(l10n, issue.reason),
                  style: typography.bodySm.copyWith(color: surface.body),
                ),
              ],
            ),
          ),
        ],
      ),
    );

    if (isLast) return tile;
    return Column(
      children: [
        tile,
        Divider(height: 1, color: surface.hairline),
      ],
    );
  }
}

class _TagPill extends StatelessWidget {
  const _TagPill({required this.label, required this.color});

  final String label;
  final Color color;

  @override
  Widget build(BuildContext context) {
    final typography = AppTypographyTokens.mobile(
      Theme.of(context).colorScheme.onSurface,
    );

    return DecoratedBox(
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.08),
        borderRadius: BorderRadius.circular(AppRadiusTokens.pill),
      ),
      child: Padding(
        padding: const EdgeInsets.symmetric(
          horizontal: AppSpacingTokens.sm,
          vertical: AppSpacingTokens.xxs,
        ),
        child: Text(
          label,
          style: typography.caption.copyWith(
            color: color,
            fontWeight: FontWeight.w700,
          ),
        ),
      ),
    );
  }
}

class _MedicineRiskCheckLoading extends StatelessWidget {
  const _MedicineRiskCheckLoading();

  @override
  Widget build(BuildContext context) {
    return const Padding(
      padding: EdgeInsets.symmetric(horizontal: AppSpacingTokens.md),
      child: AppInlineSkeletonSection(
        children: [
          AppInlineSkeletonBlock(height: 96),
          AppInlineSkeletonBlock(height: 220),
          AppInlineSkeletonBlock(height: 140),
        ],
      ),
    );
  }
}
