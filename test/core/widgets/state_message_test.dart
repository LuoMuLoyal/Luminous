import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:forui/forui.dart';
import 'package:luminous/core/widgets/common/state_message.dart';

import '../../helpers/test_forui_app.dart';

Widget _appShell(Widget child) {
  return TestForuiApp(
    home: Scaffold(body: Center(child: child)),
  );
}

void main() {
  group('StateMessageView', () {
    testWidgets('renders title, description and icon', (tester) async {
      await tester.pumpWidget(
        _appShell(
          const StateMessageView(
            title: 'No data',
            description: 'Nothing to show yet.',
            icon: FLucideIcons.inbox,
          ),
        ),
      );

      expect(find.byType(FCard), findsOneWidget);
      expect(find.text('No data'), findsOneWidget);
      expect(find.text('Nothing to show yet.'), findsOneWidget);
      expect(find.byIcon(FLucideIcons.inbox), findsOneWidget);
    });

    testWidgets('renders action button when provided', (tester) async {
      await tester.pumpWidget(
        _appShell(
          StateMessageView(
            title: 'Error',
            description: 'Tap to retry',
            icon: FLucideIcons.triangleAlert,
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
          StateMessageView(
            title: 'Network error',
            description: 'Check connection',
            icon: FLucideIcons.wifiOff,
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
          const StateMessageView(
            maxWidth: 560,
            title: 'Limited',
            description: 'Width is constrained.',
            icon: FLucideIcons.info,
          ),
        ),
      );

      final constrainedBox = tester.widget<ConstrainedBox>(
        find.descendant(
          of: find.byType(StateMessageView),
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
          const StateMessageView(
            title: 'Full',
            description: 'No width limit.',
            icon: FLucideIcons.info,
          ),
        ),
      );

      expect(
        find.descendant(
          of: find.byType(StateMessageView),
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
            child: StateMessageView(
              title: 'Need retry',
              description: 'The response did not finish.',
              icon: FLucideIcons.triangleAlert,
              actionLabel: 'Retry',
            ),
          ),
        ),
      );

      expect(tester.takeException(), isNull);
    });
  });

  group('StateErrorView', () {
    testWidgets('renders title and description', (tester) async {
      await tester.pumpWidget(
        _appShell(
          const StateErrorView(
            title: 'Something went wrong',
            description: 'Please try again later.',
            icon: FLucideIcons.circleAlert,
          ),
        ),
      );

      expect(find.text('Something went wrong'), findsOneWidget);
      expect(find.text('Please try again later.'), findsOneWidget);
    });

    testWidgets('uses compact padding when compact is true', (tester) async {
      await tester.pumpWidget(
        _appShell(
          const StateErrorView(
            title: 'Compact',
            description: 'Small error view',
            icon: FLucideIcons.info,
            compact: true,
          ),
        ),
      );

      expect(find.text('Compact'), findsOneWidget);
      expect(find.text('Small error view'), findsOneWidget);
    });
  });

  group('StateTone', () {
    testWidgets('neutral uses primary accent', (tester) async {
      await tester.pumpWidget(
        _appShell(
          const StateMessageView(
            title: 'Neutral',
            description: 'Primary accent',
            icon: FLucideIcons.info,
            tone: StateTone.neutral,
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
          const StateMessageView(
            title: 'Danger',
            description: 'Destructive accent',
            icon: FLucideIcons.circleAlert,
            tone: StateTone.danger,
          ),
        ),
      );

      final iconWidget = tester.widget<Icon>(find.byType(Icon));
      final theme = tester.widget<FTheme>(find.byType(FTheme)).data;
      expect(iconWidget.color, theme.colors.destructive);
    });
  });
}
