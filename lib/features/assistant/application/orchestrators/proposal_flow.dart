import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:luminous/core/errors/result.dart';
import 'package:luminous/core/errors/run_guarded.dart';
import 'package:luminous/core/feedback/toast.dart';
import 'package:luminous/features/assistant/domain/entities/models.dart';
import 'package:luminous/features/record/data/providers/record_access.dart';
import 'package:luminous/features/record/domain/entities/inputs.dart';
import 'package:luminous/features/record/domain/entities/record.dart';
import 'package:luminous/features/settings/domain/entities/user_settings.dart';
import 'package:luminous/features/settings/presentation/providers/user_settings.dart';

/// Orchestrates the execution of assistant proposed actions.
///
/// Handles the cross-feature write path: when a user confirms a proposed
/// action (create/update/delete daily record, update user settings), this
/// orchestrator dispatches to the appropriate repository and returns the
/// result. It encapsulates the mapping from assistant proposal payloads to
/// domain inputs, keeping the [AssistantController] Notifier focused on
/// state management.
class ProposalExecutionOrchestrator {
  ProposalExecutionOrchestrator({required this.ref});

  final Ref ref;

  /// Executes a confirmed proposed action.
  ///
  /// Throws if the proposal is expired or if the underlying operation fails.
  /// The caller is responsible for updating proposal execution state before
  /// and after this call.
  Future<void> execute(AssistantProposedAction proposal) async {
    if (proposal.isExpired) {
      throw Exception('Proposal expired; please regenerate.');
    }

    switch (proposal.payload) {
      case AssistantCreateDailyRecordProposalPayload():
        final payload =
            proposal.payload as AssistantCreateDailyRecordProposalPayload;
        await ref
            .read(dailyRecordRepositoryProvider)
            .create(
              DailyRecordCreateInput(
                kind: _mapDailyRecordKind(payload.draft.kind),
                occurredAt: payload.draft.occurredAt,
                title: payload.draft.title,
                value: payload.draft.value,
                unit: payload.draft.unit,
                note: payload.draft.note,
                payload: payload.draft.payload,
              ),
            );

      case AssistantUpdateDailyRecordProposalPayload():
        final payload =
            proposal.payload as AssistantUpdateDailyRecordProposalPayload;
        await ref
            .read(dailyRecordRepositoryProvider)
            .update(
              payload.recordId,
              DailyRecordUpdateInput(
                occurredAt: payload.hasOccurredAt
                    ? payload.occurredAt
                    : dailyRecordNoChange,
                title: payload.hasTitle ? payload.title : dailyRecordNoChange,
                value: payload.hasValue ? payload.value : dailyRecordNoChange,
                unit: payload.hasUnit ? payload.unit : dailyRecordNoChange,
                note: payload.hasNote ? payload.note : dailyRecordNoChange,
                payload: payload.hasPayload
                    ? payload.payload
                    : dailyRecordNoChange,
              ),
            );

      case AssistantDeleteDailyRecordProposalPayload():
        final payload =
            proposal.payload as AssistantDeleteDailyRecordProposalPayload;
        await ref.read(dailyRecordRepositoryProvider).delete(payload.recordId);

      case AssistantUpdateUserSettingsProposalPayload():
        final payload =
            proposal.payload as AssistantUpdateUserSettingsProposalPayload;
        final ctx = payload.draft.assistantContext;
        final current = ref.read(userSettingsControllerProvider).value;
        await ref
            .read(userSettingsControllerProvider.notifier)
            .applySettingsPatch(
              aiSummariesEnabled: current?.aiSummariesEnabled ?? false,
              dataSharingConsent: current?.dataSharingConsent ?? false,
              assistantEnabled:
                  payload.draft.assistantEnabled ??
                  current?.assistantEnabled ??
                  false,
              assistantMemoryEnabled:
                  payload.draft.assistantMemoryEnabled ??
                  current?.assistantMemoryEnabled ??
                  false,
              waterTargetCount: current?.waterTargetCount ?? 8,
              assistantContext: ctx != null
                  ? AssistantContextPatch(
                      healthProfile: ctx.healthProfile,
                      dailyRecords: ctx.dailyRecords,
                      sleepRecords: ctx.sleepRecords,
                      currentMedicines: ctx.currentMedicines,
                    )
                  : AssistantContextPatch(
                      healthProfile: current?.assistantContext.healthProfile,
                      dailyRecords: current?.assistantContext.dailyRecords,
                      sleepRecords: current?.assistantContext.sleepRecords,
                      currentMedicines:
                          current?.assistantContext.currentMedicines,
                    ),
            );
    }
  }

  /// Convenience method: executes a proposal and shows a toast on success/failure.
  /// Returns `true` if the proposal executed successfully.
  Future<bool> executeWithFeedback({
    required BuildContext context,
    required String messageId,
    required String proposalId,
    required AssistantProposedAction proposal,
    required String successMessage,
  }) async {
    final result = await runGuarded(
      ref: ref,
      tag: 'ProposalExecutionOrchestrator.executeWithFeedback',
      action: () => execute(proposal),
    );

    switch (result) {
      case Success():
        if (context.mounted) {
          await Toast.show(context, successMessage);
        }
        return true;
      case Failure(:final error):
        if (context.mounted) {
          await Toast.show(context, error.message);
        }
        return false;
    }
  }

  DailyRecordKind _mapDailyRecordKind(String raw) {
    return switch (raw) {
      'water' => DailyRecordKind.water,
      'meal' => DailyRecordKind.meal,
      'symptom' => DailyRecordKind.symptom,
      'note' => DailyRecordKind.note,
      'sleep' => DailyRecordKind.sleep,
      _ => DailyRecordKind.note,
    };
  }
}
