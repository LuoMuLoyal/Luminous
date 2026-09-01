import 'dart:io';

import 'bootstrap_generated_sources.dart';
import 'tooling_support.dart';

Future<void> runDailyChecks(ToolContext context, {String? openApiPath}) async {
  await runLoggedCommand(
    'dart',
    ['run', 'scripts/check_doc_coverage.dart', '--warning-only'],
    workingDirectory: context.repoRoot,
    stepName: 'dart run scripts/check_doc_coverage.dart --warning-only',
  );
  stdout.writeln('');

  // Full-tree governance check (doc-map references, link integrity,
  // front-matter, freshness, readership, feature coverage). Blocking —
  // daily checks keep the per-rule coverage report advisory above, but
  // structural doc-governance problems fail the run.
  await runLoggedCommand(
    'dart',
    ['run', 'scripts/check_doc_coverage.dart', '--verify'],
    workingDirectory: context.repoRoot,
    stepName: 'dart run scripts/check_doc_coverage.dart --verify',
  );
  stdout.writeln('');

  // Wikilink / relative-link integrity for the docs vault (blocks on
  // broken links).
  await runLoggedCommand(
    'dart',
    ['run', 'scripts/check_doc_links.dart'],
    workingDirectory: context.repoRoot,
    stepName: 'dart run scripts/check_doc_links.dart',
  );
  stdout.writeln('');

  // Generated reference docs (design tokens / routes / features) must be
  // fresh — regenerating must produce no diff.
  await runLoggedCommand(
    'dart',
    ['run', 'scripts/generate_docs.dart', '--check'],
    workingDirectory: context.repoRoot,
    stepName: 'dart run scripts/generate_docs.dart --check',
  );
  stdout.writeln('');

  await bootstrapGeneratedSources(context, openApiPath: openApiPath);
  stdout.writeln('');

  await runLoggedCommand(
    'flutter',
    ['analyze'],
    workingDirectory: context.repoRoot,
    stepName: 'flutter analyze',
  );
  stdout.writeln('');

  // Custom lint rules (observation) — per-rule summary only.
  await runLoggedCommand(
    'dart',
    ['run', 'bin/luminous_lints.dart', '--quiet'],
    workingDirectory: Directory(
      '${context.repoRoot.path}${Platform.pathSeparator}'
      'tool${Platform.pathSeparator}luminous_lints',
    ),
    stepName: 'luminous_lints (observation)',
  );
  stdout.writeln('');

  await runLoggedCommand(
    'dart',
    ['format', '--set-exit-if-changed', 'lib/', 'test/', 'scripts/'],
    workingDirectory: context.repoRoot,
    stepName: 'dart format --set-exit-if-changed',
  );
  stdout.writeln('');

  await runLoggedCommand(
    'flutter',
    ['test', '--coverage'],
    workingDirectory: context.repoRoot,
    stepName: 'flutter test --coverage',
  );
  stdout.writeln('');

  await runLoggedCommand(
    'dart',
    [
      'run',
      'scripts/verify_lucent_openapi_sync.dart',
      if (openApiPath != null) '--openapi=$openApiPath',
    ],
    workingDirectory: context.repoRoot,
    stepName: 'dart run scripts/verify_lucent_openapi_sync.dart',
  );
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
    ['run', 'scripts/generate_docs.dart', '--check'],
    workingDirectory: context.repoRoot,
    stepName: 'dart run scripts/generate_docs.dart --check',
  );
  stdout.writeln('');

  // Structural docs governance (doc-map references, link integrity,
  // front-matter, freshness, readership, README budget).
  await runLoggedCommand(
    'dart',
    ['run', 'scripts/check_doc_coverage.dart', '--verify'],
    workingDirectory: context.repoRoot,
    stepName: 'dart run scripts/check_doc_coverage.dart --verify',
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
    ['run', 'scripts/check_doc_coverage.dart', '--staged', '--warning-only'],
    workingDirectory: context.repoRoot,
    stepName: 'doc-check (report-only)',
  );
  stdout.writeln('');

  // ── Wikilink integrity (blocking) ──────────────────────────────────
  // Broken doc links fail the commit regardless of SKIP_DOC_CHECK.
  // --changed scopes the scan to the git change set (full vault fallback
  // when the change set deletes/renames docs) for fast commit feedback.
  // Scope note: the coverage check above judges only the staged snapshot
  // (--staged), while the link scan reads staged + unstaged + untracked —
  // link resolution sees the working tree, and a not-yet-staged deletion
  // already breaks links, so the scan cannot be narrower.
  await runLoggedCommand(
    'dart',
    ['run', 'scripts/check_doc_links.dart', '--changed'],
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

class FullstackOptions {
  const FullstackOptions({
    this.deviceId = 'emulator-5554',
    this.baseUrl = 'http://10.0.2.2:3000',
    this.email = 'fullstack-record-lane@example.com',
    this.password = 'RecordLane123',
    this.recordDate = '2026-06-12',
    this.defineFile,
  });

  final String deviceId;
  final String baseUrl;
  final String email;
  final String password;
  final String recordDate;
  final String? defineFile;
}

Future<void> runFullstackChecks(
  ToolContext context,
  FullstackOptions options,
) async {
  final activeDefineFile = _resolveActiveDefineFile(
    context.repoRoot,
    options.defineFile,
  );
  final healthUri = Uri.parse('http://127.0.0.1:3000/api/v1/health');
  const tests = <String>[
    'integration_test/auth/fullstack_auth_smoke_test.dart',
    'integration_test/record/fullstack_record_lane_test.dart',
    'integration_test/record/fullstack_sleep_lane_test.dart',
    'integration_test/record/fullstack_quick_choice_time_lane_test.dart',
    'integration_test/app/fullstack_today_report_lane_test.dart',
  ];

  await runLoggedCommand(
    'pnpm',
    ['--dir', context.lucentRoot.path, 'test:runtime:stop'],
    workingDirectory: context.repoRoot,
    stepName: 'Start Lucent test runtime',
  );
  await runLoggedCommand('pnpm', [
    '--dir',
    context.lucentRoot.path,
    'test:runtime:start',
  ], workingDirectory: context.repoRoot);
  stdout.writeln('');

  stdout.writeln('==> Verify Lucent health');
  await waitForHttpOk(healthUri, timeout: const Duration(seconds: 30));
  stdout.writeln('');

  final commonArgs = <String>['-d', options.deviceId];
  if (activeDefineFile != null) {
    stdout.writeln('==> Use dart defines from $activeDefineFile');
    commonArgs.add('--dart-define-from-file=$activeDefineFile');
  } else {
    commonArgs.addAll([
      '--dart-define=LUCENT_BASE_URL=${options.baseUrl}',
      '--dart-define=E2E_LUCENT_BASE_URL=${options.baseUrl}',
      '--dart-define=E2E_TEST_EMAIL=${options.email}',
      '--dart-define=E2E_TEST_PASSWORD=${options.password}',
      '--dart-define=E2E_RECORD_DATE=${options.recordDate}',
    ]);
  }
  stdout.writeln('');

  for (final testFile in tests) {
    await runLoggedCommand(
      'flutter',
      ['test', testFile, ...commonArgs],
      workingDirectory: context.repoRoot,
      stepName: 'flutter test $testFile',
    );
    stdout.writeln('');
  }
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

String? _resolveActiveDefineFile(
  Directory repoRoot,
  String? explicitDefineFile,
) {
  final trimmed = explicitDefineFile?.trim();
  if (trimmed != null && trimmed.isNotEmpty) {
    final file = resolveExistingFile(trimmed, repoRoot: repoRoot);
    if (!file.existsSync()) {
      throw StateError('Dart define file not found: ${file.path}');
    }
    return file.path;
  }

  final defaultFiles = <String>['.env', '.env.fullstack-e2e'];
  for (final name in defaultFiles) {
    final file = File('${repoRoot.path}${Platform.pathSeparator}$name');
    if (file.existsSync()) {
      return file.path;
    }
  }

  return null;
}
