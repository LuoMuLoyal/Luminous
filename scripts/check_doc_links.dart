import 'dart:io';

import 'tooling_support.dart';

/// Wikilink & relative-link integrity check for the Luminous docs vault.
///
/// Scans `docs/**/*.md` (excluding `.obsidian/`) for:
/// - Obsidian wikilinks `[[path|alias]]` / `[[path]]` (with or without `.md`)
/// - Markdown links `[text](path)` (relative links; external URLs skipped)
///
/// Targets are resolved against the vault root (`docs/`). Wikilinks match
/// case-insensitively (Obsidian semantics); relative links resolve from the
/// containing file's directory. Any broken link exits with code 1.
///
/// Usage:
///   dart run scripts/check_doc_links.dart            # full vault scan
///   dart run scripts/check_doc_links.dart --changed  # only changed docs
///
/// `--changed` reads the git change set (staged + unstaged + untracked) and
/// checks only the outgoing links of the changed docs. When the change set
/// deletes or renames docs, the whole vault is scanned instead so incoming
/// links to the removed docs are caught. The full scan remains the default
/// (no flag) for daily/CI use.

Future<void> main(List<String> args) async {
  if (args.contains('--help') || args.contains('-h')) {
    stdout.writeln(_usage);
    return;
  }
  var changedOnly = false;
  for (final arg in args) {
    if (arg == '--changed') {
      changedOnly = true;
      continue;
    }
    stderr.writeln('Unexpected argument: $arg');
    stderr.writeln('');
    stderr.writeln(_usage);
    exitCode = 64;
    return;
  }

  final scriptFile = File.fromUri(Platform.script);
  final repoRoot = scriptFile.parent.parent.absolute;
  final docsDir = Directory('${repoRoot.path}${Platform.pathSeparator}docs');
  if (!docsDir.existsSync()) {
    stderr.writeln('Docs vault not found: ${docsDir.path}');
    exitCode = 1;
    return;
  }

  final vault = VaultIndex(docsDir);
  var filesToCheck = vault.markdownFiles;

  if (changedOnly) {
    try {
      final changeSet = await collectDocChangeSet(repoRoot);
      if (changeSet.deletedDocs.isEmpty) {
        filesToCheck = vault.markdownFiles
            .where(
              (file) =>
                  changeSet.changedDocs.contains(vault.relativePath(file)),
            )
            .toList(growable: false);
      }
      // Deletions/renames: fall back to the whole vault so incoming links to
      // the removed docs are reported as broken.
    } on ProcessException catch (error) {
      stderr.writeln(error.message);
      exitCode = 1;
      return;
    }
  }

  final problems = <String>[];
  for (final file in filesToCheck) {
    problems.addAll(checkDocFileLinks(vault, file));
  }

  if (problems.isNotEmpty) {
    stderr.writeln('Broken doc links found:');
    for (final problem in problems) {
      stderr.writeln('  - $problem');
    }
    exitCode = 1;
    return;
  }

  stdout.writeln(
    'Doc links check passed (${filesToCheck.length} files, '
    'no broken links).',
  );
}

/// Scans [file] for broken wikilinks and relative markdown links.
///
/// Returns human-readable problem strings prefixed with the display path
/// (e.g. `docs/TODO.md: [[Missing]] — no matching file`). Shared
/// with the `--verify` mode of check_doc_coverage.dart so both tools resolve
/// links identically.
List<String> checkDocFileLinks(VaultIndex vault, File file) {
  final problems = <String>[];
  final content = file.readAsStringSync();
  final relative = vault.relativePath(file);
  var inFence = false;

  for (final rawLine in content.split(RegExp(r'\r?\n'))) {
    final line = rawLine.trimRight();
    final trimmed = line.trimLeft();

    if (trimmed.startsWith('```')) {
      inFence = !inFence;
      continue;
    }
    if (inFence) {
      continue;
    }

    // Inline code (`...`) is literal text — never a link.
    final scanLine = stripInlineCode(line);

    for (final link in extractWikilinks(scanLine)) {
      final resolved = vault.resolveWikilink(link.target, fromFile: file);
      if (resolved == null) {
        problems.add('docs/$relative: [[${link.raw}]] — no matching file');
      }
    }

    for (final link in extractMarkdownLinks(scanLine)) {
      final url = link.url ?? link.target;
      if (isExternalUrl(url) || url.startsWith('#')) {
        continue;
      }
      final resolved = vault.resolveRelativeLink(url, fromFile: file);
      if (resolved == null) {
        problems.add('docs/$relative: [${link.text}]($url) — no matching file');
      }
    }
  }
  return problems;
}

