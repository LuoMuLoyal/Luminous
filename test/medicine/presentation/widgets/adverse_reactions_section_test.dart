import 'package:flutter/widgets.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:luminous/features/medicine/domain/entities/adverse_reaction.dart';
import 'package:luminous/features/medicine/presentation/widgets/adverse_reactions_section.dart';
import 'package:luminous/l10n/app_localizations.dart';

import '../../../helpers/test_forui_app.dart';

AdverseReaction _reaction({
  required String name,
  String section = 'AR',
  List<String>? sections,
  double? confidence,
  int labelCount = 3,
}) {
  return AdverseReaction(
    meddraId: 'm-$name',
    name: name,
    termType: 'LLT',
    labelCount: labelCount,
    labelSections: sections ?? [section],
    sources: const ['US'],
    confidence: ReactionConfidence.fromScore(confidence),
  );
}

AdverseReactionReport _report(List<AdverseReaction> reactions) {
  final bySection = <ReactionSection, List<AdverseReaction>>{};
  for (final reaction in reactions) {
    for (final section in reaction.labelSections.map(
      ReactionSection.fromWire,
    )) {
      (bySection[section] ??= []).add(reaction);
    }
  }
  return AdverseReactionReport(
    rxnormCui: '5640',
    sourceVersion: 'v3.1.1',
    reactions: reactions,
    groups: [
      for (final section in ReactionSection.values)
        if (bySection[section] case final items?)
          ReactionGroup(section: section, reactions: items),
    ],
  );
}

Future<void> _pump(
  WidgetTester tester, {
  required AsyncValue<AdverseReactionReport?> report,
  required AppLocalizations l10n,
}) async {
  await tester.pumpWidget(
    TestForuiApp(
      locale: const Locale('en'),
      home: SingleChildScrollView(
        child: DrugAdverseReactionsSection(
          drugbankId: 'DB01050',
          l10n: l10n,
          reportOverride: report,
        ),
      ),
    ),
  );
  await tester.pumpAndSettle();
}

void main() {
  late AppLocalizations l10n;

  setUpAll(() async {
    l10n = await AppLocalizations.delegate.load(const Locale('en'));
  });

  group('DrugAdverseReactionsSection', () {
    testWidgets(
      'renders a quiet no-data line when the drug has no RxCUI bridge',
      (tester) async {
        await _pump(tester, report: const AsyncData(null), l10n: l10n);

        expect(find.text(l10n.medicineReactionNoBridge), findsOneWidget);
        // No retry: nothing failed, and retrying cannot create a bridge.
        expect(find.text(l10n.todayRetryAction), findsNothing);
      },
    );

    testWidgets('groups reactions by label section, AR first', (tester) async {
      await _pump(
        tester,
        report: AsyncData(
          _report([
            _reaction(name: 'Rash', confidence: 5.9),
            _reaction(name: 'Hepatotoxicity', section: 'BW', confidence: 5.5),
          ]),
        ),
        l10n: l10n,
      );

      // The AR bucket carries no label: the accordion header above it already
      // reads "Adverse Reactions". Only the distinguishing buckets are named.
      expect(find.text(l10n.medicineReactionSectionAr), findsNothing);
      expect(find.text(l10n.medicineReactionSectionBw), findsOneWidget);
      expect(find.text('Rash'), findsOneWidget);
      expect(find.text('Hepatotoxicity'), findsOneWidget);
    });

    testWidgets('shows the confidence band, never the raw score', (
      tester,
    ) async {
      await _pump(
        tester,
        report: AsyncData(
          _report([
            _reaction(name: 'Common', confidence: 5.9),
            _reaction(name: 'Middle', confidence: 4.9),
            _reaction(name: 'Rare', confidence: 3.5),
          ]),
        ),
        l10n: l10n,
      );

      expect(find.text(l10n.medicineReactionConfidenceHigh), findsOneWidget);
      expect(find.text(l10n.medicineReactionConfidenceMedium), findsOneWidget);
      expect(find.text(l10n.medicineReactionConfidenceLow), findsOneWidget);
      // The log-odds value itself must not leak into the UI.
      expect(find.textContaining('5.9'), findsNothing);
    });

    testWidgets('an unscored reaction gets no badge rather than a "low" one', (
      tester,
    ) async {
      await _pump(
        tester,
        report: AsyncData(_report([_reaction(name: 'Unscored')])),
        l10n: l10n,
      );

      expect(find.text('Unscored'), findsOneWidget);
      expect(find.text(l10n.medicineReactionConfidenceLow), findsNothing);
    });

    testWidgets('states the label-stated caveat once', (tester) async {
      await _pump(
        tester,
        report: AsyncData(
          _report([
            _reaction(name: 'A', confidence: 5.9),
            _reaction(name: 'B', confidence: 5.9),
          ]),
        ),
        l10n: l10n,
      );

      expect(find.text(l10n.medicineReactionFootNote), findsOneWidget);
    });

    testWidgets('caps the preview and offers to show the rest', (tester) async {
      final reactions = [
        for (var index = 0; index < 12; index += 1)
          _reaction(name: 'Reaction $index', confidence: 5.9),
      ];

      await _pump(tester, report: AsyncData(_report(reactions)), l10n: l10n);

      expect(find.text('Reaction 0'), findsOneWidget);
      expect(find.text('Reaction 11'), findsNothing);

      await tester.tap(find.text(l10n.medicineReactionShowAll));
      await tester.pumpAndSettle();

      expect(find.text('Reaction 11'), findsOneWidget);
    });

    testWidgets('an error state offers retry', (tester) async {
      await _pump(
        tester,
        report: AsyncError<AdverseReactionReport?>(
          StateError('boom'),
          StackTrace.empty,
        ),
        l10n: l10n,
      );

      expect(find.text(l10n.medicineReactionError), findsOneWidget);
      expect(find.text(l10n.todayRetryAction), findsOneWidget);
    });
  });
}
