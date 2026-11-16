import 'package:luminous/shared/domain/composition/surface.dart';

/// 可以挂生成式组件的 surface。
///
/// 排除 `tab_chrome`：它是底部栏（图标、名称、顺序），不是页面，客户端用另
/// 一套模型渲染。服务端也在 `GENERATIVE_SURFACES` 里做了同样的排除，两边的
/// 差集必须一致——否则打开实验开关后，客户端会给一个服务端拒绝生成的 surface
/// 注册入口，用户点下去必然拿到 400 `GENERATIVE_SURFACE_UNSUPPORTED`。
///
/// 导出成常量而不是在各处重复 `surface != SurfaceId.tabChrome`：注册逻辑与
/// 契约测试必须基于**同一份**清单，各写一份迟早漂移。
///
/// 放在 `gates/` 而不是组件目录：组件注册表（`components/catalog.dart`）要
/// 用 [可生成 surface 判定][isComposableSurface]，编排入口也要用——放进任一方
/// 都会让两者互相 import 成环。
final List<SurfaceId> generativeSurfaces = [
  for (final surface in SurfaceId.values)
    if (surface != SurfaceId.tabChrome) surface,
];

/// surface 是否还能继续生成（`tab_chrome` 不是页面，不参与生成）。
///
/// 与服务端 `GENERATIVE_SURFACES` 对齐，判定依据是 [generativeSurfaces] 这份
/// 共享清单——调用点不重复写 `surface != SurfaceId.tabChrome`。
bool isComposableSurface(SurfaceId surface) =>
    generativeSurfaces.contains(surface);
