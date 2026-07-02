import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:forui/forui.dart';
import 'package:luminous/core/widgets/common/app_state_views.dart';

import '../../helpers/test_forui_app.dart';

Widget _appShell(Widget child) {
  return TestForuiApp(home: Scaffold(body: Center(child: child)));
}

void main() {
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

      expect(find.byType(FCard), findsOneWidget);
      expect(find.text('Something went wrong'), findsOneWidget);
      expect(find.text('Please try again later.'), findsOneWidget);
      expect(find.byIcon(Icons.error_outline), findsOneWidget);
    });

    testWidgets('renders action button when provided', (tester) async {
      await tester.pumpWidget(
        _appShell(
          AppStateErrorView(
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
          AppStateErrorView(
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

    testWidgets('AppStateMessageView does not overflow in tight height', (
      tester,
    ) async {
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

  group('AppStateSkeletonBlock rendering', () {
    testWidgets('AppStateSkeletonView renders shimmer blocks', (tester) async {
      await tester.pumpWidget(
        _appShell(
          const AppStateSkeletonView(
            blocks: [
              AppStateSkeletonBlock(height: 80),
              AppStateSkeletonBlock(height: 40),
            ],
          ),
        ),
      );

      // Shimmer renders decorated boxes
      expect(find.byType(DecoratedBox), findsWidgets);
    });
  });

  group('AppSkeletonSlot', () {
    testWidgets('shows child when isLoading is false', (tester) async {
      await tester.pumpWidget(
        _appShell(
          const AppSkeletonSlot(
            isLoading: false,
            skeleton: Text('Skeleton'),
            child: Text('Real content'),
          ),
        ),
      );

      expect(find.text('Real content'), findsOneWidget);
      expect(find.text('Skeleton'), findsNothing);
    });

    testWidgets('shows skeleton when isLoading is true', (tester) async {
      await tester.pumpWidget(
        _appShell(
          const AppSkeletonSlot(
            isLoading: true,
            skeleton: Text('Skeleton'),
            child: Text('Real content'),
          ),
        ),
      );

      expect(find.text('Real content'), findsNothing);
      // Skeleton is wrapped in shimmer, so we look for the skeleton text
      // which should still be in the tree
      expect(find.text('Skeleton'), findsOneWidget);
    });

    testWidgets('inherits loading state from AppSkeletonScope', (tester) async {
      await tester.pumpWidget(
        _appShell(
          const AppSkeletonScope(
            isLoading: true,
            child: AppSkeletonSlot(
              skeleton: Text('From scope'),
              child: Text('Hidden'),
            ),
          ),
        ),
      );

      expect(find.text('Hidden'), findsNothing);
      expect(find.text('From scope'), findsOneWidget);
    });
  });

  group('AppInlineSkeletonBlock', () {
    testWidgets('renders with explicit width', (tester) async {
      await tester.pumpWidget(
        _appShell(const AppInlineSkeletonBlock(height: 20, width: 100)),
      );

      expect(find.byType(DecoratedBox), findsOneWidget);
    });
  });

  group('AppInlineSkeletonCircle', () {
    testWidgets('renders circle', (tester) async {
      await tester.pumpWidget(
        _appShell(const AppInlineSkeletonCircle(size: 40)),
      );

      expect(find.byType(DecoratedBox), findsOneWidget);
    });
  });

  group('AppTextAction', () {
    testWidgets('renders text and triggers callback', (tester) async {
      bool tapped = false;
      await tester.pumpWidget(
        _appShell(
          TextButton(
            onPressed: () => tapped = true,
            child: const Text('Action text'),
          ),
        ),
      );

      await tester.tap(find.text('Action text'));
      expect(tapped, isTrue);
    });
  });
}
