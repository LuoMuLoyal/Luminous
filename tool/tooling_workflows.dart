import 'dart:io';

import 'tooling_support.dart';

Future<void> runDailyChecks(ToolContext context) async {
  await runLoggedCommand(
    'flutter',
    ['pub', 'get'],
    workingDirectory: context.repoRoot,
    stepName: 'flutter pub get',
  );
  stdout.writeln('');

  await runLoggedCommand(
    'flutter',
    ['gen-l10n'],
    workingDirectory: context.repoRoot,
    stepName: 'flutter gen-l10n',
  );
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
    ['format', '--set-exit-if-changed', 'lib/', 'test/', 'tool/'],
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
    ['run', 'tool/verify_lucent_openapi_sync.dart'],
    workingDirectory: context.repoRoot,
    stepName: 'dart run tool/verify_lucent_openapi_sync.dart',
  );
}

Future<void> runPreCommitChecks(ToolContext context) async {
  await runLoggedCommand(
    'flutter',
    ['gen-l10n'],
    workingDirectory: context.repoRoot,
    stepName: 'flutter gen-l10n',
  );
  stdout.writeln('');

  final stagedDartFiles = await _listStagedDartFiles(context);
  if (stagedDartFiles.isNotEmpty) {
    // Batch files to avoid hitting Windows command-line length limits.
    const batchSize = 40;
    for (var i = 0; i < stagedDartFiles.length; i += batchSize) {
      final batch = stagedDartFiles.skip(i).take(batchSize).toList();
      await runLoggedCommand(
        'dart',
        ['format', ...batch],
        workingDirectory: context.repoRoot,
        stepName:
            'dart format <staged dart files> (batch ${i ~/ batchSize + 1})',
      );
    }
    // Re-stage the formatted files so the commit includes the changes.
    final gitResult = await Process.run('git', [
      'add',
      ...stagedDartFiles,
    ], workingDirectory: context.repoRoot.path);
    if (gitResult.exitCode != 0) {
      stderr.writeln(gitResult.stderr);
      exitCode = gitResult.exitCode;
      return;
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

  final defaultFile = File(
    '${repoRoot.path}${Platform.pathSeparator}.env.fullstack-e2e',
  );
  if (defaultFile.existsSync()) {
    return defaultFile.path;
  }

  return null;
}
