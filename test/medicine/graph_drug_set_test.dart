import 'package:flutter_test/flutter_test.dart';
import 'package:luminous/features/medicine/domain/services/graph_drug_set.dart';

/// 图查询入参派生。
///
/// 这是整个 A5-1 组件的输入边界：拿不到 DrugBank id 的药不参与药理分析。
/// 这些用例守两条：**不能把不可解析的药算进 covered**，**同一组药必须得到同一个
/// key**（否则挂到两个 surface 会重复打图库）。
void main() {
  GraphDrugEntry entry(String? ref, {bool current = true}) =>
      GraphDrugEntry(sourceRefId: ref, isCurrent: current);

  group('deriveGraphDrugSet', () {
    test('只取当前在册的药', () {
      final set = deriveGraphDrugSet([
        entry('DB00682'),
        entry('DB00004', current: false),
      ]);

      expect(set.drugbankIds, ['DB00682']);
      // 总数只算在册的：历史用药不构成当下的组合风险。
      expect(set.totalMedicines, 1);
    });

    test('无 sourceRefId 的药计入总数、不计入可分析数', () {
      final set = deriveGraphDrugSet([
        entry('DB00682'),
        entry(null),
        entry(''),
      ]);

      expect(set.drugbankIds, ['DB00682']);
      expect(set.totalMedicines, 3);
      expect(set.unresolvableCount, 2);
    });

    test('非 DrugBank 形态的编号被排除', () {
      final set = deriveGraphDrugSet([
        entry('DB00682'),
        // 中药/商品名来源的编号不是 DrugBank id。
        entry('cn-12345'),
        entry('ASPIRIN'),
        entry('DB123'), // 位数不足
        entry('DB0000123'), // 位数过多
      ]);

      expect(set.drugbankIds, ['DB00682']);
      expect(set.totalMedicines, 5);
      expect(set.unresolvableCount, 4);
    });

    test('重复的 DrugBank id 去重', () {
      final set = deriveGraphDrugSet([entry('DB00682'), entry('DB00682')]);

      expect(set.drugbankIds, ['DB00682']);
      // 去重不影响「在册药数」：用户确实录了两条。
      expect(set.totalMedicines, 2);
    });

    test('输出顺序稳定，与输入顺序无关', () {
      // 稳定 key 是「同一组件挂两个 surface 只发一次请求」的前提。
      final a = deriveGraphDrugSet([entry('DB00004'), entry('DB00682')]);
      final b = deriveGraphDrugSet([entry('DB00682'), entry('DB00004')]);

      expect(a.drugbankIds, b.drugbankIds);
      expect(a.drugbankIds, ['DB00004', 'DB00682']);
    });

    test('超过 10 个时截断到上限，总数仍如实反映', () {
      final entries = [
        for (var i = 0; i < 12; i += 1)
          entry('DB${(i + 1).toString().padLeft(5, '0')}'),
      ];
      final set = deriveGraphDrugSet(entries);

      expect(set.drugbankIds.length, graphMaxDrugIds);
      expect(set.totalMedicines, 12);
    });

    test('hasPair 要求至少两个可分析药', () {
      expect(deriveGraphDrugSet([entry('DB00682')]).hasPair, isFalse);
      expect(
        deriveGraphDrugSet([entry('DB00682'), entry('DB00004')]).hasPair,
        isTrue,
      );
    });

    test('没有用药时不崩', () {
      final set = deriveGraphDrugSet(const []);
      expect(set.drugbankIds, isEmpty);
      expect(set.totalMedicines, 0);
      expect(set.hasPair, isFalse);
      expect(set.unresolvableCount, 0);
    });

    test('首尾空格被忽略', () {
      expect(deriveGraphDrugSet([entry('  DB00682 ')]).drugbankIds, [
        'DB00682',
      ]);
    });
  });
}
