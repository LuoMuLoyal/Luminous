/// 生成式 UI 的组件准入规则（纯函数，无框架依赖）。
///
/// 这是**第二道闸**，也是唯一能在域层测试的一道：`GenerativeCatalog` 只允许
/// 注册过的 type 被渲染（注册闸），但注册过的 type 仍然可能被塞进不该有的
/// 属性——比如 agent 给 `metric_card` 直接写 `value: 1800`，绕开引用键把编造
/// 的数值当成健康数据显示。
///
/// 所以每个领域 item 的属性在**落到渲染之前**逐项过这里：
/// - 允许的键白名单（不在白名单里的一律拒绝，包括 agent 自创的字段）；
/// - 引用键的**形状**：`kind` 必须是该 surface `DataScope` 里声明过的维度；
/// - 数值字段出现即视为编造，直接拒绝——这是计划 §6「AI 编造健康数值」那条
///   红线的可执行形态。
library;

import 'package:luminous/shared/domain/generative/data_scope.dart';

/// 一个领域 item 的属性规则。
final class CatalogItemPolicy {
  const CatalogItemPolicy({
    required this.name,
    required this.allowedKeys,
    required this.requiredKeys,
    this.referenceKeys = const {},
    this.referenceListKeys = const {},
    this.enumValues = const {},
  });

  /// A2UI type 名，例如 `metric_card`。
  final String name;

  /// 允许出现的属性名。白名单之外的一切都被拒绝。
  final Set<String> allowedKeys;

  /// 必须出现的属性名；缺了就无法渲染。
  final Set<String> requiredKeys;

  /// 哪些属性是「引用键」：取值必须能在 [DataScope] 里找到。
  ///
  /// 映射到 `DataScopeKind`——`kind` 对应 [DataScopeKind.metric]，
  /// `findingId` 对应 [DataScopeKind.finding]。
  final Map<String, DataScopeKind> referenceKeys;

  /// 哪些属性是「引用键数组」：每一项都要能在 [DataScope] 里找到。
  ///
  /// 单独一组而不是让 `referenceKeys` 猜「值是字符串还是数组」：数组与标量
  /// 的校验口径不同（数组逐项校验且不能为空），靠形状推断会让 agent 用错的
  /// 形状悄悄通过。
  final Map<String, DataScopeKind> referenceListKeys;

  /// 哪些属性是枚举键，以及允许的取值。
  final Map<String, Set<String>> enumValues;
}

/// 一条组件属性的拒绝理由。
final class CatalogViolation {
  const CatalogViolation({
    required this.component,
    required this.key,
    required this.kind,
    this.detail,
  });

  /// 出问题的组件 type 名。
  final String component;

  /// 出问题的属性名；组件整体不合法时为 `null`。
  final String? key;

  final CatalogViolationKind kind;

  /// 开发者诊断信息；不面向用户。
  final String? detail;

  @override
  String toString() =>
      'CatalogViolation(${kind.name}: $component'
      '${key == null ? '' : '.$key'}${detail == null ? '' : ' — $detail'})';
}

enum CatalogViolationKind {
  /// 该 type 不在白名单里。
  unknownComponent,

  /// 组件定义不是对象（A2UI 组件必须是 `{Type: {...}}` 形态的对象）。
  malformedComponent,

  /// 出现了白名单之外的属性。
  unexpectedKey,

  /// 缺少必需属性。
  missingKey,

  /// 引用键的取值不在该 surface 的可引用数据里。
  unknownReference,

  /// 出现了一个数值——即「AI 编造健康数值」。
  fabricatedNumber,

  /// 枚举键的取值不在允许集合里。
  invalidEnumValue,
}

