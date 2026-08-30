import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:luminous/core/auth/session_provider.dart';
import 'package:luminous/core/i18n/locale.dart';
import 'package:luminous/core/logger/log_level.dart';
import 'package:luminous/core/providers/data_change_bus.dart';
import 'package:luminous/features/settings/data/providers/profile.dart';

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
        ref.read(localeControllerProvider).asData?.value ?? AppLocale.system;

    if (hasLocaleChange) {
      await ref.read(localeControllerProvider.notifier).setLocale(locale);
    }

    try {
      await _syncPreferencesToBackend(
        locale: hasLocaleChange ? locale : null,
        timezone: timezone,
        unitSystem: unitSystem,
      );
      _refreshDerivedState();
    } catch (error) {
      ref
          .read(talkerProvider)
          .error('SettingsProfileSyncNotifier.syncPreferences: failed: $error');
      if (hasLocaleChange) {
        await ref
            .read(localeControllerProvider.notifier)
            .setLocale(previousLocale);
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
    if (!session.canAccessProtectedData) {
      return;
    }

    final backendTimezone = identical(timezone, _noChange)
        ? _noChange
        : timezone;
    await ref
        .read(settingsProfileRemoteDataSourceProvider)
        .updatePreferences(
          locale: locale == null ? _noChange : _toBackendLocale(locale),
          timezone: backendTimezone,
          unitSystem: unitSystem,
        );
  }

  void _refreshDerivedState() {
    ref
        .read(dataChangeBusProvider.notifier)
        .emit(DataChangeTopic.healthContext);
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
