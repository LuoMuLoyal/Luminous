import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:luminous/core/i18n/app_locale.dart';
import 'package:luminous/core/i18n/app_locale_controller.dart';
import 'package:luminous/features/auth/presentation/providers/auth_session_provider.dart';
import 'package:luminous/features/health_context/data/providers/health_context_data_providers.dart';
import 'package:luminous/features/mine/presentation/providers/mine_dashboard_provider.dart';
import 'package:luminous/features/settings/data/providers/settings_profile_data_providers.dart';

class SettingsProfileSyncNotifier extends Notifier<void> {
  @override
  void build() {}

  Future<void> syncPreferences({
    AppLocale? locale,
    Object? timezone = _noChange,
    Object? unitSystem = _noChange,
  }) async {
    final hasLocaleChange = locale != null;
    final previousLocale =
        ref.read(appLocaleControllerProvider).asData?.value ?? AppLocale.system;

    if (hasLocaleChange) {
      await ref.read(appLocaleControllerProvider.notifier).setLocale(locale);
    }

    try {
      await _syncPreferencesToBackend(
        locale: hasLocaleChange ? locale : null,
        timezone: timezone,
        unitSystem: unitSystem,
      );
      _refreshDerivedState();
    } catch (error) {
      if (hasLocaleChange) {
        await ref.read(appLocaleControllerProvider.notifier).setLocale(
          previousLocale,
        );
      }
      rethrow;
    }
  }

  Future<void> setLocale(AppLocale locale) async {
    await syncPreferences(locale: locale);
  }

  Future<void> resetLocaleToSystem() async {
    await setLocale(AppLocale.system);
  }

  Future<void> resetProfilePreferences() async {
    await syncPreferences(
      locale: AppLocale.system,
      timezone: '',
      unitSystem: null,
    );
  }

  Future<void> _syncPreferencesToBackend({
    AppLocale? locale,
    Object? timezone = _noChange,
    Object? unitSystem = _noChange,
  }) async {
    final session = ref.read(authSessionProvider);
    if (!session.isAuthenticated) {
      return;
    }

    final backendTimezone = identical(timezone, _noChange) ? _noChange : timezone;
    await ref
        .read(settingsProfileRemoteDataSourceProvider)
        .updatePreferences(
          locale: locale == null ? _noChange : _toBackendLocale(locale),
          timezone: backendTimezone,
          unitSystem: unitSystem,
        );
  }

  void _refreshDerivedState() {
    ref.invalidate(healthContextSnapshotProvider);
    ref.invalidate(mineDashboardProvider);
  }

  Object? _toBackendLocale(AppLocale locale) {
    return switch (locale) {
      AppLocale.system => '',
      AppLocale.en => 'en',
      AppLocale.zhCn => 'zh-CN',
    };
  }
}

const Object _noChange = Object();

final settingsProfileSyncProvider =
    NotifierProvider<SettingsProfileSyncNotifier, void>(
      SettingsProfileSyncNotifier.new,
    );
