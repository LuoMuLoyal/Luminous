import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:forui/forui.dart';
import 'package:go_router/go_router.dart';
import 'package:luminous/core/config/pref_keys.dart';
import 'package:luminous/features/search/data/repositories/lucent.dart';
import 'package:luminous/features/search/domain/entities/entities.dart';
import 'package:luminous/features/search/domain/repositories/search.dart';
import 'package:luminous/features/search/presentation/pages/page.dart';
import 'package:luminous/features/search/presentation/widgets/sections/recent_searches.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../auth/test_helpers.dart';

void main() {
  testWidgets('renders persisted recent keywords on the empty-query state', (
    tester,
  ) async {
    SharedPreferences.setMockInitialValues({
      PrefKeys.medicineSearchRecentKeywords: ['布洛芬', '阿司匹林'],
    });
    await _pumpSearchApp(tester);

    await tester.pump();
    await tester.pump(const Duration(milliseconds: 400));

    expect(find.byType(RecentSearches), findsOneWidget);
    expect(find.text('最近搜索'), findsOneWidget);
    expect(find.text('布洛芬'), findsOneWidget);
    expect(find.text('阿司匹林'), findsOneWidget);
    expect(find.text('清空'), findsOneWidget);
  });

  testWidgets('hides the recent searches section when nothing is stored', (
    tester,
  ) async {
    SharedPreferences.setMockInitialValues({});
    await _pumpSearchApp(tester);

    await tester.pump();
    await tester.pump(const Duration(milliseconds: 400));

    expect(find.text('最近搜索'), findsNothing);
    expect(find.text('清空'), findsNothing);
  });

  testWidgets('tapping a recent keyword triggers a search', (tester) async {
    SharedPreferences.setMockInitialValues({
      PrefKeys.medicineSearchRecentKeywords: ['布洛芬'],
    });
    await _pumpSearchApp(tester);

    await tester.pump();
    await tester.pump(const Duration(milliseconds: 400));

    await tester.tap(find.text('布洛芬'));
    await tester.pump(const Duration(milliseconds: 500));

    // The keyword filled the query and the search ran.
    expect(find.text('[DEMO] 布洛芬片'), findsOneWidget);
    expect(find.text('最近搜索'), findsNothing);
  });

  testWidgets('tapping clear empties the section and the store', (
    tester,
  ) async {
    SharedPreferences.setMockInitialValues({
      PrefKeys.medicineSearchRecentKeywords: ['布洛芬', '阿司匹林'],
    });
    await _pumpSearchApp(tester);

    await tester.pump();
    await tester.pump(const Duration(milliseconds: 400));
    expect(find.text('清空'), findsOneWidget);

    await tester.tap(find.text('清空'));
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 100));

    // Section collapses back to shrink and storage is wiped.
    expect(find.text('最近搜索'), findsNothing);
    expect(find.text('清空'), findsNothing);
    final prefs = await SharedPreferences.getInstance();
    expect(prefs.getStringList(PrefKeys.medicineSearchRecentKeywords), isNull);
  });

  testWidgets('a successful search shows up in recent searches', (
    tester,
  ) async {
    SharedPreferences.setMockInitialValues({});
    await _pumpSearchApp(tester);

    await tester.pump();
    await tester.pump(const Duration(milliseconds: 400));
    expect(find.text('最近搜索'), findsNothing);

    await tester.enterText(find.byType(FTextField), '布洛芬');
    await tester.pump(const Duration(milliseconds: 500));
    expect(find.text('[DEMO] 布洛芬片'), findsOneWidget);

    // Clearing the query reveals the just-recorded keyword.
    await tester.enterText(find.byType(FTextField), '');
    await tester.pump(const Duration(milliseconds: 100));

    expect(find.text('最近搜索'), findsOneWidget);
    expect(find.text('布洛芬'), findsOneWidget);
  });

  testWidgets('desktop layout renders keywords and supports tapping', (
    tester,
  ) async {
    tester.view.physicalSize = const Size(1600, 1000);
    tester.view.devicePixelRatio = 1.0;
    addTearDown(tester.view.reset);

    SharedPreferences.setMockInitialValues({
      PrefKeys.medicineSearchRecentKeywords: ['布洛芬'],
    });
    await _pumpSearchApp(tester);

    await tester.pump();
    await tester.pump(const Duration(milliseconds: 400));

    expect(find.text('最近搜索'), findsOneWidget);
    expect(find.text('布洛芬'), findsOneWidget);

    await tester.tap(find.text('布洛芬'));
    await tester.pump(const Duration(milliseconds: 500));

    expect(find.text('[DEMO] 布洛芬片'), findsOneWidget);
  });
}

Future<void> _pumpSearchApp(WidgetTester tester) async {
  await tester.pumpWidget(
    ProviderScope(
      overrides: [
        medicineSearchRepositoryProvider.overrideWith(
          (ref) => const _MockMedicineSearchRepository(),
        ),
      ],
      child: TestAuthApp(router: _searchRouter()),
    ),
  );
}

GoRouter _searchRouter() {
  return GoRouter(
    initialLocation: '/medicine/search',
    routes: [
      GoRoute(
        path: '/medicine/search',
        builder: (context, state) => const FToaster(child: SearchPage()),
      ),
    ],
  );
}

/// Test-only mock with demo data prefixed to avoid confusion with real data.
class _MockMedicineSearchRepository implements MedicineSearchRepository {
  const _MockMedicineSearchRepository();

  @override
  Future<List<MedicineSearchResult>> search({
    required String query,
    required MedicineSearchSource source,
    int page = 1,
    int pageSize = 20,
  }) async {
    return const [
      MedicineSearchResult(
        id: '__mock_cn_ibuprofen__',
        source: MedicineSearchSource.cn,
        name: '[DEMO] 布洛芬片',
        subtitle: '[DEMO] 0.2g*12片 · 示例药业',
        summary: '[DEMO] 示例摘要，仅用于测试搜索界面。',
        tags: <String>['示例标签'],
        matchType: MedicineSearchMatchType.ingredient,
      ),
    ];
  }

  @override
  Future<MedicineSearchSafetyPreview?> fetchDetail(
    String id,
    MedicineSearchSource source,
  ) async {
    return const MedicineSearchSafetyPreview(
      title: '[DEMO] Ibuprofen',
      conditions: [],
      checklist: [],
    );
  }
}
