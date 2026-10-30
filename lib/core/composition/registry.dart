import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'descriptor.dart';
import 'id.dart';

/// Open registry of component types, keyed by [ComponentId].
///
/// This is the "plugin table" of the app: adding a component means registering
/// one descriptor, and no page file changes. It is deliberately *global* (not
/// per surface) — which surface may mount which id is a separate declaration in
/// `SurfaceCatalog`, so a component can be mounted on several surfaces.
///
/// Registration is a startup concern of the composition root
/// (`lib/app/composition/components/`), not something features do at runtime.
final class ComponentRegistry {
  ComponentRegistry([Iterable<RegisteredComponent> components = const []]) {
    for (final component in components) {
      register(component);
    }
  }

  final Map<String, RegisteredComponent> _byId = {};

  /// Registers an already type-erased component. Throws on a duplicate id: two
  /// implementations for one id would make the rendered layout depend on
  /// registration order.
  void register(RegisteredComponent component) {
    final id = component.id;
    if (!id.isValid) {
      throw ArgumentError.value(id.value, 'id', 'must match domain.view');
    }
    if (_byId.containsKey(id.value)) {
      throw StateError('component id already registered: ${id.value}');
    }
    _byId[id.value] = component;
  }

  /// Registers a typed descriptor, erasing its config type once.
  void registerDescriptor<C>(ComponentDescriptor<C> descriptor) {
    register(
      RegisteredComponent(
        id: descriptor.id,
        supportedSizes: descriptor.supportedSizes,
        defaultConfig: descriptor.encode(descriptor.defaultConfig),
        build: (context, ref, config) {
          final decoded = descriptor.decode(config) ?? descriptor.defaultConfig;
          return descriptor.build(context, ref, decoded);
        },
      ),
    );
  }

  /// Removes a component. Layouts referencing it keep working: the host skips
  /// unknown ids instead of failing, which is also how a downgraded client
  /// survives a server layout that mentions components it does not have.
  void unregister(ComponentId id) {
    _byId.remove(id.value);
  }

  RegisteredComponent? find(ComponentId id) => _byId[id.value];

  bool contains(ComponentId id) => _byId.containsKey(id.value);

  Iterable<RegisteredComponent> get components => _byId.values;

  int get length => _byId.length;
}

/// The app-wide registry. Defaults to an empty registry so widget tests that do
/// not touch composition still build; the composition root overrides it with the
/// populated one (see `lib/app/composition/components/`).
final componentRegistryProvider = Provider<ComponentRegistry>(
  (ref) => ComponentRegistry(),
  name: 'componentRegistry',
);
