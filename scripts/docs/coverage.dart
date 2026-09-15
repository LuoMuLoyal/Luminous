import 'dart:io';

import '../support.dart';

/// 低频稳定叙事(explanation/、product/)只要求携带 `updated`,不做 90 天
/// 陈旧告警(它们按设计只减不增)。`status: stale` 标记仍会被报告。
const List<String> stalenessExemptPatterns = [
  'docs/explanation/**',
  'docs/product/**',
];

/// Days after which an `status: active` doc is considered stale.
const int staleDocThresholdDays = 90;

// --- Glob matching -------------------------------------------------------
// `*` matches a single path segment; `**` matches multiple segments.
// Used by the front-matter / active-doc pattern lists below.

bool _matchesPattern(String path, String pattern) {
  final normalizedPath = path.replaceAll('\\', '/');
  final normalizedPattern = pattern.replaceAll('\\', '/');
  final regex = _globToRegExp(normalizedPattern);
  return regex.hasMatch(normalizedPath);
}

RegExp _globToRegExp(String pattern) {
  final buffer = StringBuffer('^');
  for (var i = 0; i < pattern.length; i += 1) {
    final char = pattern[i];
    if (char == '*') {
      final isDoubleStar = i + 1 < pattern.length && pattern[i + 1] == '*';
      if (isDoubleStar) {
        buffer.write('.*');
        i += 1;
      } else {
        buffer.write('[^/]*');
      }
      continue;
    }

    if (r'\.[]{}()+-?^$|'.contains(char)) {
      buffer.write('\\$char');
    } else {
      buffer.write(char);
    }
  }
  buffer.write(r'$');
  return RegExp(buffer.toString());
}

// --- Front-matter & freshness -----------------------------------------

/// Parses a leading YAML front-matter block (Obsidian-compatible).
Map<String, String> parseFrontMatter(String content) {
  final match = RegExp(r'^---\r?\n([\s\S]*?)\r?\n---\r?\n').firstMatch(content);
  if (match == null) {
    return const {};
  }
  final result = <String, String>{};
  for (final line in match.group(1)!.split(RegExp(r'\r?\n'))) {
    final kv = RegExp(r'^([a-zA-Z][\w-]*):\s*(.*)$').firstMatch(line.trim());
    if (kv != null) {
      result[kv.group(1)!] = kv.group(2)!.trim();
    }
  }
  return result;
}

class DocFreshnessReport {
  const DocFreshnessReport({
    required this.staleActiveDocs,
    required this.staleStatusDocs,
  });

  /// Docs with `status: active` whose front-matter `updated` is older than
  /// [staleDocThresholdDays] — review or archive.
  final List<String> staleActiveDocs;

  /// Docs explicitly marked `status: stale` but not yet archived.
  final List<String> staleStatusDocs;

  bool get hasWarnings =>
      staleActiveDocs.isNotEmpty || staleStatusDocs.isNotEmpty;
}

/// Analyzes doc freshness from front-matter. [contentByPath] maps a display
/// path (e.g. `docs/TODO.md`) to file content.
///
/// Docs marked `status: frozen` are intentionally exempt from the freshness
/// checks (they are skipped along with every other non-`active` status);
/// `status: stale` docs are flagged for archiving.
DocFreshnessReport analyzeDocFreshness({
  required Map<String, String> contentByPath,
  required String today,
  int staleThresholdDays = staleDocThresholdDays,
}) {
  final todayMs = DateTime.parse(today).millisecondsSinceEpoch;
  final staleActive = <String>[];
  final staleStatus = <String>[];

  contentByPath.forEach((path, content) {
    // Intentionally frozen docs are exempt from all freshness checks —
    // see [isFrozenDoc].
    if (isFrozenDoc(content)) {
      return;
    }
    final frontMatter = parseFrontMatter(content);
    final status = frontMatter['status'];
    if (status == null) {
      return;
    }
    if (status == 'stale') {
      staleStatus.add(path);
      return;
    }
    if (status != 'active') {
      return;
    }
    final updated = frontMatter['updated'];
    if (updated == null) {
      return;
    }
    final updatedMs = DateTime.tryParse(updated)?.millisecondsSinceEpoch;
    if (updatedMs == null) {
      return;
    }
    if (stalenessExemptPatterns.any(
      (pattern) => _matchesPattern(path, pattern),
    )) {
      return;
    }
    if (todayMs - updatedMs >
        staleThresholdDays * Duration.millisecondsPerDay) {
      staleActive.add(path);
    }
  });

  return DocFreshnessReport(
    staleActiveDocs: List.unmodifiable(staleActive),
    staleStatusDocs: List.unmodifiable(staleStatus),
  );
}

// --- Verify mode ---------------------------------------------------------

