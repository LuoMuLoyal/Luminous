import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:forui/forui.dart';
import 'package:go_router/go_router.dart';
import 'package:luminous/core/design/app_design.dart';
import 'package:luminous/core/widgets/common/app_state_views.dart';
import 'package:luminous/core/widgets/layout/page_scaffold_shell.dart';
import 'package:luminous/features/auth/presentation/providers/session/auth_session_provider.dart';
import 'package:luminous/features/auth/presentation/widgets/auth_required_dialog.dart';
import 'package:luminous/features/medicine/domain/entities/medicine_risk_check.dart';
import 'package:luminous/features/medicine/presentation/providers/medicine_risk_check_provider.dart';
import 'package:luminous/features/medicine/presentation/widgets/risk/medicine_risk_coverage_issue_tile.dart';
import 'package:luminous/features/medicine/presentation/widgets/risk/medicine_risk_finding_tile.dart';
import 'package:luminous/features/medicine/presentation/widgets/risk/medicine_risk_metric_chip.dart';
import 'package:luminous/features/medicine/presentation/widgets/risk/medicine_risk_red_flag.dart';
import 'package:luminous/features/medicine/presentation/widgets/risk/medicine_risk_check_loading.dart';
import 'package:luminous/core/widgets/common/app_back_button.dart';
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
        leading: const AppBackButton(),
        children: [
          session.isLoading
              ? const MedicineRiskCheckLoading()
              : AuthRequiredDialogGate(
                  onLogin: () =>
                      context.push(loginRouteForCurrentLocation(context)),
                ),
        ],
      );
    }

    final resultAsync = ref.watch(medicineRiskCheckProvider);
    final redFlagAlertsAsync = ref.watch(redFlagAlertsProvider);
    return PageScaffoldShell(
      title: l10n.medicineRiskCheckPageTitle,
      centerTitle: true,
      leading: const AppBackButton(),
      children: [
        resultAsync.when(
          data: (result) {
            final alerts = redFlagAlertsAsync.asData?.value ?? const [];
            return _MedicineRiskCheckBody(
              result: result,
              redFlagAlerts: alerts,
            );
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
        ),
      ],
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
    final colors = context.theme.colors;
    final textTheme = Theme.of(context).textTheme;

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: AppSpacingTokens.md),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          if (redFlagAlerts.isNotEmpty) ...[
            MedicineRiskRedFlagBanner(alerts: redFlagAlerts, l10n: l10n),
            const SizedBox(height: AppSpacingTokens.md),
          ],
          PageSectionCard(
            title: l10n.medicineRiskCheckSummaryTitle,
            child: Wrap(
              spacing: AppSpacingTokens.sm,
              runSpacing: AppSpacingTokens.sm,
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
          if (result.coverageSummary.isNotEmpty) ...[
            const SizedBox(height: AppSpacingTokens.md),
            Container(
              padding: const EdgeInsets.all(AppSpacingTokens.md),
              decoration: BoxDecoration(
                color: Color(0xFFFEF3C7).withValues(alpha: 0.42),
                borderRadius: BorderRadius.circular(AppRadiusTokens.md),
              ),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Icon(
                    FLucideIcons.circleAlert,
                    color: Color(0xFFB45309),
                    size: AppSpacingTokens.lg,
                  ),
                  const SizedBox(width: AppSpacingTokens.sm),
                  Expanded(
                    child: Text(
                      result.coverageSummary,
                      style: textTheme.bodySmall?.copyWith(
                        color: colors.mutedForeground,
                      ),
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
              icon: FLucideIcons.badgeCheck,
              tone: AppStateTone.success,
              padding: const EdgeInsets.all(AppSpacingTokens.lg),
            )
          else
            PageSectionCard(
              title: l10n.medicineRiskCheckFindingsTitle,
              child: Column(
                children: [
                  for (
                    var index = 0;
                    index < result.findings.length;
                    index += 1
                  )
                    MedicineRiskFindingTile(
                      finding: result.findings[index],
                      isLast: index == result.findings.length - 1,
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
                    MedicineRiskCoverageIssueTile(
                      issue: result.coverageIssues[index],
                      isLast: index == result.coverageIssues.length - 1,
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