/// 校验一条组件定义。
///
/// [component] 是 A2UI 的 `{"component": "<Name>", ...}` 形式的解码结果。
/// 返回空列表表示可以渲染。
List<CatalogViolation> checkComponent({
  required Object? component,
  required Map<String, CatalogItemPolicy> policies,
  required DataScope scope,
}) {
  if (component is! Map) {
    return const [
      CatalogViolation(
        component: '?',
        key: null,
        kind: CatalogViolationKind.malformedComponent,
      ),
    ];
  }

  final map = <String, Object?>{
    for (final entry in component.entries) entry.key.toString(): entry.value,
  };
  final name = map['component'];
  final policy = name is String ? policies[name] : null;
  if (policy == null) {
    return [
      CatalogViolation(
        component: name is String ? name : '?',
        key: null,
        kind: CatalogViolationKind.unknownComponent,
        detail: 'not the whitelist',
      ),
    ];
  }

  final violations = <CatalogViolation>[];

  for (final key in policy.requiredKeys) {
    if (!map.containsKey(key)) {
      violations.add(
        CatalogViolation(
          component: policy.name,
          key: key,
          kind: CatalogViolationKind.missingKey,
        ),
      );
    }
  }

  for (final entry in map.entries) {
    final key = entry.key;
    // `component`（判别键）与 `id`（A2UI 每个组件都带的实例 id）是协议字段，
    // 不是 agent 声明的内容；白名单只管**自定义属性**。把 `id` 也当白名单项
    // 会让每条 policy 都得重复列它，漏一条就整棵树被判非法。
    if (key == 'component' || key == 'id') continue;

    if (!policy.allowedKeys.contains(key)) {
      violations.add(
        CatalogViolation(
          component: policy.name,
          key: key,
          kind: CatalogViolationKind.unexpectedKey,
        ),
      );
      continue;
    }

    final value = entry.value;

    // 数值字段本身就是红线：领域 item 只能拿引用键，真值由 builder 从
    // Riverpod 取。这里连「数字型引用键」都不放行，因为没有这种合法形态。
    if (value is num) {
      violations.add(
        CatalogViolation(
          component: policy.name,
          key: key,
          kind: CatalogViolationKind.fabricatedNumber,
          detail: 'expected a reference key, got $value',
        ),
      );
      continue;
    }

    final referenceKind = policy.referenceKeys[key];
    if (referenceKind != null) {
      final ok =
          value is String && scope.valuesOf(referenceKind).contains(value);
      if (!ok) {
        violations.add(
          CatalogViolation(
            component: policy.name,
            key: key,
            kind: CatalogViolationKind.unknownReference,
            detail: 'not in DataScope: $value',
          ),
        );
      }
      continue;
    }

    final referenceListKind = policy.referenceListKeys[key];
    if (referenceListKind != null) {
      violations.addAll(
        _checkReferenceList(
          component: policy.name,
          key: key,
          value: value,
          kind: referenceListKind,
          scope: scope,
        ),
      );
      continue;
    }

    final allowed = policy.enumValues[key];
    if (allowed != null) {
      final ok = value is String && allowed.contains(value);
      if (!ok) {
        violations.add(
          CatalogViolation(
            component: policy.name,
            key: key,
            kind: CatalogViolationKind.invalidEnumValue,
            detail: 'allowed: ${allowed.join(', ')}',
          ),
        );
      }
    }
  }

  return violations;
}

/// 校验一个引用键数组：必须是非空字符串数组，且每一项都在 scope 里。
List<CatalogViolation> _checkReferenceList({
  required String component,
  required String key,
  required Object? value,
  required DataScopeKind kind,
  required DataScope scope,
}) {
  if (value is! List || value.isEmpty) {
    return [
      CatalogViolation(
        component: component,
        key: key,
        kind: CatalogViolationKind.unknownReference,
        detail: 'expected a non-empty list of reference keys',
      ),
    ];
  }

  final available = scope.valuesOf(kind);
  final violations = <CatalogViolation>[];
  for (final entry in value) {
    if (entry is num) {
      violations.add(
        CatalogViolation(
          component: component,
          key: key,
          kind: CatalogViolationKind.fabricatedNumber,
          detail: 'expected a reference key, got $entry',
        ),
      );
      continue;
    }
    if (entry is! String || !available.contains(entry)) {
      violations.add(
        CatalogViolation(
          component: component,
          key: key,
          kind: CatalogViolationKind.unknownReference,
          detail: 'not in DataScope: $entry',
        ),
      );
    }
  }
  return violations;
}

/// 校验整棵组件树里所有**领域 item** 的组件定义。
///
/// 只校验白名单内的 type：展示原语（`Text` / `Column` / …）由 `genui` 自己的
/// schema 约束，未知 type 由渲染层的 `FallbackWidget` 降级——这两类都不归这条
/// 规则管，所以这里**不报**它们。重复报会让人误以为展示原语也被拒绝。
///
/// 返回**列表**而不是「违规 → 组件」的映射：`CatalogViolation` 没有实现相等性，
/// 拿它做键会让每个实例各占一格。
List<CatalogViolation> checkComponents({
  required Iterable<Object?> components,
  required Map<String, CatalogItemPolicy> policies,
  required DataScope scope,
}) {
  final violations = <CatalogViolation>[];
  for (final component in components) {
    final name = component is Map ? component['component'] : null;
    if (name is! String || !policies.containsKey(name)) continue;
    violations.addAll(
      checkComponent(component: component, policies: policies, scope: scope),
    );
  }
  return violations;
}
