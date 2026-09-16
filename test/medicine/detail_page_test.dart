import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:forui/forui.dart';
import 'package:fpdart/fpdart.dart';
import 'package:luminous/core/auth/session_provider.dart';
import 'package:luminous/core/errors/lucent_failure.dart';
import 'package:luminous/core/widgets/common/feedback/skeleton.dart';
import 'package:luminous/features/health_context/data/providers/health_context.dart';
import 'package:luminous/features/health_context/domain/entities/snapshot.dart';
import 'package:luminous/features/health_context/domain/entities/write_inputs.dart';
import 'package:luminous/features/health_context/domain/repositories/snapshot.dart';
import 'package:luminous/features/medicine/domain/entities/medicine_detail.dart';
import 'package:luminous/features/medicine/presentation/pages/detail.dart';
import 'package:luminous/features/medicine/presentation/providers/medicine_detail.dart';
import 'package:luminous/l10n/app_localizations.dart';

import '../auth/test_helpers.dart';
import '../helpers/test_forui_app.dart';

const _cnDetail = MedicineDetail(
  id: 'cn_1',
  source: 'cn',
  name: '布洛芬片',
  subtitle: '0.2g*12片',
  kind: 'cnProduct',
  approvalNumber: '国药准字 H20013062',
  manufacturer: '石药集团欧意药业有限公司',
  indications: '用于缓解轻至中度疼痛',
  contraindications: '对本品过敏者禁用',
  // storage intentionally left null to verify empty sections are hidden.
);

const _drugbankDetail = MedicineDetail(
  id: 'DB01050',
  source: 'drugbank',
  name: 'Ibuprofen',
  subtitle: 'Small molecule',
  kind: 'drugbank',
  indication: 'For mild pain.',
  description: 'A nonsteroidal anti-inflammatory drug.',
  halfLife: '2 hours',
  drugInteractions: [
    MedicineDetailInteraction(
      drugbankId: 'DB00795',
      description: 'May increase bleeding risk.',
    ),
  ],
);

/// Imatinib-like shape: a well-studied target with more PDB entries than the
/// preview shows.
const _targetDetail = MedicineDetail(
  id: 'DB00619',
  source: 'drugbank',
  name: 'Imatinib',
  kind: 'drugbank',
  targets: [
    MedicineDetailTarget(
      name: 'Tyrosine-protein kinase ABL1',
      geneName: 'ABL1',
      uniprotId: 'P00519',
      species: 'Humans',
      pdbIds: ['1ABC', '2DEF', '3GHI', '4JKL', '5MNO', '6FGH', '7XYZ', '8UVW'],
      actions: ['inhibitor'],
      relationKind: 'target',
    ),
  ],
);

/// Advertises sequences without carrying any: the counts are all the detail
/// response contains.
const _sequenceSummaryDetail = MedicineDetail(
  id: 'DB00002',
  source: 'drugbank',
  name: 'Cetuximab',
  kind: 'drugbank',
  sequenceSummary: MedicineDetailSequenceSummary(
    drugChainCount: 2,
    targetSequenceCount: 56,
  ),
);

const _longToxicityDetail = MedicineDetail(
  id: 'DB00619',
  source: 'drugbank',
  name: 'Imatinib',
  kind: 'drugbank',
  toxicity:
      'LD50 in rats is 500 mg/kg. '
      'Severe adverse reactions include hepatotoxicity, fluid retention, and '
      'cytopenias. Monitor liver function before and during treatment, and '
      'reduce the dose when transaminases rise above five times the upper '
      'limit of normal. Patients with severe congestive heart failure should '
      'be evaluated before starting therapy, and weight gain should be '
      'investigated promptly. Pleural effusion and pulmonary edema have been '
      'reported, and pericardial effusion requires dose interruption until '
      'resolution. Growth retardation has been observed in paediatric '
      'patients on prolonged therapy, so height should be monitored.',
);

const _emptyCnDetail = MedicineDetail(
  id: 'cn_empty',
  source: 'cn',
  name: '空药品',
  kind: 'cnProduct',
);