/// Active docs that MUST stay fresh — everything outside the archive and the
/// migration logs. Paths follow the de-numbered layout (explanation/,
/// product/, reference/, howto/, logs/) introduced by the 2026-08-31
/// governance rebuild.
const List<String> activeDocPatterns = [
  'docs/README.md',
  'docs/TODO.md',
  'docs/explanation/**/*.md',
  'docs/product/**/*.md',
  'docs/reference/*.md',
  'docs/reference/adr/*.md',
  'docs/howto/*.md',
  'docs/logs/MigrationLog.md',
];

bool isActiveDoc(String path) =>
    activeDocPatterns.any((pattern) => _matchesPattern(path, pattern));

/// Content docs that MUST carry front-matter (status / owner / updated).
/// ADRs are exempt — they keep their conventional bare format. Generated
/// docs (reference/generated/) are exempt — they carry no hand-written
/// metadata.
const List<String> frontMatterRequiredPatterns = [
  'docs/explanation/**/*.md',
  'docs/product/**/*.md',
  'docs/reference/*.md',
  'docs/howto/*.md',
];

bool isFrontMatterRequired(String path) => frontMatterRequiredPatterns.any(
  (pattern) => _matchesPattern(path, pattern),
);

/// Docs intentionally frozen (`status: frozen`): exempt from the freshness
/// checks (front-matter `updated` staleness), but still must carry valid
/// front-matter. Distinct from `status: stale`, which means the doc should be
/// archived.
bool isFrozenDoc(String? content) {
  if (content == null) {
    return false;
  }
  return parseFrontMatter(content)['status'] == 'frozen';
}

/// Docs that should carry front-matter but do not (or have an empty block).
List<String> findDocsMissingFrontMatter(
  List<String> activeDocs,
  Map<String, String> contentByPath,
) {
  return activeDocs
      .where((path) {
        if (!isFrontMatterRequired(path)) {
          return false;
        }
        final content = contentByPath[path];
        if (content == null) {
          return false;
        }
        final frontMatter = parseFrontMatter(content);
        return frontMatter['status'] == null ||
            frontMatter['owner'] == null ||
            frontMatter['updated'] == null;
      })
      .toList(growable: false);
}

/// Docs with a standing reader channel (README nav / subdir READMEs) —
/// exempt from the readership check.
const List<String> exemptUnreferencedPatterns = [
  'docs/reference/adr/**',
  'docs/reference/generated/**',
  'docs/howto/**',
  'docs/logs/**',
];

/// Active docs subject to the readership rule: every `status: active` doc
/// outside the standing channels (READMEs, ADR/how-to, generated and log
/// trees) must be linked from another doc.
/// Selection is path-based — no front-matter `quadrant` involvement.
List<String> readershipSubjectPaths(
  List<String> activeDocs,
  Map<String, String> contentByPath,
) {
  return activeDocs
      .where((path) {
        if (path.endsWith('/README.md') || path == 'docs/README.md') {
          return false;
        }
        if (exemptUnreferencedPatterns.any(
          (pattern) => _matchesPattern(path, pattern),
        )) {
          return false;
        }
        final content = contentByPath[path];
        if (content == null) {
          return false;
        }
        // Frozen docs are intentionally exempt from the readership rule.
        if (isFrozenDoc(content)) {
          return false;
        }
        return parseFrontMatter(content)['status'] == 'active';
      })
      .toList(growable: false);
}

/// Subject docs not linked from any other doc in the vault ([linkedPaths]).
List<String> findUnreferencedActiveDocs({
  required List<String> subjectPaths,
  required Set<String> linkedPaths,
}) {
  return subjectPaths
      .where((path) => !linkedPaths.contains(path))
      .toList(growable: false);
}

/// Feature dirs under `lib/features/*` intentionally exempt from README
/// coverage. Keep this list minimal — document the reason next to each entry.
const List<String> exemptFeaturePatterns = <String>[];

/// Feature dirs under `lib/features/*` without a code-adjacent `README.md`.
///
/// New features must ship with a `lib/features/<dir>/README.md` so their
/// changes are governed. `readmeExists` is injectable so the branch is
/// testable; [exemptions] skips documented exceptions.
List<String> findUncoveredFeatureDirs(
  List<String> featureDirs,
  bool Function(String dir) readmeExists, {
  List<String> exemptions = exemptFeaturePatterns,
}) {
  return featureDirs
      .where((dir) => !exemptions.contains(dir) && !readmeExists(dir))
      .toList(growable: false);
}

/// Collects all markdown files under [docsDir], excluding `.obsidian/`.
List<File> collectMarkdownFiles(Directory docsDir) {
  final files = <File>[];
  for (final entity in docsDir.listSync()) {
    if (entity is Directory) {
      if (entity.path.split(Platform.pathSeparator).last == '.obsidian') {
        continue;
      }
      files.addAll(collectMarkdownFiles(entity));
    } else if (entity is File && entity.path.endsWith('.md')) {
      files.add(entity);
    }
  }
  return files;
}
