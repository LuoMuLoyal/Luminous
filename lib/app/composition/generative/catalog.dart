import 'package:a2ui_flutter/a2ui_flutter.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:forui/forui.dart';
import 'package:json_schema_builder/json_schema_builder.dart';
import 'package:luminous/core/composition/a2ui/a2ui.dart';
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
/// 只有这里允许同时看见三样东西：A2UI 的组件类型（`ComponentImplementation`）、
/// feature 的组件（review 的趋势图）、以及 core 的契约（`GenerativeCatalog`）。
///
/// A2UI 1.0 起不再有组件白名单：`basicCatalog()` 的全部基础组件都在，这里加的
/// 只是**读本仓业务数据**的那几个。它们从 Riverpod 取真值，不是因为「不许 agent
/// 看数字」，而是因为这些数据本来就在客户端——让 agent 抄一遍没有意义，还会抄错。
GenerativeCatalog buildGenerativeCatalog(
  SurfaceId surface, {
  String locale = 'en-US',
}) {
  return GenerativeCatalog(
    locale: locale,
    domainComponents: [_metricCardItem(), _trendChartItem(), _findingItem()],
  );
}

/// `metric_card`：`{kind, range?}`。
///
/// 复用 `ReviewTrendSection`（它自带「该维度没有数据」的空态），不另造一张只有
/// 数字的卡。
ComponentImplementation _metricCardItem() => ComponentImplementation(
  name: GenerativeItemNames.metricCard,
  schema: Schema.object(
    description:
        'A single health metric card. The value is read from the app by '
        'metric key; never pass numbers.',
    properties: {
      'kind': Schema.string(
        description: 'Which metric to show.',
        enumValues: generativeMetricKinds.toList()..sort(),
      ),
      'range': Schema.string(
        description: 'Time range for the metric.',
        enumValues: generativeRangeWireValues.toList()..sort(),
      ),
    },
    required: ['kind'],
    additionalProperties: false,
  ),
  builder: (context, node, props, buildChild) {
    final kind = _parseKind(props.string('kind'));
    if (kind == null) return const SizedBox.shrink();
    return _MetricCardSlot(kind: kind);
  },
);

/// `trend_chart`：`{kind | kinds, range?}`。
///
/// 单维走 `ReviewTrendSection`，多维走 `ReviewMultiTrendSection`。
ComponentImplementation _trendChartItem() => ComponentImplementation(
  name: GenerativeItemNames.trendChart,
  schema: Schema.object(
    description:
        'A trend chart. Provide either kind (one metric) or kinds '
        '(several metrics), never series values.',
    properties: {
      'kind': Schema.string(
        description: 'Single metric to chart.',
        enumValues: generativeMetricKinds.toList()..sort(),
      ),
      'kinds': Schema.list(
        description: 'Several metrics to overlay.',
        items: Schema.string(
          enumValues: generativeMetricKinds.toList()..sort(),
        ),
      ),
      'range': Schema.string(
        description: 'Time range for the chart.',
        enumValues: generativeRangeWireValues.toList()..sort(),
      ),
    },
    additionalProperties: false,
  ),
  builder: (context, node, props, buildChild) {
    final kinds = _parseKinds(props);
    if (kinds.isEmpty) return const SizedBox.shrink();
    return _TrendChartSlot(kinds: kinds);
  },
);

/// `finding`：`{findingId}`。
///
/// 文案来自后端 findings 原文，`findingId` 是稳定规则标识。agent 只能选展示
/// 哪一条：这条不是安全红线，而是数据归属——结论是后端算的，客户端只渲染。
ComponentImplementation _findingItem() => ComponentImplementation(
  name: GenerativeItemNames.finding,
  schema: Schema.object(
    description:
        'A key finding rendered verbatim from the backend by id. The text '
        'must not be written or paraphrased by the model.',
    properties: {
      'findingId': Schema.string(
        description: 'Id of an existing finding.',
        enumValues: generativeFindingIds.toList()..sort(),
      ),
    },
    required: ['findingId'],
    additionalProperties: false,
  ),
  builder: (context, node, props, buildChild) {
    final id = props.string('findingId');
    if (id == null || id.isEmpty) return const SizedBox.shrink();
    return _FindingSlot(findingId: id);
  },
);

// ---------------------------------------------------------------------------
// 领域组件的渲染：从 Riverpod 取真值
//
// `ComponentImplementation.builder` 只给 `BuildContext`，没有 `WidgetRef`，所以
// 每个 slot 用 `Consumer` 读 provider。

/// 解析 `kind` / `kinds` 两种形状，返回可渲染的维度列表。
List<ReviewDataKind> _parseKinds(ComponentProps props) {
  final single = _parseKind(props.string('kind'));
  if (single != null) return [single];
  return [
    for (final entry in props.list('kinds'))
      if (_parseKind(entry) case final kind?) kind,
  ];
}

ReviewDataKind? _parseKind(Object? raw) {
  if (raw is! String) return null;
  for (final kind in ReviewDataKind.values) {
    if (kind.name == raw) return kind;
  }
  return null;
}

/// 当前 review 看板数据；未登录 / 首帧加载中时为 `null`。
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

    return ReviewTrendSection(
      trends: frame.trends.where((series) => series.kind == kind).toList(),
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
/// `hydration_low`）。用它而不是 `kind`：多条规则共用同一个 kind，kind 无法唯一
/// 标识一条 finding。
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
