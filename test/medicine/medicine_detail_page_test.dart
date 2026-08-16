import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:forui/forui.dart';
import 'package:luminous/core/auth/session_provider.dart';
import 'package:luminous/core/widgets/common/skeleton.dart';
import 'package:luminous/features/health_context/data/providers/health_context.dart';
import 'package:luminous/features/health_context/domain/entities/snapshot.dart';
import 'package:luminous/features/health_context/domain/entities/write_inputs.dart';
import 'package:luminous/features/health_context/domain/repositories/snapshot.dart';
import 'package:luminous/features/medicine/domain/entities/medicine_detail.dart';
import 'package:luminous/features/medicine/presentation/pages/medicine_detail.dart';
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
  description: 'A nonsteroidal anti-inflammatory drug.',
  halfLife: '2 hours',
  drugInteractions: [
    MedicineDetailInteraction(
      drugbankId: 'DB00795',
      description: 'May increase bleeding risk.',
    ),
  ],
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

    // Present sections render (indications is the first item, expanded).
    expect(find.text(l10n.medicineDetailSectionIndications), findsOneWidget);
    expect(find.text('用于缓解轻至中度疼痛'), findsOneWidget);
    expect(
      find.text(l10n.medicineDetailSectionContraindications),
      findsOneWidget,
    );
    expect(find.text('对本品过敏者禁用'), findsOneWidget);

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

    // Description is the first section (expanded).
    expect(find.text(l10n.medicineDetailSectionDescription), findsOneWidget);
    expect(find.text('A nonsteroidal anti-inflammatory drug.'), findsOneWidget);
    expect(find.text(l10n.medicineDetailSectionHalfLife), findsOneWidget);
    expect(find.text('2 hours'), findsOneWidget);
    expect(
      find.text(l10n.medicineDetailSectionDrugInteractions),
      findsOneWidget,
    );
    expect(find.textContaining('DB00795'), findsOneWidget);
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

class _FakeHealthContextRepository implements HealthContextRepository {
  CurrentMedicineWriteInput? createdCurrentMedicine;

  @override
  Future<HealthContextSnapshot> fetchHealthContext() async => _emptySnapshot;

  @override
  Future<HealthContextSnapshot> updateProfile(
    HealthProfileUpdateInput input,
  ) async => _emptySnapshot;

  @override
  Future<HealthContextSnapshot> createAllergy(
    HealthAllergyWriteInput input,
  ) async => _emptySnapshot;

  @override
  Future<HealthContextSnapshot> updateAllergy(
    String id,
    HealthAllergyUpdateInput input,
  ) async => _emptySnapshot;

  @override
  Future<HealthContextSnapshot> deleteAllergy(String id) async =>
      _emptySnapshot;

  @override
  Future<HealthContextSnapshot> createCondition(
    HealthConditionWriteInput input,
  ) async => _emptySnapshot;

  @override
  Future<HealthContextSnapshot> updateCondition(
    String id,
    HealthConditionUpdateInput input,
  ) async => _emptySnapshot;

  @override
  Future<HealthContextSnapshot> deleteCondition(String id) async =>
      _emptySnapshot;

  @override
  Future<HealthContextSnapshot> createCurrentMedicine(
    CurrentMedicineWriteInput input,
  ) async {
    createdCurrentMedicine = input;
    return _snapshotWithMedicine(
      sourceRefId: input.sourceRefId,
      source: input.source.value,
      displayName: input.displayName,
    );
  }

  @override
  Future<HealthContextSnapshot> updateCurrentMedicine(
    String id,
    CurrentMedicineUpdateInput input,
  ) async => _emptySnapshot;

  @override
  Future<HealthContextSnapshot> deleteCurrentMedicine(String id) async =>
      _emptySnapshot;
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
    bloodType: null,
    locale: null,
    timezone: null,
    unitSystem: null,
    onboardingCompletedAt: null,
    emergencyContactName: null,
    emergencyContactPhone: null,
    extras: {},
  ),
  allergies: [],
  conditions: [],
  currentMedicines: [],
);