/// Git change set of a working tree, scoped to the docs vault.
class DocChangeSet {
  const DocChangeSet({required this.changedDocs, required this.deletedDocs});

  /// Vault-relative paths of changed markdown docs
  /// (staged + unstaged + untracked).
  final List<String> changedDocs;

  /// Vault-relative paths of docs deleted or renamed (staged + unstaged).
  final Set<String> deletedDocs;
}

/// Collects the docs-related git change set (staged + unstaged + untracked).
///
/// The diff queries pass `--no-renames`: with default rename detection a pure
/// `git mv` shows up as a single R entry (only the NEW path in --name-only),
/// so a `--diff-filter=D` query would miss it and the deletion fallback would
/// silently skip the rename hazard. Disabling rename detection surfaces the
/// move as a delete+add pair, putting the old path into [DocChangeSet.deletedDocs].
Future<DocChangeSet> collectDocChangeSet(Directory repoRoot) async {
  final changed = <String>{};
  final deleted = <String>{};
  for (final cached in [false, true]) {
    final diffArgs = [
      'diff',
      if (cached) '--cached',
      '--name-only',
      '--no-renames',
    ];
    changed.addAll(
      await captureCommandLines('git', [
        ...diffArgs,
        '--diff-filter=ADMR',
      ], workingDirectory: repoRoot),
    );
    deleted.addAll(
      await captureCommandLines('git', [
        ...diffArgs,
        '--diff-filter=D',
      ], workingDirectory: repoRoot),
    );
  }
  changed.addAll(
    await captureCommandLines('git', [
      'ls-files',
      '--others',
      '--exclude-standard',
    ], workingDirectory: repoRoot),
  );

  return DocChangeSet(
    changedDocs: filterChangedDocs(changed),
    deletedDocs: filterChangedDocs(deleted).toSet(),
  );
}

/// Vault-relative paths of markdown files under `docs/` among [changedPaths].
List<String> filterChangedDocs(Iterable<String> changedPaths) {
  return changedPaths
      .map(_normalizePath)
      .where(
        (path) =>
            path.startsWith('docs/') &&
            path.endsWith('.md') &&
            !path.contains('/.obsidian/'),
      )
      .map((path) => path.substring('docs/'.length))
      .toList(growable: false);
}

class DocLinkMatch {
  const DocLinkMatch({
    required this.raw,
    required this.target,
    required this.text,
    this.url,
  });

  final String raw;
  final String target;
  final String text;
  final String? url;
}

/// `[[target|alias]]` — returns the target without the alias part.
Iterable<DocLinkMatch> extractWikilinks(String line) sync* {
  final re = RegExp(r'\[\[([^\[\]]+)\]\]');
  for (final match in re.allMatches(line)) {
    final raw = match.group(1)!.trim();
    if (raw.isEmpty) {
      continue;
    }
    final target = raw.split('|').first.trim();
    yield DocLinkMatch(raw: raw, target: target, text: '');
  }
}

/// `[text](url)` and `![alt](url)` — returns the URL portion.
Iterable<DocLinkMatch> extractMarkdownLinks(String line) sync* {
  final re = RegExp(r'!?\[([^\]]*)\]\(([^)\s]+)\)');
  for (final match in re.allMatches(line)) {
    final text = match.group(1) ?? '';
    final url = match.group(2) ?? '';
    if (url.isEmpty) {
      continue;
    }
    yield DocLinkMatch(raw: url, target: url, text: text, url: url);
  }
}

bool isExternalUrl(String url) {
  return RegExp(r'^[a-zA-Z][a-zA-Z0-9+.-]*:').hasMatch(url);
}

/// Removes inline code spans (`` `...` ``) — literal text, never links.
String stripInlineCode(String line) => line.replaceAll(RegExp(r'`[^`]*`'), '');

class VaultIndex {
  VaultIndex(this.docsDir) {
    _indexDir(docsDir, docsDir);
  }

  final Directory docsDir;
  final List<File> markdownFiles = <File>[];

  /// Lowercased vault-relative path (e.g. `reference/adr/0002-gorouter-navigation.md`).
  final Set<String> _allLowerPaths = <String>{};

  /// Lowercased basename (with extension) -> vault-relative paths.
  final Map<String, List<String>> _basenameIndex = <String, List<String>>{};

  /// Lowercased basename without extension -> vault-relative paths.
  final Map<String, List<String>> _basenameNoExtIndex =
      <String, List<String>>{};