void main() {
  late AppLocalizations l10n;

  setUpAll(() async {
    l10n = await AppLocalizations.delegate.load(const Locale('zh'));
  });

  testWidgets('renders CN detail with header, notice and visible sections', (
    tester,
  ) async {
    await _pumpDetailPage(tester, source: 'cn', id: 'cn_1', detail: _cnDetail);

    // Header name + CN meta info.
    expect(find.text('布洛芬片'), findsOneWidget);
    expect(find.text(l10n.medicineDetailApprovalNumber), findsOneWidget);
    expect(find.text('国药准字 H20013062'), findsOneWidget);
    expect(find.text(l10n.medicineDetailManufacturer), findsOneWidget);
    expect(find.text('石药集团欧意药业有限公司'), findsOneWidget);

    // Reference notice.
    expect(find.text(l10n.medicineReferenceNoticeTitle), findsOneWidget);

    // Indications is the highest-frequency field: it renders and is expanded
    // by default. Contraindications is safety-tier, so it renders collapsed.
    expect(find.text(l10n.medicineDetailSectionIndications), findsOneWidget);
    expect(_revealOf(tester, '用于缓解轻至中度疼痛'), 1);
    expect(
      find.text(l10n.medicineDetailSectionContraindications),
      findsOneWidget,
    );
    expect(_revealOf(tester, '对本品过敏者禁用'), 0);

    // Empty field sections are not rendered at all.
    expect(find.text(l10n.medicineDetailSectionStorage), findsNothing);
  });

  testWidgets('renders DrugBank detail sections and interactions', (
    tester,
  ) async {
    await _pumpDetailPage(
      tester,
      source: 'drugbank',
      id: 'DB01050',
      detail: _drugbankDetail,
    );

    expect(find.text('Ibuprofen'), findsOneWidget);

    // Every populated section is reachable from its accordion header, whether
    // or not it starts expanded.
    expect(find.text(l10n.medicineDetailSectionDescription), findsOneWidget);
    expect(find.text(l10n.medicineDetailSectionHalfLife), findsOneWidget);
    expect(
      find.text(l10n.medicineDetailSectionDrugInteractions),
      findsOneWidget,
    );

    // The interaction count is surfaced in the header badge.
    expect(find.text('1'), findsWidgets);
  });

  testWidgets('shows error view with retry on load failure', (tester) async {
    await _pumpDetailPage(
      tester,
      source: 'cn',
      id: 'cn_1',
      error: Exception('boom'),
    );

    expect(find.text(l10n.medicineDetailErrorTitle), findsOneWidget);
    expect(find.text(l10n.medicineDetailErrorDescription), findsOneWidget);
    expect(find.text(l10n.todayRetryAction), findsOneWidget);
  });

  testWidgets('shows disabled already-added state', (tester) async {
    await _pumpDetailPage(
      tester,
      source: 'cn',
      id: 'cn_1',
      detail: _cnDetail,
      snapshot: _snapshotWithMedicine(sourceRefId: 'cn_1', source: 'cn'),
    );

    expect(find.text(l10n.medicineSearchAlreadyAddedLabel), findsOneWidget);
    final button = tester.widget<FButton>(
      find.ancestor(
        of: find.text(l10n.medicineSearchAlreadyAddedLabel),
        matching: find.byType(FButton),
      ),
    );
    expect(button.onPress, isNull);
  });

  testWidgets(
    'shows add-to-box action when matching medicine is soft-deleted',
    (tester) async {
      await _pumpDetailPage(
        tester,
        source: 'cn',
        id: 'cn_1',
        detail: _cnDetail,
        snapshot: _snapshotWithMedicine(
          sourceRefId: 'cn_1',
          source: 'cn',
          isCurrent: false,
        ),
      );

      expect(find.text(l10n.medicineSearchAddToBoxAction), findsOneWidget);
      expect(find.text(l10n.medicineSearchAlreadyAddedLabel), findsNothing);
    },
  );

  testWidgets(
    'opens only indications by default and keeps the rest collapsed',
    (tester) async {
      await _pumpDetailPage(
        tester,
        source: 'drugbank',
        id: 'DB01050',
        detail: _drugbankDetail,
      );

      // Indications is the highest-frequency field, so it is the one section
      // whose body is visible without interaction.
      expect(find.text('For mild pain.'), findsOneWidget);

      // Description and half-life start collapsed. FAccordion keeps collapsed
      // children in the tree and clips them via FCollapsible, so assert on that
      // widget's reveal value rather than expecting the text to be absent.
      for (final body in [
        'A nonsteroidal anti-inflammatory drug.',
        '2 hours',
      ]) {
        expect(
          _revealOf(tester, body),
          0,
          reason: '$body should start collapsed',
        );
      }
    },
  );

  testWidgets('expands a collapsed section on tap', (tester) async {
    await _pumpDetailPage(
      tester,
      source: 'drugbank',
      id: 'DB01050',
      detail: _drugbankDetail,
    );

    expect(_revealOf(tester, '2 hours'), 0);

    await _expandSection(tester, l10n.medicineDetailSectionHalfLife);

    expect(_revealOf(tester, '2 hours'), 1);
  });

  testWidgets('renders targets with actions and bounds the PDB preview', (
    tester,
  ) async {
    await _pumpDetailPage(
      tester,
      source: 'drugbank',
      id: 'DB00619',
      detail: _targetDetail,
    );

    await _expandSection(tester, l10n.medicineDetailSectionTargets);

    expect(find.text('Tyrosine-protein kinase ABL1'), findsOneWidget);
    expect(find.text('inhibitor'), findsOneWidget);
    expect(find.textContaining('ABL1'), findsWidgets);
    expect(find.textContaining('P00519'), findsWidgets);

    // Only the first 6 PDB ids show; the rest collapse behind a "+N more"
    // affordance, which is what keeps an 80-structure target readable.
    expect(find.text('1ABC'), findsOneWidget);
    expect(find.text('6FGH'), findsOneWidget);
    expect(find.text('7XYZ'), findsNothing);
    expect(find.text(l10n.medicineDetailTargetPdbMore(2)), findsOneWidget);

    await tester.tap(find.text(l10n.medicineDetailTargetPdbMore(2)));
    await tester.pumpAndSettle();

    expect(find.text('7XYZ'), findsOneWidget);
  });

  testWidgets('clamps long prose behind an expand affordance', (tester) async {
    await _pumpDetailPage(
      tester,
      source: 'drugbank',
      id: 'DB00619',
      detail: _longToxicityDetail,
    );

    await _expandSection(tester, l10n.medicineDetailSectionToxicity);

    expect(find.text(l10n.medicineDetailExpandLongText), findsOneWidget);

    await tester.tap(find.text(l10n.medicineDetailExpandLongText));
    await tester.pumpAndSettle();

    expect(find.text(l10n.medicineDetailCollapseLongText), findsOneWidget);
  });

  testWidgets('shows the sequence summary without fetching it', (tester) async {
    var fetchCount = 0;

    await _pumpDetailPage(
      tester,
      source: 'drugbank',
      id: 'DB00002',
      detail: _sequenceSummaryDetail,
      overrides: [
        medicineSequencesProvider('drugbank', 'DB00002').overrideWith((ref) {
          fetchCount += 1;
          return const MedicineSequences(id: 'DB00002', source: 'drugbank');
        }),
      ],
    );

    // The section advertises what it holds...
    expect(find.text(l10n.medicineDetailSectionSequences), findsOneWidget);
    expect(
      find.text(
        '${l10n.medicineDetailSequencesDrugChains(2)} · '
        '${l10n.medicineDetailSequencesTargets(56)}',
      ),
      findsOneWidget,
    );

    // ...but the accordion builds collapsed children, so a fetch here would
    // mean the 96 KB payload rides along with every page load.
    expect(fetchCount, 0);
  });

  testWidgets('fetches sequences only once the section is opened', (
    tester,
  ) async {
    var fetchCount = 0;

    await _pumpDetailPage(
      tester,
      source: 'drugbank',
      id: 'DB00002',
      detail: _sequenceSummaryDetail,
      overrides: [
        medicineSequencesProvider('drugbank', 'DB00002').overrideWith((ref) {
          fetchCount += 1;
          return const MedicineSequences(
            id: 'DB00002',
            source: 'drugbank',
            drug: [
              MedicineDrugSequence(
                description: 'heavy chain',
                length: 12,
                sequence: 'QVQLKQSGPGLV',
              ),
            ],
            targets: [
              MedicineTargetSequence(
                uniprotId: 'P00533',
                targetName: 'Epidermal growth factor receptor',
                dataset: 'protein_fasta',
                length: 12,
                sequence: 'MRPSGTAGAALL',
              ),
            ],
          );
        }),
      ],
    );

    expect(fetchCount, 0);

    await _expandSection(tester, l10n.medicineDetailSectionSequences);

    expect(fetchCount, 1);
    expect(find.text('heavy chain'), findsOneWidget);
    expect(find.text('Epidermal growth factor receptor'), findsOneWidget);
    // Protein and coding sequence are labelled so the two readings of a gene
    // are not confused for one another.
    expect(
      find.textContaining(l10n.medicineDetailSequenceProtein),
      findsOneWidget,
    );
    expect(find.textContaining('P00533'), findsOneWidget);
  });

  testWidgets('shows skeleton while detail is loading', (tester) async {
    final completer = Completer<MedicineDetail>();
    await _pumpDetailPage(
      tester,
      source: 'cn',
      id: 'cn_1',
      detailFuture: completer.future,
      settle: false,
    );

    expect(find.byType(InlineSkeletonSection), findsOneWidget);
    expect(find.byType(InlineSkeletonBlock), findsNWidgets(4));

    completer.complete(_cnDetail);
    await tester.pumpAndSettle();
  });

  testWidgets('shows unknown-source view for unsupported source', (
    tester,
  ) async {
    await _pumpDetailPage(tester, source: 'foo', id: 'cn_1', detail: _cnDetail);

    expect(find.text(l10n.medicineDetailUnknownSourceTitle), findsOneWidget);
  });

  testWidgets('shows no-content view when all detail fields are empty', (
    tester,
  ) async {
    await _pumpDetailPage(
      tester,
      source: 'cn',
      id: 'cn_empty',
      detail: _emptyCnDetail,
    );

    expect(find.text(l10n.medicineDetailNoContentTitle), findsOneWidget);
  });

  testWidgets('add to drugbox writes current medicine and shows toast', (
    tester,
  ) async {
    final fakeRepo = _FakeHealthContextRepository();

    await _pumpDetailPage(
      tester,
      source: 'cn',
      id: 'cn_1',
      detail: _cnDetail,
      showToaster: true,
      overrides: [
        authSessionProvider.overrideWith(SignedInAuthSessionNotifier.new),
        healthContextRepositoryProvider.overrideWithValue(fakeRepo),
      ],
    );

    await tester.tap(find.text(l10n.medicineSearchAddToBoxAction));
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 300));

    final input = fakeRepo.createdCurrentMedicine;
    expect(input, isNotNull);
    expect(input!.source, HealthMedicineSource.cn);
    expect(input.sourceRefId, 'cn_1');
    expect(input.displayName, '布洛芬片');

    expect(find.text(l10n.medicineSearchAddedToBoxToast), findsOneWidget);

    // Drain the toast auto-dismiss timer.
    await tester.pump(const Duration(milliseconds: 1800));
    await tester.pumpAndSettle();
  });
}

