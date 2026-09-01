import 'dart:io';

import '../support.dart';

Future<void> main(List<String> args) async {
  final context = ToolContext.fromScript(Platform.script);
  if (args.isEmpty) {
    stderr.writeln(
      'Usage: dart run scripts/hooks/git.dart <install|pre-commit|commit-msg|pre-push> [args]',
    );
    exitCode = 64;
    return;
  }

  try {
    switch (args.first) {
      case 'install':
        await _installHooks(context);
      case 'pre-commit':
        await runPreCommitChecks(context);
      case 'pre-push':
        await runPrePushChecks(context);
      case 'commit-msg':
        if (args.length < 2) {
          stderr.writeln(
            'commit-msg hook requires a commit message file path argument.',
          );
          exitCode = 64;
          return;
        }
        validateCommitMessage(args[1]);
      default:
        stderr.writeln('Unsupported git hook: ${args.first}');
        exitCode = 64;
    }
  } on ProcessException catch (error) {
    stderr.writeln(error.message);
    exitCode = error.errorCode;
  } on StateError catch (error) {
    stderr.writeln(error.message);
    exitCode = 1;
  }
}

Future<void> _installHooks(ToolContext context) async {
  final gitDir = Directory(
    '${context.repoRoot.path}${Platform.pathSeparator}.git',
  );

  if (!gitDir.existsSync()) {
    stderr.writeln('Git repository not found at ${context.repoRoot.path}');
    exitCode = 1;
    return;
  }

  await runLoggedCommand(
    'git',
    ['-C', context.repoRoot.path, 'config', 'core.hooksPath', '.githooks'],
    workingDirectory: context.repoRoot,
    stepName: 'Configure core.hooksPath',
  );
  stdout.writeln('');
  stdout.writeln('Configured core.hooksPath to .githooks');
  stdout.writeln('Git hooks are now shared from .githooks/');
}

Future<void> runPrePushChecks(ToolContext context) async {
  stdout.writeln('==> flutter analyze');
  await runLoggedCommand(
    'flutter',
    ['analyze'],
    workingDirectory: context.repoRoot,
    stepName: 'flutter analyze',
  );
  stdout.writeln('');

  stdout.writeln('==> dart format --set-exit-if-changed');
  await runLoggedCommand(
    'dart',
    ['format', '--set-exit-if-changed', 'lib/', 'test/', 'scripts/'],
    workingDirectory: context.repoRoot,
    stepName: 'dart format --set-exit-if-changed',
  );
  stdout.writeln('');

  // Generated reference docs (design tokens / routes / features) must be
  // fresh — regenerating must produce no diff.
  await runLoggedCommand(
    'dart',
    ['run', 'scripts/docs/generate.dart', '--check'],
    workingDirectory: context.repoRoot,
    stepName: 'dart run scripts/docs/generate.dart --check',
  );
  stdout.writeln('');

  // Structural docs governance (doc-map references, link integrity,
  // front-matter, freshness, readership, README budget).
  await runLoggedCommand(
    'dart',
    ['run', 'scripts/docs/verify.dart', '--verify'],
    workingDirectory: context.repoRoot,
    stepName: 'dart run scripts/docs/verify.dart --verify',
  );
  stdout.writeln('');

  await runLoggedCommand(
    'flutter',
    ['test'],
    workingDirectory: context.repoRoot,
    stepName: 'flutter test',
  );
  stdout.writeln('');

  // Custom lint rules — observation mode (always exit 0); --quiet keeps
  // the output to the per-rule summary.
  await runLoggedCommand(
    'dart',
    ['run', 'bin/luminous_lints.dart', '--quiet'],
    workingDirectory: Directory(
      '${context.repoRoot.path}${Platform.pathSeparator}'
      'tool${Platform.pathSeparator}luminous_lints',
    ),
    stepName: 'luminous_lints (observation)',
  );
}

