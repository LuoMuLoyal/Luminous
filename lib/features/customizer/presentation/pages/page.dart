import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_reorderable_grid_view/widgets/reorderable_builder.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:forui/forui.dart';
import 'package:go_router/go_router.dart';

import 'package:luminous/core/composition/composition.dart';
import 'package:luminous/core/design/design.dart';
import 'package:luminous/features/customizer/domain/entities/edit.dart';
import 'package:luminous/features/customizer/presentation/providers/draft.dart';
import 'package:luminous/features/customizer/presentation/widgets/palette.dart';
import 'package:luminous/l10n/app_localizations.dart';

/// 编排页：编辑**一个** surface 的组件列表，并可把别的 surface 的组件加入。
///
/// 用户从某个 tab 点标题进来，心智是"我在改这一页"；跨 tab 能力由右侧
/// 面板提供——拖到左侧、或点一下即加入。
///
/// 用 `flutter_reorderable_grid_view` 而不是内置 `ReorderableListView`：内置版
/// 只能在一维列表内排序，既不能跨列表拖入，也展示不了组件的真实尺寸
/// （compact/regular/wide 三档正是编排页要让用户看到的东西）。
class CustomizerPage extends ConsumerStatefulWidget {
  const CustomizerPage({super.key, required this.surface});

  final SurfaceId surface;

  @override
  ConsumerState<CustomizerPage> createState() => _CustomizerPageState();
}

class _CustomizerPageState extends ConsumerState<CustomizerPage> {
  /// 拖入落点的列表参照框（GlobalKey 挂在**列表容器**上，不是行上）。
  ///
  /// 行上不能挂 GlobalKey：`ReorderableBuilder` 拖拽时会克隆被拖的那一行渲染
  /// feedback，同一个 GlobalKey 同时属于原行与克隆，Flutter 直接抛
  /// "Duplicate GlobalKey detected" 崩溃。列表容器只在树上存在一份。
  final GlobalKey _listKey = GlobalKey();

  /// 指针落在第几项之前；在列表下方返回末尾。
  ///
  /// 行高是固定的（名称占两行、尾部操作定宽），因此用首行顶部 + 行高换算，
  /// 不必逐行测量。
  int _insertIndexAt(
    Offset globalPosition,
    List<ComponentPlacement> placements,
  ) {
    final box = _listKey.currentContext?.findRenderObject();
    if (box is! RenderBox || !box.hasSize || placements.isEmpty) {
      return placements.length;
    }
    final local = box.globalToLocal(globalPosition);
    final index = (local.dy - _listTopInset) ~/ _rowExtent;
    return index.clamp(0, placements.length);
  }

