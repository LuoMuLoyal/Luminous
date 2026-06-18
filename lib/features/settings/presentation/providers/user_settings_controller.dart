import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:lucent_openapi/lucent_openapi.dart';
import 'package:luminous/core/network/lucent_network_providers.dart';

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

  Future<void> setAiChatEnabled(bool enabled) async {
    await _patch(UpdateUserSettingsDto(aiChatEnabled: enabled));
  }

  Future<void> setAiChatMemoryEnabled(bool enabled) async {
    await _patch(UpdateUserSettingsDto(aiChatMemoryEnabled: enabled));
  }

  Future<void> setAiChatContext(
    UpdateAiChatContextSettingsDto contextSettings,
  ) async {
    await _patch(UpdateUserSettingsDto(aiChatContext: contextSettings));
  }

  Future<void> setDataSharingConsent(bool consent) async {
    await _patch(UpdateUserSettingsDto(dataSharingConsent: consent));
  }

  Future<void> applySettingsPatch(UpdateUserSettingsDto dto) async {
    await _patch(dto);
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