Future<void> runPreCommitChecks(ToolContext context) async {
  // ── Migration-log overwrite detection (blocking) ────────────
  // Migration logs must be appended to, not overwritten. If a staged
  // migration-log file has more than 5 deleted lines, block the commit.
  // Bypass with SKIP_DOC_CHECK=1 or `git commit --no-verify`.
  if (Platform.environment['SKIP_DOC_CHECK'] != '1') {
    await _checkMigrationLogOverwrite(context);
  }

  // ── Documentation check (report-only, observation) ──────────────
  // Phase 4 of the doc-governance plan retired the "code staged but no
  // docs/ file staged → exit(1)" pre-commit gate: the per-rule doc-touch
  // mapping now runs as a report (--warning-only), while --verify
  // (pre-push / daily) keeps the structural guarantees. After a two-week
  // observation window the mapping is removed entirely (see docs/TODO.md).
  // Bypass with SKIP_DOC_CHECK=1 or `git commit --no-verify`.
  await runLoggedCommand(
    'dart',
    ['run', 'scripts/docs/verify.dart', '--staged', '--warning-only'],
    workingDirectory: context.repoRoot,
    stepName: 'doc-check (report-only)',
  );
  stdout.writeln('');

  // ── Link integrity (blocking) ──────────────────────────────────
  // Broken doc links fail the commit regardless of SKIP_DOC_CHECK.
  // --changed scopes the scan to the git change set (full vault fallback
  // when the change set deletes/renames docs) for fast commit feedback.
  // Scope note: the coverage check above judges only the staged snapshot
  // (--staged), while the link scan reads staged + unstaged + untracked —
  // link resolution sees the working tree, and a not-yet-staged deletion
  // already breaks links, so the scan cannot be narrower.
  await runLoggedCommand(
    'dart',
    ['run', 'scripts/docs/links.dart', '--changed'],
    workingDirectory: context.repoRoot,
    stepName: 'doc-links check (changed)',
  );
  stdout.writeln('');

  // ── Format & analyze staged Dart files ────────────────────────
  final stagedDartFiles = await _listStagedDartFiles(context);
  if (stagedDartFiles.isNotEmpty) {
    // Batch files to avoid hitting Windows command-line length limits.
    // Both `dart format` and `git add` receive the file list as CLI args,
    // so we re-stage each batch right after formatting it.
    const batchSize = 20;
    for (var i = 0; i < stagedDartFiles.length; i += batchSize) {
      final batch = stagedDartFiles.skip(i).take(batchSize).toList();
      await runLoggedCommand(
        'dart',
        ['format', ...batch],
        workingDirectory: context.repoRoot,
        stepName:
            'dart format <staged dart files> (batch ${i ~/ batchSize + 1})',
      );
      // Re-stage the formatted files so the commit includes the changes.
      final gitResult = await Process.run('git', [
        'add',
        ...batch,
      ], workingDirectory: context.repoRoot.path);
      if (gitResult.exitCode != 0) {
        stderr.writeln(gitResult.stderr);
        exitCode = gitResult.exitCode;
        return;
      }
    }
    stdout.writeln('');
  }

  await runLoggedCommand(
    'flutter',
    ['analyze'],
    workingDirectory: context.repoRoot,
    stepName: 'flutter analyze',
  );
}

const _validCommitTypes = [
  'feat',
  'fix',
  'docs',
  'style',
  'refactor',
  'perf',
  'test',
  'build',
  'ci',
  'chore',
  'revert',
];

