import 'package:flutter/widgets.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:luminous/core/composition/composition.dart';
import 'package:luminous/features/generative/presentation/providers/generation.dart';
import 'package:luminous/features/generative/presentation/providers/surface_state.dart';
import 'package:luminous/features/generative/presentation/widgets/compose_entry.dart';
import 'package:luminous/features/generative/presentation/widgets/generative_surface.dart';

/// 生成式 UI 的组件 id：`generative.<surface>`。
///
/// 每个 surface 一个（计划 §7 第 2 问的结论）。理由：生成结果是**按 surface
/// 存的**（`genui.<surface>.surface`），一个全局可挂任意 surface 的组件会让
/// 「这块结果属于哪个页面」变成运行期才知道的事，而布局层是按 surface 存的。
///
/// id 是 `generative.<surface>` 而不是 `generative.<domain>.<view>`：生成式 UI
/// 没有「域 + 视图」的细分，它就是「这个格子里的东西由 agent 现拼」，`surface`
/// 是它唯一的区分维度。
ComponentId generativeSurfaceComponentId(SurfaceId surface) =>
    ComponentId('generative.${surface.wireValue}');

/// 可以挂生成式组件的 surface。
///
/// 排除 `tab_chrome`：它是底部栏（图标、名称、顺序），不是页面，客户端用另
/// 一套模型渲染。服务端也在 `GENERATIVE_SURFACES` 里做了同样的排除，两边的
/// 差集必须一致——否则打开实验开关后，客户端会给一个服务端拒绝生成的 surface
/// 注册入口，用户点下去必然拿到 400 `GENERATIVE_SURFACE_UNSUPPORTED`。
///
/// 导出成常量而不是在各处重复 `surface != SurfaceId.tabChrome`：注册逻辑与
/// 契约测试必须基于**同一份**清单，各写一份迟早漂移。
final List<SurfaceId> generativeSurfaces = [
  for (final surface in SurfaceId.values)
    if (surface != SurfaceId.tabChrome) surface,
];

/// 注册 `generative.<surface>` 组件。
///
/// builder 直接返回 [GenerativeSurface]：三态（不渲染 / 骨架 / 渲染）的判断在
/// 那个组件里，这里不做重复。返回 `null` 的约定由组件内部用
/// `SizedBox.shrink()` 表达——`ComponentHost` 的 `null` 语义是「跳过我并连带
/// 跳过间距」，而生成式 UI 的结果通常要占满整行，由它自己决定间距更合适。
///
/// **注意**：`ComponentId` 只接受 `[a-z0-9_]`，`SurfaceId.tabChrome` 的 wire
/// 值是 `tab_chrome`，合法；但 tab 栏本身不是页面，生成式 UI 不挂它
/// （见 [generativeSurfaces]）。
void registerGenerativeComponents(ComponentRegistry registry) {
  for (final surface in generativeSurfaces) {
    registry.register(
      RegisteredComponent(
        id: generativeSurfaceComponentId(surface),
        supportedSizes: const {ComponentSize.regular},
        defaultConfig: const {},
        build:
            (BuildContext context, WidgetRef ref, Map<String, Object?> config) {
              return ProviderScope(
                // 每个 surface 的生成态互相独立：一个 surface 重新生成不该让别的
                // surface 也闪一下骨架。
                overrides: [
                  generativeSurfaceIdProvider.overrideWithValue(surface),
                ],
                child: const _GenerativeSurfaceSlot(),
              );
            },
      ),
    );
  }
}

class _GenerativeSurfaceSlot extends ConsumerWidget {
  const _GenerativeSurfaceSlot();

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final surface = ref.watch(generativeSurfaceIdProvider);
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        const GenerativeComposeEntry(),
        GenerativeSurface(
          state: ref.watch(generativeStateProvider),
          transport: ref.watch(generativeTransportProvider(surface)),
          surfaceId: generativeA2uiSurfaceId(surface),
        ),
      ],
    );
  }
}
