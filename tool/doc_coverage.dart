import 'dart:io';

import 'tooling_support.dart';

class DocCoverageConfig {
  const DocCoverageConfig(this.rules);

  final List<DocCoverageRule> rules;
}

class DocCoverageRule {
  const DocCoverageRule({
    required this.name,
    required this.codePatterns,
    required this.requiredDocs,
  });

  final String name;
  final List<String> codePatterns;
  final List<String> requiredDocs;
}

class DocCoverageReport {
  const DocCoverageReport(this.matchedRules);

  final List<DocCoverageMatch> matchedRules;

  bool get hasWarnings =>
      matchedRules.any((match) => match.missingDocs.isNotEmpty);
}

class DocCoverageMatch {
  const DocCoverageMatch({
    required this.ruleName,
    required this.touchedCodeFiles,
    required this.missingDocs,
  });

  final String ruleName;
  final List<String> touchedCodeFiles;
  final List<String> missingDocs;
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

    if (trimmed.startsWith('- ')) {
      final value = trimmed.substring(2).trim();
      switch (currentSection) {
        case _RuleSection.code:
          currentCodePatterns?.add(value);
        case _RuleSection.docsRequired:
          currentRequiredDocs?.add(value);
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

    final missingDocs = rule.requiredDocs
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
        missingDocs: missingDocs,
      ),
    );
  }

  return DocCoverageReport(List.unmodifiable(matches));
}

String renderDocCoverageReport(DocCoverageReport report) {
  if (report.matchedRules.isEmpty) {
    return 'Documentation coverage: no mapped code changes detected.';
  }

  if (!report.hasWarnings) {
    return 'Documentation coverage: all mapped doc targets were updated.';
  }

  final buffer = StringBuffer('Documentation coverage warnings:\n');
  for (final match in report.matchedRules.where(
    (match) => match.missingDocs.isNotEmpty,
  )) {
    buffer.writeln('- Rule: ${match.ruleName}');
    buffer.writeln('  Code changes: ${match.touchedCodeFiles.join(', ')}');
    buffer.writeln('  Review/update docs: ${match.missingDocs.join(', ')}');
  }
  buffer.write('This is warning-only and does not block the workflow.');
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

enum _RuleSection { code, docsRequired }
