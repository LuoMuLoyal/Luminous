import 'dart:async';

import 'package:collection/collection.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:luminous/core/auth/session_provider.dart';
import 'package:luminous/core/errors/user_message.dart';
import 'package:luminous/core/feedback/toast.dart';
import 'package:luminous/core/logger/logger.dart';
import 'package:luminous/core/providers/data_change_bus.dart';
import 'package:luminous/features/auth/presentation/widgets/shared/required_dialog.dart';
import 'package:luminous/features/health_context/data/providers/health_context.dart';
import 'package:luminous/features/health_context/domain/entities/write_inputs.dart';
import 'package:luminous/features/medicine/data/repositories/risk_check.dart';
import 'package:luminous/features/medicine/domain/entities/risk_check.dart';
import 'package:luminous/features/medicine/presentation/routes.dart';
import 'package:luminous/features/search/presentation/widgets/shared/medicine_add_precheck_dialog.dart';
import 'package:luminous/l10n/app_localizations.dart';

/// Shared "add to drugbox" closed loop (F-9), the single implementation used
/// by both the medicine search page and the barcode scan result sheet (F-3).
///
/// [source] is the wire source name ('cn' | 'drugbank') and [sourceRefId] the
/// medicine DB product id — never a drugbox record id. Flow: auth gate →
/// instant risk pre-check (`runPrecheck`) → precheck confirm dialog when
/// findings/coverage issues exist → `createCurrentMedicine` →
/// DataChangeBus emit → success toast with a typed "set reminder" action that
/// jumps to `/medicine/reminders/new` carrying the box record id.
Future<void> addMedicineToBoxWithPrecheck(
  BuildContext context, {
  required WidgetRef ref,
  required String source, // 'cn' | 'drugbank'
  required String sourceRefId, // 药品库产品 id
  required String displayName,
}) async {
  final l10n = AppLocalizations.of(context)!;

  final authSession = ref.read(authSessionProvider);
  if (!authSession.canAccessProtectedData) {
    if (authSession.isLoading) {
      return;
    }
    if (context.mounted) {
      await showAuthRequiredDialog(
        context,
        // The login action runs on a later user tap: the calling surface
        // (e.g. the recognition dialog) may already be closed by then, so
        // guard the push with a fresh mounted check — pushing through a
        // deactivated context registers an Inherited dependency on a dying
        // element and trips `debugDeactivated`'s `_dependents.isEmpty`
        // assertion.
        onLogin: () {
          if (!context.mounted) return;
          unawaited(context.push(loginRouteForCurrentLocation(context)));
        },
      );
    }
    return;
  }

  final repository = ref.read(healthContextRepositoryProvider);
  final riskCheckRepository = ref.read(medicineRiskCheckRepositoryProvider);

  final medicineSource = source == 'drugbank'
      ? HealthMedicineSource.drugbank
      : HealthMedicineSource.cn;

  final input = CurrentMedicineWriteInput(
    source: medicineSource,
    sourceRefId: sourceRefId,
    displayName: displayName,
  );

  try {
    // Instant pre-check of the current box + the candidate medicine. The
    // server runs it on the fly without persisting a record, so the scope
    // now genuinely includes the medicine about to be added.
    MedicineRiskCheckResult? previewResult;
    try {
      previewResult = await riskCheckRepository.runPrecheck(
        source: medicineSource.name,
        sourceRefId: sourceRefId,
      );
    } catch (e) {
      // Pre-check failure must not block adding: be honest that the check
      // could not be run now and continue without a safety judgement.
      ref
          .read(talkerProvider)
          .error('addMedicineToBoxWithPrecheck: precheck failed: $e');
      if (context.mounted) {
        unawaited(
          Toast.show(context, l10n.medicineSearchPrecheckUnavailableToast),
        );
      }
    }

    if (context.mounted &&
        previewResult != null &&
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

    final result = await repository.createCurrentMedicine(input).run();
    final updatedSnapshot = result.fold(
      (failure) => throw failure,
      (snapshot) => snapshot,
    );
    ref
        .read(dataChangeBusProvider.notifier)
        .emit(DataChangeTopic.currentMedicines);

    if (context.mounted) {
      final newMedicine = updatedSnapshot.currentMedicines.firstWhereOrNull(
        (m) => m.sourceRefId == sourceRefId && m.source == medicineSource.name,
      );
      if (newMedicine == null) return;
      unawaited(
        Toast.showWithAction(
          context,
          l10n.medicineSearchAddedToBoxToast,
          l10n.medicineSearchGoToReminderAction,
          // Typed route (F-14) — avoids the string query concatenation bug.
          // The action fires on a later user tap; the calling surface (e.g.
          // the recognition dialog) may have been closed in between, so a
          // deactivated context must not be pushed through (same
          // `_dependents.isEmpty` assertion as the login action above).
          () {
            if (!context.mounted) return;
            unawaited(
              MedicineRemindersNewRoute(
                medicineId: newMedicine.id,
              ).push(context),
            );
          },
        ),
      );
    }
  } catch (e) {
    ref.read(talkerProvider).error('addMedicineToBoxWithPrecheck: failed: $e');
    if (context.mounted) {
      unawaited(
        Toast.show(
          context,
          userMessageFromError(
            e,
            fallback: l10n.medicineSearchPrecheckFailedToast,
            l10n: l10n,
          ),
        ),
      );
    }
  }
}
