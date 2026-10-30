import 'package:flutter_test/flutter_test.dart';
import 'package:luminous/core/composition/composition.dart';
import 'package:luminous/features/customizer/domain/entities/draft.dart';
import 'package:luminous/features/customizer/domain/entities/edit.dart';
import 'package:luminous/features/customizer/domain/services/draft_rules.dart';

/// `add` 的契约：**从面板加入的组件必须真的出现在表上**。
///
/// 回归用例——旧实现只在「本页移除过的组件池」里查，而首次加入的组件
/// 从来不在池里，于是 `add` 静默返回原草稿。屏幕上表现为「点了/拖了没
/// 反应」，没有任何报错。
void main() {
  const surface = SurfaceId.today;
  const existing = ComponentId('daily.greeting');
  const fresh = ComponentId('summary.metrics');
  // 属于别的 tab 的组件：跨 tab 复用是组件系统的目的，必须能加进来。
  const fromOtherSurface = ComponentId('dose.records');

  final catalog = SurfaceCatalog(const [
    SurfaceDefinition(
      surface: surface,
      owned: [existing, fresh],
      defaultLayout: SurfaceLayout(
        placements: [ComponentPlacement(id: existing)],
      ),
    ),
  ]);

  LayoutDraft baseDraft() => LayoutDraft(
    surfaces: {
      surface: const SurfaceLayout(
        placements: [ComponentPlacement(id: existing)],
      ),
    },
  );

  test('a component that was never mounted can be added', () {
    final next = applyEdit(
      baseDraft(),
      const LayoutEdit.add(surface: surface, id: fresh, toIndex: 1),
      catalog,
    );

    expect(
      next.layoutOf(surface).placements.map((p) => p.id),
      [existing, fresh],
    );
  });

  test('adding an already mounted component is a no-op, not a duplicate', () {
    final next = applyEdit(
      baseDraft(),
      const LayoutEdit.add(surface: surface, id: existing, toIndex: 0),
      catalog,
    );

    expect(
      next.layoutOf(surface).placements.map((p) => p.id),
      [existing],
    );
  });

  test('a component owned by another surface can be added here', () {
    final next = applyEdit(
      baseDraft(),
      const LayoutEdit.add(surface: surface, id: fromOtherSurface, toIndex: 1),
      catalog,
    );

    expect(next.layoutOf(surface).placements.map((p) => p.id), [
      existing,
      fromOtherSurface,
    ]);
  });

  test('a surface that does not exist refuses every component', () {
    final draft = baseDraft();
    final next = applyEdit(
      draft,
      const LayoutEdit.add(surface: SurfaceId.tabChrome, id: fresh, toIndex: 0),
      catalog,
    );

    // 拒绝的编辑返回同一份草稿（不抛异常、不部分应用）。
    expect(identical(next, draft), isTrue);
  });

  test('re-adding a removed component restores its placement, not a copy', () {
    const sized = SurfaceLayout(
      placements: [
        ComponentPlacement(id: existing),
        ComponentPlacement(id: fresh, size: ComponentSize.wide, visible: false),
      ],
    );
    final withBoth = LayoutDraft(surfaces: {surface: sized});

    final removed = applyEdit(
      withBoth,
      const LayoutEdit.remove(surface: surface, id: fresh),
      catalog,
    );
    expect(removed.layoutOf(surface).placements.map((p) => p.id), [existing]);
    expect(removed.poolOf(surface).single.id, fresh);

    final readded = applyEdit(
      removed,
      const LayoutEdit.add(surface: surface, id: fresh, toIndex: 1),
      catalog,
    );
    final placement = readded.layoutOf(surface).placements.last;
    expect(placement.id, fresh);
    // 用户之前设过的尺寸与显隐没有被重置。
    expect(placement.size, ComponentSize.wide);
    expect(placement.visible, isFalse);
    expect(readded.poolOf(surface), isEmpty);
  });
}
