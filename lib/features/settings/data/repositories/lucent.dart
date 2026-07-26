import 'package:lucent_api/lucent_api.dart';
import 'package:luminous/core/network/network_providers.dart';
import 'package:luminous/features/settings/domain/entities/user_settings.dart';
import 'package:luminous/features/settings/domain/repositories/user_settings.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

part 'lucent.g.dart';

@riverpod
UserSettingsRepository userSettingsRepository(Ref ref) {
  return LucentUserSettingsRepository(
    api: ref.watch(lucentClientProvider).userSettings,
  );
}

/// Lucent-backed implementation of [UserSettingsRepository].
class LucentUserSettingsRepository implements UserSettingsRepository {
  LucentUserSettingsRepository({required this.api});

  final UserSettingsApi api;

  @override
  Future<UserSettings> getSettings() async {
    final response = await api.userSettingsControllerGetSettingsV1();
    return _mapSettings(response.data!.data);
  }

  @override
  Future<UserSettings> updateSettings({
    required bool aiSummariesEnabled,
    required bool dataSharingConsent,
    required bool assistantEnabled,
    required bool assistantMemoryEnabled,
    required int waterTargetCount,
    required AssistantContextPatch assistantContext,
  }) async {
    final response = await api.userSettingsControllerUpdateSettingsV1(
      updateUserSettingsDto: UpdateUserSettingsDto(
        aiSummariesEnabled: aiSummariesEnabled,
        dataSharingConsent: dataSharingConsent,
        assistantEnabled: assistantEnabled,
        assistantMemoryEnabled: assistantMemoryEnabled,
        waterTargetCount: waterTargetCount,
        assistantContext: UpdateAssistantContextSettingsDto(
          healthProfile: assistantContext.healthProfile,
          dailyRecords: assistantContext.dailyRecords,
          sleepRecords: assistantContext.sleepRecords,
          currentMedicines: assistantContext.currentMedicines,
        ),
      ),
    );
    return _mapSettings(response.data!.data);
  }

  @override
  Future<UserSettings> enableSecurityPin(String pin) async {
    final response = await api.userSettingsControllerEnableSecurityPinV1(
      enableSecurityPinDto: EnableSecurityPinDto(pin: pin),
    );
    return _mapSettings(response.data!.data);
  }

  @override
  Future<UserSettings> changeSecurityPin(String oldPin, String newPin) async {
    final response = await api.userSettingsControllerChangeSecurityPinV1(
      changeSecurityPinDto: ChangeSecurityPinDto(
        oldPin: oldPin,
        newPin: newPin,
      ),
    );
    return _mapSettings(response.data!.data);
  }

  @override
  Future<UserSettings> disableSecurityPin(String pin) async {
    final response = await api.userSettingsControllerDisableSecurityPinV1(
      disableSecurityPinDto: DisableSecurityPinDto(pin: pin),
    );
    return _mapSettings(response.data!.data);
  }

  UserSettings _mapSettings(UserSettingsDataDto dto) {
    return UserSettings(
      aiSummariesEnabled: dto.aiSummariesEnabled,
      dataSharingConsent: dto.dataSharingConsent,
      assistantEnabled: dto.assistantEnabled,
      assistantMemoryEnabled: dto.assistantMemoryEnabled,
      waterTargetCount: dto.waterTargetCount.toInt(),
      assistantContext: AssistantContextSettings(
        healthProfile: dto.assistantContext.healthProfile,
        dailyRecords: dto.assistantContext.dailyRecords,
        sleepRecords: dto.assistantContext.sleepRecords,
        currentMedicines: dto.assistantContext.currentMedicines,
      ),
      updatedAt: dto.updatedAt,
      securityPin: SecurityPinSettings(
        enabled: dto.securityPin.enabled,
        lastChangedAt: dto.securityPin.lastChangedAt,
      ),
    );
  }
}
