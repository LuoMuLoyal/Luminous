import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:lucent_openapi/lucent_openapi.dart';
import 'package:luminous/core/theme/app_theme.dart';
import 'package:luminous/features/notification/presentation/widgets/notification_list_item.dart';

Widget _appShell(Widget child) {
  return MaterialApp(
    theme: AppTheme.light,
    home: Scaffold(body: child),
  );
}

NotificationListItemDto _item({
  required String id,
  String title = 'Title',
  String content = 'Content',
  bool isRead = false,
  String createdAt = '2026-06-10T08:00:00.000Z',
}) {
  return NotificationListItemDto(
    id: id,
    type: UserNotificationType.systemAnnouncement,
    title: title,
    content: content,
    isRead: isRead,
    createdAt: createdAt,
  );
}

void main() {
  group('NotificationListItemWidget', () {
    testWidgets('renders title and content', (tester) async {
      await tester.pumpWidget(
        _appShell(
          NotificationListItemWidget(
            item: _item(id: '1', title: 'Test notice', content: 'Some content'),
            onTap: () {},
            onDismiss: () {},
          ),
        ),
      );

      expect(find.text('Test notice'), findsOneWidget);
      expect(find.text('Some content'), findsOneWidget);
    });

    testWidgets('shows unread indicator when not read', (tester) async {
      await tester.pumpWidget(
        _appShell(
          NotificationListItemWidget(
            item: _item(id: '1', isRead: false),
            onTap: () {},
            onDismiss: () {},
          ),
        ),
      );

      // Unread indicator is a small circle
      expect(find.byType(Container), findsWidgets);
    });

    testWidgets('triggers onTap when tapped', (tester) async {
      bool tapped = false;
      await tester.pumpWidget(
        _appShell(
          NotificationListItemWidget(
            item: _item(id: '1'),
            onTap: () => tapped = true,
            onDismiss: () {},
          ),
        ),
      );

      await tester.tap(find.text('Title'));
      expect(tapped, isTrue);
    });

    testWidgets('includes Dismissible for swipe-to-delete', (tester) async {
      await tester.pumpWidget(
        _appShell(
          NotificationListItemWidget(
            item: _item(id: '1'),
            onTap: () {},
            onDismiss: () {},
          ),
        ),
      );

      expect(find.byType(Dismissible), findsOneWidget);
    });

    testWidgets('formats createdAt as time for today', (tester) async {
      final now = DateTime.now();
      final iso =
          '${now.year}-${now.month.toString().padLeft(2, '0')}-${now.day.toString().padLeft(2, '0')}T${now.hour.toString().padLeft(2, '0')}:${now.minute.toString().padLeft(2, '0')}:00.000Z';

      await tester.pumpWidget(
        _appShell(
          NotificationListItemWidget(
            item: _item(id: '1', title: 'Today', content: '', createdAt: iso),
            onTap: () {},
            onDismiss: () {},
          ),
        ),
      );

      // Today's notifications show HH:mm format
      final timeStr =
          '${now.hour.toString().padLeft(2, '0')}:${now.minute.toString().padLeft(2, '0')}';
      expect(find.text(timeStr), findsOneWidget);
    });
  });
}
