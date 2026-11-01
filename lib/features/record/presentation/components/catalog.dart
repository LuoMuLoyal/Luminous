import 'package:flutter/widgets.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:luminous/core/composition/composition.dart';
import 'package:luminous/core/design/design.dart';
import 'package:luminous/features/record/presentation/widgets/sections/dashboard/calendar_section.dart';
import 'package:luminous/features/record/presentation/widgets/sections/dashboard/date_section.dart';
import 'package:luminous/features/record/presentation/widgets/sections/dashboard/filter_panel_section.dart';
import 'package:luminous/features/record/presentation/widgets/sections/dashboard/filter_section.dart';
import 'package:luminous/features/record/presentation/widgets/sections/detail/timeline_section.dart';
import 'package:luminous/features/record/presentation/widgets/sections/quick_entry/new_entry_section.dart';
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
const recordCalendarId = ComponentId('calendar.month');
const recordNewEntryId = ComponentId('quick_entry.panel');
const recordFilterPanelId = ComponentId('filter.panel');

/// Surface definition: record 表面可以挂载哪些组件、默认显示什么。
///
/// 默认布局是「手机上的区块顺序」，桌面端在此基础上多出两个原本只存在于手写
/// 桌面布局里的面板（月历、新建录入）——见下方 placements 的注释。
const recordSurfaceDefinition = SurfaceDefinition(
  surface: SurfaceId.record,
  owned: [
    recordDateId,
    recordQuickEntryId,
    recordFilterId,
    recordTimelineId,
    recordCalendarId,
    recordNewEntryId,
    recordFilterPanelId,
  ],
  defaultLayout: SurfaceLayout(
    placements: [
      ComponentPlacement(id: recordDateId, size: ComponentSize.compact),
      // 月历只在桌面出现：手机端顶部已有日期条，再放一个整月网格会把首屏挤满。
      ComponentPlacement(id: recordCalendarId, size: ComponentSize.compact),
      ComponentPlacement(id: recordQuickEntryId, size: ComponentSize.compact),
      // Desktop renders two columns and `regular` spans both, so the filter
      // chips and the entry timeline only sit side by side when compact.
      ComponentPlacement(id: recordFilterId, size: ComponentSize.compact),
      ComponentPlacement(id: recordNewEntryId, size: ComponentSize.compact),
      ComponentPlacement(id: recordFilterPanelId, size: ComponentSize.compact),
      ComponentPlacement(id: recordTimelineId, size: ComponentSize.compact),
    ],
  ),
);

/// 把 record 的每个组件注册进 [registry]。
void registerRecordComponents(ComponentRegistry registry) {
  registry.registerDescriptor(const _DateComponent());
  registry.registerDescriptor(const _QuickEntryComponent());
  registry.registerDescriptor(const _FilterComponent());
  registry.registerDescriptor(const _TimelineComponent());
  registry.registerDescriptor(const _CalendarComponent());
  registry.registerDescriptor(const _NewEntryComponent());
  registry.registerDescriptor(const _FilterPanelComponent());
}

class _FilterPanelComponent extends ComponentDescriptor<NoComponentConfig> {
  const _FilterPanelComponent();

  @override
  ComponentId get id => recordFilterPanelId;

  @override
  NoComponentConfig get defaultConfig => const NoComponentConfig();

  @override
  Set<ComponentSize> get supportedSizes => {ComponentSize.compact};

  @override
  Widget build(
    BuildContext context,
    WidgetRef ref,
    ComponentRenderContext render,
    NoComponentConfig config,
  ) {
    if (MediaQuery.sizeOf(context).width < Breakpoints.desktop) {
      return const SizedBox.shrink();
    }
    return const RecordFilterPanelSection();
  }
}

class _CalendarComponent extends ComponentDescriptor<NoComponentConfig> {
  const _CalendarComponent();

  @override
  ComponentId get id => recordCalendarId;

  @override
  NoComponentConfig get defaultConfig => const NoComponentConfig();

  @override
  Set<ComponentSize> get supportedSizes => {ComponentSize.compact};

  @override
  Widget build(
    BuildContext context,
    WidgetRef ref,
    ComponentRenderContext render,
    NoComponentConfig config,
  ) {
    // 手机端不渲染：桌面才是这个面板的归属形态。
    if (MediaQuery.sizeOf(context).width < Breakpoints.desktop) {
      return const SizedBox.shrink();
    }
    return const RecordCalendarSection();
  }
}

class _NewEntryComponent extends ComponentDescriptor<NoComponentConfig> {
  const _NewEntryComponent();

  @override
  ComponentId get id => recordNewEntryId;

  @override
  NoComponentConfig get defaultConfig => const NoComponentConfig();

  @override
  Set<ComponentSize> get supportedSizes => {ComponentSize.compact};

  @override
  Widget build(
    BuildContext context,
    WidgetRef ref,
    ComponentRenderContext render,
    NoComponentConfig config,
  ) {
    if (MediaQuery.sizeOf(context).width < Breakpoints.desktop) {
      return const SizedBox.shrink();
    }
    return const RecordNewEntrySection();
  }
}

class _DateComponent extends ComponentDescriptor<NoComponentConfig> {
  const _DateComponent();

  @override
  ComponentId get id => recordDateId;

  @override
  NoComponentConfig get defaultConfig => const NoComponentConfig();

  @override
  Set<ComponentSize> get supportedSizes => {
    // 默认布局要 `compact`（与日历 / 快速录入并排）。不覆写会落到基类的
    // `{regular}`，而 `regular` 在双列桌面网格里跨满整行。
    ComponentSize.compact,
    ComponentSize.regular,
    ComponentSize.wide,
  };

  @override
  Widget build(
    BuildContext context,
    WidgetRef ref,
    ComponentRenderContext render,
    NoComponentConfig config,
  ) {
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
  Set<ComponentSize> get supportedSizes => {
    // 默认布局要 `compact`。不覆写会落到基类的 `{regular}`，
    // 在双列桌面网格里跨满整行。
    ComponentSize.compact,
    ComponentSize.regular,
    ComponentSize.wide,
  };

  @override
  Widget build(
    BuildContext context,
    WidgetRef ref,
    ComponentRenderContext render,
    NoComponentConfig config,
  ) {
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
  Set<ComponentSize> get supportedSizes => {
    // 默认布局要 `compact`；不覆写会落到基类的 `{regular}`，桌面下占满整行。
    ComponentSize.compact,
    ComponentSize.regular,
    ComponentSize.wide,
  };

  @override
  Widget build(
    BuildContext context,
    WidgetRef ref,
    ComponentRenderContext render,
    NoComponentConfig config,
  ) {
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
  Set<ComponentSize> get supportedSizes => {
    // 默认布局要 `wide`（时间线独占一行）。`regular` 在双列下同样跨满两列，
    // 观感恰好一致——但那是巧合而不是声明，换到三列或改 `regular` 的语义就会
    // 错位。声明成它实际想要的东西。
    ComponentSize.compact,
    ComponentSize.regular,
    ComponentSize.wide,
  };

  @override
  Widget build(
    BuildContext context,
    WidgetRef ref,
    ComponentRenderContext render,
    NoComponentConfig config,
  ) {
    return const RecordTimelineSection();
  }
}
