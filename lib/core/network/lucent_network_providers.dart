import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:luminous/core/i18n/app_locale.dart';
import 'package:luminous/core/i18n/app_locale_controller.dart';
import 'package:luminous/core/network/lucent_api.dart';

final lucentBaseUrlProvider = Provider<String>((ref) {
  return LucentBaseUrl.value;
});

final lucentSessionStoreProvider = Provider<LucentSessionStore>((ref) {
  return const SecureLucentSessionStore();
});

final lucentDioClientProvider = Provider<LucentDioClient>((ref) {
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
});

final lucentAuthApiProvider = Provider<AuthApi>((ref) {
  return ref.watch(lucentDioClientProvider).authApi;
});

final lucentAppApiProvider = Provider<AppApi>((ref) {
  return ref.watch(lucentDioClientProvider).appApi;
});

final lucentMedicinesApiProvider = Provider<MedicinesApi>((ref) {
  return ref.watch(lucentDioClientProvider).medicinesApi;
});

final lucentEnvironmentApiProvider = Provider<EnvironmentApi>((ref) {
  return ref.watch(lucentDioClientProvider).environmentApi;
});

final lucentUserHealthContextApiProvider = Provider<UserHealthContextApi>((
  ref,
) {
  return ref.watch(lucentDioClientProvider).userHealthContextApi;
});

final lucentDailyRecordsApiProvider = Provider<DailyRecordsApi>((ref) {
  return ref.watch(lucentDioClientProvider).dailyRecordsApi;
});

final lucentMedicineDoseLogsApiProvider = Provider<MedicineDoseLogsApi>((ref) {
  return ref.watch(lucentDioClientProvider).medicineDoseLogsApi;
});

final lucentMedicineRemindersApiProvider = Provider<MedicineRemindersApi>((
  ref,
) {
  return ref.watch(lucentDioClientProvider).medicineRemindersApi;
});

final lucentSupportResourcesApiProvider = Provider<SupportResourcesApi>((ref) {
  return ref.watch(lucentDioClientProvider).supportResourcesApi;
});

final lucentUserSettingsApiProvider = Provider<UserSettingsApi>((ref) {
  return ref.watch(lucentDioClientProvider).userSettingsApi;
});

final lucentDataExportApiProvider = Provider<DataExportApi>((ref) {
  return ref.watch(lucentDioClientProvider).dataExportApi;
});