Future<void> _pumpDetailPage(
  WidgetTester tester, {
  required String source,
  required String id,
  MedicineDetail? detail,
  Object? error,
  HealthContextSnapshot? snapshot,
  List overrides = const [],
  bool showToaster = false,
  Future<MedicineDetail>? detailFuture,
  bool settle = true,
}) async {
  await tester.pumpWidget(
    ProviderScope(
      overrides: [
        medicineDetailProvider(source, id).overrideWith(
          (ref) =>
              detailFuture ??
              () async {
                if (error != null) throw error;
                return detail!;
              }(),
        ),
        healthContextSnapshotProvider.overrideWith(
          (ref) async => snapshot ?? _emptySnapshot,
        ),
        ...overrides,
      ],
      child: TestForuiApp(
        showToaster: showToaster,
        home: MedicineDetailPage(source: source, id: id),
      ),
    ),
  );
  if (settle) {
    await tester.pumpAndSettle();
  } else {
    await tester.pump();
  }
}

/// The reveal value of the accordion body containing [text]: 0 while the
/// section is collapsed, 1 once it is expanded.
double _revealOf(WidgetTester tester, String text) {
  return tester
      .widget<FCollapsible>(
        find
            .ancestor(of: find.text(text), matching: find.byType(FCollapsible))
            .first,
      )
      .value;
}

