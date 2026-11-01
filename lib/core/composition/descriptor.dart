import 'package:flutter/widgets.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'package:luminous/shared/domain/composition/id.dart';
import 'package:luminous/shared/domain/composition/size.dart';
import 'package:luminous/shared/domain/composition/surface.dart';

/// Configuration of a component type that takes no options.
///
/// Used as the `C` type argument for components whose only "configuration" is
/// being mounted at all (a greeting line, a shortcuts strip, ...).
final class NoComponentConfig {
  const NoComponentConfig();
}

/// 组件渲染时能拿到的上下文。
///
/// 组件的 `build` 收这个而不是裸 `(context, ref)`：组件有时需要知道
/// **自己挂在哪张表上、是哪个 id**——典型场景是就地改自己的配置（列表/图
/// 变体切换要写回 `SurfaceLayout`，而布局按 surface 存）。
///
/// 为什么不塞进 `BuildContext`：那要靠 `InheritedWidget` 转发，读的地方得
/// 处理「可能不在宿主里」的空值，而组件本来只可能由宿主构建。显式传参让
/// 「没有 surface」这个状态在类型上不存在。
class ComponentRenderContext {
  const ComponentRenderContext({required this.surface, required this.id});

  /// 组件当前所在的表面。
  final SurfaceId surface;

  /// 组件自己的 id（配置写回时要用它定位 placement）。
  final ComponentId id;
}

/// Erased render function stored by [ComponentRegistry].
///
/// The typed `C` only exists inside a [ComponentDescriptor]; the registry and
/// the host work with the raw persisted map so one list can hold components
/// with different config types without downcasts at call sites.
///
/// Returning `null` means "this component has nothing to show right now". The
/// host then removes it **including its spacing**, so a hidden banner does not
/// leave a hole — the reason the old hand-written section lists carried a
/// `SizedBox.shrink()` placeholder for every conditionally visible section.
typedef ComponentBuilder =
    Widget? Function(
      BuildContext context,
      WidgetRef ref,
      ComponentRenderContext render,
      Map<String, Object?> config,
    );

/// Template for one component type.
///
/// `decode`/`encode` live here (not in the layout model) so the persisted
/// format stays a plain map and every component owns its own schema. A config
/// that fails to decode is reported as `null` and treated exactly like an
/// unknown component id.
abstract class ComponentDescriptor<C> {
  const ComponentDescriptor();

  /// Stable id, `<domain>.<view>`. Never renamed after release.
  ComponentId get id;

  /// Configuration used by a surface's default layout.
  C get defaultConfig;

  /// Sizes this component can render at. The customizer only offers these.
  Set<ComponentSize> get supportedSizes => const {ComponentSize.regular};

  /// Parses the persisted config. Returning `null` marks the payload unusable.
  C? decode(Map<String, Object?> config) => defaultConfig;

  /// Serialises [config] for persistence.
  Map<String, Object?> encode(C config) => const {};

  /// Renders the component. Returning `null` skips it entirely (no spacing).
  Widget? build(
    BuildContext context,
    WidgetRef ref,
    ComponentRenderContext render,
    C config,
  );
}

/// A descriptor after registration: config type erased, config pre-decoded per
/// placement by the host.
final class RegisteredComponent {
  const RegisteredComponent({
    required this.id,
    required this.supportedSizes,
    required this.defaultConfig,
    required this.build,
  });

  final ComponentId id;
  final Set<ComponentSize> supportedSizes;
  final Map<String, Object?> defaultConfig;
  final ComponentBuilder build;
}
