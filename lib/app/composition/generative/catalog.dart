import 'package:flutter/widgets.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:forui/forui.dart';
import 'package:genui/genui.dart';
import 'package:json_schema_builder/json_schema_builder.dart';
import 'package:luminous/core/composition/genui/genui.dart';
import 'package:luminous/core/design/design.dart';
import 'package:luminous/features/generative/domain/services/item_catalog.dart';
import 'package:luminous/features/review/domain/entities/dashboard.dart';
import 'package:luminous/features/review/presentation/providers/surface.dart';
import 'package:luminous/features/review/presentation/widgets/sections/preview/multi_trend.dart';
import 'package:luminous/features/review/presentation/widgets/sections/preview/trend.dart';
import 'package:luminous/l10n/app_localizations.dart';
import 'package:luminous/shared/domain/composition/surface.dart';

/// 组合根：装配生成式 UI 的 catalog。
///
/// 只有这里允许同时看见三样东西：`genui` 的类型（`CatalogItem`）、feature 的
/// 组件（review 的趋势图）、以及 core 的契约（`GenerativeCatalog`）。feature 的
/// `domain/` / `application/` 不碰 `genui`，`core/` 不碰 feature——这条装配
/// 边界就是计划 §3.5 说的「CatalogItem 没有直接落文件的特殊情况」。
///
/// 首批三个领域 item（计划 §4.1 / §7 第 1 问）：
/// - `metric_card`：单指标当前值；
/// - `trend_chart`：一维或多维趋势；
/// - `finding`：后端 findings 原样展示。
GenerativeCatalog buildGenerativeCatalog(SurfaceId surface) {
  return GenerativeCatalog(
    catalogId: 'com.luminous.generative',
    domainItems: [_metricCardItem(), _trendChartItem(), _findingItem()],
  );
}

/// `metric_card`：`{kind, range?}`。
///
/// 渲染时从 `reviewSurfaceStateProvider` 取真值——**agent 给的是维度名，不是
/// 数值**。复用 `ReviewTrendSection`（它自带「该维度没有数据」的空态），不另造
/// 一张只有数字的卡：单独的数字没有口径说明，对健康数据反而更容易被误读。
CatalogItem _metricCardItem() {
  return CatalogItem(
    name: GenerativeItemNames.metricCard,
    dataSchema: S.object(
      description:
          'A single health metric card. The value is read from the app by '
          'metric key; never pass numbers.',
      properties: {
        'kind': S.string(
          title: 'Metric',
          description: 'Which metric to show.',
          enumValues: generativeMetricKinds.toList()..sort(),
        ),
        'range': S.string(
          title: 'Range',
          description: 'Time range for the metric.',
          enumValues: generativeRangeWireValues.toList()..sort(),
        ),
      },
      required: ['kind'],
      additionalProperties: false,
    ),
    widgetBuilder: (itemContext) {
      final kind = _parseKinds(_asMap(itemContext.data)).firstOrNull;
      if (kind == null) return const SizedBox.shrink();
      return _MetricCardSlot(kind: kind);
    },
  );
}

/// `trend_chart`：`{kind | kinds, range?}`。
///
/// 单维走 `ReviewTrendSection`，多维走 `ReviewMultiTrendSection`——后者是 A5-2
/// 已落地的组件，正好回答「几个指标是否同向变化」。
CatalogItem _trendChartItem() {
  return CatalogItem(
    name: GenerativeItemNames.trendChart,
    dataSchema: S.object(
      description:
          'A trend chart. Provide either kind (one metric) or kinds '
          '(several metrics), never series values.',
      properties: {
        'kind': S.string(
          title: 'Metric',
          description: 'Single metric to chart.',
          enumValues: generativeMetricKinds.toList()..sort(),
        ),
        'kinds': S.list(
          title: 'Metrics',
          description: 'Several metrics to overlay.',
          items: S.string(enumValues: generativeMetricKinds.toList()..sort()),
        ),
        'range': S.string(
          title: 'Range',
          description: 'Time range for the chart.',
          enumValues: generativeRangeWireValues.toList()..sort(),
        ),
      },
      additionalProperties: false,
    ),
    widgetBuilder: (itemContext) {
      final kinds = _parseKinds(_asMap(itemContext.data));
      if (kinds.isEmpty) return const SizedBox.shrink();
      return _TrendChartSlot(kinds: kinds);
    },
  );
}

/// `finding`：`{findingId}`。
///
/// **文案透传**：`title` / `body` 来自后端 findings，agent 只能选 id。这条是
/// 计划 §6「AI 改写医学结论」红线的落点——即使 agent 在 JSON 里塞了 `title`，
/// 它也进不了白名单，而渲染时用的永远是后端的原文。
CatalogItem _findingItem() {
  return CatalogItem(
    name: GenerativeItemNames.finding,
    dataSchema: S.object(
      description:
          'A key finding rendered verbatim from the backend by id. The text '
          'must not be written or paraphrased by the model.',
      properties: {
        'findingId': S.string(
          title: 'Finding id',
          description: 'Id of an existing finding.',
        ),
      },
      required: ['findingId'],
      additionalProperties: false,
    ),
    widgetBuilder: (itemContext) {
      final id = _asMap(itemContext.data)['findingId'];
      if (id is! String || id.isEmpty) return const SizedBox.shrink();
      return _FindingSlot(findingId: id);
    },
  );
}

