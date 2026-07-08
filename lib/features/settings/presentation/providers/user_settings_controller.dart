import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:lucent_api/api/export.dart';
import 'package:luminous/core/network/network_providers.dart';

/// Remote-backed controller for the authenticated user's privacy/AI settings.
///
/// Reads from `GET /api/v1/user/settings` and patches individual toggles via
/// `PATCH /api/v1/user/settings`. Optimistically updates local state on success;
/// surfaces errors through [AsyncError] so the UI can show rollback toasts.
class UserSettingsController extends AsyncNotifier<UserSettingsDataDto> {
  @override
  Future<UserSettingsDataDto> build() async {
    final api = ref.read(lucentUserSettingsApiProvider);
    final response = await api.userSettingsControllerGetSettingsV1();
    return response.data;
  }

  Future<void> setAiSummariesEnabled(bool enabled) async {
    final current = state.value!;
    await _patch(
      UpdateUserSettingsDto(
        aiSummariesEnabled: enabled,
        dataSharingConsent: current.dataSharingConsent,
        assistantEnabled: current.assistantEnabled,
        assistantMemoryEnabled: current.assistantMemoryEnabled,
        assistantContext: _contextToUpdate(current.assistantContext),
      ),
    );
  }

  Future<void> setAssistantEnabled(bool enabled) async {
    final current = state.value!;
    await _patch(
      UpdateUserSettingsDto(
        aiSummariesEnabled: current.aiSummariesEnabled,
        dataSharingConsent: current.dataSharingConsent,
        assistantEnabled: enabled,
        assistantMemoryEnabled: current.assistantMemoryEnabled,
        assistantContext: _contextToUpdate(current.assistantContext),
      ),
    );
  }

  Future<void> setAssistantMemoryEnabled(bool enabled) async {
    final current = state.value!;
    await _patch(
      UpdateUserSettingsDto(
        aiSummariesEnabled: current.aiSummariesEnabled,
        dataSharingConsent: current.dataSharingConsent,
        assistantEnabled: current.assistantEnabled,
        assistantMemoryEnabled: enabled,
        assistantContext: _contextToUpdate(current.assistantContext),
      ),
    );
  }

  Future<void> setAssistantContext(
    UpdateAssistantContextSettingsDto contextSettings,
  ) async {
    final current = state.value!;
    await _patch(
      UpdateUserSettingsDto(
        aiSummariesEnabled: current.aiSummariesEnabled,
        dataSharingConsent: current.dataSharingConsent,
        assistantEnabled: current.assistantEnabled,
        assistantMemoryEnabled: current.assistantMemoryEnabled,
        assistantContext: contextSettings,
      ),
    );
  }

  Future<void> setDataSharingConsent(bool consent) async {
    final current = state.value!;
    await _patch(
      UpdateUserSettingsDto(
        aiSummariesEnabled: current.aiSummariesEnabled,
        dataSharingConsent: consent,
        assistantEnabled: current.assistantEnabled,
        assistantMemoryEnabled: current.assistantMemoryEnabled,
        assistantContext: _contextToUpdate(current.assistantContext),
      ),
    );
  }

  Future<void> applySettingsPatch(UpdateUserSettingsDto dto) async {
    await _patch(dto);
  }

  // -- Security PIN --

  Future<void> enableSecurityPin(String pin) async {
    final api = ref.read(lucentUserSettingsApiProvider);
    final response = await api.userSettingsControllerEnableSecurityPinV1(
      body: EnableSecurityPinDto(pin: pin),
    );
    state = AsyncData(response.data);
  }

  Future<void> changeSecurityPin(String oldPin, String newPin) async {
    final api = ref.read(lucentUserSettingsApiProvider);
    final response = await api.userSettingsControllerChangeSecurityPinV1(
      body: ChangeSecurityPinDto(oldPin: oldPin, newPin: newPin),
    );
    state = AsyncData(response.data);
  }

  Future<void> disableSecurityPin(String pin) async {
    final api = ref.read(lucentUserSettingsApiProvider);
    final response = await api.userSettingsControllerDisableSecurityPinV1(
      body: DisableSecurityPinDto(pin: pin),
    );
    state = AsyncData(response.data);
  }

  UpdateAssistantContextSettingsDto _contextToUpdate(
    AssistantContextSettingsDto ctx,
  ) {
    return UpdateAssistantContextSettingsDto(
      healthProfile: ctx.healthProfile,
      dailyRecords: ctx.dailyRecords,
      sleepRecords: ctx.sleepRecords,
      currentMedicines: ctx.currentMedicines,
    );
  }

  Future<void> _patch(UpdateUserSettingsDto dto) async {
    final api = ref.read(lucentUserSettingsApiProvider);
    final response = await api.userSettingsControllerUpdateSettingsV1(
      body: dto,
    );
    state = AsyncData(response.data);
  }
}

final userSettingsControllerProvider =
    AsyncNotifierProvider<UserSettingsController, UserSettingsDataDto>(
      UserSettingsController.new,
    );
