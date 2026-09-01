/// Shared helpers for the Luminous lint rules.
///
/// All path handling is string based and normalized to forward slashes so the
/// rules behave identically on Windows (development) and Linux (CI).
library;

/// Name of the host application package. Used to resolve
/// `package:luminous/...` imports to `lib/...` paths.
const String hostPackageName = 'luminous';

/// Returns [path] with all backslashes replaced by forward slashes.
String normalizePath(String path) => path.replaceAll('\\', '/');

/// Returns the path of [filePath] relative to the enclosing package's `lib`
/// directory (for example `lib/features/record/data/x.dart`), or `null` when
/// the file is not inside a `lib` directory.
String? libRelativePath(String filePath) {
  final normalized = normalizePath(filePath);
  final index = normalized.lastIndexOf('/lib/');
  if (index < 0) return null;
  return normalized.substring(index + 1);
}

/// Whether [libRelativePath] points into a data-layer directory (any path
/// segment named `data`).
bool isDataLayerPath(String libRelativePath) =>
    libRelativePath.startsWith('lib/data/') ||
    libRelativePath.contains('/data/');

/// Whether [libRelativePath] points into a presentation-layer directory (any
/// path segment named `presentation`).
bool isPresentationLayerPath(String libRelativePath) =>
    libRelativePath.startsWith('lib/presentation/') ||
    libRelativePath.contains('/presentation/');

/// Whether [libRelativePath] points into the shared `core` directory.
bool isCorePath(String libRelativePath) =>
    libRelativePath.startsWith('lib/core/');

/// Returns the feature name of a `lib/features/<feature>/...` path, or `null`
/// when the path is not inside a feature.
String? featureNameOf(String libRelativePath) {
  const prefix = 'lib/features/';
  if (!libRelativePath.startsWith(prefix)) return null;
  final rest = libRelativePath.substring(prefix.length);
  final slash = rest.indexOf('/');
  if (slash <= 0) return null;
  return rest.substring(0, slash);
}

/// Resolves an import [uri] to a package `lib/...` path.
///
/// - `package:luminous/a/b.dart` resolves to `lib/a/b.dart`;
/// - relative URIs are resolved against the directory of [importerPath]
///   (which must itself be a `lib/...` path);
/// - `dart:` URIs, imports of other packages, and URIs that escape `lib`
///   resolve to `null` (out of scope for the layered-import rules).
String? resolveImportTarget(String uri, String importerPath) {
  if (uri.startsWith('package:')) {
    final rest = uri.substring('package:'.length);
    if (!rest.startsWith('$hostPackageName/')) return null;
    return 'lib/${rest.substring(hostPackageName.length + 1)}';
  }
  if (uri.startsWith('dart:')) return null;

  final base = normalizePath(importerPath);
  final dirEnd = base.lastIndexOf('/') + 1;
  final segments = <String>[];
  for (final segment in '${base.substring(0, dirEnd)}$uri'.split('/')) {
    if (segment.isEmpty || segment == '.') continue;
    if (segment == '..') {
      if (segments.isEmpty) return null;
      segments.removeLast();
    } else {
      segments.add(segment);
    }
  }
  final joined = segments.join('/');
  return joined.startsWith('lib/') ? joined : null;
}
