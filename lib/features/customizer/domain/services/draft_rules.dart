import 'package:luminous/core/composition/composition.dart';
import 'package:luminous/features/customizer/domain/entities/draft.dart';
import 'package:luminous/features/customizer/domain/entities/edit.dart';

/// 草稿上的纯规则：把一次 [LayoutEdit] 应用到 [LayoutDraft]，返回新草稿。
///
/// 放在 domain 且无副作用，是因为跨 surface 移动这类操作最容易出错
/// （源列表少了、目标列表多了、index 越界），需要能脱离 UI 单测。
/// 非法编辑返回原草稿而不是抛异常——编排页不该因为一次误操作崩掉。
LayoutDraft applyEdit(LayoutDraft draft, LayoutEdit edit, SurfaceCatalog catalog) {
  return switch (edit) {
    LayoutEditMove(:final from, :final to, :final id, :final toIndex) =>
      _move(draft, catalog, from: from, to: to, id: id, toIndex: toIndex),
    LayoutEditToggle(:final surface, :final id, :final visible) =>
      _toggle(draft, surface: surface, id: id, visible: visible),
    LayoutEditRemove(:final surface, :final id) =>
      _remove(draft, surface: surface, id: id),
    LayoutEditAdd(:final surface, :final id, :final toIndex) =>
      _add(draft, catalog, surface: surface, id: id, toIndex: toIndex),
    LayoutEditResize(:final surface, :final id, :final size) =>
      _resize(draft, surface: surface, id: id, size: size),
  };
}

LayoutDraft _move(
  LayoutDraft draft,
  SurfaceCatalog catalog, {
  required SurfaceId from,
  required SurfaceId to,
  required ComponentId id,
  required int toIndex,
}) {
  // 目标 surface 必须允许挂载该组件；跨 tab 的自由度上限由 catalog 决定。
  if (!catalog.availableOf(to).contains(id)) return draft;

  final source = draft.layoutOf(from).placements;
  final placement = source.where((p) => p.id == id).firstOrNull;
  if (placement == null) return draft;

  final withoutSource = [
    for (final p in source)
      if (p.id != id) p,
  ];

  final target = [
    for (final p in draft.layoutOf(to).placements)
      if (p.id != id) p,
  ];
  final clamped = toIndex.clamp(0, target.length);
  target.insert(clamped, placement);

  return draft.copyWith(
    surfaces: {
      ...draft.surfaces,
      from: draft.layoutOf(from).copyWith(placements: withoutSource),
      to: draft.layoutOf(to).copyWith(placements: target),
    },
  );
}

LayoutDraft _toggle(
  LayoutDraft draft, {
  required SurfaceId surface,
  required ComponentId id,
  required bool visible,
}) {
  final layout = draft.layoutOf(surface);
  final next = [
    for (final p in layout.placements)
      if (p.id == id) p.copyWith(visible: visible) else p,
  ];
  return draft.copyWith(
    surfaces: {...draft.surfaces, surface: layout.copyWith(placements: next)},
  );
}

LayoutDraft _remove(
  LayoutDraft draft, {
  required SurfaceId surface,
  required ComponentId id,
}) {
  final layout = draft.layoutOf(surface);
  final placement = layout.placements.where((p) => p.id == id).firstOrNull;
  if (placement == null) return draft;

  final next = [
    for (final p in layout.placements)
      if (p.id != id) p,
  ];
  // 回到未挂载池，保留原 size/config，用户加回来时不用重设。
  final pool = [...draft.poolOf(surface), placement];

  return draft.copyWith(
    surfaces: {...draft.surfaces, surface: layout.copyWith(placements: next)},
    pool: {...draft.pool, surface: pool},
  );
}

LayoutDraft _add(
  LayoutDraft draft,
  SurfaceCatalog catalog, {
  required SurfaceId surface,
  required ComponentId id,
  required int toIndex,
}) {
  if (!catalog.availableOf(surface).contains(id)) return draft;

  final layout = draft.layoutOf(surface);
  // 已经在表上就是空操作：`add` 的语义是「让这个组件出现在这里」。
  if (layout.placements.any((p) => p.id == id)) return draft;

  final pool = draft.poolOf(surface);
  // 池里有就复用它（保留用户之前设过的尺寸/配置）；没有就是首次加入，
  // 按组件自身的默认配置新建一条。旧实现只认池，所以从面板加从未生效。
  final placement = pool.where((p) => p.id == id).firstOrNull ??
      ComponentPlacement(id: id);

  final next = [...layout.placements];
  next.insert(toIndex.clamp(0, next.length), placement);

  return draft.copyWith(
    surfaces: {...draft.surfaces, surface: layout.copyWith(placements: next)},
    pool: {
      ...draft.pool,
      surface: [
        for (final p in pool)
          if (p.id != id) p,
      ],
    },
  );
}

LayoutDraft _resize(
  LayoutDraft draft, {
  required SurfaceId surface,
  required ComponentId id,
  required ComponentSize size,
}) {
  final layout = draft.layoutOf(surface);
  if (!layout.placements.any((p) => p.id == id)) return draft;
  final next = [
    for (final p in layout.placements)
      if (p.id == id) p.copyWith(size: size) else p,
  ];
  return draft.copyWith(
    surfaces: {...draft.surfaces, surface: layout.copyWith(placements: next)},
  );
}
