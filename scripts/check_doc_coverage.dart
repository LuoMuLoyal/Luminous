import 'dart:io';

import 'check_doc_links.dart';
import 'doc_coverage.dart';
import 'tooling_support.dart';

/// Documentation coverage check for Luminous.
///
/// By default this script **blocks** (exit 1) when code files are staged/changed
/// but no `docs/` files are included. Use `--warning-only` for a non-blocking
/// report (e.g. in daily checks).
///
/// `--verify` runs a full governance check on the whole docs tree (mirroring
/// Lucent's `check-docs-updated.ts --verify`): doc-map references exist, doc
/// links resolve, front-matter completeness, 90-day freshness (`status: frozen`
/// exempt), doc readership (every `status: active` doc outside standing
/// channels must be listed in doc-map or linked from another doc), and
/// `lib/features/*` doc-map coverage. Exit(1) on any problem.
///
/// `SKIP_DOC_CHECK=1` bypasses the blocking coverage path only — it does not
/// apply to `--verify` (or `--warning-only`). `git commit --no-verify` bypasses
/// the whole hook.
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

    // Bypass (only meaningful in blocking mode).
    if (!options.warningOnly && Platform.environment['SKIP_DOC_CHECK'] == '1') {
      stdout.writeln('[doc-check] Skipped (SKIP_DOC_CHECK=1)');
      return;
    }

    final configFile = resolveExistingFile(
      options.configPath ?? defaultDocCoverageConfigPath(context.repoRoot),
      repoRoot: context.repoRoot,
    );
    final config = loadDocCoverageConfig(configFile);
    final changedFiles = await collectChangedFiles(
      context.repoRoot,
      stagedOnly: options.stagedOnly,
    );

    if (changedFiles.isEmpty) {
      stdout.writeln('Documentation coverage: no changed files detected.');
      return;
    }

    final documentedFiles = changedFiles
        .map((file) => file.replaceAll('\\', '/'))
        .where((file) => file.startsWith('docs/'))
        .toList(growable: false);

    final report = buildDocCoverageReport(
      config: config,
      changedFiles: changedFiles,
      documentedFiles: documentedFiles,
    );
    stdout.writeln(renderDocCoverageReport(report));

    // Default: block the commit if code files are staged/changed but NO
    // documentation files are included. Per-rule warnings about specific
    // missing docs are printed above but do not independently block.
    //
    // --warning-only: skip the blocking check, just print the report.
    if (!options.warningOnly && report.matchedRules.isNotEmpty) {
      final hasCodeChanges = report.matchedRules.any(
        (m) => m.touchedCodeFiles.isNotEmpty,
      );
      if (hasCodeChanges && documentedFiles.isEmpty) {
        stderr.writeln('');
        stderr.writeln(
          'Documentation check failed: code files are staged/changed but no '
          'documentation files (docs/) are included.\n'
          'Bypass with SKIP_DOC_CHECK=1 or --no-verify.',
        );
        exitCode = 1;
      }
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
  var stagedOnly = false;
  var warningOnly = false;
  var verify = false;
  String? configPath;
  var showHelp = false;

  for (var index = 0; index < args.length; index += 1) {
    final argument = args[index];
    if (argument == '--staged') {
      stagedOnly = true;
      continue;
    }
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
    if (argument == '--config') {
      if (index + 1 >= args.length) {
        throw const FormatException('Missing value for argument: --config');
      }
      configPath = args[index + 1];
      index += 1;
      continue;
    }
    if (argument.startsWith('--config=')) {
      final value = argument.substring('--config='.length);
      if (value.isEmpty) {
        throw const FormatException('Missing value for argument: --config');
      }
      configPath = value;
      continue;
    }
    throw FormatException('Unexpected argument: $argument');
  }

  return _ParsedArgs(
    stagedOnly: stagedOnly,
    warningOnly: warningOnly,
    verify: verify,
    configPath: configPath,
    showHelp: showHelp,
  );
}

