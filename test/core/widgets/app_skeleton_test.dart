import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:luminous/core/widgets/common/app_skeleton.dart';
import 'package:shimmer/shimmer.dart';

import '../../helpers/test_forui_app.dart';

Widget _appShell(Widget child) {
  return TestForuiApp(
    home: Scaffold(body: Center(child: child)),
  );
}

void main() {
  group('AppStateSkeletonView', () {
    testWidgets('renders shimmer blocks', (tester) async {
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

      expect(find.byType(Shimmer), findsOneWidget);
      expect(find.byType(DecoratedBox), findsWidgets);
    });
  });

  group('AppInlineSkeleton', () {
    testWidgets('wraps children in shimmer column', (tester) async {
      await tester.pumpWidget(
        _appShell(
          const AppInlineSkeleton(
            children: [
              AppInlineSkeletonBlock(height: 20),
              AppInlineSkeletonBlock(height: 20),
            ],
          ),
        ),
      );

      expect(find.byType(Shimmer), findsOneWidget);
      expect(find.byType(Column), findsOneWidget);
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

  group('AppSkeletonText', () {
    testWidgets('shows text when not loading', (tester) async {
      await tester.pumpWidget(
        _appShell(const AppSkeletonText(isLoading: false, text: 'Hello')),
      );

      expect(find.text('Hello'), findsOneWidget);
    });

    testWidgets('shows skeleton block when loading', (tester) async {
      await tester.pumpWidget(
        _appShell(const AppSkeletonText(isLoading: true, text: 'Hello')),
      );

      expect(find.text('Hello'), findsNothing);
      expect(find.byType(AppInlineSkeletonBlock), findsOneWidget);
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
    testWidgets('renders circle and is shimmered', (tester) async {
      await tester.pumpWidget(
        _appShell(const AppInlineSkeletonCircle(size: 40)),
      );

      expect(find.byType(Shimmer), findsOneWidget);
      expect(find.byType(DecoratedBox), findsOneWidget);
    });
  });

  group('AppInlineSkeletonSection', () {
    testWidgets('renders bordered panel with shimmer children', (tester) async {
      await tester.pumpWidget(
        _appShell(
          const AppInlineSkeletonSection(
            children: [AppInlineSkeletonBlock(height: 20)],
          ),
        ),
      );

      expect(find.byType(DecoratedBox), findsWidgets);
      expect(find.byType(Shimmer), findsOneWidget);
    });
  });
}
