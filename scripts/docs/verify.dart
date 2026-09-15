import 'dart:io';

import 'links.dart';
import 'coverage.dart';
import '../support.dart';

/// Documentation governance check for Luminous.
///
/// The code→docs coverage mapping (doc-map.yaml, per-rule report) was retired
/// on 2026-09-15 after its two-week observation window (docs/TODO.md): the
/// structural guarantees in `--verify` cover its value, and per-feature doc
/// duties live in each `lib/features/<feature>/README.md` plus the AGENTS.md
/// doc rules.
///
/// `--verify` runs the full governance check on the whole docs tree:
/// doc link integrity, front-matter completeness, 90-day freshness
/// (`status: frozen` exempt), doc readership (every `status: active` doc
/// must be linked from another doc), and `lib/features/*` README coverage.
/// Exit(1) on any problem.
///
/// Without `--verify` the script prints a doc freshness advisory and never
/// blocks (consumed by daily checks via `--warning-only`).
Future<void> main(List<String> args) async {
  final context = ToolContext.fromScript(Platform.script);

  try {
    final options = _parseArgs(args);
    if (options.showHelp) {
      stdout.writeln(_usage);
      return;
    }
    if (options.verify) {
      await _runVerify(context);
      return;
    }

    // Doc freshness advisory (front-matter based) — runs in every mode and
    // never blocks. Consumed by daily checks via --warning-only.
    final freshness = analyzeDocFreshness(
      contentByPath: _collectDocContents(context.repoRoot),
      today: _todayIso(),
    );
    if (freshness.hasWarnings) {
      stdout.writeln('Doc freshness warnings:');
      for (final path in freshness.staleActiveDocs) {
        stdout.writeln(
          '  - $path: stale (>$staleDocThresholdDays days without update — '
          'review or archive)',
        );
      }
      for (final path in freshness.staleStatusDocs) {
        stdout.writeln('  - $path: marked status: stale — archive it');
      }
      stdout.writeln('');
    }
  } on ProcessException catch (error) {
    stderr.writeln(error.message);
    exitCode = error.errorCode;
  } on FormatException catch (error) {
    stderr.writeln(error.message);
    stderr.writeln('');
    stderr.writeln(_usage);
    exitCode = 64;
  } on StateError catch (error) {
    stderr.writeln(error.message);
    exitCode = 1;
  }
}

_ParsedArgs _parseArgs(List<String> args) {
  var warningOnly = false;
  var verify = false;
  var showHelp = false;

  for (final argument in args) {
    if (argument == '--warning-only') {
      warningOnly = true;
      continue;
    }
    if (argument == '--verify') {
      verify = true;
      continue;
    }
    if (argument == '--help' || argument == '-h') {
      showHelp = true;
      continue;
    }
    throw FormatException('Unexpected argument: $argument');
  }

  return _ParsedArgs(
    warningOnly: warningOnly,
    verify: verify,
    showHelp: showHelp,
  );
}

class _ParsedArgs {
  const _ParsedArgs({
    required this.warningOnly,
    required this.verify,
    required this.showHelp,
  });

  final bool warningOnly;
  final bool verify;
  final bool showHelp;
}

const _usage = '''
Usage: dart run scripts/docs/verify.dart [options]

Without --verify this script prints a doc freshness advisory and never
blocks. The code→docs coverage mapping (doc-map.yaml) was retired on
2026-09-15 after its two-week observation window.

Options:
  --warning-only      Alias of the default advisory mode.
  --verify            Verify doc link integrity, front-matter metadata,
                      stale active docs, doc readership (every
                      'status: active' doc linked from another doc), and
                      feature README coverage (every lib/features/* dir
                      must ship a README). Docs marked 'status: frozen'
                      are exempt from the freshness checks; exit(1) on
                      problems.
  --help              Show this help text.
''';

/// Collects `docs/**/*.md` contents (excluding `.obsidian/`) keyed by
/// display path, for the freshness advisory.
Map<String, String> _collectDocContents(Directory repoRoot) {
  final docsDir = Directory('${repoRoot.path}${Platform.pathSeparator}docs');
  if (!docsDir.existsSync()) {
    return const {};
  }
  final docsBase = docsDir.path.replaceAll('\\', '/');
  final contents = <String, String>{};
  for (final file in collectMarkdownFiles(docsDir)) {
    final relative = file.path
        .replaceAll('\\', '/')
        .substring(docsBase.length + 1);
    if (relative.startsWith('archive/')) {
      // Historical records are exempt from freshness advisories.
      continue;
    }
    contents['docs/$relative'] = file.readAsStringSync();
  }
  return contents;
}

/// Collects display paths (`docs/...`) of all markdown files under [docsDir].
List<String> _collectDocPaths(Directory docsDir) {
  final docsBase = docsDir.path.replaceAll('\\', '/');
  return collectMarkdownFiles(docsDir)
      .map((file) {
        final relative = file.path
            .replaceAll('\\', '/')
            .substring(docsBase.length + 1);
        return 'docs/$relative';
      })
      .toList(growable: false);
}

