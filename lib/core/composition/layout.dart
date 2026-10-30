import 'id.dart';
import 'size.dart';

/// One user-owned entry of a [SurfaceLayout]: which component, at which size,
/// with which configuration, visible or not.
///
/// `config` is the raw persisted map. It is decoded into the component's typed
/// configuration inside the registry/host boundary — nothing upstream of that
/// reads it as an untyped map.
///
/// Hand-written instead of `freezed`: this is a persistence envelope, not a
/// domain entity, and its `fromJson` has to be total (bad input degrades to
/// "skip this placement") rather than generated.
final class ComponentPlacement {
  const ComponentPlacement({
    required this.id,
    this.size = ComponentSize.regular,
    this.config = const {},
    this.visible = true,
  });

  final ComponentId id;
  final ComponentSize size;
  final Map<String, Object?> config;
  final bool visible;

  ComponentPlacement copyWith({
    ComponentSize? size,
    Map<String, Object?>? config,
    bool? visible,
  }) {
    return ComponentPlacement(
      id: id,
      size: size ?? this.size,
      config: config ?? this.config,
      visible: visible ?? this.visible,
    );
  }

  Map<String, Object?> toJson() => {
    'id': id.value,
    'size': size.wireValue,
    if (config.isNotEmpty) 'config': config,
    if (!visible) 'visible': false,
  };

  /// Returns `null` when the entry cannot be represented (missing/invalid id),
  /// so the caller drops it instead of failing the whole layout.
  static ComponentPlacement? fromJson(Object? json) {
    if (json is! Map) return null;
    final rawId = json['id'];
    if (rawId is! String) return null;
    final id = ComponentId(rawId);
    if (!id.isValid) return null;
    final rawSize = json['size'];
    final rawConfig = json['config'];
    return ComponentPlacement(
      id: id,
      size: rawSize is String
          ? ComponentSize.fromWire(rawSize) ?? ComponentSize.regular
          : ComponentSize.regular,
      config: rawConfig is Map
          ? rawConfig.map((key, value) => MapEntry(key.toString(), value))
          : const {},
      visible: json['visible'] != false,
    );
  }

  @override
  bool operator ==(Object other) =>
      other is ComponentPlacement &&
      other.id == id &&
      other.size == size &&
      other.visible == visible &&
      _mapEquals(other.config, config);

  @override
  int get hashCode => Object.hash(id, size, visible, config.length);

  static bool _mapEquals(Map<String, Object?> a, Map<String, Object?> b) {
    if (a.length != b.length) return false;
    for (final entry in a.entries) {
      if (!b.containsKey(entry.key) || b[entry.key] != entry.value) return false;
    }
    return true;
  }
}

/// Ordered component list of one surface, as owned by the user.
///
/// [schemaVersion] guards the *shape* of the payload; the server stores it as
/// an opaque integer and refuses layouts from a newer client. A layout whose
/// version is not understood is discarded as a whole — the caller falls back to
/// the surface's default layout instead of guessing per-entry.
final class SurfaceLayout {
  const SurfaceLayout({required this.placements, this.schemaVersion = currentSchemaVersion});

  /// Shape version of the persisted layout document.
  static const int currentSchemaVersion = 1;

  final int schemaVersion;
  final List<ComponentPlacement> placements;

  /// An empty layout, used when a surface has no definition yet.
  static const SurfaceLayout empty = SurfaceLayout(placements: []);

  List<ComponentPlacement> get visiblePlacements =>
      placements.where((placement) => placement.visible).toList(growable: false);

  Map<String, Object?> toJson() => {
    'schemaVersion': schemaVersion,
    'placements': placements.map((placement) => placement.toJson()).toList(),
  };

  /// Returns `null` when the document is unreadable or written by a client that
  /// knows a newer schema, in which case the caller must fall back to defaults.
  static SurfaceLayout? fromJson(Object? json) {
    if (json is! Map) return null;
    final version = json['schemaVersion'];
    if (version is! int || version < 1 || version > currentSchemaVersion) {
      return null;
    }
    final rawPlacements = json['placements'];
    if (rawPlacements is! List) return null;
    final placements = <ComponentPlacement>[];
    for (final raw in rawPlacements) {
      final placement = ComponentPlacement.fromJson(raw);
      if (placement != null) placements.add(placement);
    }
    return SurfaceLayout(placements: placements, schemaVersion: version);
  }

  SurfaceLayout copyWith({List<ComponentPlacement>? placements}) =>
      SurfaceLayout(
        placements: placements ?? this.placements,
        schemaVersion: schemaVersion,
      );
}
