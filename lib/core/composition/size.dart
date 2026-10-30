/// How much horizontal room a component occupies on its surface.
///
/// Only three steps: the surfaces are single-column scrolling lists, so the
/// grid vocabulary of a dashboard product (x/y/w/h) would be unused weight.
/// A `compact` component may be paired with another `compact` one on a wide
/// viewport; `wide` always takes the full row.
enum ComponentSize {
  compact,
  regular,
  wide;

  /// Value stored in the persisted layout JSON.
  String get wireValue => name;

  /// Parses a persisted value; unknown values return `null` so the caller can
  /// fall back to the descriptor's default instead of guessing.
  static ComponentSize? fromWire(String raw) {
    for (final size in ComponentSize.values) {
      if (size.wireValue == raw) return size;
    }
    return null;
  }
}
