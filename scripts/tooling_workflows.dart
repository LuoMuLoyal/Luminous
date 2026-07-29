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

  await bootstrapGeneratedSources(context, openApiPath: openApiPath);
  stdout.writeln('');

  await runLoggedCommand(
    'flutter',
    ['analyze'],
    workingDirectory: context.repoRoot,
    stepName: 'flutter analyze',
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
}

Future<void> runPreCommitChecks(ToolContext context) async {
  // ── Documentation check (non-blocking) ───────────────────────
  // Runs in warning-only mode so missing docs are reported but do
  // not block the commit. Bypass entirely with SKIP_DOC_CHECK=1.
  await runLoggedCommand(
    'dart',
    ['run', 'scripts/check_doc_coverage.dart', '--warning-only', '--staged'],
    workingDirectory: context.repoRoot,
    stepName: 'doc-check (warning only)',
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
  final subject = match.group(4)!;
  final errors = <String>[];

  // type-enum
  if (!_validCommitTypes.contains(type)) {
    errors.add(
      'Invalid commit type: "$type". '
      'Valid types: ${_validCommitTypes.join(', ')}',
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

  // header-max-length
  if (trimmedHeader.length > 200) {
    errors.add(
      'Commit header exceeds 200 characters (current: ${trimmedHeader.length}).',
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