  @override
  void initState() {
    super.initState();
    // 进入编排即读现有布局生成草稿。用 postFrame 是因为 begin() 会写 provider
    // 状态，不能在 build/initState 期间同步改。
    WidgetsBinding.instance.addPostFrameCallback((_) {
      unawaited(
        ref
            .read(editSessionProvider.notifier)
            .begin(ref.read(surfaceCatalogProvider)),
      );
    });
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final draft = ref.watch(editSessionProvider);
    final catalog = ref.watch(surfaceCatalogProvider);

    if (draft == null) {
      return const FScaffold(child: Center(child: FProgress()));
    }

    final placements = draft.layoutOf(widget.surface).placements;

    // children 与 onReorder 共用同一份列表：它既是渲染来源，也是重排回调
    // 算新顺序的输入。key 用组件 id，重排后据此还原是哪个组件动了。
    //
    // 每个孩子必须带稳定 key：`ReorderableBuilder` 靠 key 在重排后还原是哪个
    // 组件动了（它自己接管拖拽手势，不需要额外的 drag listener）。
    final children = <Widget>[
      for (var index = 0; index < placements.length; index += 1)
        _PlacementTile(
          key: ValueKey(placements[index].id.value),
          surface: widget.surface,
          placement: placements[index],
        ),
    ];

    // 窄屏放不下两栏：主列表占满，可选组件走可拖高的底部面板。
    // 桌面/平板仍然并排——那里宽度足够，两栏能同时看见。
    final isNarrow = MediaQuery.sizeOf(context).width < Breakpoints.tablet;

    final builder = Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        _Header(
          title: surfaceTitle(l10n, widget.surface),
          onDone: () => _finish(context),
          onCancel: () => _cancel(context),
          onReset: () =>
              ref.read(editSessionProvider.notifier).resetToDefaults(),
          onAdd: isNarrow ? () => _openPalette(context, catalog) : null,
        ),
        Expanded(
          child: isNarrow
              ? _buildList(context, children, placements)
              : Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Expanded(
                      flex: 3,
                      child: _buildList(context, children, placements),
                    ),
                    Expanded(
                      flex: 2,
                      child: CustomizerPalette(
                        current: widget.surface,
                        catalog: catalog,
                      ),
                    ),
                  ],
                ),
        ),
      ],
    );

    // 顶部安全区由 Scaffold 的 SafeArea 负责：编排页是自定义 header，不是
    // `page_scaffold` 那套带返回箭头的顶栏，不包 SafeArea 时标题会被状态栏压住。

    return Scaffold(
      backgroundColor: context.theme.scaffoldStyle.backgroundColor,
      body: SafeArea(bottom: false, child: builder),
    );
  }

  /// 主列表 + 跨 tab 拖入落点。
  ///
  /// 落点是**整个列表区域**，不是单一插入点：指针移到某一行上半部分就插到它
  /// 之前、下半部分插到它之后（落在列表下方则追加到末尾）。旧实现固定
  /// `toIndex: placements.length`，每次拖入都只能追加到末尾。
  Widget _buildList(
    BuildContext context,
    List<Widget> children,
    List<ComponentPlacement> placements,
  ) {
    return DragTarget<ComponentId>(
      onAcceptWithDetails: (details) {
        ref
            .read(editSessionProvider.notifier)
            .applyEdit(
              LayoutEdit.add(
                surface: widget.surface,
                id: details.data,
                toIndex: _insertIndexAt(details.offset, placements),
              ),
            );
      },
      builder: (context, candidates, _) {
        return DecoratedBox(
          decoration: BoxDecoration(
            border: candidates.isEmpty
                ? null
                : Border.all(
                    color: SemanticColor.primary.solid(context),
                    width: 2,
                  ),
          ),
          child: SingleChildScrollView(
            key: _listKey,
            padding: const EdgeInsets.fromLTRB(
              Spacing.lg,
              0,
              Spacing.lg,
              Spacing.xl,
            ),
            child: ReorderableBuilder<Widget>(
              onReorder: (reorder) => _onReorder(reorder, children, placements),
              // 移动端要求「按住这一行就能拖」：默认 500ms 的长按门槛在真机
              // 上显得像没反应，缩短到 120ms；桌面用鼠标拖动同样生效。
              longPressDelay: const Duration(milliseconds: 120),
              children: children,
              builder: (ordered) => Column(children: ordered.toList()),
            ),
          ),
        );
      },
    );
  }

  /// 窄屏的「添加组件」面板：底部弹出，**高度可拖动**。
  ///
  /// 拖动条在顶部标题上：向上拉可以铺满到接近全屏（组件多时不用反复滚），
  /// 向下拉收起列表只留标题。初始高度 0.6 屏，介于「看得见下面的编排页」
  /// 和「一次能浏览十来个组件」之间。
  Future<void> _openPalette(
    BuildContext context,
    SurfaceCatalog catalog,
  ) async {
    final screenHeight = MediaQuery.sizeOf(context).height;
    const minHeight = 220.0;
    final maxHeight = screenHeight * 0.9;
    var sheetHeight = screenHeight * 0.6;

    await showModalBottomSheet<void>(
      context: context,
      isScrollControlled: true,
      useSafeArea: true,
      backgroundColor: context.theme.scaffoldStyle.backgroundColor,
      builder: (sheetContext) => StatefulBuilder(
        builder: (sheetContext, setSheetState) => SizedBox(
          height: sheetHeight.clamp(minHeight, maxHeight),
          child: Column(
            children: [
              // 拖动手柄：视觉上是抓握点，行为上把垂直拖拽翻译成高度变化。
              GestureDetector(
                behavior: HitTestBehavior.opaque,
                onVerticalDragUpdate: (details) => setSheetState(() {
                  sheetHeight = (sheetHeight - details.delta.dy).clamp(
                    minHeight,
                    maxHeight,
                  );
                }),
                child: Padding(
                  padding: const EdgeInsets.symmetric(vertical: Spacing.md),
                  child: Column(
                    children: [
                      Container(
                        width: 36,
                        height: 4,
                        decoration: BoxDecoration(
                          color: SemanticColor.neutral.solid(sheetContext),
                          borderRadius: BorderRadius.circular(2),
                        ),
                      ),
                      const SizedBox(height: Spacing.md),
                      Text(
                        AppLocalizations.of(
                          sheetContext,
                        )!.customizerAddComponents,
                        style: sheetContext.theme.typography.body.md.copyWith(
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              Expanded(
                child: CustomizerPalette(
                  current: widget.surface,
                  catalog: catalog,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  /// 「完成」：写回布局并离开。取消（返回手势/返回键）直接丢弃草稿。
  Future<void> _finish(BuildContext context) async {
    await ref.read(editSessionProvider.notifier).commit();
    if (!context.mounted) return;
    if (context.canPop()) {
      context.pop();
    } else {
      context.go('/');
    }
  }

  /// 「取消」：丢弃草稿直接离开，不写回布局。
  ///
  /// 草稿只活在 `editSessionProvider` 里（autoDispose），退出即丢弃；
  /// 这里不需要额外回滚，也不该调用 `commit`。
  void _cancel(BuildContext context) {
    if (context.canPop()) {
      context.pop();
    } else {
      context.go('/');
    }
  }

  /// 把重排结果翻译成一次 `move` 编辑。
  ///
  /// 拖拽库回传的是「给我当前 children，我给你新顺序」的函数；我们只在找到
  /// 第一个位置变化的组件时落一次编辑——草稿是唯一真相来源，UI 不自己维护
  /// 顺序，避免"界面顺序"和"草稿顺序"两份状态打架。
  void _onReorder(
    List<Widget> Function(List<Widget>) reorder,
    List<Widget> children,
    List<ComponentPlacement> placements,
  ) {
    final reordered = reorder(children);
    for (var index = 0; index < reordered.length; index += 1) {
      final id = _idOfKey(reordered[index].key);
      if (id == null) continue;
      if (placements.elementAtOrNull(index)?.id == id) continue;
      ref
          .read(editSessionProvider.notifier)
          .applyEdit(
            LayoutEdit.move(
              from: widget.surface,
              to: widget.surface,
              id: id,
              toIndex: index,
            ),
          );
      return;
    }
  }
}

/// 从 `ValueKey<String>` 还原组件 id —— 拖拽库只回传 key，不认业务类型。
ComponentId? _idOfKey(Object? key) {
  if (key is ValueKey<String>) return ComponentId(key.value);
  return null;
}

class _Header extends StatelessWidget {
  const _Header({
    required this.title,
    required this.onReset,
    required this.onDone,
    required this.onCancel,
    this.onAdd,
  });

  final String title;
  final VoidCallback onReset;
  final VoidCallback onDone;

  /// 放弃改动并退出（不写回布局）。
  final VoidCallback onCancel;

  /// 窄屏才有：打开「添加组件」面板（宽屏上面板常驻，不需要入口）。
  final VoidCallback? onAdd;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;

    final titleText = Text(
      title,
      maxLines: 1,
      overflow: TextOverflow.ellipsis,
      style: context.theme.typography.body.lg,
    );
    final cancelButton = FTooltip(
      tipBuilder: (context, controller) => Text(l10n.customizerCancelAction),
      child: FButton.icon(
        variant: FButtonVariant.ghost,
        size: FButtonSizeVariant.sm,
        onPress: onCancel,
        semanticsLabel: l10n.customizerCancelAction,
        child: const Icon(SemanticIcons.actionClose),
      ),
    );
    final resetButton = FTooltip(
      tipBuilder: (context, controller) => Text(l10n.customizerResetAction),
      child: FButton.icon(
        variant: FButtonVariant.outline,
        size: FButtonSizeVariant.sm,
        onPress: onReset,
        semanticsLabel: l10n.customizerResetAction,
        child: const Icon(SemanticIcons.actionReset),
      ),
    );
    final addButton = onAdd == null
        ? null
        : FTooltip(
            tipBuilder: (context, controller) =>
                Text(l10n.customizerAddComponents),
            child: FButton.icon(
              size: FButtonSizeVariant.sm,
              onPress: onAdd,
              semanticsLabel: l10n.customizerAddComponents,
              child: const Icon(SemanticIcons.actionAdd),
            ),
          );
    final doneButton = FTooltip(
      tipBuilder: (context, controller) => Text(l10n.customizerDoneAction),
      child: FButton.icon(
        size: FButtonSizeVariant.sm,
        onPress: onDone,
        semanticsLabel: l10n.customizerDoneAction,
        child: const Icon(SemanticIcons.actionDone),
      ),
    );

    return Padding(
      padding: const EdgeInsets.fromLTRB(
        Spacing.lg,
        Spacing.md,
        Spacing.lg,
        Spacing.md,
      ),
      // 结构化装配：标题吃剩余宽度，操作按钮以 `Flexible` 参与分配，
      // 窄屏 + 大字号时也不会把标题挤成多行（见 luminous_lints 规则
      // `non_shrinking_row_child`）。
      child: Row(
        children: [
          Flexible(child: cancelButton),
          const SizedBox(width: Spacing.sm),
          Expanded(child: titleText),
          const SizedBox(width: Spacing.sm),
          if (addButton != null) ...[
            Flexible(child: addButton),
            const SizedBox(width: Spacing.xs),
          ],
          Flexible(child: resetButton),
          const SizedBox(width: Spacing.xs),
          Flexible(child: doneButton),
        ],
      ),
    );
  }
}

/// 列表里的一行：把手 + 名称 + 显隐 + 移除。
class _PlacementTile extends ConsumerWidget {
  const _PlacementTile({
    super.key,
    required this.surface,
    required this.placement,
  });

  final SurfaceId surface;
  final ComponentPlacement placement;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = AppLocalizations.of(context)!;
    final notifier = ref.read(editSessionProvider.notifier);
    final registry = ref.watch(componentRegistryProvider);
    final id = placement.id;
    final known = registry.contains(id);

    // 尺寸档：只有支持多于一个档位的组件才给选择器。持久化的 size 可能来自
    // 旧版本、或超出该组件当前支持的档位，此时不高亮任何一项，用户点一下即可修正。
    final supportedSizes =
        registry.find(id)?.supportedSizes ?? const <ComponentSize>{};
    final sizePicker = supportedSizes.length > 1
        ? Padding(
            padding: const EdgeInsets.only(top: Spacing.xs),
            child: _SizePicker(
              selected: placement.size,
              supported: supportedSizes,
              onSelect: (size) => notifier.applyEdit(
                LayoutEdit.resize(surface: surface, id: id, size: size),
              ),
            ),
          )
        : null;

    // 结构化装配：名称吃剩余宽度；显隐与移除交给 `Flexible`，窄屏 + 大字号
    // 时不会把名称挤成多行（luminous_lints 规则 non_shrinking_row_child）。
    // 主行是用户能读懂的名字，id 作为副行保留——id 才是持久化与下架的真正
    // 身份，出问题时用户报的就是它。
    final nameText = Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      mainAxisSize: MainAxisSize.min,
      children: [
        Text(
          componentDisplayName(l10n, id),
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
          style: context.theme.typography.body.sm.copyWith(
            color: known ? null : SemanticColor.neutral.solid(context),
          ),
        ),
        Text(
          id.value,
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
          style: context.theme.typography.body.xs2.copyWith(
            color: SemanticColor.neutral.solid(context),
          ),
        ),
        if (sizePicker != null) sizePicker,
      ],
    );
    final visibilitySwitch = FSwitch(
      value: placement.visible,
      onChange: (value) => notifier.applyEdit(
        LayoutEdit.toggle(surface: surface, id: id, visible: value),
      ),
    );
    final removeButton = FTooltip(
      tipBuilder: (context, controller) => Text(l10n.customizerRemoveAction),
      child: FButton.icon(
        variant: FButtonVariant.ghost,
        size: FButtonSizeVariant.xs,
        onPress: () =>
            notifier.applyEdit(LayoutEdit.remove(surface: surface, id: id)),
        semanticsLabel: l10n.customizerRemoveAction,
        child: const Icon(SemanticIcons.actionDelete),
      ),
    );

    return Padding(
      padding: const EdgeInsets.only(bottom: Spacing.sm),
      child: FCard(
        child: Row(
          children: [
            Padding(
              padding: const EdgeInsets.all(Spacing.sm),
              child: Icon(
                SemanticIcons.actionDragHandle,
                size: IconSizeTokens.md,
                color: SemanticColor.neutral.solid(context),
              ),
            ),
            Expanded(child: nameText),
            // 开关与删除是**固定宽度的尾部操作**：宽度由控件自身决定，
            // 不参与 flex 分配，所以每一行的两个按钮横向位置一致。
            // 行宽不够时由名称 `Expanded` 先让位（它已经带省略号）。
            SizedBox(width: _switchWidth, child: visibilitySwitch),
            SizedBox(width: _removeWidth, child: removeButton),
          ],
        ),
      ),
    );
  }
}

/// 尾部操作区的固定宽度。
///
/// 用固定值而不用 flex：flex 按行内剩余空间分配，会让每行的开关与删除落在
/// 不同横向位置。这两个值覆盖 Forui 默认尺寸下的控件宽度，并给大字号留余量。
/// 列表顶部到第一行顶部的距离（SingleChildScrollView 的 top padding 为 0）。
const double _listTopInset = 0;

/// 单行的总高度：行内容 + 卡片间距。
///
/// 名称固定占两行文本，尾部操作定宽；带尺寸选择器的组件多一行，这里取两者
/// 中较高的一个。`_insertIndexAt` 靠它换算落点，宁可偏大（落点靠前）也不要
/// 偏小，否则跨列表拖入会插到错误位置。
const double _rowExtent = 96;

const double _switchWidth = 56;

const double _removeWidth = 44;

/// 三档宽度选择器：一行紧凑的 chip 式按钮。
///
/// 用一排按钮而不是下拉菜单：只有三个选项，用户需要在**看到**当前档位的同时
/// 一眼看完可选范围——下拉菜单会把"还能选什么"藏起来。
///
/// 选中态用 `primary` 变体（实心）而不是 `outline`：outline 与未选中的 ghost
/// 在浅色主题下几乎无区别，用户看不出当前是哪一档。
class _SizePicker extends StatelessWidget {
  const _SizePicker({
    required this.selected,
    required this.supported,
    required this.onSelect,
  });

  final ComponentSize selected;
  final Set<ComponentSize> supported;
  final ValueChanged<ComponentSize> onSelect;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;

    // 按从小到大固定顺序渲染，保证同一组件每次进入编排页按钮顺序一致。
    final options = [
      for (final size in ComponentSize.values)
        if (supported.contains(size)) size,
    ];

    return Semantics(
      label: l10n.customizerSizeLabel,
      child: Wrap(
        spacing: Spacing.xs,
        runSpacing: Spacing.xs,
        children: [
          for (final size in options)
            _SizeChip(
              label: _sizeLabel(l10n, size),
              selected: size == selected,
              onPress: () => onSelect(size),
            ),
        ],
      ),
    );
  }
}

/// 单个尺寸档位按钮。
///
/// 不用 `FButton`：Forui 按钮的 xs 尺寸仍带最小宽度与内边距，三个并排会
/// 撑满整行宽度并换行，把一行装饰性信息变成三行主内容。这里直接用
/// `FBadge`——它本来就是「短标签」的语义，且自带圆角与主题色。
class _SizeChip extends StatelessWidget {
  const _SizeChip({
    required this.label,
    required this.selected,
    required this.onPress,
  });

  final String label;
  final bool selected;
  final VoidCallback onPress;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      behavior: HitTestBehavior.opaque,
      onTap: onPress,
      child: FBadge(
        variant: selected ? FBadgeVariant.primary : FBadgeVariant.outline,
        child: Text(
          label,
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
          style: context.theme.typography.body.xs2.copyWith(
            fontWeight: selected ? FontWeight.w700 : FontWeight.w400,
          ),
        ),
      ),
    );
  }
}

String _sizeLabel(AppLocalizations l10n, ComponentSize size) => switch (size) {
  ComponentSize.compact => l10n.customizerSizeCompact,
  ComponentSize.regular => l10n.customizerSizeRegular,
  ComponentSize.wide => l10n.customizerSizeWide,
};