/// Vault-relative paths (`TODO.md`) of every doc linked from a
/// navigational doc. Migration logs and archive/ are historical records,
/// not standing reader channels, so their links do not count.
Set<String> _collectVaultLinkedPaths(VaultIndex vault) {
  final linked = <String>{};
  for (final file in vault.markdownFiles) {
    final relative = vault.relativePath(file);
    if (relative.startsWith('logs/migration-log/') ||
        relative.startsWith('archive/')) {
      continue;
    }
    final content = file.readAsStringSync();
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
      final scanLine = stripInlineCode(line);
      for (final link in extractMarkdownLinks(scanLine)) {
        final url = link.url ?? link.target;
        if (isExternalUrl(url) || url.startsWith('#')) {
          continue;
        }
        final resolved = vault.resolveRelativeLink(url, fromFile: file);
        if (resolved == null || resolved.startsWith('../')) {
          continue; // unresolved or outside the vault
        }
        if (resolved != relative) {
          linked.add('docs/$resolved');
        }
      }
    }
  }
  return linked;
}

/// Full-tree documentation governance check (--verify).
Future<void> _runVerify(ToolContext context) async {
  final docsDir = Directory(
    '${context.repoRoot.path}${Platform.pathSeparator}docs',
  );
  if (!docsDir.existsSync()) {
    stderr.writeln('Docs vault not found: ${docsDir.path}');
    exitCode = 1;
    return;
  }

  final availableDocs = _collectDocPaths(docsDir);
  final problems = <String>[];

  // (a) Link integrity — wikilinks and relative links must resolve
  // (same resolution semantics as links.dart). Archive snapshots are exempt
  // from outgoing-link checks (see VaultIndex.checkableMarkdownFiles).
  final vault = VaultIndex(docsDir);
  for (final file in vault.checkableMarkdownFiles) {
    problems.addAll(checkDocFileLinks(vault, file));
  }

  // (b) Front-matter completeness on the required patterns.
  final activeDocs = availableDocs.where(isActiveDoc).toList(growable: false);
  final contentByPath = <String, String>{
    for (final doc in activeDocs)
      doc: File(
        '${docsDir.path}${Platform.pathSeparator}'
        '${doc.substring('docs/'.length).replaceAll('/', Platform.pathSeparator)}',
      ).readAsStringSync(),
  };
  problems.addAll(
    findDocsMissingFrontMatter(activeDocs, contentByPath).map(
      (path) =>
          '$path: missing/incomplete front-matter (need status / owner / updated)',
    ),
  );

  // (c) Freshness — front-matter `updated` staleness and `status: stale`
  // archiving, scoped to active docs (archive/ and migration logs are not
  // active, so an archived doc is never told to archive itself). `status:
  // frozen` docs are exempt via [isFrozenDoc].
  final freshness = analyzeDocFreshness(
    contentByPath: contentByPath,
    today: _todayIso(),
  );
  problems.addAll(
    freshness.staleActiveDocs.map(
      (path) =>
          '$path: stale (>$staleDocThresholdDays days without update — '
          'review or archive)',
    ),
  );
  problems.addAll(
    freshness.staleStatusDocs.map(
      (path) => '$path: status=stale but not archived — move to docs/archive/',
    ),
  );

  // (d) Readership — subject docs must be linked from another doc.
  final linkedPaths = _collectVaultLinkedPaths(vault);
  final subjects = readershipSubjectPaths(activeDocs, contentByPath);
  problems.addAll(
    findUnreferencedActiveDocs(
      subjectPaths: subjects,
      linkedPaths: linkedPaths,
    ).map(
      (path) =>
          '$path: unreferenced — add a link from another doc or archive it',
    ),
  );

  // (e) Feature README coverage — every lib/features/* dir must ship a
  // code-adjacent README (or a documented exemption).
  final featuresDir = Directory(
    '${context.repoRoot.path}${Platform.pathSeparator}lib'
    '${Platform.pathSeparator}features',
  );
  if (featuresDir.existsSync()) {
    final featureDirs = featuresDir
        .listSync()
        .whereType<Directory>()
        .map((dir) => dir.path.split(Platform.pathSeparator).last)
        .toList(growable: false);
    problems.addAll(
      findUncoveredFeatureDirs(
        featureDirs,
        (dir) => File(
          '${featuresDir.path}${Platform.pathSeparator}$dir'
          '${Platform.pathSeparator}README.md',
        ).existsSync(),
      ).map(
        (dir) =>
            '$dir: feature dir has no lib/features/$dir/README.md — add one or a documented exemption',
      ),
    );
  }

  if (problems.isNotEmpty) {
    stderr.writeln('Doc verification failed:');
    for (final problem in problems) {
      stderr.writeln('  - $problem');
    }
    exitCode = 1;
    return;
  }
  stdout.writeln(
    'Doc verification passed (link integrity, front-matter, freshness, '
    'readership, feature README coverage).',
  );
}

String _todayIso() {
  final now = DateTime.now();
  final month = now.month.toString().padLeft(2, '0');
  final day = now.day.toString().padLeft(2, '0');
  return '${now.year}-$month-$day';
}
