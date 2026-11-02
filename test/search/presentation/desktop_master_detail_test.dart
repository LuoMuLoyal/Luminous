import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:luminous/app/composition/health_context/health_context.dart';
import 'package:luminous/features/health_context/domain/entities/snapshot.dart';
import 'package:luminous/features/medicine/domain/entities/medicine_detail.dart'
    hide MedicineDetailTarget;
import 'package:luminous/features/medicine/presentation/providers/medicine_detail.dart';
import 'package:luminous/features/search/domain/entities/entities.dart';
import 'package:luminous/features/search/presentation/providers/medicine_search.dart';
import 'package:luminous/features/search/presentation/widgets/views/content.dart';
import 'package:luminous/features/shell/presentation/detail_pane_state.dart';

import '../../helpers/kv_test_store.dart';
import '../../helpers/test_forui_app.dart';

/// 桌面搜索的主从布局：右栏渲染的是**药品详情页本身**，不是精简预览卡。
void main() {
  setUp(KvTestStore.install);

  final result = MedicineSearchResult(
    id: _detail.id,
    source: MedicineSearchSource.cn,
    name: _detail.name,
    subtitle: _detail.subtitle ?? '',
    summary: '解热镇痛类非甾体抗炎药，用于退热与镇痛。',
    tags: const ['解热镇痛'],
    matchType: MedicineSearchMatchType.name,
  );

  testWidgets('desktop layout opens the shared detail pane for the selected '
      'result', (tester) async {
    tester.view.devicePixelRatio = 1;
    tester.view.physicalSize = const Size(1280, 800);
    addTearDown(tester.view.reset);

    final container = await _pumpSearch(
      tester,
      state: MedicineSearchState(
        query: '布洛芬',
        submittedQuery: '布洛芬',
        results: [result],
        selectedResultId: result.id,
      ),
    );

    expect(
      container.read(detailPaneProvider),
      isA<MedicineDetailTarget>()
          .having((target) => target.source, 'source', 'cn')
          .having((target) => target.id, 'id', _detail.id),
    );

    // 面板头部 + 详情页正文（药名与适应症）都在右栏里。
    expect(find.text('详情'), findsOneWidget);
    expect(find.text(_detail.name), findsWidgets);
    expect(find.text('用于缓解轻至中度疼痛'), findsOneWidget);
  });

  testWidgets('no selected result keeps the pane closed', (tester) async {
    tester.view.devicePixelRatio = 1;
    tester.view.physicalSize = const Size(1280, 800);
    addTearDown(tester.view.reset);

    final container = await _pumpSearch(
      tester,
      state: const MedicineSearchState(),
    );

    expect(container.read(detailPaneProvider), isNull);
    expect(find.text('详情'), findsNothing);
  });
}

Future<ProviderContainer> _pumpSearch(
  WidgetTester tester, {
  required MedicineSearchState state,
}) async {
  final container = ProviderContainer(
    overrides: [
      medicineDetailProvider(
        _detail.source,
        _detail.id,
      ).overrideWith((ref) async => _detail),
      healthContextSnapshotProvider.overrideWith((ref) async => _emptySnapshot),
    ],
  );
  addTearDown(container.dispose);
  await container.read(healthContextSnapshotProvider.future);

  await tester.pumpWidget(
    UncontrolledProviderScope(
      container: container,
      child: TestForuiApp(
        home: Builder(
          builder: (context) => MedicineSearchView(
            state: state,
            addedMedicineIds: const {},
            onQueryChanged: (_) {},
            onQuerySubmitted: (_) {},
            onSourceSwitched: (_) {},
            onResultSelected: (_) {},
            onRetry: () {},
          ),
        ),
      ),
    ),
  );
  await tester.pump();
  await tester.pump(const Duration(milliseconds: 100));
  return container;
}

const _detail = MedicineDetail(
  id: 'cn-ibuprofen',
  source: 'cn',
  name: '布洛芬片',
  subtitle: '0.2g*12片',
  kind: 'cnProduct',
  indications: '用于缓解轻至中度疼痛',
);

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
