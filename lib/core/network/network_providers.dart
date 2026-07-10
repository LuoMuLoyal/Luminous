// ignore_for_file: prefer_final_locals, prefer_const_constructors

import 'package:flutter/foundation.dart';
import 'package:luminous/core/config/developer_settings_controller.dart';
import 'package:luminous/core/i18n/app_locale.dart';
import 'package:luminous/core/i18n/app_locale_controller.dart';
import 'package:luminous/core/network/base_url.dart';
import 'package:luminous/core/network/dio_client.dart';
import 'package:luminous/core/network/session_store.dart';
import 'package:lucent_api/api/export.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

part 'network_providers.g.dart';

// ---------------------------------------------------------------------------
// Core infrastructure providers (keepAlive — singleton-like services)
// ---------------------------------------------------------------------------

/// Resolves the Lucent API base URL.
///
/// In release mode, always uses the compile-time default. In debug mode,
/// allows runtime switching via developer settings.
@Riverpod(keepAlive: true)
String lucentBaseUrl(Ref ref) {
  if (kReleaseMode) {
    return LucentBaseUrl.value;
  }

  final devSettings = ref
      .watch(developerSettingsControllerProvider)
      .asData
      ?.value;
  if (devSettings != null) {
    return devSettings.resolvedBaseUrl;
  }
  return LucentBaseUrl.value;
}

/// Provides the [LucentSessionStore] for token persistence.
@Riverpod(keepAlive: true)
LucentSessionStore lucentSessionStore(Ref ref) {
  return const SecureLucentSessionStore();
}

/// Provides the [LucentDioClient] singleton — the root HTTP client for all
/// Lucent API communication.
///
/// Wires up auth interceptors, token refresh, and locale resolution.
/// Disposes the underlying Dio instances when the provider is destroyed.
@Riverpod(keepAlive: true)
LucentDioClient lucentDioClient(Ref ref) {
  final client = LucentDioClient(
    baseUrl: ref.watch(lucentBaseUrlProvider),
    sessionStore: ref.watch(lucentSessionStoreProvider),
    localeResolver: () =>
        (ref.read(appLocaleControllerProvider).asData?.value ??
                AppLocale.system)
            .acceptLanguage,
  );
  ref.onDispose(client.dispose);
  return client;
}

// ---------------------------------------------------------------------------
// Generated API accessors — each delegates to the LucentDioClient singleton.
// These are autoDispose: they are cheap one-line getters and the underlying
// LucentClient is owned by the keepAlive [lucentDioClientProvider].
// ---------------------------------------------------------------------------

@riverpod
AuthApi lucentAuthApi(Ref ref) {
  return ref.watch(lucentDioClientProvider).authApi;
}

@riverpod
HealthApi lucentHealthApi(Ref ref) {
  return ref.watch(lucentDioClientProvider).healthApi;
}

@riverpod
MedicinesApi lucentMedicinesApi(Ref ref) {
  return ref.watch(lucentDioClientProvider).medicinesApi;
}

@riverpod
EnvironmentApi lucentEnvironmentApi(Ref ref) {
  return ref.watch(lucentDioClientProvider).environmentApi;
}

@riverpod
UserHealthContextApi lucentUserHealthContextApi(Ref ref) {
  return ref.watch(lucentDioClientProvider).userHealthContextApi;
}

@riverpod
DailyRecordsApi lucentDailyRecordsApi(Ref ref) {
  return ref.watch(lucentDioClientProvider).dailyRecordsApi;
}

@riverpod
MedicineDoseLogsApi lucentMedicineDoseLogsApi(Ref ref) {
  return ref.watch(lucentDioClientProvider).medicineDoseLogsApi;
}

@riverpod
MedicineRemindersApi lucentMedicineRemindersApi(Ref ref) {
  return ref.watch(lucentDioClientProvider).medicineRemindersApi;
}

@riverpod
SupportResourcesApi lucentSupportResourcesApi(Ref ref) {
  return ref.watch(lucentDioClientProvider).supportResourcesApi;
}

@riverpod
UserSettingsApi lucentUserSettingsApi(Ref ref) {
  return ref.watch(lucentDioClientProvider).userSettingsApi;
}

@riverpod
DataExportApi lucentDataExportApi(Ref ref) {
  return ref.watch(lucentDioClientProvider).dataExportApi;
}

@riverpod
ReportsApi lucentReportsApi(Ref ref) {
  return ref.watch(lucentDioClientProvider).reportsApi;
}

@riverpod
TodayAnalysisApi lucentTodayAnalysisApi(Ref ref) {
  return ref.watch(lucentDioClientProvider).todayAnalysisApi;
}

@riverpod
TodaySuggestionApi lucentTodaySuggestionApi(Ref ref) {
  return ref.watch(lucentDioClientProvider).todaySuggestionApi;
}

@riverpod
AssistantApi lucentAssistantApi(Ref ref) {
  return ref.watch(lucentDioClientProvider).assistantApi;
}

@riverpod
NotificationsApi lucentNotificationsApi(Ref ref) {
  return ref.watch(lucentDioClientProvider).notificationsApi;
}

@riverpod
FilesApi lucentFilesApi(Ref ref) {
  return ref.watch(lucentDioClientProvider).filesApi;
}
