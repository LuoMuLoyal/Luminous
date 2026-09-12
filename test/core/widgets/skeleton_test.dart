import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:luminous/core/accessibility/motion.dart';
import 'package:luminous/core/widgets/common/feedback/skeleton.dart';
import 'package:shimmer/shimmer.dart';

import '../../helpers/test_forui_app.dart';

Widget _appShell(Widget child) {
  return TestForuiApp(
    home: Scaffold(body: Center(child: child)),
  );
}

/// Wraps [child] in a [MediaQuery] that requests reduced motion, mirroring what
/// `bootstrap.dart` injects (its own setting maps to `accessibleNavigation`).
Widget _reducedMotionShell(
  Widget child, {
  bool viaAccessibleNavigation = false,
}) {
  return TestForuiApp(
    home: MediaQuery(
      data: MediaQueryData(
        disableAnimations: !viaAccessibleNavigation,
        accessibleNavigation: viaAccessibleNavigation,
      ),
      child: Scaffold(body: Center(child: child)),
    ),
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

  group('reduced motion', () {
    Future<void> pumpAndSettleFrames(WidgetTester tester) async {
      for (var i = 0; i < 40; i++) {
        await tester.pump(const Duration(milliseconds: 16));
      }
    }

    testWidgets('prefersReducedMotion reads disableAnimations', (tester) async {
      var reduced = false;
      await tester.pumpWidget(
        TestForuiApp(
          home: Builder(
            builder: (context) {
              reduced = prefersReducedMotion(context);
              return const SizedBox.shrink();
            },
          ),
        ),
      );
      expect(reduced, isFalse);

      await tester.pumpWidget(
        TestForuiApp(
          home: MediaQuery(
            data: const MediaQueryData(disableAnimations: true),
            child: Builder(
              builder: (context) {
                reduced = prefersReducedMotion(context);
                return const SizedBox.shrink();
              },
            ),
          ),
        ),
      );
      expect(reduced, isTrue);
    });

    testWidgets('prefersReducedMotion reads accessibleNavigation', (
      tester,
    ) async {
      var reduced = false;
      await tester.pumpWidget(
        TestForuiApp(
          home: MediaQuery(
            data: const MediaQueryData(accessibleNavigation: true),
            child: Builder(
              builder: (context) {
                reduced = prefersReducedMotion(context);
                return const SizedBox.shrink();
              },
            ),
          ),
        ),
      );
      expect(reduced, isTrue);
    });

    testWidgets('StateSkeletonView drops the infinite shimmer', (tester) async {
      await tester.pumpWidget(
        _appShell(
          const StateSkeletonView(blocks: [StateSkeletonBlock(height: 80)]),
        ),
      );
      await pumpAndSettleFrames(tester);
      // The shimmer keeps scheduling frames forever...
      expect(find.byType(Shimmer), findsOneWidget);
      expect(tester.binding.hasScheduledFrame, isTrue);

      await tester.pumpWidget(
        _reducedMotionShell(
          const StateSkeletonView(blocks: [StateSkeletonBlock(height: 80)]),
        ),
      );
      await pumpAndSettleFrames(tester);
      // ...so with reduced motion requested it must not be built at all, and
      // the app must go idle.
      expect(find.byType(Shimmer), findsNothing);
      expect(find.byType(DecoratedBox), findsWidgets);
      expect(tester.binding.hasScheduledFrame, isFalse);
    });

    testWidgets('InlineSkeleton drops the infinite shimmer', (tester) async {
      await tester.pumpWidget(
        _reducedMotionShell(
          const InlineSkeleton(children: [InlineSkeletonBlock(height: 20)]),
        ),
      );
      await pumpAndSettleFrames(tester);
      expect(find.byType(Shimmer), findsNothing);
      expect(find.byType(Column), findsOneWidget);
      expect(tester.binding.hasScheduledFrame, isFalse);
    });

    testWidgets('InlineSkeletonCircle drops the infinite shimmer', (
      tester,
    ) async {
      await tester.pumpWidget(
        _reducedMotionShell(const InlineSkeletonCircle(size: 40)),
      );
      await pumpAndSettleFrames(tester);
      expect(find.byType(Shimmer), findsNothing);
      expect(find.byType(DecoratedBox), findsOneWidget);
      expect(tester.binding.hasScheduledFrame, isFalse);
    });

    testWidgets('accessibleNavigation path also drops the shimmer', (
      tester,
    ) async {
      await tester.pumpWidget(
        _reducedMotionShell(
          const InlineSkeleton(children: [InlineSkeletonBlock(height: 20)]),
          viaAccessibleNavigation: true,
        ),
      );
      await pumpAndSettleFrames(tester);
      expect(find.byType(Shimmer), findsNothing);
      expect(tester.binding.hasScheduledFrame, isFalse);
    });
  });
}
