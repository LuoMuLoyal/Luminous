import 'dart:convert';
import 'dart:io';

import 'tooling_support.dart';

Future<void> main(List<String> args) async {
  final context = ToolContext.fromScript(Platform.script);

  try {
    final parsed = _parseNamedArgs(args);
    if (parsed.showHelp) {
      stdout.writeln(_usage);
      return;
    }

    final lucentOpenApi = resolveRequiredOpenApiFile(
      parsed.openApiPath,
      defaultLucentRoot: context.lucentRoot,
      repoRoot: context.repoRoot,
    );
    final generatedClientRoot = Directory(
      '${context.repoRoot.path}${Platform.pathSeparator}packages'
      '${Platform.pathSeparator}lucent_openapi',
    );

    if (!generatedClientRoot.existsSync()) {
      throw StateError(
        'Generated client directory not found: ${generatedClientRoot.path}',
      );
    }

    _verifyOpenApiJson(lucentOpenApi);
    stdout.writeln('Lucent OpenAPI file resolved: ${lucentOpenApi.path}');
    stdout.writeln(
      'Generated client directory resolved: ${generatedClientRoot.path}',
    );
    _verifyGeneratedClientLayout(generatedClientRoot);
  } on ProcessException catch (error) {
    stderr.writeln(error.message);
    stderr.writeln(
      'OpenAPI/client verification command failed. Run `dart run tool/regenerate_lucent_openapi.dart` after exporting Lucent OpenAPI if the generated client needs to be refreshed.',
    );
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

_ParsedArgs _parseNamedArgs(List<String> args) {
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

void _verifyOpenApiJson(File openApiFile) {
  final raw = openApiFile.readAsStringSync();
  final decoded = jsonDecode(raw);
  if (decoded is! Map<String, dynamic>) {
    throw StateError('Lucent OpenAPI file is not a JSON object.');
  }
  if (decoded['openapi'] is! String) {
    throw StateError(
      'Lucent OpenAPI file is missing the top-level openapi key.',
    );
  }
}

void _verifyGeneratedClientLayout(Directory generatedClientRoot) {
  final requiredPaths = <String>[
    'pubspec.yaml',
    'lib/lucent_openapi.dart',
    'lib/src/api.dart',
  ];

  for (final relativePath in requiredPaths) {
    final file = File(
      '${generatedClientRoot.path}${Platform.pathSeparator}'
      '${relativePath.replaceAll('/', Platform.pathSeparator)}',
    );
    if (!file.existsSync()) {
      throw StateError(
        'Generated client is missing required file: ${file.path}',
      );
    }
  }
}

class _ParsedArgs {
  const _ParsedArgs({required this.openApiPath, required this.showHelp});

  final String? openApiPath;
  final bool showHelp;
}

const _usage = '''
Usage: dart run tool/verify_lucent_openapi_sync.dart [options]

Options:
  --openapi <path>   Verify against an explicit Lucent OpenAPI file path.
  --help             Show this help text.
''';
