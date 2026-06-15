import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:luminous/core/design/app_design.dart';
import 'package:luminous/core/feedback/app_toast.dart';
import 'package:luminous/core/theme/app_theme_extensions.dart';
import 'package:luminous/features/auth/presentation/providers/auth_session_provider.dart';
import 'package:luminous/features/auth/presentation/widgets/auth_required_dialog.dart';
import 'package:luminous/features/health_context/data/providers/health_context_data_providers.dart';
import 'package:luminous/features/health_context/domain/entities/health_context_snapshot.dart';
import 'package:luminous/features/health_context/domain/entities/health_context_write_inputs.dart';
import 'package:luminous/features/medicine/data/repositories/medicine_risk_check_repository.dart';
import 'package:luminous/features/medicine/domain/entities/medicine_risk_check.dart';
import 'package:luminous/features/medicine/presentation/providers/medicine_workspace_provider.dart';
import 'package:luminous/features/medicine/presentation/widgets/medicine_copy.dart';
import 'package:luminous/features/search/domain/entities/search_entities.dart';
import 'package:luminous/features/search/presentation/providers/search_provider.dart';
import 'package:luminous/features/search/presentation/widgets/search_view.dart';
import 'package:luminous/features/today/presentation/providers/today_dashboard_provider.dart';
import 'package:luminous/l10n/app_localizations.dart';

class SearchPage extends ConsumerWidget {
  const SearchPage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final searchState = ref.watch(medicineSearchNotifierProvider);
    final l10n = AppLocalizations.of(context)!;

    return Scaffold(
      body: MedicineSearchView(
        state: searchState,
        onQueryChanged: (q) =>
            ref.read(medicineSearchNotifierProvider.notifier).updateQuery(q),
        onSourceSwitched: (s) =>
            ref.read(medicineSearchNotifierProvider.notifier).switchSource(s),
        onResultSelected: (id) =>
            ref.read(medicineSearchNotifierProvider.notifier).selectResult(id),
        onRetry: () =>
            ref.read(medicineSearchNotifierProvider.notifier).retry(),
        onAddToCurrentMedicines: (result) =>
            _addToCurrentMedicines(ref, context, l10n, result),
      ),
    );
  }

  Future<void> _addToCurrentMedicines(
    WidgetRef ref,
    BuildContext context,
    AppLocalizations l10n,
    MedicineSearchResult result,
  ) async {
    final authSession = ref.read(authSessionProvider);
    if (!authSession.canAccessProtectedData) {
      if (authSession.isLoading) {
        return;
      }
      if (context.mounted) {
        await showAuthRequiredDialog(
          context,
          onLogin: () => context.push(loginRouteForCurrentLocation(context)),
        );
      }
      return;
    }

    final repository = ref.read(healthContextRepositoryProvider);
    final riskCheckRepository = ref.read(medicineRiskCheckRepositoryProvider);

    final medicineSource = result.source == MedicineSearchSource.drugbank
        ? HealthMedicineSource.drugbank
        : HealthMedicineSource.cn;

    final input = CurrentMedicineWriteInput(
      source: medicineSource,
      sourceRefId: result.id,
      displayName: result.name,
    );

    try {
      final snapshot = await ref.read(healthContextSnapshotProvider.future);
      final previewResult = await riskCheckRepository.fetchForSnapshot(
        _snapshotWithCandidate(snapshot, result),
      );

      if (context.mounted &&
          (previewResult.findings.isNotEmpty ||
              previewResult.coverageIssues.isNotEmpty)) {
        final confirmed = await showMedicineAddPrecheckSheet(
          context,
          result: previewResult,
        );
        if (confirmed != true) {
          return;
        }
      }

      await repository.createCurrentMedicine(input);
      ref.invalidate(healthContextSnapshotProvider);
      ref.invalidate(medicineWorkspaceProvider);
      ref.invalidate(todayDashboardProvider);

      if (context.mounted) {
        AppToast.show(context, l10n.mineEditSavedToast);
      }
    } catch (e) {
      if (context.mounted) {
        AppToast.show(context, '${l10n.medicineSearchPrecheckFailedToast}: $e');
      }
    }
  }
}

HealthContextSnapshot _snapshotWithCandidate(
  HealthContextSnapshot snapshot,
  MedicineSearchResult result,
) {
  final now = DateTime.now().toIso8601String();
  return snapshot.copyWith(
    currentMedicines: [
      ...snapshot.currentMedicines,
      CurrentMedicineItem(
        id: '__candidate__${result.source.name}_${result.id}',
        source: result.source.name,
        sourceRefId: result.id,
        displayName: result.name,
        strengthText: null,
        doseText: null,
        route: null,
        startedAt: null,
        endedAt: null,
        isCurrent: true,
        note: null,
        createdAt: now,
        updatedAt: now,
      ),
    ],
  );
}

