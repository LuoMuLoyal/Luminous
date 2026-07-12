import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:luminous/core/config/developer_settings_controller.dart';
import 'package:luminous/core/logger/logger.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:talker_flutter/talker_flutter.dart' as talker;

void main() {
  late ProviderContainer container;
  late talker.Talker testTalker;

  ProviderContainer buildContainer({Map<String, Object>? initialValues}) {
    SharedPreferences.setMockInitialValues(
      initialValues ?? const <String, Object>{},
    );
    final c = ProviderContainer(
      overrides: [talkerProvider.overrideWithValue(testTalker)],
    );
    addTearDown(c.dispose);
    return c;
  }

  setUp(() {
    testTalker = talker.Talker();
  });

  group('ApiEndpoint', () {
    test('fromStorage returns correct endpoint for known values', () {
      expect(ApiEndpoint.fromStorage('local'), ApiEndpoint.local);
      expect(ApiEndpoint.fromStorage('staging'), ApiEndpoint.staging);
      expect(ApiEndpoint.fromStorage('production'), ApiEndpoint.production);
      expect(ApiEndpoint.fromStorage('custom'), ApiEndpoint.custom);
    });

    test('fromStorage returns local for null', () {
      expect(ApiEndpoint.fromStorage(null), ApiEndpoint.local);
    });

    test('fromStorage returns local for unknown value', () {
      expect(ApiEndpoint.fromStorage('unknown'), ApiEndpoint.local);
    });

    test('defaultUrl values are correct', () {
      expect(ApiEndpoint.local.defaultUrl, 'http://127.0.0.1:3000');
      expect(
        ApiEndpoint.staging.defaultUrl,
        'https://staging-api.luminous.app',
      );
      expect(ApiEndpoint.production.defaultUrl, 'https://api.luminous.app');
      expect(ApiEndpoint.custom.defaultUrl, '');
    });

    test('storageValue values are correct', () {
      expect(ApiEndpoint.local.storageValue, 'local');
      expect(ApiEndpoint.staging.storageValue, 'staging');
      expect(ApiEndpoint.production.storageValue, 'production');
      expect(ApiEndpoint.custom.storageValue, 'custom');
    });
  });

  group('DeveloperSettingsState.resolvedBaseUrl', () {
    test('returns defaultUrl for local endpoint', () {
      const state = DeveloperSettingsState(apiEndpoint: ApiEndpoint.local);
      expect(state.resolvedBaseUrl, 'http://127.0.0.1:3000');
    });

    test('returns defaultUrl for staging endpoint', () {
      const state = DeveloperSettingsState(apiEndpoint: ApiEndpoint.staging);
      expect(state.resolvedBaseUrl, 'https://staging-api.luminous.app');
    });

    test('returns defaultUrl for production endpoint', () {
      const state = DeveloperSettingsState(apiEndpoint: ApiEndpoint.production);
      expect(state.resolvedBaseUrl, 'https://api.luminous.app');
    });

    test('returns customApiUrl when non-empty for custom endpoint', () {
      const state = DeveloperSettingsState(
        apiEndpoint: ApiEndpoint.custom,
        customApiUrl: 'http://192.168.1.100:8080',
      );
      expect(state.resolvedBaseUrl, 'http://192.168.1.100:8080');
    });

    test('trims customApiUrl', () {
      const state = DeveloperSettingsState(
        apiEndpoint: ApiEndpoint.custom,
        customApiUrl: '  http://192.168.1.100:8080  ',
      );
      expect(state.resolvedBaseUrl, 'http://192.168.1.100:8080');
    });

    test('falls back to compile-time default when customApiUrl is empty', () {
      const state = DeveloperSettingsState(
        apiEndpoint: ApiEndpoint.custom,
        customApiUrl: '',
      );
      // In debug/test mode, LucentBaseUrl.value returns 'http://127.0.0.1:3000'
      expect(state.resolvedBaseUrl, 'http://127.0.0.1:3000');
    });

    test(
      'falls back to compile-time default when customApiUrl is whitespace',
      () {
        const state = DeveloperSettingsState(
          apiEndpoint: ApiEndpoint.custom,
          customApiUrl: '   ',
        );
        expect(state.resolvedBaseUrl, 'http://127.0.0.1:3000');
      },
    );
  });

  group('LogLevel.fromString', () {
    test('parses verbose', () {
      expect(LogLevel.fromString('verbose'), LogLevel.verbose);
    });

    test('parses info', () {
      expect(LogLevel.fromString('info'), LogLevel.info);
    });

    test('parses warning', () {
      expect(LogLevel.fromString('warning'), LogLevel.warning);
    });

    test('parses error', () {
      expect(LogLevel.fromString('error'), LogLevel.error);
    });

    test('parses none', () {
      expect(LogLevel.fromString('none'), LogLevel.none);
    });

    test('is case-insensitive', () {
      expect(LogLevel.fromString('INFO'), LogLevel.info);
      expect(LogLevel.fromString('Warning'), LogLevel.warning);
    });

    test('defaults to info for null', () {
      expect(LogLevel.fromString(null), LogLevel.info);
    });

    test('defaults to info for unknown value', () {
      expect(LogLevel.fromString('unknown'), LogLevel.info);
    });
  });

  group('DeveloperSettingsController.build', () {
    test('uses default values when no preferences are stored', () async {
      container = buildContainer();

      final state = await container.read(
        developerSettingsControllerProvider.future,
      );

      expect(state.apiEndpoint, ApiEndpoint.local);
      expect(state.customApiUrl, '');
      expect(state.logLevel, LogLevel.info);
    });

    test('loads persisted apiEndpoint', () async {
      container = buildContainer(
        initialValues: const <String, Object>{
          'developer.apiEndpoint': 'staging',
        },
      );

      final state = await container.read(
        developerSettingsControllerProvider.future,
      );

      expect(state.apiEndpoint, ApiEndpoint.staging);
    });

    test('loads persisted customApiUrl', () async {
      container = buildContainer(
        initialValues: const <String, Object>{
          'developer.apiEndpoint': 'custom',
          'developer.customApiUrl': 'http://my-custom-url:3000',
        },
      );

      final state = await container.read(
        developerSettingsControllerProvider.future,
      );

      expect(state.apiEndpoint, ApiEndpoint.custom);
      expect(state.customApiUrl, 'http://my-custom-url:3000');
    });

    test('loads persisted logLevel', () async {
      container = buildContainer(
        initialValues: const <String, Object>{'developer.logLevel': 'warning'},
      );

      final state = await container.read(
        developerSettingsControllerProvider.future,
      );

      expect(state.logLevel, LogLevel.warning);
    });

    test('falls back to local for unknown apiEndpoint', () async {
      container = buildContainer(
        initialValues: const <String, Object>{
          'developer.apiEndpoint': 'nonexistent',
        },
      );

      final state = await container.read(
        developerSettingsControllerProvider.future,
      );

      expect(state.apiEndpoint, ApiEndpoint.local);
    });
  });

  group('setApiEndpoint', () {
    test('updates state and persists the value', () async {
      container = buildContainer();

      await container.read(developerSettingsControllerProvider.future);

      await container
          .read(developerSettingsControllerProvider.notifier)
          .setApiEndpoint(ApiEndpoint.staging);

      final state = container.read(developerSettingsControllerProvider);
      expect(state.value?.apiEndpoint, ApiEndpoint.staging);

      final preferences = await SharedPreferences.getInstance();
      expect(preferences.getString('developer.apiEndpoint'), 'staging');
    });
  });

  group('setCustomApiUrl', () {
    test('updates state and persists the value', () async {
      container = buildContainer();

      await container.read(developerSettingsControllerProvider.future);

      await container
          .read(developerSettingsControllerProvider.notifier)
          .setCustomApiUrl('http://192.168.1.1:3000');

      final state = container.read(developerSettingsControllerProvider);
      expect(state.value?.customApiUrl, 'http://192.168.1.1:3000');

      final preferences = await SharedPreferences.getInstance();
      expect(
        preferences.getString('developer.customApiUrl'),
        'http://192.168.1.1:3000',
      );
    });
  });

  group('setLogLevel', () {
    test('updates state and persists the value', () async {
      container = buildContainer();

      await container.read(developerSettingsControllerProvider.future);

      await container
          .read(developerSettingsControllerProvider.notifier)
          .setLogLevel(LogLevel.error);

      final state = container.read(developerSettingsControllerProvider);
      expect(state.value?.logLevel, LogLevel.error);

      final preferences = await SharedPreferences.getInstance();
      expect(preferences.getString('developer.logLevel'), 'error');
    });
  });

  group('reset', () {
    test(
      'clears all developer preference keys and restores defaults',
      () async {
        container = buildContainer(
          initialValues: const <String, Object>{
            'developer.apiEndpoint': 'production',
            'developer.customApiUrl': 'http://custom:3000',
            'developer.logLevel': 'error',
          },
        );

        await container.read(developerSettingsControllerProvider.future);

        await container
            .read(developerSettingsControllerProvider.notifier)
            .reset();

        final state = container.read(developerSettingsControllerProvider);
        expect(state.value?.apiEndpoint, ApiEndpoint.local);
        expect(state.value?.customApiUrl, '');
        expect(state.value?.logLevel, LogLevel.info);

        final preferences = await SharedPreferences.getInstance();
        expect(preferences.containsKey('developer.apiEndpoint'), isFalse);
        expect(preferences.containsKey('developer.customApiUrl'), isFalse);
        expect(preferences.containsKey('developer.logLevel'), isFalse);
      },
    );
  });
}
