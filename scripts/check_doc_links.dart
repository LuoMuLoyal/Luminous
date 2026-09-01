import 'dart:io';

import 'tooling_support.dart';

/// Wikilink & relative-link integrity check for the Luminous docs vault.
///
/// Scans `docs/**/*.md` (excluding `.obsidian/`) for:
/// - Obsidian wikilinks `[[path|alias]]` / `[[path]]` (with or without `.md`)
/// - Markdown links `[text](path)` (relative links; external URLs skipped)
/// - Repo-relative path references (`lib/**`, `docs/**`, `plans/**`) found in
///   doc bodies, validated for existence against the repo root (see
///   [extractRepoPathTokens] for the extraction rules)
///
/// Targets are resolved against the vault root (`docs/`). Wikilinks match
/// case-insensitively (Obsidian semantics); relative links resolve from the
/// containing file's directory. Any broken link or missing repo path exits
/// with code 1.
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
    problems.addAll(checkDocFileLinks(vault, file, repoRoot: repoRoot));
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

/// Scans [file] for broken wikilinks, relative markdown links, and missing
/// repo-relative path references (`lib/`, `docs/`, `plans/` tokens).
///
/// Returns human-readable problem strings prefixed with the display path
/// (e.g. `docs/TODO.md: [[Missing]] — no matching file`). Shared
/// with the `--verify` mode of check_doc_coverage.dart so both tools resolve
/// links identically.
///
/// [repoRoot] is the base for repo-relative path existence checks; defaults
/// to the docs vault's parent directory.
List<String> checkDocFileLinks(
  VaultIndex vault,
  File file, {
  Directory? repoRoot,
}) {
  final problems = <String>[];
  final root = repoRoot ?? vault.repoRoot;
  final content = file.readAsStringSync();
  final relative = vault.relativePath(file);
  var inFence = false;
  final reportedPaths = <String>{};
  // Historical records are exempt from repo-path validation only (their
  // wikilinks/relative links are still checked) — see
  // [isRepoPathCheckScopedOut].
  final pathCheckEnabled = !isRepoPathCheckScopedOut(relative);

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

    // Repo-relative path references. Unlike links, inline code is the
    // PRIMARY source here (a backtick-quoted path is a deliberate file
    // reference), so this runs on the raw line, not [scanLine].
    if (pathCheckEnabled) {
      for (final token in extractRepoPathTokens(line)) {
        if (reportedPaths.contains(token)) {
          continue;
        }
        if (isExemptRepoPath(token) || repoPathExists(root, token)) {
          continue;
        }
        reportedPaths.add(token);
        problems.add('docs/$relative: path $token not found');
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

// --- Repo-relative path references (Phase 3C) ----------------------------
//
// Doc bodies reference repo files as plain path tokens (`lib/app/router.dart`,
// `docs/logs/migration-log/`). Unlike wikilinks these carry no link syntax,
// so they are extracted heuristically and validated for existence against
// the repo root. Zero false positives is a hard requirement (the check gates
// pre-commit), hence the deliberately conservative extraction rules below.

/// Repo-relative prefixes whose references are validated for existence.
const List<String> repoPathPrefixes = ['lib/', 'docs/', 'plans/'];

/// Whether [vaultRelative] (a docs-vault-relative path) is scoped out of
/// repo-path existence validation.
///
/// - `archive/**`: frozen historical records, checked out of the governance
///   loop by design.
/// - `logs/migration-log/**`: the append-only dated ledger — entries document
///   past tree states (paths since renamed or removed) and must stay valid as
///   written; validating them against the current tree would contradict the
///   ledger's immutability. The standing index (`docs/logs/MigrationLog.md`)
///   is still validated.
bool isRepoPathCheckScopedOut(String vaultRelative) {
  return vaultRelative.startsWith('archive/') ||
      vaultRelative.startsWith('logs/migration-log/');
}

/// Repo paths referenced by current docs that intentionally do not exist in
/// this repo. Exact token matches (trailing `/` ignored on both sides).
/// Keep this list minimal — prefer fixing the doc over adding an exemption;
/// every entry carries the reason it cannot be resolved.
const List<String> exemptRepoPaths = [
  // Date-placeholder naming template used in migration-log guidance, not a
  // concrete file.
  'docs/logs/migration-log/YYYY-MM-DD.md',
  // Lucent's generated OpenAPI artifact (sibling repo) — scripts resolve it
  // against the Lucent checkout, not this repo.
  'docs/reference/generated/openapi.json',
  // openapi-generator option name quoted in prose ("docs/tests 生成关闭").
  'docs/tests',
  // Legacy directories documented as removed (architecture.md, ADR-0001).
  'lib/pages/',
  'lib/stores/',
  'lib/viewmodels/',
  'lib/components/',
  // Settings widgets subtree documented as removed (architecture.md).
  'lib/core/widgets/settings/',
  // RecordTypeColors file documented as deleted in the referencing doc
  // itself (Design_System.md).
  'lib/features/record/domain/entities/record_type_colors.dart',
  // Stale rename lag: the file now lives at .../shared/form_mixin.dart;
  // exempt until the doc catches up.
  'lib/features/auth/presentation/providers/shared/auth_form_mixin.dart',
];

final Set<String> _exemptRepoPathsNormalized = {
  for (final path in exemptRepoPaths) _withoutTrailingSlash(path),
};

/// Characters that mark a token as a glob/wildcard or a placeholder template
/// rather than a concrete path (`*`, `**`, `?`, `[...]`, `{...}`, `<...>`).
final RegExp _globOrPlaceholderChars = RegExp(r'[*?{}\[\]<>]');

/// Trailing punctuation prose attaches to a token (sentence period, comma,
/// CJK separators, closing brackets/quotes). Stripped before validation.
const String _trailingPunctuation = '.,;:!?)】」）、，。；：！？"\'';

/// Leading brackets that prose may wrap a token in.
const String _leadingPunctuation = '(（【「『"\'';

/// URL scheme guard (same semantics as [isExternalUrl]).
final RegExp _urlScheme = RegExp(r'^[a-zA-Z][a-zA-Z0-9+.\-]*:');

/// Inline code spans in a line.
final RegExp _inlineCodeSpan = RegExp(r'`([^`]*)`');

/// Separators for splitting an inline code span into tokens: whitespace,
/// list separators, and `|`-joined shorthand (`lib/a|lib/b`).
final RegExp _inlineListSeparators = RegExp(r'[\s,;、，；|]+');

/// Plain-text path shapes outside inline code: path characters only, so
/// CJK/whitespace delimiters stop the match naturally.
final RegExp _plainTextPath = RegExp(r'\b(?:lib|docs|plans)/[A-Za-z0-9_\-./]+');

/// Obsidian wikilinks (`[[target|alias]]`) — vault-relative by definition,
/// governed by the link checks below.
final RegExp _wikilinkSyntax = RegExp(r'\[\[[^\[\]]*\]\]');

/// Markdown link/image targets (`](url)`) — vault-relative, governed by the
/// link checks below.
final RegExp _markdownLinkTarget = RegExp(r'\]\(([^)\s]*)\)');

/// Repo-relative path tokens referenced by [line], deduplicated in
/// first-occurrence order.
///
/// Two extraction sources, in priority order:
///
/// 1. Inline code spans (primary) — a backtick-quoted path is a deliberate
///    reference. Span contents are tokenized on whitespace and list
///    separators, so command-like spans (`dart run scripts/x.dart`) yield
///    tokens that simply never start with a [repoPathPrefixes] prefix.
/// 2. Plain text outside inline code (secondary) — prose references without
///    backticks. URLs are removed wholesale first (a URL tail can contain a
///    `docs/...` shape).
///
/// A candidate is only checkable when it starts with a [repoPathPrefixes]
/// prefix, contains no whitespace, and names something beyond the bare tree
/// prefix (a file extension or a deeper directory segment — `docs/` or `lib`
/// alone is prose shorthand for a whole tree, not a checkable reference).
///
/// Design trade-offs (chosen for zero false positives; borderline shapes are
/// skipped rather than guessed):
/// - URL-shaped tokens, globs/placeholders, and `...` ellipsis shorthands
///   are skipped entirely.
/// - `#anchor` suffixes are stripped before validation.
/// - Trailing prose punctuation is stripped (no path ends with a bare dot;
///   `...` endings were already skipped above).
/// - A plain-text match immediately preceded by `/` is a sub-path of a
///   larger reference (`../Lucent/docs/x.md`) and is skipped.
List<String> extractRepoPathTokens(String line) {
  final tokens = <String>[];
  final seen = <String>{};
  void add(String? candidate) {
    if (candidate != null && seen.add(candidate)) {
      tokens.add(candidate);
    }
  }

  for (final span in _inlineCodeSpan.allMatches(line)) {
    for (final piece in span.group(1)!.split(_inlineListSeparators)) {
      add(_normalizePathCandidate(piece));
    }
  }

  final plainText = line
      // URLs removed wholesale: a URL tail can contain a `docs/...` shape.
      .replaceAll(RegExp(r'\S*://\S*'), ' ')
      // Wikilinks and markdown link targets are vault-relative and already
      // governed by the link checks above — single authority, and no false
      // repo-path reports for vault-relative directory structures.
      .replaceAll(_wikilinkSyntax, ' ')
      .replaceAll(_markdownLinkTarget, ']()')
      .replaceAll(_inlineCodeSpan, ' ');
  for (final match in _plainTextPath.allMatches(plainText)) {
    final start = match.start;
    if (start > 0 &&
        (plainText[start - 1] == '/' || plainText[start - 1] == '-')) {
      // Sub-path of a larger reference (`../Lucent/docs/x.md`) or a
      // hyphenated compound — not a repo-relative reference.
      continue;
    }
    add(_normalizePathCandidate(match.group(0)!));
  }
  return tokens;
}

/// Normalizes [raw] into a checkable repo path token, or `null` when the
/// token is not a checkable reference (see [extractRepoPathTokens]).
String? _normalizePathCandidate(String raw) {
  var token = raw.trim();
  if (token.isEmpty) {
    return null;
  }
  // Ellipsis shorthand ("lib/foo...") — "and so on", no concrete target.
  if (token.endsWith('...')) {
    return null;
  }
  token = _stripEdges(token);
  if (token.isEmpty) {
    return null;
  }
  // Anchor suffix: `docs/README.md#section` refers to docs/README.md.
  final hashIndex = token.indexOf('#');
  if (hashIndex >= 0) {
    token = _stripEdges(token.substring(0, hashIndex));
  }
  if (token.isEmpty) {
    return null;
  }
  if (_urlScheme.hasMatch(token)) {
    return null; // URL, not a repo path.
  }
  if (_globOrPlaceholderChars.hasMatch(token)) {
    return null; // Glob/wildcard or `<...>` placeholder template.
  }
  final prefix = repoPathPrefixes.where(token.startsWith).firstOrNull;
  if (prefix == null) {
    return null;
  }
  // Bare tree prefixes (`lib`, `lib/`, `docs/`) are whole-tree shorthand.
  if (_withoutTrailingSlash(token) == _withoutTrailingSlash(prefix)) {
    return null;
  }
  return token;
}

/// Strips prose punctuation hugging the token edges.
String _stripEdges(String token) {
  var result = token;
  while (result.isNotEmpty &&
      _trailingPunctuation.contains(result[result.length - 1])) {
    result = result.substring(0, result.length - 1);
  }
  while (result.isNotEmpty && _leadingPunctuation.contains(result[0])) {
    result = result.substring(1);
  }
  return result;
}

String _withoutTrailingSlash(String path) {
  if (path.length > 1 && path.endsWith('/')) {
    return path.substring(0, path.length - 1);
  }
  return path;
}

/// Whether [token] is on the explicit [exemptRepoPaths] list. Matching
/// ignores the trailing slash so `lib/pages` and `lib/pages/` are equivalent.
bool isExemptRepoPath(String token) {
  return _exemptRepoPathsNormalized.contains(_withoutTrailingSlash(token));
}

/// Whether [token] resolves to an existing file or directory under
/// [repoRoot]. A trailing `/` or an extension-less last segment means a
/// directory reference; either kind existing satisfies the reference — the
/// check targets genuinely broken references, not file-vs-directory intent.
bool repoPathExists(Directory repoRoot, String token) {
  final withoutSlash = _withoutTrailingSlash(token);
  if (withoutSlash.isEmpty) {
    return true;
  }
  final fsPath =
      '${repoRoot.path}${Platform.pathSeparator}'
      '${withoutSlash.replaceAll('/', Platform.pathSeparator)}';
  return File(fsPath).existsSync() || Directory(fsPath).existsSync();
}

class VaultIndex {
  VaultIndex(this.docsDir) {
    _indexDir(docsDir, docsDir);
  }

  final Directory docsDir;
  final List<File> markdownFiles = <File>[];

  /// Repository root — the docs vault's parent directory. Base for
  /// repo-relative path references (`lib/`, `docs/`, `plans/`) found in doc
  /// bodies.
  Directory get repoRoot => docsDir.parent;

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

Scans docs/**/*.md for wikilinks ([[path|alias]]), relative markdown links,
and repo-relative path references (lib/, docs/, plans/ tokens in inline code
or prose), resolving them against the docs/ vault root and the repo root
respectively. External URLs, globs, ellipsis shorthands and #anchors are
skipped; referenced paths are matched against an explicit exemption list.
Broken links or missing repo paths exit with code 1.

  --changed   Only check docs in the git change set (staged + unstaged +
              untracked). When the change set deletes or renames docs, the
              whole vault is scanned so incoming links to the removed docs
              are caught.
''';