Future<bool?> showMedicineAddPrecheckSheet(
  BuildContext context, {
  required MedicineRiskCheckResult result,
}) {
  final l10n = AppLocalizations.of(context)!;
  final theme = Theme.of(context);
  final surface = theme.extension<AppThemeSurface>()!;
  final typography = AppTypographyTokens.mobile(theme.colorScheme.onSurface);

  return showModalBottomSheet<bool>(
    context: context,
    showDragHandle: true,
    isScrollControlled: true,
    builder: (sheetContext) {
      return SafeArea(
        child: ConstrainedBox(
          constraints: BoxConstraints(
            maxHeight: MediaQuery.sizeOf(sheetContext).height * 0.85,
          ),
          child: SingleChildScrollView(
            padding: const EdgeInsets.fromLTRB(
              AppSpacingTokens.md,
              0,
              AppSpacingTokens.md,
              AppSpacingTokens.md,
            ),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                Text(
                  l10n.medicineSearchPrecheckTitle,
                  textAlign: TextAlign.center,
                  style: typography.displaySm.copyWith(letterSpacing: 0),
                ),
                Text(
                  l10n.medicineSearchPrecheckDescription,
                  textAlign: TextAlign.center,
                  style: typography.bodySm.copyWith(
                    color: surface.body,
                    letterSpacing: 0,
                  ),
                ),
                if (result.coverageSummary.isNotEmpty) ...[
                  const SizedBox(height: AppSpacingTokens.md),
                  Container(
                    padding: const EdgeInsets.all(AppSpacingTokens.sm),
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
                          size: 18,
                        ),
                        const SizedBox(width: AppSpacingTokens.sm),
                        Expanded(
                          child: Text(
                            result.coverageSummary,
                            style: typography.bodySm.copyWith(
                              color: surface.body,
                              letterSpacing: 0,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
                if (result.findings.isNotEmpty) ...[
                  const SizedBox(height: AppSpacingTokens.lg),
                  Text(
                    l10n.medicineRiskCheckFindingsTitle,
                    style: typography.bodySmStrong.copyWith(
                      fontWeight: FontWeight.w800,
                    ),
                  ),
                  const SizedBox(height: AppSpacingTokens.sm),
                  ...result.findings.take(3).map(
                    (finding) => Padding(
                      padding: const EdgeInsets.only(
                        bottom: AppSpacingTokens.sm,
                      ),
                      child: _PrecheckFindingRow(finding: finding),
                    ),
                  ),
                ],
                if (result.coverageIssues.isNotEmpty) ...[
                  const SizedBox(height: AppSpacingTokens.md),
                  Text(
                    l10n.medicineRiskCheckCoverageTitle,
                    style: typography.bodySmStrong.copyWith(
                      fontWeight: FontWeight.w800,
                    ),
                  ),
                  const SizedBox(height: AppSpacingTokens.sm),
                  ...result.coverageIssues.take(3).map(
                    (issue) => Padding(
                      padding: const EdgeInsets.only(
                        bottom: AppSpacingTokens.sm,
                      ),
                      child: _PrecheckCoverageRow(issue: issue),
                    ),
                  ),
                ],
                const SizedBox(height: AppSpacingTokens.lg),
                FilledButton(
                  key: const Key('medicine-search-precheck-confirm'),
                  onPressed: () => Navigator.of(sheetContext).pop(true),
                  child: Text(l10n.medicineSearchPrecheckConfirmAction),
                ),
                const SizedBox(height: AppSpacingTokens.sm),
                OutlinedButton(
                  key: const Key('medicine-search-precheck-cancel'),
                  onPressed: () => Navigator.of(sheetContext).pop(false),
                  child: Text(l10n.medicineReminderCancelAction),
                ),
              ],
            ),
          ),
        ),
      );
    },
  );
}

class _PrecheckFindingRow extends StatelessWidget {
  const _PrecheckFindingRow({required this.finding});

  final MedicineRiskFinding finding;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final theme = Theme.of(context);
    final surface = theme.extension<AppThemeSurface>()!;
    final typography = AppTypographyTokens.mobile(theme.colorScheme.onSurface);
    final color = medicineRiskSeverityColor(finding.severity);

    return DecoratedBox(
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.08),
        borderRadius: BorderRadius.circular(AppRadiusTokens.md),
        border: Border.all(color: color.withValues(alpha: 0.18)),
      ),
      child: Padding(
        padding: const EdgeInsets.all(AppSpacingTokens.sm),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Icon(medicineRiskFindingIcon(finding), color: color, size: 18),
            const SizedBox(width: AppSpacingTokens.sm),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    medicineRiskFindingTitle(l10n, finding),
                    style: typography.bodySmStrong.copyWith(
                      fontWeight: FontWeight.w800,
                    ),
                  ),
                  const SizedBox(height: AppSpacingTokens.xxs),
                  Text(
                    medicineRiskFindingBody(l10n, finding),
                    style: typography.bodySm.copyWith(
                      color: surface.body,
                      letterSpacing: 0,
                    ),
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

class _PrecheckCoverageRow extends StatelessWidget {
  const _PrecheckCoverageRow({required this.issue});

  final MedicineRiskCoverageIssue issue;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final theme = Theme.of(context);
    final surface = theme.extension<AppThemeSurface>()!;
    final typography = AppTypographyTokens.mobile(theme.colorScheme.onSurface);

    return DecoratedBox(
      decoration: BoxDecoration(
        color: AppColorTokens.warningSoft.withValues(alpha: 0.42),
        borderRadius: BorderRadius.circular(AppRadiusTokens.md),
        border: Border.all(color: AppColorTokens.warningDeep.withValues(alpha: 0.18)),
      ),
      child: Padding(
        padding: const EdgeInsets.all(AppSpacingTokens.sm),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Icon(
              Icons.info_outline_rounded,
              color: AppColorTokens.warningDeep,
              size: 18,
            ),
            const SizedBox(width: AppSpacingTokens.sm),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    issue.medicineName,
                    style: typography.bodySmStrong.copyWith(
                      fontWeight: FontWeight.w800,
                    ),
                  ),
                  const SizedBox(height: AppSpacingTokens.xxs),
                  Text(
                    medicineRiskCoverageReasonLabel(l10n, issue.reason),
                    style: typography.bodySm.copyWith(
                      color: surface.body,
                      letterSpacing: 0,
                    ),
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
