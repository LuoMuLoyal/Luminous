/// Stable identifier of a composable component: `<domain>.<view>`.
///
/// The first segment names **what the component shows** (`summary`, `water`,
/// `dose`), never the surface that happens to host it. That is what allows the
/// same component to be mounted on a second surface (e.g. putting the dose
/// risk overview on the today surface) without duplicating it.
///
/// Published ids are never renamed: a rename is indistinguishable from a
/// deletion for every layout that already references the old id.
final class ComponentId {
  const ComponentId(this.value);

  /// Wire value, `domain.view`.
  final String value;

  static final RegExp _format = RegExp(r'^[a-z][a-z0-9_]*\.[a-z][a-z0-9_]*$');

  /// Whether [value] matches the `domain.view` shape.
  ///
  /// Kept out of the constructor so ids can be `const` literals; the registry
  /// rejects malformed ids at registration time.
  bool get isValid => _format.hasMatch(value);

  @override
  bool operator ==(Object other) => other is ComponentId && other.value == value;

  @override
  int get hashCode => value.hashCode;

  @override
  String toString() => value;
}
