import 'dart:io';

import '../support.dart';

class DocCoverageConfig {
  const DocCoverageConfig(this.rules);

  final List<DocCoverageRule> rules;
}

class DocCoverageRule {
  const DocCoverageRule({
    required this.name,
    required this.codePatterns,
    required this.requiredDocs,
    this.anyOfDocs = const [],
    this.infoDocs = const [],
  });

  final String name;
  final List<String> codePatterns;

  /// docs_required — ALL of these must be touched.
  final List<String> requiredDocs;

  /// docs_any_of — AT LEAST ONE of these must be touched.
  final List<String> anyOfDocs;

  /// docs_info — informational only, missing is not a warning.
  final List<String> infoDocs;
}

class DocCoverageReport {
  const DocCoverageReport(this.matchedRules);

  final List<DocCoverageMatch> matchedRules;

  /// True when a required or any-of target is missing for a matched rule.
  bool get hasWarnings => matchedRules.any(
    (match) =>
        match.missingRequired.isNotEmpty || match.missingAnyOf.isNotEmpty,
  );

  /// True when an info-level target is missing for a matched rule.
  bool get hasInfos =>
      matchedRules.any((match) => match.missingInfo.isNotEmpty);
}

class DocCoverageMatch {
  const DocCoverageMatch({
    required this.ruleName,
    required this.touchedCodeFiles,
    required this.missingRequired,
    required this.missingAnyOf,
    required this.missingInfo,
  });

  final String ruleName;
  final List<String> touchedCodeFiles;
  final List<String> missingRequired;
  final List<String> missingAnyOf;
  final List<String> missingInfo;
}

DocCoverageConfig loadDocCoverageConfig(File file) {
  if (!file.existsSync()) {
    throw StateError('Doc coverage config not found: ${file.path}');
  }
  return parseDocCoverageConfig(file.readAsStringSync());
}

DocCoverageConfig parseDocCoverageConfig(String source) {
  final rules = <DocCoverageRule>[];
  String? currentName;
  List<String>? currentCodePatterns;
  List<String>? currentRequiredDocs;
  List<String>? currentAnyOfDocs;
  List<String>? currentInfoDocs;
  _RuleSection? currentSection;

  void commitRule() {
    if (currentName == null) {
      return;
    }
    rules.add(
      DocCoverageRule(
        name: currentName,
        codePatterns: List.unmodifiable(currentCodePatterns ?? const []),
        requiredDocs: List.unmodifiable(currentRequiredDocs ?? const []),
        anyOfDocs: List.unmodifiable(currentAnyOfDocs ?? const []),
        infoDocs: List.unmodifiable(currentInfoDocs ?? const []),
      ),
    );
  }

  final lines = source.split(RegExp(r'\r?\n'));
  for (final rawLine in lines) {
    final line = rawLine.trimRight();
    final trimmed = line.trimLeft();
    if (trimmed.isEmpty || trimmed.startsWith('#') || trimmed == 'rules:') {
      continue;
    }

    if (trimmed.startsWith('- name:')) {
      commitRule();
      currentName = trimmed.substring('- name:'.length).trim();
      currentCodePatterns = <String>[];
      currentRequiredDocs = <String>[];
      currentAnyOfDocs = <String>[];
      currentInfoDocs = <String>[];
      currentSection = null;
      continue;
    }

    if (trimmed == 'code:') {
      currentSection = _RuleSection.code;
      continue;
    }

    if (trimmed == 'docs_required:') {
      currentSection = _RuleSection.docsRequired;
      continue;
    }

    if (trimmed == 'docs_any_of:') {
      currentSection = _RuleSection.anyOf;
      continue;
    }

    if (trimmed == 'docs_info:') {
      currentSection = _RuleSection.info;
      continue;
    }

    if (trimmed.startsWith('- ')) {
      final value = trimmed.substring(2).trim();
      switch (currentSection) {
        case _RuleSection.code:
          currentCodePatterns?.add(value);
        case _RuleSection.docsRequired:
          currentRequiredDocs?.add(value);
        case _RuleSection.anyOf:
          currentAnyOfDocs?.add(value);
        case _RuleSection.info:
          currentInfoDocs?.add(value);
        case null:
          throw FormatException(
            'Unexpected list item outside a rule section: $line',
          );
      }
      continue;
    }

    throw FormatException('Unsupported doc coverage config line: $line');
  }

  commitRule();
  return DocCoverageConfig(List.unmodifiable(rules));
}

