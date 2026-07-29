import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:lucent_api/lucent_api.dart';
import 'package:luminous/core/auth/session_provider.dart';
import 'package:luminous/core/i18n/locale.dart';
import 'package:luminous/core/i18n/locale_controller.dart';
import 'package:luminous/features/settings/data/datasources/profile_remote.dart';
import 'package:luminous/features/settings/data/providers/profile.dart';
import 'package:luminous/features/settings/presentation/providers/profile_sync.dart';
import 'package:mocktail/mocktail.dart';

class _MockSettingsProfileRemoteDataSource extends Mock
    implements SettingsProfileRemoteDataSource {}

class _SignedInSessionNotifier extends AuthSessionNotifier {
  @override
  AuthSessionState build() =>
      const AuthSessionState(isLoading: false, isAuthenticated: true);
}

class _SignedOutSessionNotifier extends AuthSessionNotifier {
  @override
  AuthSessionState build() => const AuthSessionState();
}

class _FakeLocaleController extends LocaleController {
  AppLocale _locale = AppLocale.system;
  bool setLocaleCalled = false;
  List<AppLocale> setLocaleHistory = [];

  @override
  Future<AppLocale> build() async => _locale;

  @override
  Future<void> setLocale(AppLocale locale) async {
    setLocaleCalled = true;
    setLocaleHistory.add(locale);
    _locale = locale;
    state = AsyncData(locale);
  }
}

HealthContextDataDto _testDto() => HealthContextDataDto(
  summary: UserHealthSummaryDto(
    age: null,
    onboardingCompleted: false,
    activeAllergyCount: 0,
    conditionCount: 0,
    currentMedicineCount: 0,
    missingCoreProfileFields: [],
  ),
  profile: UserHealthProfileDto(
    birthDate: null,
    sexAtBirth: SexAtBirth.unknownDefaultOpenApi,
    heightCm: null,
    weightKg: null,
    bloodType: null,
    locale: null,
    timezone: null,
    unitSystem: UnitSystem.unknownDefaultOpenApi,
    onboardingCompletedAt: null,
    emergencyContact: null,
    extras: null,
  ),
  allergies: [],
  conditions: [],
  currentMedicines: [],
);