class _ParsedArgs {
  const _ParsedArgs({
    required this.stagedOnly,
    required this.warningOnly,
    required this.verify,
    required this.configPath,
    required this.showHelp,
  });

  final bool stagedOnly;
  final bool warningOnly;
  final bool verify;
  final String? configPath;
  final bool showHelp;
}

const _usage = '''
Usage: dart run scripts/check_doc_coverage.dart [options]

By default this script blocks (exit 1) when code files are staged/changed
but no docs/ files are included.

Options:
  --staged            Read staged changes instead of the working tree.
  --warning-only      Do not block; just print the per-rule report.
  --verify            Verify doc-map references, doc link integrity,
                      front-matter metadata, stale active docs, doc
                      readership, and feature-dir coverage (every
                      lib/features/* dir must be matched by a doc-map rule).
                      Docs marked 'status: frozen' are exempt from the
                      freshness checks; exit(1) on problems.
  --config <path>     Use an explicit doc coverage config path.
  --help              Show this help text.

Environment:
  SKIP_DOC_CHECK=1    Bypass the blocking coverage check only (ignored with
                      --warning-only; --verify always runs).
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
      for (final link in extractWikilinks(scanLine)) {
        final resolved = vault.resolveWikilink(link.target, fromFile: file);
        if (resolved != null && resolved != relative) {
          linked.add('docs/$resolved');
        }
      }
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

/// Full-tree documentation governance check (--verify). Mirrors Lucent's
/// `check-docs-updated.ts --verify`.
Future<void> _runVerify(ToolContext context) async {
  final docsDir = Directory(
    '${context.repoRoot.path}${Platform.pathSeparator}docs',
  );
  if (!docsDir.existsSync()) {
    stderr.writeln('Docs vault not found: ${docsDir.path}');
    exitCode = 1;
    return;
  }

  final configFile = resolveExistingFile(
    defaultDocCoverageConfigPath(context.repoRoot),
    repoRoot: context.repoRoot,
  );
  final config = loadDocCoverageConfig(configFile);
  final availableDocs = _collectDocPaths(docsDir);
  final problems = <String>[];

  // (a) Doc-map reference existence (literal + glob orphans).
  problems.addAll(findDocMapOrphans(config, availableDocs));
  problems.addAll(findDocMapGlobOrphans(config, availableDocs));

  // (b) Link integrity — wikilinks and relative links must resolve
  // (same resolution semantics as check_doc_links.dart).
  final vault = VaultIndex(docsDir);
  for (final file in vault.markdownFiles) {
    problems.addAll(checkDocFileLinks(vault, file));
  }

  // (c) Front-matter completeness on the required patterns.
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

  // (d) Freshness — front-matter `updated` staleness and `status: stale`
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

  // (e) Readership — subject docs must be in doc-map or linked from another
  // doc.
  final linkedPaths = _collectVaultLinkedPaths(vault);
  final subjects = readershipSubjectPaths(activeDocs, contentByPath);
  problems.addAll(
    findUnreferencedActiveDocs(
      config: config,
      subjectPaths: subjects,
      linkedPaths: linkedPaths,
    ).map(
      (path) =>
          '$path: unreferenced — add a doc-map reference or a link from another doc',
    ),
  );

  // (f) Feature-dir coverage — every lib/features/* dir must be matched by a
  // rule's code glob (or a documented exemption).
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
      findUncoveredFeatureDirs(config.rules, featureDirs).map(
        (dir) =>
            '$dir: feature dir not covered by any doc-map rule — add a rule or a documented exemption',
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
    'Doc verification passed (doc-map references, link integrity, '
    'front-matter, freshness, readership, feature coverage).',
  );
}

String _todayIso() {
  final now = DateTime.now();
  final month = now.month.toString().padLeft(2, '0');
  final day = now.day.toString().padLeft(2, '0');
  return '${now.year}-$month-$day';
}
