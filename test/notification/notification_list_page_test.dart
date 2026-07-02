import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:lucent_openapi/lucent_openapi.dart';
import 'package:luminous/features/notification/presentation/pages/notification_list_page.dart';
import 'package:luminous/features/notification/presentation/providers/notification_providers.dart';
import 'package:luminous/l10n/app_localizations.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../helpers/test_forui_app.dart';

Widget _testApp(Widget child) {
  return TestForuiApp(home: child);
}

void main() {
  testWidgets('NotificationListPage shows empty state', (tester) async {
    SharedPreferences.setMockInitialValues(const <String, Object>{});
    final l10n = await AppLocalizations.delegate.load(const Locale('zh'));

    // Use a ProviderContainer to control the provider
    final container = ProviderContainer(
      overrides: [
        notificationListControllerProvider.overrideWith(
          () => _FixedListController(items: const <NotificationListItemDto>[]),
        ),
      ],
    );
    addTearDown(container.dispose);

    // Pre-resolve the provider before rendering
    await container.read(notificationListControllerProvider.future);

    await tester.pumpWidget(
      UncontrolledProviderScope(
        container: container,
        child: _testApp(const NotificationListPage()),
      ),
    );

    await tester.pumpAndSettle();

    expect(find.text(l10n.notificationEmptyTitle), findsOneWidget);
    expect(find.text(l10n.notificationEmptyDescription), findsOneWidget);
  });

  testWidgets('NotificationListPage shows items', (tester) async {
    SharedPreferences.setMockInitialValues(const <String, Object>{});

    final now = DateTime.now();
    final today =
        '${now.year}-${now.month.toString().padLeft(2, '0')}-${now.day.toString().padLeft(2, '0')}T08:00:00.000Z';

    final container = ProviderContainer(
      overrides: [
        notificationListControllerProvider.overrideWith(
          () => _FixedListController(
            items: [
              NotificationListItemDto(
                id: 'n1',
                type: UserNotificationType.systemAnnouncement,
                title: 'Hello',
                content: 'World',
                isRead: false,
                createdAt: today,
              ),
            ],
          ),
        ),
      ],
    );
    addTearDown(container.dispose);

    await container.read(notificationListControllerProvider.future);

    await tester.pumpWidget(
      UncontrolledProviderScope(
        container: container,
        child: _testApp(const NotificationListPage()),
      ),
    );

    await tester.pumpAndSettle();

    expect(find.text('Hello'), findsOneWidget);
    expect(find.text('World'), findsOneWidget);
    expect(find.text('今天'), findsOneWidget);
  });
}

/// A simple controller that returns the given items immediately.
class _FixedListController extends NotificationListController {
  _FixedListController({required this.items});

  final List<NotificationListItemDto> items;

  @override
  Future<NotificationListResponseDto> build() async {
    return NotificationListResponseDto(
      code: 0,
      message: '',
      items: items,
      total: items.length,
    );
  }
}