  void _indexDir(Directory dir, Directory vaultRoot) {
    for (final entity in dir.listSync()) {
      if (entity is Directory) {
        if (entity.path.split(Platform.pathSeparator).last == '.obsidian') {
          continue;
        }
        _indexDir(entity, vaultRoot);
      } else if (entity is File) {
        final relative = relativePath(entity);
        final lower = relative.toLowerCase();
        _allLowerPaths.add(lower);
        if (entity.path.endsWith('.md')) {
          markdownFiles.add(entity);
        }
        final basename = lower.split('/').last;
        _basenameIndex.putIfAbsent(basename, () => <String>[]).add(relative);
        final withoutExt = _stripExtension(basename);
        _basenameNoExtIndex
            .putIfAbsent(withoutExt, () => <String>[])
            .add(relative);
      }
    }
  }

  String relativePath(File file) {
    final base = docsDir.path.replaceAll('\\', '/');
    return file.path.replaceAll('\\', '/').substring(base.length + 1);
  }

  String? resolveWikilink(String target, {required File fromFile}) {
    var clean = target.trim();
    // Strip a heading anchor: [[file#section]].
    final hashIndex = clean.indexOf('#');
    if (hashIndex >= 0) {
      clean = clean.substring(0, hashIndex).trim();
    }
    if (clean.isEmpty) {
      return null;
    }

    if (clean.startsWith('../') || clean.startsWith('./')) {
      // Relative wikilink: resolved from the containing file's directory.
      final fromDir = fromFile.parent.path.replaceAll('\\', '/');
      final normalized = _normalizePath('$fromDir/$clean');
      final base = docsDir.path.replaceAll('\\', '/');
      if (!normalized.startsWith('$base/')) {
        return null;
      }
      final relative = normalized.substring(base.length + 1);
      final candidates = <String>{
        relative,
        if (!relative.endsWith('.md')) '$relative.md',
      };
      for (final candidate in candidates) {
        if (_allLowerPaths.contains(candidate.toLowerCase())) {
          return candidate;
        }
      }
      return null;
    }

    if (clean.contains('/')) {
      // Path-style: resolved from the vault root.
      final candidates = <String>{
        clean,
        if (!clean.endsWith('.md')) '$clean.md',
      };
      for (final candidate in candidates) {
        if (_allLowerPaths.contains(candidate.toLowerCase())) {
          return candidate;
        }
      }
      return null;
    }

    // Short name: match by basename, case-insensitively, with or without
    // extension. Obsidian tolerates case differences.
    final matches =
        _basenameIndex[clean.toLowerCase()] ??
        _basenameNoExtIndex[_stripExtension(clean.toLowerCase())];
    if (matches != null && matches.isNotEmpty) {
      return matches.first;
    }
    return null;
  }

  String? resolveRelativeLink(String url, {required File fromFile}) {
    var path = url;
    final hashIndex = path.indexOf('#');
    if (hashIndex >= 0) {
      path = path.substring(0, hashIndex);
    }
    final queryIndex = path.indexOf('?');
    if (queryIndex >= 0) {
      path = path.substring(0, queryIndex);
    }
    if (path.isEmpty) {
      return null;
    }

    final fromDir = fromFile.parent.path.replaceAll('\\', '/');
    final normalized = _normalizePath('$fromDir/$path');

    // Vault-relative position.
    final base = docsDir.path.replaceAll('\\', '/');
    if (normalized.startsWith('$base/')) {
      final relative = normalized.substring(base.length + 1);
      final candidates = <String>{
        relative,
        if (!relative.endsWith('.md')) '$relative.md',
      };
      for (final candidate in candidates) {
        if (_allLowerPaths.contains(candidate.toLowerCase())) {
          return candidate;
        }
      }
      return null;
    }

    // Outside the vault (rare) — fall back to the real filesystem.
    if (File(normalized).existsSync()) {
      return normalized;
    }
    return null;
  }
}

String _stripExtension(String basename) {
  final dot = basename.lastIndexOf('.');
  if (dot <= 0) {
    return basename;
  }
  return basename.substring(0, dot);
}

String _normalizePath(String path) {
  final parts = <String>[];
  for (final segment in path.split('/')) {
    if (segment.isEmpty || segment == '.') {
      continue;
    }
    if (segment == '..') {
      if (parts.isNotEmpty && parts.last != '..') {
        parts.removeLast();
      } else {
        parts.add(segment);
      }
    } else {
      parts.add(segment);
    }
  }
  return parts.join('/');
}

const _usage = '''
Usage: dart run scripts/check_doc_links.dart [--changed] [--help]

Scans docs/**/*.md for wikilinks ([[path|alias]]) and relative markdown
links, resolving them against the docs/ vault root. External URLs and
#anchors are skipped. Broken links exit with code 1.

  --changed   Only check docs in the git change set (staged + unstaged +
              untracked). When the change set deletes or renames docs, the
              whole vault is scanned so incoming links to the removed docs
              are caught.
''';