DocCoverageReport buildDocCoverageReport({
  required DocCoverageConfig config,
  required List<String> changedFiles,
  required List<String> documentedFiles,
}) {
  final normalizedChangedFiles = changedFiles.map(_normalizePath).toSet();
  final normalizedDocFiles = documentedFiles.map(_normalizePath).toSet();
  final matches = <DocCoverageMatch>[];

  for (final rule in config.rules) {
    final touchedCodeFiles = normalizedChangedFiles
        .where(
          (file) => rule.codePatterns.any(
            (pattern) => _matchesPattern(file, pattern),
          ),
        )
        .toList(growable: false);
    if (touchedCodeFiles.isEmpty) {
      continue;
    }

    final missingRequired = rule.requiredDocs
        .map(_normalizePath)
        .where(
          (docPattern) => !normalizedDocFiles.any(
            (docFile) => _matchesPattern(docFile, docPattern),
          ),
        )
        .toList(growable: false);

    final anyOfTouched = rule.anyOfDocs.any(
      (pattern) => normalizedDocFiles.any(
        (docFile) => _matchesPattern(docFile, _normalizePath(pattern)),
      ),
    );
    final missingAnyOf = rule.anyOfDocs.isEmpty || anyOfTouched
        ? const <String>[]
        : rule.anyOfDocs.map(_normalizePath).toList(growable: false);

    final missingInfo = rule.infoDocs
        .map(_normalizePath)
        .where(
          (docPattern) => !normalizedDocFiles.any(
            (docFile) => _matchesPattern(docFile, docPattern),
          ),
        )
        .toList(growable: false);

    matches.add(
      DocCoverageMatch(
        ruleName: rule.name,
        touchedCodeFiles: touchedCodeFiles,
        missingRequired: missingRequired,
        missingAnyOf: missingAnyOf,
        missingInfo: missingInfo,
      ),
    );
  }

  return DocCoverageReport(List.unmodifiable(matches));
}

String renderDocCoverageReport(DocCoverageReport report) {
  if (report.matchedRules.isEmpty) {
    return 'Documentation coverage: no mapped code changes detected.';
  }

  if (!report.hasWarnings && !report.hasInfos) {
    return 'Documentation coverage: all mapped doc targets were updated.';
  }

  final buffer = StringBuffer('Documentation coverage warnings:\n');
  for (final match in report.matchedRules) {
    if (match.missingRequired.isEmpty &&
        match.missingAnyOf.isEmpty &&
        match.missingInfo.isEmpty) {
      continue;
    }
    buffer.writeln('- Rule: ${match.ruleName}');
    buffer.writeln('  Code changes: ${match.touchedCodeFiles.join(', ')}');
    if (match.missingRequired.isNotEmpty) {
      buffer.writeln(
        '  Required docs not updated: ${match.missingRequired.join(', ')}',
      );
    }
    if (match.missingAnyOf.isNotEmpty) {
      buffer.writeln(
        '  Update at least one of: ${match.missingAnyOf.join(', ')}',
      );
    }
    if (match.missingInfo.isNotEmpty) {
      buffer.writeln(
        '  Suggested docs (optional): ${match.missingInfo.join(', ')}',
      );
    }
  }
  if (report.hasWarnings) {
    buffer.write('This is warning-only and does not block the workflow.');
  } else {
    buffer.write('No required docs missing — suggestions only.');
  }
  return buffer.toString();
}

Future<List<String>> collectChangedFiles(
  Directory repoRoot, {
  required bool stagedOnly,
}) async {
  final changed = await captureCommandLines('git', [
    'diff',
    if (stagedOnly) '--cached',
    '--name-only',
    '--diff-filter=ACMR',
  ], workingDirectory: repoRoot);

  if (stagedOnly) {
    return changed;
  }

  final untracked = await captureCommandLines('git', [
    'ls-files',
    '--others',
    '--exclude-standard',
  ], workingDirectory: repoRoot);

  return {...changed, ...untracked}.toList(growable: false);
}

