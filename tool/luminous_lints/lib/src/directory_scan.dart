// Directory-shape scan for the Luminous lint driver.
//
// R8 (`directory_file_cap`) and R9 (`forbidden_directory`) are directory-level
// rules: a per-compilation-unit analysis cannot see them, so the driver walks
// the file system once and reports one finding per offending directory.
//
// The predicates live in `lib/src/directory_shape.dart` and are unit tested
// there; this file only owns the walk and the path normalization.
import 'dart:io';

import 'package:luminous_lints/src/common.dart';
import 'package:luminous_lints/src/directory_shape.dart';

/// A directory-level finding, mirroring the CLI's `_Finding` shape without
/// depending on its private type.
class DirectoryFinding {
  const DirectoryFinding({
    required this.rule,
    required this.directory,
    required this.message,
  });

  /// `directory_file_cap` or `forbidden_directory`.
  final String rule;

  /// `lib/...` path of the offending directory.
  final String directory;

  final String message;
}

/// Walks [libRoot] and returns every directory-level violation.
///
/// [libRoot] must be the absolute path of the host app's `lib/` directory.
List<DirectoryFinding> scanDirectories(String libRoot) {
  final findings = <DirectoryFinding>[];
  final root = Directory(libRoot);
  if (!root.existsSync()) return findings;

  for (final entity in root.listSync(recursive: true, followLinks: false)) {
    if (entity is! Directory) continue;
    final relative = libRelativeDir(entity.path);
    if (relative == null) continue;

    var sourceCount = 0;
    for (final child in entity.listSync(followLinks: false)) {
      if (child is! File) continue;
      final name = child.uri.pathSegments.last;
      if (!name.endsWith('.dart')) continue;
      if (isGeneratedSourceName(name)) continue;
      sourceCount++;
    }

    final violation = checkDirectory(
      directory: relative,
      directSourceFileCount: sourceCount,
    );
    if (violation == null) continue;

    final rule = violation.startsWith('forbidden_directory')
        ? 'forbidden_directory'
        : 'directory_file_cap';
    findings.add(
      DirectoryFinding(
        rule: rule,
        directory: relative,
        message: violation.substring(violation.indexOf(':') + 1).trim(),
      ),
    );
  }
  return findings;
}
