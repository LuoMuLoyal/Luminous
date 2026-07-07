import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:lucent_openapi/lucent_openapi.dart';
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
    final data = response.data?.data;
    if (data == null) {
      throw StateError('User settings response data is null.');
    }
    return data;
  }

  Future<void> setAiSummariesEnabled(bool enabled) async {
    await _patch(UpdateUserSettingsDto(aiSummariesEnabled: enabled));
  }

  Future<void> setAssistantEnabled(bool enabled) async {
    await _patch(UpdateUserSettingsDto(assistantEnabled: enabled));
  }

  Future<void> setAssistantMemoryEnabled(bool enabled) async {
    await _patch(UpdateUserSettingsDto(assistantMemoryEnabled: enabled));
  }

  Future<void> setAssistantContext(
    UpdateAssistantContextSettingsDto contextSettings,
  ) async {
    await _patch(UpdateUserSettingsDto(assistantContext: contextSettings));
  }

  Future<void> setDataSharingConsent(bool consent) async {
    await _patch(UpdateUserSettingsDto(dataSharingConsent: consent));
  }

  Future<void> applySettingsPatch(UpdateUserSettingsDto dto) async {
    await _patch(dto);
  }

  // -- Security PIN --

  Future<void> enableSecurityPin(String pin) async {
    final api = ref.read(lucentUserSettingsApiProvider);
    final response = await api.userSettingsControllerEnableSecurityPinV1(
      enableSecurityPinDto: EnableSecurityPinDto(pin: pin),
    );
    final data = response.data?.data;
    if (data == null) {
      throw StateError('Enable security PIN response data is null.');
    }
    state = AsyncData(data);
  }

  Future<void> changeSecurityPin(String oldPin, String newPin) async {
    final api = ref.read(lucentUserSettingsApiProvider);
    final response = await api.userSettingsControllerChangeSecurityPinV1(
      changeSecurityPinDto: ChangeSecurityPinDto(
        oldPin: oldPin,
        newPin: newPin,
      ),
    );
    final data = response.data?.data;
    if (data == null) {
      throw StateError('Change security PIN response data is null.');
    }
    state = AsyncData(data);
  }

  Future<void> disableSecurityPin(String pin) async {
    final api = ref.read(lucentUserSettingsApiProvider);
    final response = await api.userSettingsControllerDisableSecurityPinV1(
      disableSecurityPinDto: DisableSecurityPinDto(pin: pin),
    );
    final data = response.data?.data;
    if (data == null) {
      throw StateError('Disable security PIN response data is null.');
    }
    state = AsyncData(data);
  }

  Future<void> _patch(UpdateUserSettingsDto dto) async {
    final api = ref.read(lucentUserSettingsApiProvider);
    final response = await api.userSettingsControllerUpdateSettingsV1(
      updateUserSettingsDto: dto,
    );
    final data = response.data?.data;
    if (data == null) {
      throw StateError('User settings patch response data is null.');
    }
    state = AsyncData(data);
  }
}

final userSettingsControllerProvider =
    AsyncNotifierProvider<UserSettingsController, UserSettingsDataDto>(
      UserSettingsController.new,
    );
