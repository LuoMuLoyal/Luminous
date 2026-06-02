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

  Future<void> setLocale(AppLocale locale) async {
    final previousLocale =
        ref.read(appLocaleControllerProvider).asData?.value ?? AppLocale.system;

    await ref.read(appLocaleControllerProvider.notifier).setLocale(locale);

    try {
      await _syncLocaleToBackend(locale);
      _refreshDerivedState();
    } catch (error) {
      await ref.read(appLocaleControllerProvider.notifier).setLocale(
        previousLocale,
      );
      rethrow;
    }
  }

  Future<void> resetLocaleToSystem() async {
    await setLocale(AppLocale.system);
  }

  Future<void> _syncLocaleToBackend(AppLocale locale) async {
    final session = ref.read(authSessionProvider);
    if (!session.isAuthenticated) {
      return;
    }

    await ref
        .read(settingsProfileRemoteDataSourceProvider)
        .updatePreferences(locale: _toBackendLocale(locale));
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

final settingsProfileSyncProvider =
    NotifierProvider<SettingsProfileSyncNotifier, void>(
      SettingsProfileSyncNotifier.new,
    );
