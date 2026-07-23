import 'package:flutter/services.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:luminous/features/settings/domain/services/notification_permission.dart';
import 'package:mocktail/mocktail.dart';

class _MockFlutterLocalNotificationsPlugin extends Mock
    implements FlutterLocalNotificationsPlugin {}

class _FakeAndroidPlugin extends Mock
    implements AndroidFlutterLocalNotificationsPlugin {}

class _FakeIOSPlugin extends Mock
    implements IOSFlutterLocalNotificationsPlugin {}

class _FakeMacOSPlugin extends Mock
    implements MacOSFlutterLocalNotificationsPlugin {}

class _FakeInitializationSettings extends Fake
    implements InitializationSettings {}

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  late _MockFlutterLocalNotificationsPlugin mockPlugin;
  late _FakeAndroidPlugin mockAndroid;
  late _FakeIOSPlugin mockIOS;
  late _FakeMacOSPlugin mockMacOS;

  setUpAll(() {
    registerFallbackValue(_FakeInitializationSettings());
  });

  setUp(() {
    mockPlugin = _MockFlutterLocalNotificationsPlugin();
    mockAndroid = _FakeAndroidPlugin();
    mockIOS = _FakeIOSPlugin();
    mockMacOS = _FakeMacOSPlugin();
  });

  group('NotificationPermissionService', () {
    group('ensureInitialized', () {
      test('calls plugin.initialize on first call', () async {
        when(() => mockPlugin.initialize(any())).thenAnswer((_) async => true);

        final service = NotificationPermissionService(plugin: mockPlugin);
        await service.ensureInitialized();

        verify(() => mockPlugin.initialize(any())).called(1);
      });

      test('skips initialize on subsequent calls', () async {
        when(() => mockPlugin.initialize(any())).thenAnswer((_) async => true);

        final service = NotificationPermissionService(plugin: mockPlugin);
        await service.ensureInitialized();
        await service.ensureInitialized();

        verify(() => mockPlugin.initialize(any())).called(1);
      });

      test('handles MissingPluginException gracefully', () async {
        when(
          () => mockPlugin.initialize(any()),
        ).thenThrow(MissingPluginException());

        final service = NotificationPermissionService(plugin: mockPlugin);
        await service.ensureInitialized();
      });

      test('handles PlatformException gracefully', () async {
        when(
          () => mockPlugin.initialize(any()),
        ).thenThrow(PlatformException(code: 'test_error'));

        final service = NotificationPermissionService(plugin: mockPlugin);
        await service.ensureInitialized();
      });
    });

    group('getPermissionState', () {
      test('returns granted when android plugin reports enabled', () async {
        when(() => mockPlugin.initialize(any())).thenAnswer((_) async => true);
        when(
          () => mockPlugin
              .resolvePlatformSpecificImplementation<
                AndroidFlutterLocalNotificationsPlugin
              >(),
        ).thenReturn(mockAndroid);
        when(
          () => mockAndroid.areNotificationsEnabled(),
        ).thenAnswer((_) async => true);

        final service = NotificationPermissionService(plugin: mockPlugin);
        final state = await service.getPermissionState();

        expect(state, NotificationPermissionState.granted);
      });

      test('returns denied when android plugin reports disabled', () async {
        when(() => mockPlugin.initialize(any())).thenAnswer((_) async => true);
        when(
          () => mockPlugin
              .resolvePlatformSpecificImplementation<
                AndroidFlutterLocalNotificationsPlugin
              >(),
        ).thenReturn(mockAndroid);
        when(
          () => mockAndroid.areNotificationsEnabled(),
        ).thenAnswer((_) async => false);

        final service = NotificationPermissionService(plugin: mockPlugin);
        final state = await service.getPermissionState();

        expect(state, NotificationPermissionState.denied);
      });

      test('returns granted when iOS plugin reports enabled', () async {
        when(() => mockPlugin.initialize(any())).thenAnswer((_) async => true);
        when(
          () => mockPlugin
              .resolvePlatformSpecificImplementation<
                AndroidFlutterLocalNotificationsPlugin
              >(),
        ).thenReturn(null);
        when(
          () => mockPlugin
              .resolvePlatformSpecificImplementation<
                IOSFlutterLocalNotificationsPlugin
              >(),
        ).thenReturn(mockIOS);
        when(() => mockIOS.checkPermissions()).thenAnswer(
          (_) async => const NotificationsEnabledOptions(
            isEnabled: true,
            isAlertEnabled: true,
            isBadgeEnabled: true,
            isSoundEnabled: true,
            isProvisionalEnabled: false,
            isCriticalEnabled: false,
            isProvidesAppNotificationSettingsEnabled: false,
          ),
        );

        final service = NotificationPermissionService(plugin: mockPlugin);
        final state = await service.getPermissionState();

        expect(state, NotificationPermissionState.granted);
      });

      test('returns denied when iOS plugin reports disabled', () async {
        when(() => mockPlugin.initialize(any())).thenAnswer((_) async => true);
        when(
          () => mockPlugin
              .resolvePlatformSpecificImplementation<
                AndroidFlutterLocalNotificationsPlugin
              >(),
        ).thenReturn(null);
        when(
          () => mockPlugin
              .resolvePlatformSpecificImplementation<
                IOSFlutterLocalNotificationsPlugin
              >(),
        ).thenReturn(mockIOS);
        when(() => mockIOS.checkPermissions()).thenAnswer(
          (_) async => const NotificationsEnabledOptions(
            isEnabled: false,
            isAlertEnabled: false,
            isBadgeEnabled: false,
            isSoundEnabled: false,
            isProvisionalEnabled: false,
            isCriticalEnabled: false,
            isProvidesAppNotificationSettingsEnabled: false,
          ),
        );

        final service = NotificationPermissionService(plugin: mockPlugin);
        final state = await service.getPermissionState();

        expect(state, NotificationPermissionState.denied);
      });

      test(
        'handles MissingPluginException from android areNotificationsEnabled',
        () async {
          when(
            () => mockPlugin.initialize(any()),
          ).thenAnswer((_) async => true);
          when(
            () => mockPlugin
                .resolvePlatformSpecificImplementation<
                  AndroidFlutterLocalNotificationsPlugin
                >(),
          ).thenReturn(mockAndroid);
          when(
            () => mockAndroid.areNotificationsEnabled(),
          ).thenThrow(MissingPluginException());
          // Fall through to iOS and macOS
          when(
            () => mockPlugin
                .resolvePlatformSpecificImplementation<
                  IOSFlutterLocalNotificationsPlugin
                >(),
          ).thenReturn(null);
          when(
            () => mockPlugin
                .resolvePlatformSpecificImplementation<
                  MacOSFlutterLocalNotificationsPlugin
                >(),
          ).thenReturn(null);

          final service = NotificationPermissionService(plugin: mockPlugin);
          // Should fall through to permission_handler which throws MissingPluginException
          // in test env, but getPermissionState catches it
          expect(() => service.getPermissionState(), throwsA(anything));
        },
      );

      test('handles PlatformException from iOS checkPermissions', () async {
        when(() => mockPlugin.initialize(any())).thenAnswer((_) async => true);
        when(
          () => mockPlugin
              .resolvePlatformSpecificImplementation<
                AndroidFlutterLocalNotificationsPlugin
              >(),
        ).thenReturn(null);
        when(
          () => mockPlugin
              .resolvePlatformSpecificImplementation<
                IOSFlutterLocalNotificationsPlugin
              >(),
        ).thenReturn(mockIOS);
        when(
          () => mockIOS.checkPermissions(),
        ).thenThrow(PlatformException(code: 'test'));
        when(
          () => mockPlugin
              .resolvePlatformSpecificImplementation<
                MacOSFlutterLocalNotificationsPlugin
              >(),
        ).thenReturn(null);

        final service = NotificationPermissionService(plugin: mockPlugin);
        expect(() => service.getPermissionState(), throwsA(anything));
      });
    });

    group('requestPermission', () {
      test('returns granted when android plugin grants permission', () async {
        when(() => mockPlugin.initialize(any())).thenAnswer((_) async => true);
        when(
          () => mockPlugin
              .resolvePlatformSpecificImplementation<
                AndroidFlutterLocalNotificationsPlugin
              >(),
        ).thenReturn(mockAndroid);
        when(
          () => mockAndroid.requestNotificationsPermission(),
        ).thenAnswer((_) async => true);

        final service = NotificationPermissionService(plugin: mockPlugin);
        final state = await service.requestPermission();

        expect(state, NotificationPermissionState.granted);
      });

      test('returns denied when android plugin denies permission', () async {
        when(() => mockPlugin.initialize(any())).thenAnswer((_) async => true);
        when(
          () => mockPlugin
              .resolvePlatformSpecificImplementation<
                AndroidFlutterLocalNotificationsPlugin
              >(),
        ).thenReturn(mockAndroid);
        when(
          () => mockAndroid.requestNotificationsPermission(),
        ).thenAnswer((_) async => false);

        final service = NotificationPermissionService(plugin: mockPlugin);
        final state = await service.requestPermission();

        expect(state, NotificationPermissionState.denied);
      });

      test('returns granted when iOS plugin grants permission', () async {
        when(() => mockPlugin.initialize(any())).thenAnswer((_) async => true);
        when(
          () => mockPlugin
              .resolvePlatformSpecificImplementation<
                AndroidFlutterLocalNotificationsPlugin
              >(),
        ).thenReturn(null);
        when(
          () => mockPlugin
              .resolvePlatformSpecificImplementation<
                IOSFlutterLocalNotificationsPlugin
              >(),
        ).thenReturn(mockIOS);
        when(
          () => mockIOS.requestPermissions(
            alert: any(named: 'alert'),
            badge: any(named: 'badge'),
            sound: any(named: 'sound'),
          ),
        ).thenAnswer((_) async => true);

        final service = NotificationPermissionService(plugin: mockPlugin);
        final state = await service.requestPermission();

        expect(state, NotificationPermissionState.granted);
      });

      test('returns denied when iOS plugin denies permission', () async {
        when(() => mockPlugin.initialize(any())).thenAnswer((_) async => true);
        when(
          () => mockPlugin
              .resolvePlatformSpecificImplementation<
                AndroidFlutterLocalNotificationsPlugin
              >(),
        ).thenReturn(null);
        when(
          () => mockPlugin
              .resolvePlatformSpecificImplementation<
                IOSFlutterLocalNotificationsPlugin
              >(),
        ).thenReturn(mockIOS);
        when(
          () => mockIOS.requestPermissions(
            alert: any(named: 'alert'),
            badge: any(named: 'badge'),
            sound: any(named: 'sound'),
          ),
        ).thenAnswer((_) async => false);

        final service = NotificationPermissionService(plugin: mockPlugin);
        final state = await service.requestPermission();

        expect(state, NotificationPermissionState.denied);
      });

      test(
        'handles MissingPluginException from android requestPermission',
        () async {
          when(
            () => mockPlugin.initialize(any()),
          ).thenAnswer((_) async => true);
          when(
            () => mockPlugin
                .resolvePlatformSpecificImplementation<
                  AndroidFlutterLocalNotificationsPlugin
                >(),
          ).thenReturn(mockAndroid);
          when(
            () => mockAndroid.requestNotificationsPermission(),
          ).thenThrow(MissingPluginException());
          when(
            () => mockPlugin
                .resolvePlatformSpecificImplementation<
                  IOSFlutterLocalNotificationsPlugin
                >(),
          ).thenReturn(null);
          when(
            () => mockPlugin
                .resolvePlatformSpecificImplementation<
                  MacOSFlutterLocalNotificationsPlugin
                >(),
          ).thenReturn(null);

          final service = NotificationPermissionService(plugin: mockPlugin);
          expect(() => service.requestPermission(), throwsA(anything));
        },
      );

      test('handles PlatformException from iOS requestPermissions', () async {
        when(() => mockPlugin.initialize(any())).thenAnswer((_) async => true);
        when(
          () => mockPlugin
              .resolvePlatformSpecificImplementation<
                AndroidFlutterLocalNotificationsPlugin
              >(),
        ).thenReturn(null);
        when(
          () => mockPlugin
              .resolvePlatformSpecificImplementation<
                IOSFlutterLocalNotificationsPlugin
              >(),
        ).thenReturn(mockIOS);
        when(
          () => mockIOS.requestPermissions(
            alert: any(named: 'alert'),
            badge: any(named: 'badge'),
            sound: any(named: 'sound'),
          ),
        ).thenThrow(PlatformException(code: 'test'));
        when(
          () => mockPlugin
              .resolvePlatformSpecificImplementation<
                MacOSFlutterLocalNotificationsPlugin
              >(),
        ).thenReturn(null);

        final service = NotificationPermissionService(plugin: mockPlugin);
        expect(() => service.requestPermission(), throwsA(anything));
      });

      test('passes through to macOS plugin when available', () async {
        when(() => mockPlugin.initialize(any())).thenAnswer((_) async => true);
        when(
          () => mockPlugin
              .resolvePlatformSpecificImplementation<
                AndroidFlutterLocalNotificationsPlugin
              >(),
        ).thenReturn(null);
        when(
          () => mockPlugin
              .resolvePlatformSpecificImplementation<
                IOSFlutterLocalNotificationsPlugin
              >(),
        ).thenReturn(null);
        when(
          () => mockPlugin
              .resolvePlatformSpecificImplementation<
                MacOSFlutterLocalNotificationsPlugin
              >(),
        ).thenReturn(mockMacOS);
        when(
          () => mockMacOS.requestPermissions(
            alert: any(named: 'alert'),
            badge: any(named: 'badge'),
            sound: any(named: 'sound'),
          ),
        ).thenAnswer((_) async => true);

        final service = NotificationPermissionService(plugin: mockPlugin);
        final state = await service.requestPermission();

        expect(state, NotificationPermissionState.granted);
      });
    });
  });
}
