import 'package:flutter/widgets.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:luminous/core/composition/composition.dart';
import 'package:luminous/features/generative/design/ids.dart';
import 'package:luminous/features/generative/presentation/gates/surfaces.dart';
import 'package:luminous/features/generative/presentation/providers/generation.dart';
import 'package:luminous/features/generative/presentation/providers/surface_state.dart';
import 'package:luminous/features/generative/presentation/widgets/compose_entry.dart';
import 'package:luminous/features/generative/presentation/widgets/generative_surface.dart';

/// 注册 `generative.<surface>` 组件。
///
/// builder 直接返回 [GenerativeSurface]：三态（不渲染 / 骨架 / 渲染）的判断在
/// 那个组件里，这里不做重复。返回 `null` 的约定由组件内部用
/// `SizedBox.shrink()` 表达——`ComponentHost` 的 `null` 语义是「跳过我并连带
/// 跳过间距」，而生成式 UI 的结果通常要占满整行，由它自己决定间距更合适。
///
/// **注意**：`ComponentId` 只接受 `[a-z0-9_]`，`SurfaceId.tab` 的 wire
/// 值是 `tab`，合法；但 tab 栏本身不是页面，生成式 UI 不挂它
/// （见 [generativeSurfaces]）。
void registerGenerativeComponents(ComponentRegistry registry) {
  for (final surface in generativeSurfaces) {
    registry.register(
      RegisteredComponent(
        id: generativeSurfaceComponentId(surface),
        supportedSizes: const {ComponentSize.regular},
        defaultConfig: const {},
        build:
            (
              BuildContext context,
              WidgetRef ref,
              ComponentRenderContext render,
              Map<String, Object?> config,
            ) {
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
