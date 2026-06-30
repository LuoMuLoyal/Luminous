import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:lucent_openapi/lucent_openapi.dart';
import 'package:luminous/core/theme/app_theme_extensions.dart';
import 'package:luminous/features/notification/presentation/pages/notification_detail_page.dart';
import 'package:luminous/features/notification/presentation/providers/notification_providers.dart';
import 'package:luminous/l10n/app_localizations.dart';
import 'package:shared_preferences/shared_preferences.dart';

Widget _testApp(Widget child) {
  return MaterialApp(
    theme: ThemeData.light().copyWith(
      extensions: const <ThemeExtension<dynamic>>[AppThemeSurface.light],
    ),
    locale: const Locale('zh'),
    localizationsDelegates: AppLocalizations.localizationsDelegates,
    supportedLocales: AppLocalizations.supportedLocales,
    home: child,
  );
}

void main() {
  testWidgets(
    'NotificationDetailPage shows not found for missing notification',
    (tester) async {
      SharedPreferences.setMockInitialValues(const <String, Object>{});
      final l10n = await AppLocalizations.delegate.load(const Locale('zh'));

      final container = ProviderContainer(
        overrides: [
          notificationDetailProvider(
            'missing-id',
          ).overrideWith((ref) async => null),
        ],
      );
      addTearDown(container.dispose);

      await container.read(notificationDetailProvider('missing-id').future);

      await tester.pumpWidget(
        UncontrolledProviderScope(
          container: container,
          child: _testApp(
            const NotificationDetailPage(notificationId: 'missing-id'),
          ),
        ),
      );

      await tester.pumpAndSettle();

      expect(find.text(l10n.notificationNotFoundTitle), findsOneWidget);
      expect(find.text(l10n.notificationNotFoundDescription), findsOneWidget);
    },
  );

  testWidgets('NotificationDetailPage shows notification content', (
    tester,
  ) async {
    SharedPreferences.setMockInitialValues(const <String, Object>{});
    final l10n = await AppLocalizations.delegate.load(const Locale('zh'));

    final container = ProviderContainer(
      overrides: [
        notificationDetailProvider('n1').overrideWith(
          (ref) async => NotificationDetailDto(
            id: 'n1',
            type: UserNotificationType.systemAnnouncement,
            title: 'System Update',
            content: 'The system will be updated tonight at 2am.',
            isRead: false,
            createdAt: '2026-06-10T08:00:00.000Z',
            readAt: null,
          ),
        ),
      ],
    );
    addTearDown(container.dispose);

    await container.read(notificationDetailProvider('n1').future);

    await tester.pumpWidget(
      UncontrolledProviderScope(
        container: container,
        child: _testApp(const NotificationDetailPage(notificationId: 'n1')),
      ),
    );

    await tester.pumpAndSettle();

    expect(find.text('System Update'), findsOneWidget);
    expect(
      find.text('The system will be updated tonight at 2am.'),
      findsOneWidget,
    );
    // Action buttons
    expect(find.text(l10n.notificationActionMarkRead), findsOneWidget);
    expect(find.text(l10n.notificationActionDelete), findsOneWidget);
  });
}