/// Opens an accordion section by its header label.
///
/// The page scrolls, so a lower section header can start below the fold and a
/// bare `tap` would miss it.
Future<void> _expandSection(WidgetTester tester, String label) async {
  final header = find.text(label);
  await tester.ensureVisible(header);
  await tester.pumpAndSettle();
  await tester.tap(header);
  await tester.pumpAndSettle();
}

class _FakeHealthContextRepository implements HealthContextRepository {
  CurrentMedicineWriteInput? createdCurrentMedicine;

  @override
  TaskEither<LucentFailure, HealthContextSnapshot> fetchHealthContext() =>
      TaskEither.right(_emptySnapshot);

  @override
  TaskEither<LucentFailure, HealthContextSnapshot> updateProfile(
    HealthProfileUpdateInput input,
  ) => TaskEither.right(_emptySnapshot);

  @override
  TaskEither<LucentFailure, HealthContextSnapshot> createAllergy(
    HealthAllergyWriteInput input,
  ) => TaskEither.right(_emptySnapshot);

  @override
  TaskEither<LucentFailure, HealthContextSnapshot> updateAllergy(
    String id,
    HealthAllergyUpdateInput input,
  ) => TaskEither.right(_emptySnapshot);

  @override
  TaskEither<LucentFailure, HealthContextSnapshot> deleteAllergy(String id) =>
      TaskEither.right(_emptySnapshot);