// ---------------------------------------------------------------------------
// 领域 item 的渲染：从 Riverpod 取真值
//
// `CatalogItem.widgetBuilder` 只给 `BuildContext`，没有 `WidgetRef`，所以每个
// slot 用 `Consumer` 读 provider。不把数据塞进 A2UI DataModel 是有意的：那样
// agent 就能读到数值，也能提议改它。

Map<Object?, Object?> _asMap(Object? data) =>
    data is Map ? data : const <Object?, Object?>{};

/// 解析 `kind` / `kinds` 两种形状，返回可渲染的维度列表。
List<ReviewDataKind> _parseKinds(Map<Object?, Object?> data) {
  final single = _parseKind(data['kind']);
  if (single != null) return [single];
  final many = data['kinds'];
  if (many is! List) return const [];
  return [for (final entry in many) ?_parseKind(entry)];
}

ReviewDataKind? _parseKind(Object? raw) {
  if (raw is! String) return null;
  for (final kind in ReviewDataKind.values) {
    if (kind.name == raw) return kind;
  }
  return null;
}

/// 当前 review 看板数据；未登录 / 首帧加载中时为 `null`。
///
/// 用 `reviewSurfaceStateProvider` 而**不是**直接读 `reviewDashboardProvider`：
/// 前者已经把登录态、缓存、刷新失败合并成页面状态机，组件读到 `null` 就安静
/// 让位，这正是 review 自己的组件契约。
final class _ReviewFrame {
  const _ReviewFrame({
    required this.trends,
    required this.startDate,
    required this.range,
    required this.findings,
  });

  final List<ReviewTrendSeries> trends;
  final String startDate;
  final ReviewDashboardRange range;
  final List<ReviewFinding> findings;

  static _ReviewFrame? of(WidgetRef ref) {
    final dashboard = ref.watch(reviewSurfaceStateProvider).dataOrNull;
    if (dashboard == null) return null;
    return _ReviewFrame(
      trends: dashboard.trends,
      startDate: dashboard.startDate,
      range: dashboard.range,
      findings: dashboard.findings,
    );
  }
}

class _MetricCardSlot extends ConsumerWidget {
  const _MetricCardSlot({required this.kind});

  final ReviewDataKind kind;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final frame = _ReviewFrame.of(ref);
    if (frame == null) return const SizedBox.shrink();

    final series = frame.trends.where((s) => s.kind == kind).toList();
    return ReviewTrendSection(
      trends: series,
      selectedQuery: ReviewDashboardQuery(range: frame.range),
      onQueryChanged: (_) {},
      l10n: AppLocalizations.of(context)!,
      startDate: frame.startDate,
      showRangePill: false,
    );
  }
}

class _TrendChartSlot extends ConsumerWidget {
  const _TrendChartSlot({required this.kinds});

  final List<ReviewDataKind> kinds;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final frame = _ReviewFrame.of(ref);
    if (frame == null) return const SizedBox.shrink();

    if (kinds.length == 1) {
      return ReviewTrendSection(
        trends: frame.trends.where((s) => s.kind == kinds.first).toList(),
        selectedQuery: ReviewDashboardQuery(range: frame.range),
        onQueryChanged: (_) {},
        l10n: AppLocalizations.of(context)!,
        startDate: frame.startDate,
        showRangePill: false,
      );
    }

    return ReviewMultiTrendSection(
      trends: frame.trends,
      startDate: frame.startDate,
      kinds: kinds,
    );
  }
}

/// 一条 finding 的原文。
///
/// `findingId` 是后端的**稳定规则标识**（`ReviewFinding.id`，如
/// `hydration_low`）。用它而不是 `kind`：多条规则共用同一个 kind，kind 无法
/// 唯一标识一条 finding。
///
/// 文案完全来自后端的 `title` / `body`，agent 只能选展示哪一条——这条是计划
/// §6「AI 改写医学结论」红线的落点。
class _FindingSlot extends ConsumerWidget {
  const _FindingSlot({required this.findingId});

  final String findingId;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final frame = _ReviewFrame.of(ref);
    final finding = frame?.findings.where((f) => f.id == findingId).firstOrNull;
    if (finding == null) return const SizedBox.shrink();

    final typography = context.theme.typography;
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: Spacing.sm),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            finding.title,
            style: typography.body.md.copyWith(fontWeight: FontWeight.w700),
          ),
          const SizedBox(height: Spacing.xs),
          Text(finding.body, style: typography.body.xs),
        ],
      ),
    );
  }
}
