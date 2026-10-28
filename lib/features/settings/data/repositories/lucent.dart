import 'dart:async';
import 'dart:convert';

import 'package:fpdart/fpdart.dart';
import 'package:lucent_api/lucent_api.dart';
import 'package:luminous/core/database/cache_constants.dart';
import 'package:luminous/core/database/connection_providers.dart';
import 'package:luminous/core/database/daos/user_settings_cache.dart';
import 'package:luminous/core/errors/lucent_failure.dart';
import 'package:luminous/core/logger/log_level.dart';
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
    cacheDao: ref.watch(userSettingsDaoProvider),
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
  LucentUserSettingsRepository({required this.api, required this.cacheDao});

  final UserSettingsApi api;
  final UserSettingsDao cacheDao;

  /// Background refresh throttle for the cached settings.
  DateTime? _lastRefresh;

  @override
  TaskEither<LucentFailure, UserSettings> getSettings() {
    return TaskEither.tryCatch(() async {
      // Cache-first: settings gate several pages, so a cached copy avoids a
      // round trip before those pages can decide what to render.
      final cached = await cacheDao.fetch();
      if (cached != null) {
        _refreshInBackground();
        return UserSettings.fromJson(
          jsonDecode(cached) as Map<String, dynamic>,
        );
      }

      final settings = await _fetchRemote();
      await cacheDao.replace(jsonEncode(settings.toJson()));
      return settings;
    }, (error, stackTrace) => LucentErrorMapper.fromObject(error));
  }

  Future<UserSettings> _fetchRemote() async {
    final response = await api.getSettings();
    return _mapSettings(_requireData(response.data, operation: 'getSettings'));
  }

  /// Best-effort refresh: throttled, failures only logged.
  void _refreshInBackground() {
    final now = DateTime.now();
    final last = _lastRefresh;
    if (last != null && now.difference(last) < backgroundRefreshThrottle) {
      return;
    }
    _lastRefresh = now;

    unawaited(
      Future(() async {
        try {
          final settings = await _fetchRemote();
          await cacheDao.replace(jsonEncode(settings.toJson()));
        } catch (e) {
          appTalker.warning('User settings background refresh failed: $e');
        }
      }),
    );
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
        updateSettingsRequest: UpdateSettingsRequest(
          aiSummariesEnabled: aiSummariesEnabled,
          dataSharingConsent: dataSharingConsent,
          assistantEnabled: assistantEnabled,
          assistantMemoryEnabled: assistantMemoryEnabled,
          waterTargetCount: waterTargetCount,
          assistantContext: UpdateSettingsRequestAssistantContext(
            healthProfile: assistantContext.healthProfile,
            dailyRecords: assistantContext.dailyRecords,
            sleepRecords: assistantContext.sleepRecords,
            currentMedicines: assistantContext.currentMedicines,
          ),
        ),
      );
      final settings = _mapSettings(
        _requireData(response.data, operation: 'updateSettings'),
      );
      // The stored copy is now stale: drop it so the next read fetches the
      // updated values instead of serving the pre-update snapshot.
      await cacheDao.invalidate();
      return settings;
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
