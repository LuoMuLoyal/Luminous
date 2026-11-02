import 'package:flutter_test/flutter_test.dart';
import 'package:lucent_api/lucent_api.dart';
import 'package:luminous/features/medicine/data/mappers/medicine_relations.dart';
import 'package:luminous/features/medicine/domain/entities/relations.dart';

/// 信封映射：`status` 与数据键的关系。
///
/// 这组断言守的是用药场景最危险的一条静默降级：把「查不了」渲染成「没有」。
/// 后端在失败态下**不写数据键**，映射结果因此必须是 `items == null`，
/// 而不是 `[]`（空数组 = 图上确实没有）。
void main() {
  const mapper = MedicineRelationsMapper();

  MedicineMechanismPathsResponse envelope(
    String status, {
    List<dynamic>? paths,
  }) {
    return MedicineMechanismPathsResponse(
      status: switch (status) {
        'ok' => MedicineMechanismPathsResponseStatusEnum.ok,
        'notConfigured' =>
          MedicineMechanismPathsResponseStatusEnum.notConfigured,
        'unavailable' => MedicineMechanismPathsResponseStatusEnum.unavailable,
        'timeout' => MedicineMechanismPathsResponseStatusEnum.timeout,
        _ => MedicineMechanismPathsResponseStatusEnum.unknownDefaultOpenApi,
      },
      paths: paths?.cast<MedicineMechanismPathsResponsePaths>(),
    );
  }

  group('graph envelope', () {
    test('ok + 有数据 → 可回答且有内容', () {
      final result = mapper.mechanismPaths(
        envelope(
          'ok',
          paths: [
            MedicineMechanismPathsResponsePaths(
              enzymeGene: 'CYP2C9',
              enzymeName: 'Cytochrome P450 2C9',
              otherDrugId: 'DB00682',
              otherDrugName: 'Warfarin',
              relation: 'INHIBITS',
            ),
          ],
        ),
      );

      expect(result.status, GraphQueryStatus.ok);
      expect(result.isAnswerable, isTrue);
      expect(result.safeItems.single.enzymeGene, 'CYP2C9');
      expect(result.isEmptyAnswer, isFalse);
    });

    test('ok + 空数组 → 真的没有（不是查不了）', () {
      final result = mapper.mechanismPaths(envelope('ok', paths: []));

      expect(result.isAnswerable, isTrue);
      expect(result.isEmptyAnswer, isTrue);
      expect(result.safeItems, isEmpty);
    });

    test('失败态没有数据键 → items 为 null，不可回答', () {
      // 三个降级态都必须落在这里；任何一处塌成 [] 都会让界面把知识缺口
      // 显示成「无风险」。
      for (final status in ['notConfigured', 'unavailable', 'timeout']) {
        final result = mapper.mechanismPaths(envelope(status));

        expect(result.status.name, status, reason: status);
        expect(result.items, isNull, reason: status);
        expect(result.isAnswerable, isFalse, reason: status);
        expect(result.isEmptyAnswer, isFalse, reason: status);
      }
    });

    test('未知 status 按「无法回答」处理，不按 ok', () {
      // 服务端将来新增状态时，客户端必须降级而不是宣称安全。
      final result = mapper.mechanismPaths(
        envelope('unknown_default_open_api'),
      );

      expect(result.status, GraphQueryStatus.unknown);
      expect(result.isAnswerable, isFalse);
    });
  });

  group('medication overview', () {
    MedicationOverviewResponse overview({
      int total = 2,
      int resolvable = 2,
      List<MedicationOverviewResponseDuplicates>? duplicates,
      List<MedicationOverviewResponseSourceOverlaps>? overlaps,
    }) {
      return MedicationOverviewResponse(
        totalMedicines: total,
        resolvableMedicines: resolvable,
        duplicates: duplicates ?? const [],
        sourceOverlaps: overlaps ?? const [],
      );
    }

    test('重复成分组映射，含 high/medium', () {
      final mapped = mapper.medicationOverview(
        overview(
          duplicates: [
            MedicationOverviewResponseDuplicates(
              ingredientKey: 'acetaminophen',
              entryIds: const ['a', 'b'],
              displayNames: const ['复方感冒灵颗粒', '泰诺林'],
              severity: MedicationOverviewResponseDuplicatesSeverityEnum.high,
            ),
          ],
        ),
      );

      expect(mapped.duplicates.single.severity, DuplicateSeverity.high);
      expect(mapped.duplicates.single.displayNames, hasLength(2));
    });

    test('unattributed 来源被识别，而不是当作缺失', () {
      final mapped = mapper.medicationOverview(
        overview(
          overlaps: [
            MedicationOverviewResponseSourceOverlaps(
              source_: 'unattributed',
              medicineCount: 2,
              displayNames: const ['A', 'B'],
            ),
          ],
        ),
      );

      expect(mapped.sourceOverlaps.single.isUnattributed, isTrue);
    });

    test('空概览是答案，不是错误', () {
      final mapped = mapper.medicationOverview(
        overview(total: 0, resolvable: 0),
      );

      expect(mapped.totalMedicines, 0);
      expect(mapped.duplicates, isEmpty);
    });
  });
}
