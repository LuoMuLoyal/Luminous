import 'dart:async';

import 'package:clock/clock.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'package:go_router/go_router.dart';

import 'package:luminous/core/errors/user_message.dart';
import 'package:luminous/core/feedback/toast.dart';
import 'package:luminous/core/logger/logger.dart';
import 'package:luminous/core/providers/data_change_bus.dart';
import 'package:luminous/core/widgets/layout/page_scaffold.dart';
import 'package:luminous/features/auth/presentation/providers/session.dart';
import 'package:luminous/features/auth/presentation/widgets/shared/required_dialog.dart';
import 'package:luminous/features/health_context/data/providers/health_context.dart';
import 'package:luminous/features/health_context/domain/entities/snapshot.dart';
import 'package:luminous/features/health_context/domain/entities/write_inputs.dart';
import 'package:luminous/features/medicine/data/repositories/risk_check.dart';
import 'package:luminous/features/search/domain/entities/entities.dart';
import 'package:luminous/features/search/presentation/providers/medicine_search.dart';
import 'package:luminous/features/search/presentation/widgets/shared/medicine_add_precheck_dialog.dart';
import 'package:luminous/features/search/presentation/widgets/views/view.dart';
import 'package:luminous/l10n/app_localizations.dart';

class SearchPage extends ConsumerWidget {
  const SearchPage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final searchState = ref.watch(medicineSearchNotifierProvider);
    final l10n = AppLocalizations.of(context)!;

    // Build a set of already-added medicine keys (source:sourceRefId) so the
    // search result tiles can show an "already added" state.
    final snapshotAsync = ref.watch(healthContextSnapshotProvider);
    final addedMedicineIds = snapshotAsync.maybeWhen(
      data: (snapshot) => snapshot.currentMedicines
          .where((m) => m.isCurrent && m.sourceRefId != null)
          .map((m) => '${m.source}:${m.sourceRefId}')
          .toSet(),
      orElse: () => const <String>{},
    );

    return PageScaffold(
      title: l10n.medicineSearchPageTitle,
      child: MedicineSearchView(
        state: searchState,
        addedMedicineIds: addedMedicineIds,
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
        final confirmed = await showMedicineAddPrecheckDialog(
          context,
          result: previewResult,
        );
        if (confirmed != true) {
          return;
        }
      }

      final updatedSnapshot = await repository.createCurrentMedicine(input);
      ref
          .read(dataChangeBusProvider.notifier)
          .emit(DataChangeTopic.currentMedicines);

      if (context.mounted) {
        final newMedicine = updatedSnapshot.currentMedicines.firstWhere(
          (m) => m.sourceRefId == result.id && m.source == medicineSource.name,
          orElse: () => updatedSnapshot.currentMedicines.last,
        );
        unawaited(
          Toast.showWithAction(
            context,
            l10n.medicineSearchAddedToBoxToast,
            l10n.medicineSearchGoToReminderAction,
            () => context.push(
              '/medicine/reminders/new?medicineId=${newMedicine.id}',
            ),
          ),
        );
      }
    } catch (e) {
      ref
          .read(talkerProvider)
          .error('SearchPage._addToCurrentMedicines: failed: $e');
      if (context.mounted) {
        unawaited(
          Toast.show(
            context,
            userMessageFromError(
              e,
              fallback: l10n.medicineSearchPrecheckFailedToast,
            ),
          ),
        );
      }
    }
  }
}

HealthContextSnapshot _snapshotWithCandidate(
  HealthContextSnapshot snapshot,
  MedicineSearchResult result,
) {
  final now = clock.now().toIso8601String();
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
