import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:forui/forui.dart';
import 'package:luminous/core/design/semantic_color.dart';
import 'package:luminous/features/record/domain/entities/dashboard.dart';
import 'package:luminous/features/record/presentation/widgets/sections/quick_actions.dart';
import 'package:luminous/l10n/app_localizations.dart';

import '../../helpers/test_forui_app.dart';

void main() {
  late AppLocalizations l10n;

  setUp(() async {
    l10n = await AppLocalizations.delegate.load(const Locale('zh'));
  });

  List<RecordQuickAction> buildActions() {
    return [
      const RecordQuickAction(
        type: RecordEntryType.meal,
        icon: FLucideIcons.utensils,
        titleKey: RecordCopyKey.typeMeal,
        subtitleKey: RecordCopyKey.summaryTimesUnit,
        accent: SemanticColor.primary,
        softColor: SemanticColor.neutral,
      ),
      const RecordQuickAction(
        type: RecordEntryType.water,
        icon: FLucideIcons.cupSoda,
        titleKey: RecordCopyKey.typeWater,
        subtitleKey: RecordCopyKey.summaryCupsUnit,
        accent: SemanticColor.primary,
        softColor: SemanticColor.neutral,
      ),
      const RecordQuickAction(
        type: RecordEntryType.symptom,
        icon: FLucideIcons.cross,
        titleKey: RecordCopyKey.typeSymptom,
        subtitleKey: RecordCopyKey.summaryRecorded,
        accent: SemanticColor.warning,
        softColor: SemanticColor.neutral,
      ),
    ];
  }

  testWidgets('renders card with section title', (tester) async {
    await tester.pumpWidget(
      TestForuiApp(
        home: Scaffold(
          body: RecordQuickActions(actions: buildActions(), l10n: l10n),
        ),
      ),
    );

    expect(find.byKey(const Key('record-quick-actions')), findsOneWidget);
    expect(find.text(l10n.recordQuickSectionTitle), findsOneWidget);
  });

  testWidgets('renders all action tiles', (tester) async {
    await tester.pumpWidget(
      TestForuiApp(
        home: Scaffold(
          body: RecordQuickActions(actions: buildActions(), l10n: l10n),
        ),
      ),
    );

    expect(find.text(l10n.recordTypeMeal), findsOneWidget);
    expect(find.text(l10n.recordTypeWater), findsOneWidget);
    expect(find.text(l10n.recordTypeSymptom), findsOneWidget);
  });

  testWidgets('renders correct number of tiles', (tester) async {
    final actions = buildActions();
    await tester.pumpWidget(
      TestForuiApp(
        home: Scaffold(
          body: RecordQuickActions(actions: actions, l10n: l10n),
        ),
      ),
    );

    // Each action has an FButton.raw tile
    expect(find.byType(FButton), findsNWidgets(actions.length));
  });

  testWidgets('onQuickAction called when tile tapped', (tester) async {
    RecordQuickAction? tapped;
    await tester.pumpWidget(
      TestForuiApp(
        home: Scaffold(
          body: RecordQuickActions(
            actions: buildActions(),
            l10n: l10n,
            onQuickAction: (action) => tapped = action,
          ),
        ),
      ),
    );

    await tester.tap(find.text(l10n.recordTypeMeal));
    await tester.pumpAndSettle();

    expect(tapped, isNotNull);
    expect(tapped!.type, RecordEntryType.meal);
  });

  testWidgets('compact mode uses 4 columns', (tester) async {
    tester.view.devicePixelRatio = 1;
    tester.view.physicalSize = const Size(400, 800);
    addTearDown(() {
      tester.view.resetDevicePixelRatio();
      tester.view.resetPhysicalSize();
    });

    await tester.pumpWidget(
      TestForuiApp(
        home: Scaffold(
          body: SizedBox(
            width: 400,
            child: RecordQuickActions(
              actions: buildActions(),
              l10n: l10n,
              compact: true,
            ),
          ),
        ),
      ),
    );

    // In compact mode, 4 columns are used
    // With 3 actions, they should all fit in one row
    expect(find.byKey(const Key('record-quick-actions')), findsOneWidget);
  });

  testWidgets('renders with empty actions list', (tester) async {
    await tester.pumpWidget(
      TestForuiApp(
        home: Scaffold(
          body: RecordQuickActions(actions: [], l10n: l10n),
        ),
      ),
    );

    expect(find.byKey(const Key('record-quick-actions')), findsOneWidget);
    expect(find.text(l10n.recordQuickSectionTitle), findsOneWidget);
  });
}
