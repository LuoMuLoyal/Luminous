import 'dart:io';

import 'doc_coverage.dart';
import 'tooling_support.dart';

/// Documentation coverage check for Luminous.
///
/// By default this script **blocks** (exit 1) when code files are staged/changed
/// but no `docs/` files are included. Use `--warning-only` for a non-blocking
/// report (e.g. in daily checks).
///
/// Bypass with `SKIP_DOC_CHECK=1` or `git commit --no-verify`.
Future<void> main(List<String> args) async {
  final context = ToolContext.fromScript(Platform.script);

  try {
    final options = _parseArgs(args);
    if (options.showHelp) {
      stdout.writeln(_usage);
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
    configPath: configPath,
    showHelp: showHelp,
  );
}

class _ParsedArgs {
  const _ParsedArgs({
    required this.stagedOnly,
    required this.warningOnly,
    required this.configPath,
    required this.showHelp,
  });

  final bool stagedOnly;
  final bool warningOnly;
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
  --config <path>     Use an explicit doc coverage config path.
  --help              Show this help text.

Environment:
  SKIP_DOC_CHECK=1    Bypass the blocking check (ignored with --warning-only).
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
    contents['docs/$relative'] = file.readAsStringSync();
  }
  return contents;
}

String _todayIso() {
  final now = DateTime.now();
  final month = now.month.toString().padLeft(2, '0');
  final day = now.day.toString().padLeft(2, '0');
  return '${now.year}-$month-$day';
}
