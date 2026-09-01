import 'dart:io';

import '../contract/bootstrap.dart';
import '../support.dart';

Future<void> main(List<String> args) async {
  final context = ToolContext.fromScript(Platform.script);

  try {
    final parsed = _parseArgs(args);
    if (parsed.showHelp) {
      stdout.writeln(_usage);
      return;
    }

    await runDailyChecks(context, openApiPath: parsed.openApiPath);
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

Future<void> runDailyChecks(ToolContext context, {String? openApiPath}) async {
  await runLoggedCommand(
    'dart',
    ['run', 'scripts/docs/verify.dart', '--warning-only'],
    workingDirectory: context.repoRoot,
    stepName: 'dart run scripts/docs/verify.dart --warning-only',
  );
  stdout.writeln('');

  // Full-tree governance check (doc-map references, link integrity,
  // front-matter, freshness, readership, feature coverage). Blocking —
  // daily checks keep the per-rule coverage report advisory above, but
  // structural doc-governance problems fail the run.
  await runLoggedCommand(
    'dart',
    ['run', 'scripts/docs/verify.dart', '--verify'],
    workingDirectory: context.repoRoot,
    stepName: 'dart run scripts/docs/verify.dart --verify',
  );
  stdout.writeln('');

  // Relative-link integrity for the docs vault (blocks on broken links).
  await runLoggedCommand(
    'dart',
    ['run', 'scripts/docs/links.dart'],
    workingDirectory: context.repoRoot,
    stepName: 'dart run scripts/docs/links.dart',
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
      'scripts/contract/verify_openapi.dart',
      if (openApiPath != null) '--openapi=$openApiPath',
    ],
    workingDirectory: context.repoRoot,
    stepName: 'dart run scripts/contract/verify_openapi.dart',
  );
}

_ParsedArgs _parseArgs(List<String> args) {
  String? openApiPath;
  var showHelp = false;

  for (var index = 0; index < args.length; index += 1) {
    final argument = args[index];
    if (argument == '--help' || argument == '-h') {
      showHelp = true;
      continue;
    }
    if (argument == '--openapi') {
      if (index + 1 >= args.length) {
        throw const FormatException('Missing value for argument: --openapi');
      }
      openApiPath = args[index + 1];
      index += 1;
      continue;
    }
    if (argument.startsWith('--openapi=')) {
      final value = argument.substring('--openapi='.length);
      if (value.isEmpty) {
        throw const FormatException('Missing value for argument: --openapi');
      }
      openApiPath = value;
      continue;
    }
    throw FormatException('Unexpected argument: $argument');
  }

  return _ParsedArgs(openApiPath: openApiPath, showHelp: showHelp);
}

class _ParsedArgs {
  const _ParsedArgs({required this.openApiPath, required this.showHelp});

  final String? openApiPath;
  final bool showHelp;
}

const _usage = '''
Usage: dart run scripts/workflows/daily.dart [options]

Options:
  --openapi <path>   Verify against an explicit Lucent OpenAPI file path.
  --help             Show this help text.
''';
