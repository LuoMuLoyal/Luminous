import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:luminous/core/feedback/app_toast.dart';
import 'package:luminous/core/theme/app_theme_extensions.dart';

/// Builds a MaterialApp with AppThemeSurface registered so the toast widget
/// can resolve its theme extension without throwing.
Widget _appShell(Widget child) {
  return MaterialApp(
    theme: ThemeData.light().copyWith(
      extensions: const <ThemeExtension<dynamic>>[AppThemeSurface.light],
    ),
    home: Scaffold(body: child),
  );
}

/// Pumps past the 1800ms auto-dismiss timer + a small frame delay.
Future<void> _drainToastTimer(WidgetTester tester) async {
  await tester.pump(const Duration(milliseconds: 1900));
}

void main() {
  group('AppToast.show', () {
    testWidgets('shows a toast overlay when context has an Overlay', (
      tester,
    ) async {
      await tester.pumpWidget(
        _appShell(
          Builder(
            builder: (context) {
              return ElevatedButton(
                onPressed: () => AppToast.show(context, 'Test message'),
                child: const Text('Show'),
              );
            },
          ),
        ),
      );

      await tester.tap(find.text('Show'));
      await tester.pump();

      expect(find.text('Test message'), findsOneWidget);
      expect(find.byIcon(Icons.close), findsOneWidget);

      await _drainToastTimer(tester);
    });

    testWidgets('toast auto-dismisses after 1800ms', (tester) async {
      await tester.pumpWidget(
        _appShell(
          Builder(
            builder: (context) {
              return ElevatedButton(
                onPressed: () => AppToast.show(context, 'Dismiss me'),
                child: const Text('Show'),
              );
            },
          ),
        ),
      );

      await tester.tap(find.text('Show'));
      await tester.pump();

      expect(find.text('Dismiss me'), findsOneWidget);

      await tester.pump(const Duration(milliseconds: 1800));

      expect(find.text('Dismiss me'), findsNothing);
    });

    testWidgets('toast close button removes the toast', (tester) async {
      await tester.pumpWidget(
        _appShell(
          Builder(
            builder: (context) {
              return ElevatedButton(
                onPressed: () => AppToast.show(context, 'Close me'),
                child: const Text('Show'),
              );
            },
          ),
        ),
      );

      await tester.tap(find.text('Show'));
      await tester.pump();

      expect(find.text('Close me'), findsOneWidget);

      await tester.tap(find.byIcon(Icons.close));
      await tester.pump();

      expect(find.text('Close me'), findsNothing);
    });

    testWidgets('returns true when toast is shown', (tester) async {
      bool? result;
      await tester.pumpWidget(
        _appShell(
          Builder(
            builder: (context) {
              return ElevatedButton(
                onPressed: () async {
                  result = await AppToast.show(context, 'Result test');
                },
                child: const Text('Show'),
              );
            },
          ),
        ),
      );

      await tester.tap(find.text('Show'));
      await tester.pump();

      expect(result, isTrue);

      await _drainToastTimer(tester);
    });
  });

  group('AppToast without Overlay', () {
    testWidgets('returns false when no overlay ancestor exists', (
      tester,
    ) async {
      bool? result;
      await tester.pumpWidget(
        Material(
          child: Directionality(
            textDirection: TextDirection.ltr,
            child: Builder(
              builder: (context) {
                return GestureDetector(
                  onTap: () async {
                    result = await AppToast.show(context, 'No overlay');
                  },
                  child: const Text('Tap'),
                );
              },
            ),
          ),
        ),
      );

      await tester.tap(find.text('Tap'));
      await tester.pump();

      expect(result, isFalse);
    });
  });

  group('AppToast deduplication', () {
    testWidgets('showing the same message again resets the timer', (
      tester,
    ) async {
      await tester.pumpWidget(
        _appShell(
          Builder(
            builder: (context) {
              return ElevatedButton(
                onPressed: () => AppToast.show(context, 'Duplicate'),
                child: const Text('Show'),
              );
            },
          ),
        ),
      );

      await tester.tap(find.text('Show'));
      await tester.pump();

      await tester.tap(find.text('Show'));
      await tester.pump();

      expect(find.text('Duplicate'), findsOneWidget);

      // 1500ms < 1800ms — toast should still be visible
      await tester.pump(const Duration(milliseconds: 1500));

      expect(find.text('Duplicate'), findsOneWidget);

      await tester.pump(const Duration(milliseconds: 400));

      expect(find.text('Duplicate'), findsNothing);
    });
  });
}
