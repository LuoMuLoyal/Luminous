import 'package:flutter_test/flutter_test.dart';
import 'package:luminous/features/review/presentation/widgets/sections/suggestion_history.dart';
import 'package:luminous/features/today/domain/entities/suggestion.dart';

/// dedupeTodaySuggestions 的数据契约测试(2026-09-01 审查 #5)。
///
/// 该函数当前仅一个生产调用点:ReviewPage(`review/presentation/pages/page.dart`
/// 装配建议历史卡时调用)。契约语义:按 title|reason|type 去重,保留
/// 生命周期状态最高的条目,输出保持首次出现顺序。若未来新增第二调用点,
/// 须先在此对齐契约语义,防止各调用点行为分叉(2026-09-02 审查 S-1)。
void main() {
  TodaySuggestionHistoryItem item({
    required String id,
    required String title,
    required String reason,
    TodaySuggestionType type = TodaySuggestionType.compliance,
    TodaySuggestionLifecycleState lifecycleState =
        TodaySuggestionLifecycleState.active,
    String date = '2026-09-01',
  }) {
    return TodaySuggestionHistoryItem(
      id: id,
      date: date,
      type: type,
      title: title,
      reason: reason,
      ruleId: 'rule-$id',
      ruleVersion: '1',
      triggerType: TodaySuggestionTriggerType.event,
      lifecycleState: lifecycleState,
      confidence: TodaySuggestionConfidence.medium,
      generatedAt: '2026-09-01T08:00:00Z',
    );
  }

  group('dedupeTodaySuggestions', () {
    test('同 key 保留生命周期状态最高的条目', () {
      final dismissed = item(
        id: 'a1',
        title: '按时服药',
        reason: '连续 3 天漏服',
        lifecycleState: TodaySuggestionLifecycleState.dismissed,
      );
      final active = item(
        id: 'a2',
        title: '按时服药',
        reason: '连续 3 天漏服',
        lifecycleState: TodaySuggestionLifecycleState.active,
      );

      // 高状态在后出现,也应覆盖前面的低状态。
      final result = dedupeTodaySuggestions([dismissed, active]);

      expect(result, hasLength(1));
      expect(result.single.id, 'a2');
      expect(
        result.single.lifecycleState,
        TodaySuggestionLifecycleState.active,
      );
    });

    test('跨 key 不合并(任一字段不同即为不同条目)', () {
      final a = item(id: 'a1', title: 'A', reason: 'r1');
      final b = item(id: 'b1', title: 'B', reason: 'r1');
      final c = item(id: 'c1', title: 'A', reason: 'r2');
      final d = item(
        id: 'd1',
        title: 'A',
        reason: 'r1',
        type: TodaySuggestionType.trend,
      );

      final result = dedupeTodaySuggestions([a, b, c, d]);

      expect(result, hasLength(4));
      expect(result.map((entry) => entry.id), ['a1', 'b1', 'c1', 'd1']);
    });

    test('全部同 key 合并为 1 条', () {
      final items = [
        item(id: 'x1', title: 'T', reason: 'R'),
        item(
          id: 'x2',
          title: 'T',
          reason: 'R',
          lifecycleState: TodaySuggestionLifecycleState.fading,
        ),
        item(
          id: 'x3',
          title: 'T',
          reason: 'R',
          lifecycleState: TodaySuggestionLifecycleState.expired,
        ),
      ];

      final result = dedupeTodaySuggestions(items);

      expect(result, hasLength(1));
      expect(result.single.id, 'x1');
    });

    test('顺序不依赖输入:输出保持首次出现顺序', () {
      final first = item(id: 'f1', title: '第一', reason: 'r');
      final second = item(id: 's1', title: '第二', reason: 'r');
      final firstAgain = item(
        id: 'f2',
        title: '第一',
        reason: 'r',
        lifecycleState: TodaySuggestionLifecycleState.dismissed,
      );

      // 同 key 的高状态条目出现在中间也不改变组间相对顺序。
      final result = dedupeTodaySuggestions([first, second, firstAgain]);

      expect(result.map((entry) => entry.id), ['f1', 's1']);
    });
  });
}
