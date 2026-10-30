import 'package:flutter/widgets.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:luminous/core/composition/composition.dart';
import 'package:luminous/features/record/presentation/widgets/sections/dashboard/date_section.dart';
import 'package:luminous/features/record/presentation/widgets/sections/dashboard/filter_section.dart';
import 'package:luminous/features/record/presentation/widgets/sections/detail/timeline_section.dart';
import 'package:luminous/features/record/presentation/widgets/sections/quick_entry/quick_action_section.dart';

/// `record` 表面的组件。
///
/// 每个组件是对页面上一个区块的适配：区块自己从
/// `recordSurfaceStateProvider` 取数据、自己完成交互，适配器只负责 id、是否
/// 可见以及「现在没东西可显示」的回答。
///
/// id 形如 `<domain>.<view>`，**不含 tab 名**——首段说的是「显示什么」，这样同一个
/// 组件日后可以挂到别的表面上（例如 `timeline.daily` 挂到回顾页）。
///
/// `build` 返回 `null` 表示「连我的间距一起跳过」，手写页面因此不再需要为每个
/// 条件可见区块准备 `SizedBox.shrink()` 占位。
const recordDateId = ComponentId('calendar.strip');
const recordQuickEntryId = ComponentId('quick_entry.daily');
const recordFilterId = ComponentId('filter.types');
const recordTimelineId = ComponentId('timeline.daily');

/// Surface definition: record 表面可以挂载哪些组件、默认显示什么。
///
/// 默认布局就是组件化之前的区块顺序（日期条 → 快速录入 → 过滤条 → 时间线），
/// 所以本次是纯重构：从不编辑布局的用户看到的页面与改动前一致。
const recordSurfaceDefinition = SurfaceDefinition(
  surface: SurfaceId.record,
  available: [
    recordDateId,
    recordQuickEntryId,
    recordFilterId,
    recordTimelineId,
  ],
  defaultLayout: SurfaceLayout(
    placements: [
      ComponentPlacement(id: recordDateId),
      ComponentPlacement(id: recordQuickEntryId),
      ComponentPlacement(id: recordFilterId),
      ComponentPlacement(id: recordTimelineId),
    ],
  ),
);

/// 把 record 的每个组件注册进 [registry]。
void registerRecordComponents(ComponentRegistry registry) {
  registry.registerDescriptor(const _DateComponent());
  registry.registerDescriptor(const _QuickEntryComponent());
  registry.registerDescriptor(const _FilterComponent());
  registry.registerDescriptor(const _TimelineComponent());
}

class _DateComponent extends ComponentDescriptor<NoComponentConfig> {
  const _DateComponent();

  @override
  ComponentId get id => recordDateId;

  @override
  NoComponentConfig get defaultConfig => const NoComponentConfig();

  @override
  Widget build(BuildContext context, WidgetRef ref, NoComponentConfig config) {
    return const RecordDateSection();
  }
}

class _QuickEntryComponent extends ComponentDescriptor<NoComponentConfig> {
  const _QuickEntryComponent();

  @override
  ComponentId get id => recordQuickEntryId;

  @override
  NoComponentConfig get defaultConfig => const NoComponentConfig();

  @override
  Widget build(BuildContext context, WidgetRef ref, NoComponentConfig config) {
    return const RecordQuickActionSection();
  }
}

class _FilterComponent extends ComponentDescriptor<NoComponentConfig> {
  const _FilterComponent();

  @override
  ComponentId get id => recordFilterId;

  @override
  NoComponentConfig get defaultConfig => const NoComponentConfig();

  @override
  Widget build(BuildContext context, WidgetRef ref, NoComponentConfig config) {
    return const RecordFilterSection();
  }
}

class _TimelineComponent extends ComponentDescriptor<NoComponentConfig> {
  const _TimelineComponent();

  @override
  ComponentId get id => recordTimelineId;

  @override
  NoComponentConfig get defaultConfig => const NoComponentConfig();

  @override
  Widget build(BuildContext context, WidgetRef ref, NoComponentConfig config) {
    return const RecordTimelineSection();
  }
}
