import 'dart:io';

import '../support.dart';

Future<void> main(List<String> args) async {
  final context = ToolContext.fromScript(Platform.script);

  try {
    if (args.contains('--help') || args.contains('-h')) {
      stdout.writeln(_usage);
      return;
    }

    final parsed = _parseNamedArgs(args);
    final options = FullstackOptions(
      deviceId: parsed['device-id'] ?? 'emulator-5554',
      baseUrl: parsed['base-url'] ?? 'http://10.0.2.2:3000',
      email: parsed['email'] ?? 'fullstack-record-lane@example.com',
      password: parsed['password'] ?? 'RecordLane123',
      recordDate: parsed['record-date'] ?? '2026-06-12',
      defineFile: parsed['define-file'],
    );

    await runFullstackChecks(context, options);
  } on FormatException catch (error) {
    stderr.writeln(error.message);
    stderr.writeln('');
    stderr.writeln(_usage);
    exitCode = 64;
  } on ProcessException catch (error) {
    stderr.writeln(error.message);
    exitCode = error.errorCode;
  } on StateError catch (error) {
    stderr.writeln(error.message);
    exitCode = 1;
  }
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

Map<String, String> _parseNamedArgs(List<String> args) {
  final values = <String, String>{};

  for (var index = 0; index < args.length; index += 1) {
    final argument = args[index];
    if (!argument.startsWith('--')) {
      throw FormatException('Unexpected positional argument: $argument');
    }

    final separatorIndex = argument.indexOf('=');
    if (separatorIndex != -1) {
      final name = argument.substring(2, separatorIndex);
      final value = argument.substring(separatorIndex + 1);
      if (name.isEmpty || value.isEmpty) {
        throw FormatException('Invalid named argument: $argument');
      }
      values[name] = value;
      continue;
    }

    final name = argument.substring(2);
    if (name.isEmpty) {
      throw FormatException('Invalid named argument: $argument');
    }
    if (index + 1 >= args.length) {
      throw FormatException('Missing value for argument: $argument');
    }

    values[name] = args[index + 1];
    index += 1;
  }

  return values;
}

const _usage = '''
Usage: dart run scripts/workflows/fullstack.dart [options]

Options:
  --device-id <id>        Flutter device id. Default: emulator-5554
  --base-url <url>        Lucent base url. Default: http://10.0.2.2:3000
  --email <email>         Full-stack test account email.
  --password <password>   Full-stack test account password.
  --record-date <date>    Test record date in YYYY-MM-DD.
  --define-file <path>    Optional .env-style dart-define file.
  --help                  Show this help text.
''';