  @override
  TaskEither<LucentFailure, HealthContextSnapshot> createCondition(
    HealthConditionWriteInput input,
  ) => TaskEither.right(_emptySnapshot);

  @override
  TaskEither<LucentFailure, HealthContextSnapshot> updateCondition(
    String id,
    HealthConditionUpdateInput input,
  ) => TaskEither.right(_emptySnapshot);

  @override
  TaskEither<LucentFailure, HealthContextSnapshot> deleteCondition(String id) =>
      TaskEither.right(_emptySnapshot);

  @override
  TaskEither<LucentFailure, HealthContextSnapshot> createCurrentMedicine(
    CurrentMedicineWriteInput input,
  ) {
    createdCurrentMedicine = input;
    return TaskEither.right(
      _snapshotWithMedicine(
        sourceRefId: input.sourceRefId,
        source: input.source.value,
        displayName: input.displayName,
      ),
    );
  }

  @override
  TaskEither<LucentFailure, HealthContextSnapshot> updateCurrentMedicine(
    String id,
    CurrentMedicineUpdateInput input,
  ) => TaskEither.right(_emptySnapshot);

  @override
  TaskEither<LucentFailure, HealthContextSnapshot> deleteCurrentMedicine(
    String id,
  ) => TaskEither.right(_emptySnapshot);
}

HealthContextSnapshot _snapshotWithMedicine({
  required String? sourceRefId,
  required String source,
  String displayName = '布洛芬片',
  bool isCurrent = true,
}) {
  return HealthContextSnapshot(
    summary: _emptySnapshot.summary,
    profile: _emptySnapshot.profile,
    allergies: _emptySnapshot.allergies,
    conditions: _emptySnapshot.conditions,
    currentMedicines: [
      CurrentMedicineItem(
        id: 'new-med-1',
        source: source,
        sourceRefId: sourceRefId,
        displayName: displayName,
        strengthText: null,
        doseText: null,
        route: null,
        startedAt: null,
        endedAt: null,
        isCurrent: isCurrent,
        note: null,
        createdAt: '2026-08-16T00:00:00.000Z',
        updatedAt: '2026-08-16T00:00:00.000Z',
      ),
    ],
  );
}

const _emptySnapshot = HealthContextSnapshot(
  summary: HealthSummary(
    age: null,
    onboardingCompleted: false,
    activeAllergyCount: 0,
    conditionCount: 0,
    currentMedicineCount: 0,
    missingCoreProfileFields: [],
  ),
  profile: HealthProfile(
    birthDate: null,
    sexAtBirth: null,
    heightCm: null,
    weightKg: null,
    activityLevel: null,
    dietaryPreferences: null,
    locale: null,
    timezone: null,
    unitSystem: null,
    onboardingCompletedAt: null,
    extras: {},
  ),
  allergies: [],
  conditions: [],
  currentMedicines: [],
);
