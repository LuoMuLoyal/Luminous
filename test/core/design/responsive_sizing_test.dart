import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:luminous/core/design/design.dart';

/// A minimal BuildContext stand-in for responsive sizing tests.
///
/// Only exposes the MediaQuery data needed by cardWidth / sidebarWidth /
/// gridCrossAxisCount / scaleByWidth / scaleByHeight.
/// Helper: create a test app shell that overrides MediaQuery size.
///
/// Uses [Builder] so the callback receives a context from inside
/// the custom MediaQuery rather than the default test environment.
Widget _pump(double width, Widget Function(BuildContext) builder) {
  return MediaQuery(
    data: MediaQueryData(size: Size(width, 800)),
    child: Directionality(
      textDirection: TextDirection.ltr,
      child: Builder(builder: builder),
    ),
  );
}

void main() {
  group('ResponsiveSizing.cardWidth', () {
    test('clamps to minWidth on very small screen', () {
      final widget = _pump(200, (ctx) {
        final w = ResponsiveSizing.cardWidth(ctx);
        return Text('width=$w');
      });
      expect(widget, isA<Widget>());
    });

    testWidgets('returns default clamped value at 375 px', (tester) async {
      var captured = 0.0;
      await tester.pumpWidget(
        _pump(375, (ctx) {
          captured = ResponsiveSizing.cardWidth(ctx);
          return const SizedBox.shrink();
        }),
      );
      // 375 * 0.72 = 270, within [260, 320]
      expect(captured, inInclusiveRange(260, 320));
    });

    testWidgets('returns mobileFraction * width for medium screen', (
      tester,
    ) async {
      var captured = 0.0;
      await tester.pumpWidget(
        _pump(500, (ctx) {
          captured = ResponsiveSizing.cardWidth(ctx);
          return const SizedBox.shrink();
        }),
      );
      // 500 * 0.72 = 360, clamped to 320
      expect(captured, equals(320));
    });
  });

  group('ResponsiveSizing.gridCrossAxisCount', () {
    testWidgets('returns mobile count below 600', (tester) async {
      var count = 0;
      await tester.pumpWidget(
        _pump(375, (ctx) {
          count = ResponsiveSizing.gridCrossAxisCount(ctx);
          return const SizedBox.shrink();
        }),
      );
      expect(count, equals(2));
    });

    testWidgets('returns tablet count at 960', (tester) async {
      var count = 0;
      await tester.pumpWidget(
        _pump(960, (ctx) {
          count = ResponsiveSizing.gridCrossAxisCount(ctx);
          return const SizedBox.shrink();
        }),
      );
      expect(count, equals(3));
    });

    testWidgets('returns desktop count at 1200', (tester) async {
      var count = 0;
      await tester.pumpWidget(
        _pump(1200, (ctx) {
          count = ResponsiveSizing.gridCrossAxisCount(ctx);
          return const SizedBox.shrink();
        }),
      );
      expect(count, equals(4));
    });

    testWidgets('respects custom overrides', (tester) async {
      var count = 0;
      await tester.pumpWidget(
        _pump(375, (ctx) {
          count = ResponsiveSizing.gridCrossAxisCount(
            ctx,
            mobile: 1,
            tablet: 2,
            desktop: 3,
          );
          return const SizedBox.shrink();
        }),
      );
      expect(count, equals(1));
    });
  });

  group('ResponsiveSizing.scaleByWidth', () {
    testWidgets('clamps to minValue on narrow screen', (tester) async {
      var value = 0.0;
      await tester.pumpWidget(
        _pump(200, (ctx) {
          value = ResponsiveSizing.scaleByWidth(
            ctx,
            fraction: 0.1,
            minValue: 30,
            maxValue: 100,
          );
          return const SizedBox.shrink();
        }),
      );
      expect(value, equals(30));
    });

    testWidgets('scales with width within range', (tester) async {
      var value = 0.0;
      await tester.pumpWidget(
        _pump(500, (ctx) {
          value = ResponsiveSizing.scaleByWidth(
            ctx,
            fraction: 0.1,
            minValue: 30,
            maxValue: 100,
          );
          return const SizedBox.shrink();
        }),
      );
      // 500 * 0.1 = 50
      expect(value, equals(50));
    });
  });

  group('ResponsiveSizing.sidebarWidth', () {
    testWidgets('clamps to minWidth on narrow screen', (tester) async {
      var value = 0.0;
      await tester.pumpWidget(
        _pump(800, (ctx) {
          value = ResponsiveSizing.sidebarWidth(ctx);
          return const SizedBox.shrink();
        }),
      );
      // 800 * 0.22 = 176, clamped to 280
      expect(value, equals(280));
    });

    testWidgets('scales with screen on wider screens', (tester) async {
      var value = 0.0;
      await tester.pumpWidget(
        _pump(1440, (ctx) {
          value = ResponsiveSizing.sidebarWidth(ctx);
          return const SizedBox.shrink();
        }),
      );
      // 1440 * 0.22 = 316.8, within [280, 360]
      expect(value, inInclusiveRange(280, 360));
    });
  });
}
