import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:forui/forui.dart';
import 'package:luminous/core/feedback/toast.dart';
import 'package:luminous/core/theme/theme.dart';
import 'package:luminous/l10n/app_localizations.dart';

import '../../helpers/test_forui_app.dart';

/// Builds a Forui-aware test shell so the toast widget can resolve its theme.
Widget _appShell(Widget child) {
  return TestForuiApp(home: Scaffold(body: child));
}

/// Mirrors [LuminousApp]'s bootstrap: `FTheme` wraps an `FToaster` above the
/// Navigator so [Toast.show] can render real toasts.
Widget _toastShell(Widget child) {
  final theme = appThemeData(appDefaultThemeFamily, Brightness.light);
  return MaterialApp(
    theme: foruiMaterialTheme(theme),
    debugShowCheckedModeBanner: false,
    builder: (context, child) => FTheme(
      data: theme,
      child: FToaster(child: child ?? const SizedBox.shrink()),
    ),
    localizationsDelegates: const <LocalizationsDelegate<dynamic>>[
      AppLocalizations.delegate,
      FLocalizations.delegate,
      GlobalMaterialLocalizations.delegate,
      GlobalWidgetsLocalizations.delegate,
      GlobalCupertinoLocalizations.delegate,
    ],
    supportedLocales: AppLocalizations.supportedLocales,
    home: Scaffold(body: child),
  );
}

void main() {
  group('Toast.show — graceful degradation', () {
    testWidgets('returns false when no FToaster ancestor exists', (
      tester,
    ) async {
      bool? result;
      await tester.pumpWidget(
        _appShell(
          Builder(
            builder: (context) {
              return ElevatedButton(
                onPressed: () async {
                  result = await Toast.show(context, 'Test message');
                },
                child: const Text('Show'),
              );
            },
          ),
        ),
      );

      await tester.tap(find.text('Show'));
      await tester.pump();

      // Without FToaster in the tree, showFToast throws → caught → returns false
      expect(result, isFalse);
    });

    testWidgets('does not crash when no overlay ancestor exists', (
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
                    result = await Toast.show(context, 'No overlay');
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

      // No FToaster + no overlay → both checks fail → returns false
      expect(result, isFalse);
    });
  });

  group('Toast.show — with FToaster', () {
    testWidgets('shows the message and returns true', (tester) async {
      bool? result;
      await tester.pumpWidget(
        _toastShell(
          Builder(
            builder: (context) {
              return ElevatedButton(
                onPressed: () async {
                  result = await Toast.show(context, 'Test message');
                },
                child: const Text('Show'),
              );
            },
          ),
        ),
      );

      await tester.tap(find.text('Show'));
      await tester.pump();
      // Let the entrance animation complete before the auto-dismiss timer
      // fires. Dismissing mid-entrance trips forui's non-accessible dismiss
      // path (dispose during notifyListeners).
      await tester.pump(const Duration(milliseconds: 300));

      expect(result, isTrue);
      expect(find.text('Test message'), findsOneWidget);

      // Auto-dismisses after the 1800ms timer fires.
      await tester.pump(const Duration(milliseconds: 1800));
      await tester.pumpAndSettle();
      expect(find.text('Test message'), findsNothing);
    });
  });
}
