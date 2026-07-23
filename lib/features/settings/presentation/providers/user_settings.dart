import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'package:luminous/core/providers/data_change_bus.dart';
import 'package:luminous/features/settings/data/repositories/lucent.dart';
import 'package:luminous/features/settings/domain/entities/user_settings.dart';

/// Re-export so presentation code can import from one place.
export 'package:luminous/features/settings/data/repositories/lucent.dart'
    show userSettingsRepositoryProvider;

/// Remote-backed controller for the authenticated user's privacy/AI settings.
///
/// Reads from `GET /api/v1/user/settings` and patches individual toggles via
/// `PATCH /api/v1/user/settings`. Optimistically updates local state on success;
/// surfaces errors through [AsyncError] so the UI can show rollback toasts.
class UserSettingsController extends AsyncNotifier<UserSettings> {
  @override
  Future<UserSettings> build() async {
    final repo = ref.read(userSettingsRepositoryProvider);
    return repo.getSettings();
  }

  Future<void> setAiSummariesEnabled(bool enabled) async {
    final current = state.value!;
    await _patch(aiSummariesEnabled: enabled, current: current);
  }

  Future<void> setAssistantEnabled(bool enabled) async {
    final current = state.value!;
    await _patch(assistantEnabled: enabled, current: current);
  }

  Future<void> setAssistantMemoryEnabled(bool enabled) async {
    final current = state.value!;
    await _patch(assistantMemoryEnabled: enabled, current: current);
  }

  Future<void> setAssistantContext(AssistantContextPatch patch) async {
    final current = state.value!;
    await _patch(assistantContext: patch, current: current);
  }

  Future<void> setDataSharingConsent(bool consent) async {
    final current = state.value!;
    await _patch(dataSharingConsent: consent, current: current);
  }

  Future<void> applySettingsPatch({
    required bool aiSummariesEnabled,
    required bool dataSharingConsent,
    required bool assistantEnabled,
    required bool assistantMemoryEnabled,
    required int waterTargetCount,
    required AssistantContextPatch assistantContext,
  }) async {
    final repo = ref.read(userSettingsRepositoryProvider);
    final updated = await repo.updateSettings(
      aiSummariesEnabled: aiSummariesEnabled,
      dataSharingConsent: dataSharingConsent,
      assistantEnabled: assistantEnabled,
      assistantMemoryEnabled: assistantMemoryEnabled,
      waterTargetCount: waterTargetCount,
      assistantContext: assistantContext,
    );
    state = AsyncData(updated);
    ref.read(dataChangeBusProvider.notifier).emit(DataChangeTopic.userSettings);
  }

  // -- Security PIN --

  Future<void> enableSecurityPin(String pin) async {
    final repo = ref.read(userSettingsRepositoryProvider);
    final updated = await repo.enableSecurityPin(pin);
    state = AsyncData(updated);
  }

  Future<void> changeSecurityPin(String oldPin, String newPin) async {
    final repo = ref.read(userSettingsRepositoryProvider);
    final updated = await repo.changeSecurityPin(oldPin, newPin);
    state = AsyncData(updated);
  }

  Future<void> disableSecurityPin(String pin) async {
    final repo = ref.read(userSettingsRepositoryProvider);
    final updated = await repo.disableSecurityPin(pin);
    state = AsyncData(updated);
  }

  Future<void> _patch({
    bool? aiSummariesEnabled,
    bool? dataSharingConsent,
    bool? assistantEnabled,
    bool? assistantMemoryEnabled,
    AssistantContextPatch? assistantContext,
    required UserSettings current,
  }) async {
    final repo = ref.read(userSettingsRepositoryProvider);
    // On success the state is replaced with the patched snapshot; on failure
    // the state is left untouched (previous value stays) and the error is
    // rethrown so callers using `runGuarded` can surface a toast. Rapid-tap
    // protection is handled in the UI via a local `_isPatching` guard rather
    // than by flipping the controller into `AsyncLoading` (which would lose
    // the previous value and flash a skeleton).
    final updated = await repo.updateSettings(
      aiSummariesEnabled: aiSummariesEnabled ?? current.aiSummariesEnabled,
      dataSharingConsent: dataSharingConsent ?? current.dataSharingConsent,
      assistantEnabled: assistantEnabled ?? current.assistantEnabled,
      assistantMemoryEnabled:
          assistantMemoryEnabled ?? current.assistantMemoryEnabled,
      waterTargetCount: current.waterTargetCount,
      assistantContext:
          assistantContext ??
          AssistantContextPatch(
            healthProfile: current.assistantContext.healthProfile,
            dailyRecords: current.assistantContext.dailyRecords,
            sleepRecords: current.assistantContext.sleepRecords,
            currentMedicines: current.assistantContext.currentMedicines,
          ),
    );
    state = AsyncData(updated);
    ref.read(dataChangeBusProvider.notifier).emit(DataChangeTopic.userSettings);
  }
}

final userSettingsControllerProvider =
    AsyncNotifierProvider<UserSettingsController, UserSettings>(
      UserSettingsController.new,
    );
