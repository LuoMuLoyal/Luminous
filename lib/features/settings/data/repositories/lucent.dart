import 'package:fpdart/fpdart.dart';
import 'package:lucent_api/lucent_api.dart';
import 'package:luminous/core/errors/lucent_failure.dart';
import 'package:luminous/core/network/client_providers.dart';
import 'package:luminous/core/network/error_code.dart';
import 'package:luminous/core/network/error_mapper.dart';
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
///
/// Every expected recoverable failure (network, server business failure) is a
/// `TaskEither` Left produced via `LucentErrorMapper.fromObject`; a successful
/// response is a Right. An empty success response body is a
/// `LucentFailure.network(emptyResponse)` (auth `_requireBody` precedent).
/// Protocol violations (non `problem+json` error bodies) keep the mapper's
/// `FormatException` which propagates from `.run()`.
class LucentUserSettingsRepository implements UserSettingsRepository {
  LucentUserSettingsRepository({required this.api});

  final UserSettingsApi api;

  @override
  TaskEither<LucentFailure, UserSettings> getSettings() {
    return TaskEither.tryCatch(() async {
      final response = await api.userSettingsControllerGetSettingsV1();
      return _mapSettings(
        _requireData(response.data, operation: 'getSettings'),
      );
    }, (error, stackTrace) => LucentErrorMapper.fromObject(error));
  }

  @override
  TaskEither<LucentFailure, UserSettings> updateSettings({
    required bool aiSummariesEnabled,
    required bool dataSharingConsent,
    required bool assistantEnabled,
    required bool assistantMemoryEnabled,
    required int waterTargetCount,
    required AssistantContextPatch assistantContext,
  }) {
    return TaskEither.tryCatch(() async {
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
      return _mapSettings(
        _requireData(response.data, operation: 'updateSettings'),
      );
    }, (error, stackTrace) => LucentErrorMapper.fromObject(error));
  }

  @override
  TaskEither<LucentFailure, UserSettings> enableSecurityPin(String pin) {
    return TaskEither.tryCatch(() async {
      final response = await api.userSettingsControllerEnableSecurityPinV1(
        enableSecurityPinDto: EnableSecurityPinDto(pin: pin),
      );
      return _mapSettings(
        _requireData(response.data, operation: 'enableSecurityPin'),
      );
    }, (error, stackTrace) => LucentErrorMapper.fromObject(error));
  }

  @override
  TaskEither<LucentFailure, UserSettings> changeSecurityPin(
    String oldPin,
    String newPin,
  ) {
    return TaskEither.tryCatch(() async {
      final response = await api.userSettingsControllerChangeSecurityPinV1(
        changeSecurityPinDto: ChangeSecurityPinDto(
          oldPin: oldPin,
          newPin: newPin,
        ),
      );
      return _mapSettings(
        _requireData(response.data, operation: 'changeSecurityPin'),
      );
    }, (error, stackTrace) => LucentErrorMapper.fromObject(error));
  }

  @override
  TaskEither<LucentFailure, UserSettings> disableSecurityPin(String pin) {
    return TaskEither.tryCatch(() async {
      final response = await api.userSettingsControllerDisableSecurityPinV1(
        disableSecurityPinDto: DisableSecurityPinDto(pin: pin),
      );
      return _mapSettings(
        _requireData(response.data, operation: 'disableSecurityPin'),
      );
    }, (error, stackTrace) => LucentErrorMapper.fromObject(error));
  }

  /// Extracts a non-null generated-client payload, throwing
  /// [LucentFailure.network] (emptyResponse) when the success body is absent
  /// (auth `_requireBody` / medicine `dose_log_remote` precedent).
  T _requireData<T>(T? data, {String? operation}) {
    if (data == null) {
      final context = operation == null ? '' : '（$operation）';
      throw LucentFailure.network(
        message: 'API 返回空响应体$context',
        networkErrorCode: NetworkErrorCode.emptyResponse,
      );
    }
    return data;
  }

  UserSettings _mapSettings(UserSettingsResponseDto dto) {
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
      // Task 8: the backend replaced the Security PIN object with the
      // passwordReauthenticationRequired flag. The PIN entity is kept at
      // `enabled: false` to avoid cascading deletions until Task 9.
      securityPin: const SecurityPinSettings(enabled: false),
      passwordReauthenticationRequired: dto.passwordReauthenticationRequired,
    );
  }
}
