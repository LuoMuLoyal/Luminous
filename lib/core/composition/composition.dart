/// Composition seams that let a page be assembled from a **layout data** instead
/// of a hand-written widget list.
///
/// Three orthogonal concepts, deliberately kept apart:
///
/// - **catalog**: which component types exist (`ComponentRegistry`, global)
/// - **mount**: which ids a surface may host (`SurfaceCatalog`, per surface)
/// - **layout**: which ids the user actually mounted, in which order
///   (`SurfaceLayout`, per surface, user-owned)
///
/// Component ids are `<domain>.<view>` and never contain a surface name, so one
/// component can be mounted on several surfaces.
library;

export 'descriptor.dart';
export 'host.dart';
export 'id.dart';
export 'layout.dart';
export 'registry.dart';
export 'size.dart';
export 'surface.dart';
