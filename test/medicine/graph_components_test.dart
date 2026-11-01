import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_riverpod/misc.dart' show Override;
import 'package:flutter_test/flutter_test.dart';
import 'package:luminous/app/composition/components/registry.dart';
import 'package:luminous/features/medicine/domain/entities/relations.dart';
import 'package:luminous/features/medicine/domain/services/graph_drug_set.dart';
import 'package:luminous/features/medicine/presentation/components/catalog.dart';
import 'package:luminous/features/medicine/presentation/providers/relations/graph.dart';
import 'package:luminous/features/medicine/presentation/widgets/sections/graph/drug_set_sections.dart';
import 'package:luminous/l10n/app_localizations.dart';

import '../helpers/test_forui_app.dart';

/// 关系图组件的**降级契约**。
///
/// 守的是计划 §A5-1 与 §2.5 的红线：图查询失败必须渲染成「暂时无法给出机理分析」，
/// **不得**渲染成「没有相互作用」，也不得整块消失。
void main() {
  Widget wrap(Widget child, {required List<Override> overrides}) {
    return ProviderScope(
      overrides: overrides,
      child: TestForuiApp(home: Scaffold(body: child)),
    );
  }

  testWidgets('图不可用时显式否定「没有相互作用」', (tester) async {
    // 整个 A5-1 最重要的一条断言：知识缺口不能被渲染成安全结论。
    await tester.pumpWidget(
      wrap(
        MechanismPathsSection(componentId: medicineMechanismPathsId.value),
        overrides: [
          graphDrugSetProvider.overrideWith(
            (ref) async => const GraphDrugSet(
              drugbankIds: ['DB00682', 'DB00004'],
              totalMedicines: 2,
            ),
          ),
          graphMechanismPathsProvider.overrideWith(
            (ref, key) async => const GraphQueryResult<MechanismPath>(
              status: GraphQueryStatus.unavailable,
            ),
          ),
        ],
      ),
    );
    await tester.pumpAndSettle();

    final l10n = await AppLocalizations.delegate.load(const Locale('zh'));
    expect(find.text(l10n.medicineGraphUnavailable), findsOneWidget);
    // 关键：明确写出「这不是没有相互作用」。
    expect(find.text(l10n.medicineGraphUnavailableBody), findsOneWidget);
    expect(find.byKey(const Key('medicine-graph-unavailable')), findsOneWidget);
    // 不得出现「没有发现相关关系」——那会把知识缺口说成安全。
    expect(find.text(l10n.medicineGraphEmpty), findsNothing);
  });

  testWidgets('未接入知识库时措辞与其它失败态不同', (tester) async {
    // notConfigured 要「去配」，unavailable 要「等/重试」，不能同一句话。
    await tester.pumpWidget(
      wrap(
        MechanismPathsSection(componentId: medicineMechanismPathsId.value),
        overrides: [
          graphDrugSetProvider.overrideWith(
            (ref) async => const GraphDrugSet(
              drugbankIds: ['DB00682', 'DB00004'],
              totalMedicines: 2,
            ),
          ),
          graphMechanismPathsProvider.overrideWith(
            (ref, key) async => const GraphQueryResult<MechanismPath>(
              status: GraphQueryStatus.notConfigured,
            ),
          ),
        ],
      ),
    );
    await tester.pumpAndSettle();

    final l10n = await AppLocalizations.delegate.load(const Locale('zh'));
    expect(
      find.text(l10n.medicineGraphUnavailableNotConfiguredBody),
      findsOneWidget,
    );
    // 未配置时不给重试按钮：重试永远不会成功。
    expect(find.text(l10n.medicineGraphRetry), findsNothing);
  });

  testWidgets('查询成功但为空时用中性措辞，不用警告', (tester) async {
    await tester.pumpWidget(
      wrap(
        MechanismPathsSection(componentId: medicineMechanismPathsId.value),
        overrides: [
          graphDrugSetProvider.overrideWith(
            (ref) async => const GraphDrugSet(
              drugbankIds: ['DB00682', 'DB00004'],
              totalMedicines: 2,
            ),
          ),
          graphMechanismPathsProvider.overrideWith(
            (ref, key) async => const GraphQueryResult<MechanismPath>(
              status: GraphQueryStatus.ok,
              items: <MechanismPath>[],
            ),
          ),
        ],
      ),
    );
    await tester.pumpAndSettle();

    final l10n = await AppLocalizations.delegate.load(const Locale('zh'));
    expect(find.text(l10n.medicineGraphEmpty), findsOneWidget);
    // 「查不了」的卡片不能同时出现。
    expect(find.byKey(const Key('medicine-graph-unavailable')), findsNothing);
  });

  testWidgets('可分析药不足两个时说明需要至少两种药', (tester) async {
    await tester.pumpWidget(
      wrap(
        MechanismPathsSection(componentId: medicineMechanismPathsId.value),
        overrides: [
          graphDrugSetProvider.overrideWith(
            (ref) async =>
                const GraphDrugSet(drugbankIds: ['DB00682'], totalMedicines: 3),
          ),
        ],
      ),
    );
    await tester.pumpAndSettle();

    final l10n = await AppLocalizations.delegate.load(const Locale('zh'));
    expect(find.text(l10n.medicineGraphNeedsTwoDrugs), findsOneWidget);
  });

  testWidgets('有数据时渲染通路并显示覆盖度', (tester) async {
    await tester.pumpWidget(
      wrap(
        MechanismPathsSection(componentId: medicineMechanismPathsId.value),
        overrides: [
          graphDrugSetProvider.overrideWith(
            (ref) async => const GraphDrugSet(
              drugbankIds: ['DB00682', 'DB00004'],
              totalMedicines: 4,
            ),
          ),
          graphMechanismPathsProvider.overrideWith(
            (ref, key) async => const GraphQueryResult<MechanismPath>(
              status: GraphQueryStatus.ok,
              items: <MechanismPath>[
                MechanismPath(
                  enzymeGene: 'CYP2C9',
                  enzymeName: 'Cytochrome P450 2C9',
                  otherDrugId: 'DB00004',
                  otherDrugName: 'Fluconazole',
                  relation: 'INHIBITS',
                ),
              ],
            ),
          ),
        ],
      ),
    );
    await tester.pumpAndSettle();

    final l10n = await AppLocalizations.delegate.load(const Locale('zh'));
    expect(find.text('CYP2C9'), findsOneWidget);
    expect(find.text('Fluconazole'), findsOneWidget);
    expect(find.text(l10n.medicineGraphRelationInhibits), findsOneWidget);
    // 覆盖度：4 种药里只有 2 种参与分析，不能让用户误以为覆盖全部。
    expect(
      find.text(l10n.medicineGraphCoverageNoteWithRest(2, 4, 2)),
      findsOneWidget,
    );
  });

  test('十个关系图组件全部已注册，且都不在默认布局里', () {
    final registry = buildComponentRegistry();
    const ids = [
      medicineMedicationOverviewId,
      medicineMechanismPathsId,
      medicineSharedTargetsId,
      medicineCascadePathsId,
      medicineEnzymeDuelsId,
      medicineDrugActionsId,
      medicineTransportRoutesId,
      medicineSubstitutesId,
      medicineShortestRoutesId,
      medicineTargetDrugsId,
    ];

    for (final id in ids) {
      expect(registry.find(id), isNotNull, reason: '未注册：${id.value}');
    }

    // 进目录但**不进**默认布局：默认页与改造前一致，用户自行挂载。
    final defaultIds = medicineSurfaceDefinition.defaultLayout.placements
        .map((placement) => placement.id)
        .toSet();
    for (final id in ids) {
      expect(defaultIds, isNot(contains(id)), reason: '不该进默认布局：${id.value}');
    }
    expect(defaultIds.length, 4);
  });
}
