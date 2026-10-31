import 'package:flutter_test/flutter_test.dart';
import 'package:luminous/features/generative/domain/services/catalog_policy.dart';
import 'package:luminous/features/generative/domain/services/item_catalog.dart';
import 'package:luminous/shared/domain/composition/surface.dart';
import 'package:luminous/shared/domain/generative/data_scope.dart';

/// A7a 验收：`catalog_policy` 必须在渲染之前挡住三类越界。
///
/// 1. **agent 塞数值字段** → 拦截（这是「AI 编造健康数据」红线的可执行形态）；
/// 2. **未知 component / 未声明属性** → 拦截；
/// 3. **引用键不在该 surface 的 DataScope 里** → 拦截。
void main() {
  const scope = DataScope(
    surface: SurfaceId.review,
    entries: [
      DataScopeEntry(
        key: 'water',
        kind: DataScopeKind.metric,
        description: 'Water intake.',
      ),
      DataScopeEntry(
        key: 'sleep',
        kind: DataScopeKind.metric,
        description: 'Sleep duration.',
      ),
      DataScopeEntry(
        key: 'finding-a',
        kind: DataScopeKind.finding,
        description: 'A finding.',
      ),
    ],
  );

  final policies = buildGenerativePolicies();

  List<CatalogViolation> check(Object? component) =>
      checkComponent(component: component, policies: policies, scope: scope);

  group('合法定义放行', () {
    test('metric_card 只带引用键', () {
      expect(
        check({'component': 'metric_card', 'kind': 'water', 'range': '7d'}),
        isEmpty,
      );
    });

    test('metric_card 省略可选 range', () {
      expect(check({'component': 'metric_card', 'kind': 'sleep'}), isEmpty);
    });

    test('协议字段 id 不参与白名单检查', () {
      // 真实 A2UI 组件一定带 id；把它当自定义属性会把整棵树判成非法。
      expect(
        check({'id': 'card', 'component': 'metric_card', 'kind': 'water'}),
        isEmpty,
      );
    });

    test('trend_chart 多维（kinds）', () {
      expect(
        check({
          'component': 'trend_chart',
          'kinds': ['water', 'sleep'],
          'range': '30d',
        }),
        isEmpty,
      );
    });

    test('finding 只带 id', () {
      expect(
        check({'component': 'finding', 'findingId': 'finding-a'}),
        isEmpty,
      );
    });
  });

  group('编造数值：一律拒绝', () {
    test('metric_card 带 value', () {
      final violations = check({
        'component': 'metric_card',
        'kind': 'water',
        'value': 1800,
      });
      expect(
        violations.map((v) => v.kind),
        contains(CatalogViolationKind.unexpectedKey),
      );
    });

    test('引用键位置放数字也拒绝', () {
      final violations = check({'component': 'metric_card', 'kind': 1800});
      // 一个数字不可能同时是合法引用键，所以两条都会报：编造数值 + 引用不存在。
      // 报两条是有意的——调用方从「fabricatedNumber」就能判断这是红线违规，
      // 而不是普通的拼错维度。
      expect(
        violations.map((v) => v.kind),
        contains(CatalogViolationKind.fabricatedNumber),
      );
    });

    test('kinds 数组里混数字', () {
      final violations = check({
        'component': 'trend_chart',
        'kinds': ['water', 42],
      });
      expect(
        violations.map((v) => v.kind),
        contains(CatalogViolationKind.fabricatedNumber),
      );
    });
  });

  group('形状与白名单', () {
    test('未注册的 type', () {
      final violations = check({'component': 'Button', 'action': 'submit'});
      expect(violations.single.kind, CatalogViolationKind.unknownComponent);
    });

    test('非对象的组件定义', () {
      expect(
        check('Card').single.kind,
        CatalogViolationKind.malformedComponent,
      );
    });

    test('缺少必需属性', () {
      final violations = check({'component': 'metric_card', 'range': '7d'});
      expect(violations.single.kind, CatalogViolationKind.missingKey);
      expect(violations.single.key, 'kind');
    });

    test('agent 自创字段（finding 的 title）', () {
      final violations = check({
        'component': 'finding',
        'findingId': 'finding-a',
        'title': '你的睡眠很差',
      });
      expect(violations.single.kind, CatalogViolationKind.unexpectedKey);
      expect(violations.single.key, 'title');
    });
  });

  group('引用键必须在该 surface 的 DataScope 里', () {
    test('不存在的指标', () {
      final violations = check({'component': 'metric_card', 'kind': 'steps'});
      expect(violations.single.kind, CatalogViolationKind.unknownReference);
    });

    test('不存在的 finding', () {
      final violations = check({
        'component': 'finding',
        'findingId': 'finding-zzz',
      });
      expect(violations.single.kind, CatalogViolationKind.unknownReference);
    });

    test('非法 range', () {
      final violations = check({
        'component': 'metric_card',
        'kind': 'water',
        'range': '1y',
      });
      expect(violations.single.kind, CatalogViolationKind.invalidEnumValue);
    });
  });

  group('规则表自身的一致性', () {
    test('每个政策都登记在构建表里', () {
      expect(policies.keys, {
        GenerativeItemNames.metricCard,
        GenerativeItemNames.trendChart,
        GenerativeItemNames.finding,
      });
    });

    test('trend_chart 的单维与多维变体都在_变体表里', () {
      final variants = buildPolicyVariants();
      expect(variants[GenerativeItemNames.trendChart], hasLength(2));
    });

    test('requiredKeys 都在 allowedKeys 里', () {
      for (final policy in [
        metricCardPolicy,
        trendChartSinglePolicy,
        trendChartMultiPolicy,
        findingPolicy,
      ]) {
        expect(
          policy.allowedKeys.containsAll(policy.requiredKeys),
          isTrue,
          reason: '${policy.name} 的必需键必须同时是可允许键',
        );
      }
    });

    test('引用键也在 allowedKeys 里', () {
      for (final policy in [
        metricCardPolicy,
        trendChartSinglePolicy,
        trendChartMultiPolicy,
        findingPolicy,
      ]) {
        expect(
          policy.allowedKeys.containsAll(policy.referenceKeys.keys),
          isTrue,
        );
        expect(
          policy.allowedKeys.containsAll(policy.referenceListKeys.keys),
          isTrue,
        );
      }
    });

    test('没有任何政策允许 value / data / amount 这类数值字段', () {
      for (final policy in [
        metricCardPolicy,
        trendChartSinglePolicy,
        trendChartMultiPolicy,
        findingPolicy,
      ]) {
        for (final forbidden in ['value', 'data', 'amount', 'series']) {
          expect(policy.allowedKeys.contains(forbidden), isFalse);
        }
      }
    });
  });

  group('finding 的稳定 id', () {
    /// 用真实 id 集合（而不是上面那组合成 id）构造 scope，验的是**生产会用的
    /// 那份词表**能不能通过准入。
    DataScope realScope() => DataScope(
      surface: SurfaceId.review,
      entries: [
        for (final id in generativeFindingIds)
          DataScopeEntry(
            key: id,
            kind: DataScopeKind.finding,
            description: 'finding',
          ),
      ],
    );

    test('词表非空且是 ASCII 下划线命名', () {
      expect(generativeFindingIds, isNotEmpty);
      for (final id in generativeFindingIds) {
        expect(
          RegExp(r'^[a-z][a-z0-9_]*$').hasMatch(id),
          isTrue,
          reason:
              '$id 必须是稳定的 ASCII 标识符：它进 API 契约与提示词，'
              '翻译或驼峰都会让服务端与客户端对不上',
        );
      }
    });

    test('每个真实 id 都能通过准入', () {
      for (final id in generativeFindingIds) {
        expect(
          checkComponent(
            component: {'component': 'finding', 'findingId': id},
            policies: policies,
            scope: realScope(),
          ),
          isEmpty,
          reason: '$id 是后端真实存在的规则 id，不该被判违规',
        );
      }
    });

    test('用 kind 冒充 findingId 会被拒', () {
      // kind 是四值枚举（medication/hydration/sleep/general），多条规则共用
      // 一个 kind，所以它不是 id。如果哪天有人图省事拿 kind 当引用键，这条会红。
      for (final kind in ['hydration', 'medication', 'sleep', 'general']) {
        expect(
          checkComponent(
            component: {'component': 'finding', 'findingId': kind},
            policies: policies,
            scope: realScope(),
          ),
          isNotEmpty,
          reason: '$kind 是 kind 不是 id，不能当引用键',
        );
      }
    });
  });

  group('整棵组件树', () {
    test('只挑出有问题的组件', () {
      final violations = checkComponents(
        components: [
          {'component': 'Text', 'text': 'hi'},
          {'component': 'metric_card', 'kind': 'water'},
          {'component': 'metric_card', 'kind': 'steps'},
        ],
        policies: policies,
        scope: scope,
      );
      // Text 是展示原语，不在领域 item 白名单里，不报；坏的 metric_card 报一条。
      expect(violations, hasLength(1));
      expect(violations.single.kind, CatalogViolationKind.unknownReference);
    });
  });
}
