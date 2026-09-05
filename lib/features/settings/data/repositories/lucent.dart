import 'package:fpdart/fpdart.dart';
import 'package:lucent_api/lucent_api.dart';
import 'package:luminous/core/errors/lucent_failure.dart';
import 'package:luminous/core/network/client/client_providers.dart';
import 'package:luminous/core/network/contract/error_code.dart';
import 'package:luminous/core/network/contract/error_mapper.dart';
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
      final response = await api.getSettings();
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
      final response = await api.updateSettings(
        updateSettingsRequest:
            UpdateSettingsRequest(
              aiSummariesEnabled: aiSummariesEnabled,
              dataSharingConsent: dataSharingConsent,
              assistantEnabled: assistantEnabled,
              assistantMemoryEnabled: assistantMemoryEnabled,
              waterTargetCount: waterTargetCount,
              assistantContext:
                  UpdateSettingsRequestAssistantContext(
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

  /// Extracts a non-null generated-client payload, throwing
  /// [LucentFailure.network] (emptyResponse) when the success body is absent
  /// (auth `_requireBody` / medicine `dose_log_remote` precedent).
  T _requireData<T>(T? data, {String? operation}) {
    if (data == null) {
      final context = operation != null ? ' ($operation)' : '';
      throw LucentFailure.network(
        message: 'Empty response body$context',
        networkErrorCode: NetworkErrorCode.emptyResponse,
      );
    }
    return data;
  }

  UserSettings _mapSettings(UserSettingsResponse dto) {
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
      passwordReauthenticationRequired: dto.passwordReauthenticationRequired,
    );
  }
}