void main() {
  late _MockSettingsProfileRemoteDataSource mockDataSource;

  ProviderContainer buildContainer({
    required _FakeLocaleController localeController,
    bool authenticated = true,
  }) {
    final c = ProviderContainer(
      overrides: [
        authSessionProvider.overrideWith(
          () => authenticated
              ? _SignedInSessionNotifier()
              : _SignedOutSessionNotifier(),
        ),
        localeControllerProvider.overrideWith(() => localeController),
        settingsProfileRemoteDataSourceProvider.overrideWithValue(
          mockDataSource,
        ),
      ],
    );
    addTearDown(c.dispose);
    return c;
  }

  setUp(() {
    mockDataSource = _MockSettingsProfileRemoteDataSource();
    registerFallbackValue(_testDto());
  });

  group('SettingsProfileSyncNotifier', () {
    test(
      'setLocale updates locale and syncs to backend when authenticated',
      () async {
        final localeController = _FakeLocaleController();
        when(
          () => mockDataSource.updatePreferences(
            locale: any(named: 'locale'),
            timezone: any(named: 'timezone'),
            unitSystem: any(named: 'unitSystem'),
          ),
        ).thenAnswer((_) async => _testDto());

        final c = buildContainer(localeController: localeController);

        await c
            .read(settingsProfileSyncProvider.notifier)
            .setLocale(AppLocale.zhCn);

        expect(localeController.setLocaleCalled, isTrue);
        expect(localeController.setLocaleHistory, [AppLocale.zhCn]);
        verify(
          () => mockDataSource.updatePreferences(
            locale: 'zh-CN',
            timezone: any(named: 'timezone'),
            unitSystem: any(named: 'unitSystem'),
          ),
        ).called(1);
      },
    );

    test('setLocale with system sends empty string to backend', () async {
      final localeController = _FakeLocaleController();
      when(
        () => mockDataSource.updatePreferences(
          locale: any(named: 'locale'),
          timezone: any(named: 'timezone'),
          unitSystem: any(named: 'unitSystem'),
        ),
      ).thenAnswer((_) async => _testDto());

      final c = buildContainer(localeController: localeController);

      await c
          .read(settingsProfileSyncProvider.notifier)
          .setLocale(AppLocale.system);

      verify(
        () => mockDataSource.updatePreferences(
          locale: '',
          timezone: any(named: 'timezone'),
          unitSystem: any(named: 'unitSystem'),
        ),
      ).called(1);
    });

    test('setLocale with en sends "en" to backend', () async {
      final localeController = _FakeLocaleController();
      when(
        () => mockDataSource.updatePreferences(
          locale: any(named: 'locale'),
          timezone: any(named: 'timezone'),
          unitSystem: any(named: 'unitSystem'),
        ),
      ).thenAnswer((_) async => _testDto());

      final c = buildContainer(localeController: localeController);

      await c
          .read(settingsProfileSyncProvider.notifier)
          .setLocale(AppLocale.en);

      verify(
        () => mockDataSource.updatePreferences(
          locale: 'en',
          timezone: any(named: 'timezone'),
          unitSystem: any(named: 'unitSystem'),
        ),
      ).called(1);
    });

    test('rolls back locale on backend sync failure', () async {
      final localeController = _FakeLocaleController();
      when(
        () => mockDataSource.updatePreferences(
          locale: any(named: 'locale'),
          timezone: any(named: 'timezone'),
          unitSystem: any(named: 'unitSystem'),
        ),
      ).thenThrow(Exception('Backend error'));

      final c = buildContainer(localeController: localeController);

      expect(
        () => c
            .read(settingsProfileSyncProvider.notifier)
            .setLocale(AppLocale.zhCn),
        throwsA(isA<Exception>()),
      );

      await Future.delayed(const Duration(milliseconds: 50));

      // Should have called setLocale twice: once to set zhCn, once to roll back
      expect(localeController.setLocaleHistory.length, 2);
      expect(localeController.setLocaleHistory[0], AppLocale.zhCn);
      expect(localeController.setLocaleHistory[1], AppLocale.system);
    });

    test('skips backend sync when signed out', () async {
      final localeController = _FakeLocaleController();

      final c = buildContainer(
        localeController: localeController,
        authenticated: false,
      );

      await c
          .read(settingsProfileSyncProvider.notifier)
          .setLocale(AppLocale.en);

      // Locale is still set locally
      expect(localeController.setLocaleCalled, isTrue);
      // But backend is NOT called
      verifyNever(
        () => mockDataSource.updatePreferences(
          locale: any(named: 'locale'),
          timezone: any(named: 'timezone'),
          unitSystem: any(named: 'unitSystem'),
        ),
      );
    });

    test('resetLocaleToSystem calls setLocale with system', () async {
      final localeController = _FakeLocaleController();
      when(
        () => mockDataSource.updatePreferences(
          locale: any(named: 'locale'),
          timezone: any(named: 'timezone'),
          unitSystem: any(named: 'unitSystem'),
        ),
      ).thenAnswer((_) async => _testDto());

      final c = buildContainer(localeController: localeController);

      await c.read(settingsProfileSyncProvider.notifier).resetLocaleToSystem();

      expect(localeController.setLocaleHistory, [AppLocale.system]);
      verify(
        () => mockDataSource.updatePreferences(
          locale: '',
          timezone: any(named: 'timezone'),
          unitSystem: any(named: 'unitSystem'),
        ),
      ).called(1);
    });

    test(
      'resetProfilePreferences resets locale, timezone, and unitSystem',
      () async {
        final localeController = _FakeLocaleController();
        when(
          () => mockDataSource.updatePreferences(
            locale: any(named: 'locale'),
            timezone: any(named: 'timezone'),
            unitSystem: any(named: 'unitSystem'),
          ),
        ).thenAnswer((_) async => _testDto());

        final c = buildContainer(localeController: localeController);

        await c
            .read(settingsProfileSyncProvider.notifier)
            .resetProfilePreferences();

        expect(localeController.setLocaleHistory, [AppLocale.system]);
        verify(
          () => mockDataSource.updatePreferences(
            locale: '',
            timezone: '',
            unitSystem: null,
          ),
        ).called(1);
      },
    );
  });
}
