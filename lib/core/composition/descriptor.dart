import 'package:flutter/widgets.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'id.dart';
import 'size.dart';

/// Configuration of a component type that takes no options.
///
/// Used as the `C` type argument for components whose only "configuration" is
/// being mounted at all (a greeting line, a shortcuts strip, ...).
final class NoComponentConfig {
  const NoComponentConfig();
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
  Widget? build(BuildContext context, WidgetRef ref, C config);
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
