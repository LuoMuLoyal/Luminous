/// Directory-shape rules for the Luminous app.
///
/// Two directory-level rules that a per-compilation-unit rule cannot express:
///
/// - [directory_file_cap] (R8): a directory must not hold more than
///   [maxDirectSourceFiles] hand-written Dart sources. Generated files
///   (`*.g.dart` / `*.freezed.dart`) do not count — they are gitignored build
///   output and splitting around them would be meaningless.
/// - [forbidden_directory] (R9): `presentation/services/` and `data/providers/`
///   are neither a layer nor a responsibility; they are removed by the
///   architecture plan and must not come back.
///
/// These rules are evaluated by the CLI driver (`bin/luminous_lints.dart`),
/// which owns the file-system walk. The pure predicates live here so the unit
/// tests exercise exactly the logic the driver runs.
library;

/// Maximum number of direct hand-written `.dart` files a directory may hold.
const int maxDirectSourceFiles = 8;

/// Directory path segments that must not exist anywhere under `lib/`.
const List<String> forbiddenDirectorySuffixes = [
  '/presentation/services',
  '/data/providers',
  '/presentation/flows',
];

/// Whether [baseName] is a generated source rather than hand-written code.
bool isGeneratedSourceName(String baseName) =>
    baseName.endsWith('.g.dart') || baseName.endsWith('.freezed.dart');

/// Returns the violation for a normalized `lib/...` [directory] path holding
/// [directSourceFileCount] hand-written sources, or `null` when allowed.
String? checkDirectory({
  required String directory,
  required int directSourceFileCount,
}) {
  final normalized = directory.endsWith('/')
      ? directory.substring(0, directory.length - 1)
      : directory;
  for (final suffix in forbiddenDirectorySuffixes) {
    if (normalized.endsWith(suffix)) {
      return 'forbidden_directory: "$normalized" must not exist '
          '($suffix is neither a layer nor a responsibility)';
    }
  }
  if (directSourceFileCount > maxDirectSourceFiles) {
    return 'directory_file_cap: "$normalized" holds $directSourceFileCount '
        'direct sources (max $maxDirectSourceFiles); split into subdirectories';
  }
  return null;
}
