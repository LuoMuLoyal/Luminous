import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:luminous/core/design/design.dart';
import 'package:luminous/core/widgets/common/control/desktop_hover.dart';
import 'package:luminous/features/record/domain/entities/dashboard.dart';
import 'package:luminous/features/record/presentation/widgets/shared/timeline_drag_data.dart';

import '../helpers/test_forui_app.dart';
import '../helpers/test_helpers.dart';

void main() {
  group('TimelineDragData', () {
    test('carries recordId and entry', () {
      const entry = RecordTimelineEntry(
        time: '08:00',
        type: RecordEntryType.water,
        icon: SemanticIcons.recordWater,
        accent: SemanticColor.primary,
        softColor: SemanticColor.neutral,
        titleKey: RecordCopyKey.typeWater,
        recordId: 'rec-123',
      );

      const data = TimelineDragData(recordId: 'rec-123', entry: entry);

      expect(data.recordId, 'rec-123');
      expect(data.entry, same(entry));
    });

    test('entry without recordId is still valid for non-drag display', () {
      const entry = RecordTimelineEntry(
        time: '08:00',
        type: RecordEntryType.water,
        icon: SemanticIcons.recordWater,
        accent: SemanticColor.primary,
        softColor: SemanticColor.neutral,
        titleKey: RecordCopyKey.typeWater,
      );

      // Entry itself doesn't require recordId — only the drag data does.
      expect(entry.recordId, isNull);
    });
  });

  group('DesktopHoverCard – responsive behavior', () {
    testWidgets('renders child on mobile (pass-through)', (tester) async {
      setMobileScreenSize(tester);
      await tester.pumpWidget(
        const TestForuiApp(home: DesktopHoverCard(child: Text('Test Card'))),
      );

      expect(find.text('Test Card'), findsOneWidget);
    });

    testWidgets('renders child on desktop', (tester) async {
      setDesktopScreenSize(tester);
      await tester.pumpWidget(
        const TestForuiApp(home: DesktopHoverCard(child: Text('Test Card'))),
      );

      expect(find.text('Test Card'), findsOneWidget);
    });

    testWidgets(
      'wraps child in AnimatedContainer on desktop for hover tracking',
      (tester) async {
        setDesktopScreenSize(tester);
        await tester.pumpWidget(
          const TestForuiApp(
            home: MediaQuery(
              data: MediaQueryData(size: Size(1440, 1000)),
              child: DesktopHoverCard(child: Text('Hover Me')),
            ),
          ),
        );
        await tester.pump();

        // On desktop, the child is wrapped in an AnimatedContainer for hover effect.
        expect(
          find.ancestor(
            of: find.text('Hover Me'),
            matching: find.byType(AnimatedContainer),
          ),
          findsOneWidget,
        );
      },
    );

    testWidgets(
      'does not wrap child in AnimatedContainer on mobile (pass-through)',
      (tester) async {
        setMobileScreenSize(tester);
        await tester.pumpWidget(
          const TestForuiApp(
            home: MediaQuery(
              data: MediaQueryData(size: Size(390, 844)),
              child: DesktopHoverCard(child: Text('No Hover')),
            ),
          ),
        );
        await tester.pump();

        // On mobile, the child is returned directly — no AnimatedContainer wrapper.
        expect(
          find.ancestor(
            of: find.text('No Hover'),
            matching: find.byType(AnimatedContainer),
          ),
          findsNothing,
        );
      },
    );
  });

  group('Breakpoints', () {
    test('compact breakpoint is 360', () {
      expect(Breakpoints.compact, 360);
    });

    test('mobile breakpoint is 600', () {
      expect(Breakpoints.mobile, 600);
    });

    test('tablet breakpoint is 960', () {
      expect(Breakpoints.tablet, 960);
    });

    test('smallDesktop breakpoint is 1080', () {
      expect(Breakpoints.smallDesktop, 1080);
    });

    test('desktop breakpoint is 1200', () {
      expect(Breakpoints.desktop, 1200);
    });

    test('wide breakpoint is 1400', () {
      expect(Breakpoints.wide, 1400);
    });

    test('ultrawide breakpoint is 1920', () {
      expect(Breakpoints.ultrawide, 1920);
    });
  });

  group('LayoutScaleResolver', () {
    test('dialogMaxWidthFor returns 360 for mobile', () {
      expect(
        LayoutScaleResolver.dialogMaxWidthFor(390),
        LayoutScaleResolver.dialogMaxWidth,
      );
    });

    test('dialogMaxWidthFor returns 480 for tablet', () {
      expect(LayoutScaleResolver.dialogMaxWidthFor(960), 480);
    });

    test('dialogMaxWidthFor returns 560 for desktop', () {
      expect(LayoutScaleResolver.dialogMaxWidthFor(1200), 560);
    });

    test('wideDialogMaxWidthFor returns 640 for desktop', () {
      expect(LayoutScaleResolver.wideDialogMaxWidthFor(1200), 640);
    });

    test('wideDialogMaxWidthFor returns 520 for tablet', () {
      expect(LayoutScaleResolver.wideDialogMaxWidthFor(960), 520);
    });
  });
}