void validateCommitMessage(String commitMsgPath) {
  final file = File(commitMsgPath);
  if (!file.existsSync()) {
    stderr.writeln('Commit message file not found: $commitMsgPath');
    exitCode = 1;
    return;
  }

  final raw = file.readAsStringSync();
  final lines = raw.split('\n');

  // First non-comment, non-empty line is the header.
  final header = lines
      .where((line) => !line.startsWith('#') && line.trim().isNotEmpty)
      .firstOrNull;

  if (header == null || header.trim().isEmpty) {
    stderr.writeln('Commit message is empty.');
    exitCode = 1;
    return;
  }

  final trimmedHeader = header.trim();

  // Parse: type(scope)!: subject  or  type: subject
  // scope group (group 3) is captured but may be absent — checked below.
  final match = RegExp(
    r'^([a-z]+)(\(([^)]+)\))?!?: (.+)$',
  ).firstMatch(trimmedHeader);

  if (match == null) {
    stderr.writeln('Invalid commit message format.');
    stderr.writeln('  Expected: type(scope): subject');
    stderr.writeln('  Got:      $trimmedHeader');
    stderr.writeln('');
    stderr.writeln('Valid types: ${_validCommitTypes.join(', ')}');
    exitCode = 1;
    return;
  }

  final type = match.group(1)!;
  final scope = match.group(3);
  final subject = match.group(4)!;
  final errors = <String>[];

  // type-enum
  if (!_validCommitTypes.contains(type)) {
    errors.add(
      'Invalid commit type: "$type". '
      'Valid types: ${_validCommitTypes.join(', ')}',
    );
  }

  // scope-empty: [2, 'never'] — scope is mandatory, matching Lucent's
  // commitlint config. This catches bare `type: subject` commits.
  if (scope == null || scope.trim().isEmpty) {
    errors.add(
      'Commit scope must not be empty. Expected: type(scope): subject',
    );
  }

  // subject-empty
  if (subject.trim().isEmpty) {
    errors.add('Commit subject must not be empty.');
  }

  // subject-full-stop
  if (subject.trimRight().endsWith('.')) {
    errors.add('Commit subject must not end with "."');
  }

  // subject-max-length
  if (subject.length > 100) {
    errors.add(
      'Commit subject exceeds 100 characters (current: ${subject.length}).',
    );
  }

  // header-max-length — aligned with Lucent's commitlint (120).
  if (trimmedHeader.length > 120) {
    errors.add(
      'Commit header exceeds 120 characters (current: ${trimmedHeader.length}).',
    );
  }

  if (errors.isNotEmpty) {
    stderr.writeln('Commit message validation failed:');
    for (final error in errors) {
      stderr.writeln('  - $error');
    }
    exitCode = 1;
    return;
  }

  stdout.writeln('✓ $trimmedHeader');
}

/// Max deletion lines allowed in a staged migration-log file before blocking.
const _migrationLogMaxDeletions = 5;

/// Checks staged migration-log files for excessive deletions.
///
/// Migration logs must be **appended** to, not overwritten. If a staged
/// diff for a migration-log file contains more than
/// [_migrationLogMaxDeletions] deleted lines, the commit is blocked.
Future<void> _checkMigrationLogOverwrite(ToolContext context) async {
  final stagedModified = await captureCommandLines('git', [
    'diff',
    '--cached',
    '--name-only',
    '--diff-filter=M',
  ], workingDirectory: context.repoRoot);

  final logPattern = RegExp(r'^docs/logs/migration-log/.+\.md$');
  final logFiles = stagedModified
      .where((f) => logPattern.hasMatch(f.replaceAll('\\', '/')))
      .toList();

  for (final file in logFiles) {
    final result = await Process.run('git', [
      'diff',
      '--cached',
      '--',
      file,
    ], workingDirectory: context.repoRoot.path);
    if (result.exitCode != 0) continue;

    final diff = result.stdout.toString();
    final deletionCount = diff
        .split('\n')
        .where((line) => line.startsWith('-') && !line.startsWith('---'))
        .length;

    if (deletionCount > _migrationLogMaxDeletions) {
      stderr.writeln('');
      stderr.writeln('Migration Log Overwrite Detected:');
      stderr.writeln(
        '  $file has $deletionCount deleted lines in staged diff '
        '(max $_migrationLogMaxDeletions).',
      );
      stderr.writeln('  Migration logs must be appended to, not overwritten.');
      stderr.writeln(
        '  If restructure is needed, keep deletions <= $_migrationLogMaxDeletions.',
      );
      stderr.writeln('  Bypass with SKIP_DOC_CHECK=1 or --no-verify.');
      exitCode = 1;
      return;
    }
  }
}

Future<List<String>> _listStagedDartFiles(ToolContext context) async {
  final lines = await captureCommandLines('git', [
    'diff',
    '--cached',
    '--name-only',
    '--diff-filter=ACMR',
  ], workingDirectory: context.repoRoot);

  return lines.where((line) => line.endsWith('.dart')).toList(growable: false);
}
