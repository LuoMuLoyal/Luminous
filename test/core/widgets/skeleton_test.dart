import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:luminous/core/widgets/common/skeleton.dart';
import 'package:shimmer/shimmer.dart';

import '../../helpers/test_forui_app.dart';

Widget _appShell(Widget child) {
  return TestForuiApp(
    home: Scaffold(body: Center(child: child)),
  );
}

void main() {
  group('StateSkeletonView', () {
    testWidgets('renders shimmer blocks', (tester) async {
      await tester.pumpWidget(
        _appShell(
          const StateSkeletonView(
            blocks: [
              StateSkeletonBlock(height: 80),
              StateSkeletonBlock(height: 40),
            ],
          ),
        ),
      );

      expect(find.byType(Shimmer), findsOneWidget);
      expect(find.byType(DecoratedBox), findsWidgets);
    });
  });

  group('InlineSkeleton', () {
    testWidgets('wraps children in shimmer column', (tester) async {
      await tester.pumpWidget(
        _appShell(
          const InlineSkeleton(
            children: [
              InlineSkeletonBlock(height: 20),
              InlineSkeletonBlock(height: 20),
            ],
          ),
        ),
      );

      expect(find.byType(Shimmer), findsOneWidget);
      expect(find.byType(Column), findsOneWidget);
    });
  });

  group('SkeletonSlot', () {
    testWidgets('shows child when isLoading is false', (tester) async {
      await tester.pumpWidget(
        _appShell(
          const SkeletonSlot(
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
          const SkeletonSlot(
            isLoading: true,
            skeleton: Text('Skeleton'),
            child: Text('Real content'),
          ),
        ),
      );

      expect(find.text('Real content'), findsNothing);
      expect(find.text('Skeleton'), findsOneWidget);
    });

    testWidgets('inherits loading state from SkeletonScope', (tester) async {
      await tester.pumpWidget(
        _appShell(
          const SkeletonScope(
            isLoading: true,
            child: SkeletonSlot(
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

  group('SkeletonText', () {
    testWidgets('shows text when not loading', (tester) async {
      await tester.pumpWidget(
        _appShell(const SkeletonText(isLoading: false, text: 'Hello')),
      );

      expect(find.text('Hello'), findsOneWidget);
    });

    testWidgets('shows skeleton block when loading', (tester) async {
      await tester.pumpWidget(
        _appShell(const SkeletonText(isLoading: true, text: 'Hello')),
      );

      expect(find.text('Hello'), findsNothing);
      expect(find.byType(InlineSkeletonBlock), findsOneWidget);
    });
  });

  group('InlineSkeletonBlock', () {
    testWidgets('renders with explicit width', (tester) async {
      await tester.pumpWidget(
        _appShell(const InlineSkeletonBlock(height: 20, width: 100)),
      );

      expect(find.byType(DecoratedBox), findsOneWidget);
    });
  });

  group('InlineSkeletonCircle', () {
    testWidgets('renders circle and is shimmered', (tester) async {
      await tester.pumpWidget(_appShell(const InlineSkeletonCircle(size: 40)));

      expect(find.byType(Shimmer), findsOneWidget);
      expect(find.byType(DecoratedBox), findsOneWidget);
    });
  });

  group('InlineSkeletonSection', () {
    testWidgets('renders bordered panel with shimmer children', (tester) async {
      await tester.pumpWidget(
        _appShell(
          const InlineSkeletonSection(
            children: [InlineSkeletonBlock(height: 20)],
          ),
        ),
      );

      expect(find.byType(DecoratedBox), findsWidgets);
      expect(find.byType(Shimmer), findsOneWidget);
    });
  });
}