String defaultDocCoverageConfigPath(Directory repoRoot) =>
    '${repoRoot.path}${Platform.pathSeparator}docs${Platform.pathSeparator}doc-map.yaml';

String _normalizePath(String path) => path.replaceAll('\\', '/');

bool _matchesPattern(String path, String pattern) {
  final normalizedPath = _normalizePath(path);
  final normalizedPattern = _normalizePath(pattern);
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

enum _RuleSection { code, docsRequired, anyOf, info }

/// 低频稳定叙事(explanation/、product/)只要求携带 `updated`,不做 90 天
/// 陈旧告警(它们按设计只减不增)。`status: stale` 标记仍会被报告。
const List<String> stalenessExemptPatterns = [
  'docs/explanation/**',
  'docs/product/**',
];

/// Days after which an `status: active` doc is considered stale.
const int staleDocThresholdDays = 90;

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

// --- Verify mode (mirrors Lucent's doc-coverage-lib) --------------------

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

/// Literal (non-glob) doc paths referenced by rules that do not exist.
List<String> findDocMapOrphans(
  DocCoverageConfig config,
  List<String> availableFiles,
) {
  final orphans = <String>[];
  for (final rule in config.rules) {
    for (final pattern in [
      ...rule.requiredDocs,
      ...rule.anyOfDocs,
      ...rule.infoDocs,
    ]) {
      if (pattern.contains('*')) {
        continue;
      }
      if (!availableFiles.contains(pattern)) {
        orphans.add('${rule.name}: "$pattern" does not exist');
      }
    }
  }
  return orphans;
}

/// Glob doc patterns referenced by rules that match no existing file.
List<String> findDocMapGlobOrphans(
  DocCoverageConfig config,
  List<String> availableFiles,
) {
  final orphans = <String>[];
  for (final rule in config.rules) {
    for (final pattern in [
      ...rule.requiredDocs,
      ...rule.anyOfDocs,
      ...rule.infoDocs,
    ]) {
      if (!pattern.contains('*')) {
        continue;
      }
      if (!availableFiles.any((file) => _matchesPattern(file, pattern))) {
        orphans.add('${rule.name}: glob "$pattern" matches no existing file');
      }
    }
  }
  return orphans;
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
/// trees) must be listed in doc-map or linked from another doc.
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

/// Subject docs neither referenced by any doc-map rule nor linked from
/// another doc in the vault ([linkedPaths]).
List<String> findUnreferencedActiveDocs({
  required DocCoverageConfig config,
  required List<String> subjectPaths,
  required Set<String> linkedPaths,
}) {
  return subjectPaths
      .where((path) {
        if (linkedPaths.contains(path)) {
          return false;
        }
        return !config.rules.any((rule) {
          return [
            ...rule.requiredDocs,
            ...rule.anyOfDocs,
            ...rule.infoDocs,
          ].any((pattern) => _matchesPattern(path, pattern));
        });
      })
      .toList(growable: false);
}

/// Feature dirs under `lib/features/*` intentionally exempt from doc-map
/// coverage. Keep this list minimal — prefer adding a doc-map rule over an
/// exemption. Document the reason next to each entry.
const List<String> exemptFeaturePatterns = <String>[];

/// Feature dirs under `lib/features/*` not matched by any rule's `code` glob.
///
/// New features must ship with a doc-map rule so their changes are governed.
/// [exemptions] is injectable so the branch is testable; defaults to the
/// documented exemption list.
///
/// The probe is `lib/features/<dir>/**`, matched syntactically against each
/// rule pattern. Documented limitation: a rule whose code glob only covers
/// real files (e.g. `lib/features/*/data/**`) does not syntactically match
/// the probe, so it would not recognize the feature as covered — keep rules'
/// code globs at the feature-directory level.
List<String> findUncoveredFeatureDirs(
  List<DocCoverageRule> rules,
  List<String> featureDirs, {
  List<String> exemptions = exemptFeaturePatterns,
}) {
  return featureDirs
      .where((dir) {
        if (exemptions.contains(dir)) {
          return false;
        }
        // Features have no `<name>.module.ts`; probe the whole directory so both
        // glob and literal code patterns can match.
        final probe = 'lib/features/$dir/**';
        return !rules.any((rule) {
          return rule.codePatterns.any(
            (pattern) => _matchesPattern(probe, pattern),
          );
        });
      })
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
