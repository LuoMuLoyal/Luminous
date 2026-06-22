import 'dart:io';

import 'tooling_support.dart';
import 'tooling_workflows.dart';

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
Usage: dart run tool/run_fullstack_checks.dart [options]

Options:
  --device-id <id>        Flutter device id. Default: emulator-5554
  --base-url <url>        Lucent base url. Default: http://10.0.2.2:3000
  --email <email>         Full-stack test account email.
  --password <password>   Full-stack test account password.
  --record-date <date>    Test record date in YYYY-MM-DD.
  --define-file <path>    Optional .env-style dart-define file.
  --help                  Show this help text.
''';
