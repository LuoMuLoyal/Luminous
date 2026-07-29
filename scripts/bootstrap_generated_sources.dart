import 'dart:io';

import 'tooling_support.dart';

Future<void> main(List<String> args) async {
  final context = ToolContext.fromScript(Platform.script);

  try {
    final parsed = _parseArgs(args);
    if (parsed.showHelp) {
      stdout.writeln(_usage);
      return;
    }

    await bootstrapGeneratedSources(
      context,
      openApiPath: parsed.openApiPath,
      skipClient: parsed.skipClient,
      skipPubGet: parsed.skipPubGet,
      skipAppCodegen: parsed.skipAppCodegen,
    );
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

Future<void> bootstrapGeneratedSources(
  ToolContext context, {
  String? openApiPath,
  bool skipClient = false,
  bool skipPubGet = false,
  bool skipAppCodegen = false,
}) async {
  if (!skipPubGet) {
    await runLoggedCommand(
      'flutter',
      ['pub', 'get'],
      workingDirectory: context.repoRoot,
      stepName: 'flutter pub get',
    );
    stdout.writeln('');
  }

  // Build the client branch and app codegen branch in parallel — they
  // have no dependency on each other after root pub get completes.
  final futures = <Future<void>>[];

  if (!skipClient) {
    futures.add(_buildClient(context, openApiPath: openApiPath));
  }

  if (!skipAppCodegen) {
    futures.add(_buildAppCodegen(context));
  }

  if (futures.isNotEmpty) {
    await Future.wait(futures);
  }
}

Future<void> _buildClient(ToolContext context, {String? openApiPath}) async {
  final openApiFile = resolveRequiredOpenApiFile(
    openApiPath,
    defaultLucentRoot: context.lucentRoot,
    repoRoot: context.repoRoot,
  );
  verifyOpenApiJson(openApiFile);

  final generatedClientRoot = Directory(
    '${context.repoRoot.path}${Platform.pathSeparator}generated'
    '${Platform.pathSeparator}lucent_api',
  );
  if (!generatedClientRoot.existsSync()) {
    throw StateError(
      'Generated client directory not found: ${generatedClientRoot.path}',
    );
  }

  await runLoggedCommand(
    'dart',
    ['pub', 'get'],
    workingDirectory: generatedClientRoot,
    stepName: 'dart pub get (generated/lucent_api)',
  );
  stdout.writeln('');

  await runLoggedCommand(
    'dart',
    ['run', 'build_runner', 'build', '--delete-conflicting-outputs'],
    workingDirectory: generatedClientRoot,
    stepName:
        'dart run build_runner build --delete-conflicting-outputs '
        '(generated/lucent_api)',
  );
  stdout.writeln('');

  // Format generated code so that diffs only show semantic changes,
  // not formatting drift from the generator.
  await runLoggedCommand(
    'dart',
    ['format', generatedClientRoot.path],
    workingDirectory: context.repoRoot,
    stepName: 'dart format generated/lucent_api',
  );
  stdout.writeln('');
}

Future<void> _buildAppCodegen(ToolContext context) async {
  await runLoggedCommand(
    'flutter',
    ['gen-l10n'],
    workingDirectory: context.repoRoot,
    stepName: 'flutter gen-l10n',
  );
  stdout.writeln('');

  await runLoggedCommand(
    'dart',
    ['run', 'build_runner', 'build', '--delete-conflicting-outputs'],
    workingDirectory: context.repoRoot,
    stepName: 'dart run build_runner build --delete-conflicting-outputs',
  );
}

_ParsedArgs _parseArgs(List<String> args) {
  String? openApiPath;
  var showHelp = false;
  var skipClient = false;
  var skipPubGet = false;
  var skipAppCodegen = false;

  for (var index = 0; index < args.length; index += 1) {
    final argument = args[index];
    if (argument == '--help' || argument == '-h') {
      showHelp = true;
      continue;
    }
    if (argument == '--skip-client') {
      skipClient = true;
      continue;
    }
    if (argument == '--skip-pub-get') {
      skipPubGet = true;
      continue;
    }
    if (argument == '--skip-app-codegen') {
      skipAppCodegen = true;
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

  return _ParsedArgs(
    openApiPath: openApiPath,
    showHelp: showHelp,
    skipClient: skipClient,
    skipPubGet: skipPubGet,
    skipAppCodegen: skipAppCodegen,
  );
}

class _ParsedArgs {
  const _ParsedArgs({
    required this.openApiPath,
    required this.showHelp,
    required this.skipClient,
    required this.skipPubGet,
    required this.skipAppCodegen,
  });

  final String? openApiPath;
  final bool showHelp;
  final bool skipClient;
  final bool skipPubGet;
  final bool skipAppCodegen;
}

const _usage = '''
Usage: dart run scripts/bootstrap_generated_sources.dart [options]

Options:
  --openapi <path>        Use an explicit Lucent OpenAPI file path.
  --skip-client           Skip generated/lucent_api pub get + build_runner.
  --skip-pub-get          Skip root flutter pub get.
  --skip-app-codegen      Skip flutter gen-l10n and root build_runner.
  --help                  Show this help text.
''';
