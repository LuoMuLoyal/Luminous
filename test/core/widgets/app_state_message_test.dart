import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:forui/forui.dart';
import 'package:luminous/core/widgets/common/app_state_message.dart';

import '../../helpers/test_forui_app.dart';

Widget _appShell(Widget child) {
  return TestForuiApp(
    home: Scaffold(body: Center(child: child)),
  );
}

void main() {
  group('AppStateMessageView', () {
    testWidgets('renders title, description and icon', (tester) async {
      await tester.pumpWidget(
        _appShell(
          const AppStateMessageView(
            title: 'No data',
            description: 'Nothing to show yet.',
            icon: Icons.inbox_outlined,
          ),
        ),
      );

      expect(find.byType(FCard), findsOneWidget);
      expect(find.text('No data'), findsOneWidget);
      expect(find.text('Nothing to show yet.'), findsOneWidget);
      expect(find.byIcon(Icons.inbox_outlined), findsOneWidget);
    });

    testWidgets('renders action button when provided', (tester) async {
      await tester.pumpWidget(
        _appShell(
          AppStateMessageView(
            title: 'Error',
            description: 'Tap to retry',
            icon: Icons.warning_amber_rounded,
            actionLabel: 'Retry',
            onAction: () {},
          ),
        ),
      );

      expect(find.text('Retry'), findsOneWidget);
      expect(find.byType(FButton), findsOneWidget);
    });

    testWidgets('action button triggers callback when tapped', (tester) async {
      bool tapped = false;
      await tester.pumpWidget(
        _appShell(
          AppStateMessageView(
            title: 'Network error',
            description: 'Check connection',
            icon: Icons.wifi_off,
            actionLabel: 'Retry',
            onAction: () => tapped = true,
          ),
        ),
      );

      await tester.tap(find.text('Retry'));
      await tester.pumpAndSettle();
      expect(tapped, isTrue);
    });

    testWidgets('applies maxWidth via ConstrainedBox', (tester) async {
      await tester.pumpWidget(
        _appShell(
          const AppStateMessageView(
            maxWidth: 560,
            title: 'Limited',
            description: 'Width is constrained.',
            icon: Icons.info_outline,
          ),
        ),
      );

      final constrainedBox = tester.widget<ConstrainedBox>(
        find.descendant(
          of: find.byType(AppStateMessageView),
          matching: find.byType(ConstrainedBox),
        ),
      );
      expect(constrainedBox.constraints.maxWidth, 560);
    });

    testWidgets('does not add ConstrainedBox when maxWidth is null', (
      tester,
    ) async {
      await tester.pumpWidget(
        _appShell(
          const AppStateMessageView(
            title: 'Full',
            description: 'No width limit.',
            icon: Icons.info_outline,
          ),
        ),
      );

      expect(
        find.descendant(
          of: find.byType(AppStateMessageView),
          matching: find.byType(ConstrainedBox),
        ),
        findsNothing,
      );
    });

    testWidgets('does not overflow in tight height', (tester) async {
      await tester.pumpWidget(
        _appShell(
          const SizedBox(
            width: 320,
            height: 72,
            child: AppStateMessageView(
              title: 'Need retry',
              description: 'The response did not finish.',
              icon: Icons.warning_amber_rounded,
              actionLabel: 'Retry',
            ),
          ),
        ),
      );

      expect(tester.takeException(), isNull);
    });
  });

  group('AppStateErrorView', () {
    testWidgets('renders title and description', (tester) async {
      await tester.pumpWidget(
        _appShell(
          const AppStateErrorView(
            title: 'Something went wrong',
            description: 'Please try again later.',
            icon: Icons.error_outline,
          ),
        ),
      );

      expect(find.text('Something went wrong'), findsOneWidget);
      expect(find.text('Please try again later.'), findsOneWidget);
    });

    testWidgets('uses compact padding when compact is true', (tester) async {
      await tester.pumpWidget(
        _appShell(
          const AppStateErrorView(
            title: 'Compact',
            description: 'Small error view',
            icon: Icons.info_outline,
            compact: true,
          ),
        ),
      );

      expect(find.text('Compact'), findsOneWidget);
      expect(find.text('Small error view'), findsOneWidget);
    });
  });

  group('AppStateTone', () {
    testWidgets('neutral uses primary accent', (tester) async {
      await tester.pumpWidget(
        _appShell(
          const AppStateMessageView(
            title: 'Neutral',
            description: 'Primary accent',
            icon: Icons.info_outline,
            tone: AppStateTone.neutral,
          ),
        ),
      );

      final iconWidget = tester.widget<Icon>(find.byType(Icon));
      final theme = tester.widget<FTheme>(find.byType(FTheme)).data;
      expect(iconWidget.color, theme.colors.primary);
    });

    testWidgets('danger uses destructive accent', (tester) async {
      await tester.pumpWidget(
        _appShell(
          const AppStateMessageView(
            title: 'Danger',
            description: 'Destructive accent',
            icon: Icons.error_outline,
            tone: AppStateTone.danger,
          ),
        ),
      );

      final iconWidget = tester.widget<Icon>(find.byType(Icon));
      final theme = tester.widget<FTheme>(find.byType(FTheme)).data;
      expect(iconWidget.color, theme.colors.destructive);
    });
  });
}
