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

    await runLoggedCommand(
      'git',
      [
        '-C',
        lucentOpenApi.parent.parent.path,
        'diff',
        '--exit-code',
        '--',
        _toGitRelativePath(lucentOpenApi.parent.parent, lucentOpenApi),
      ],
      workingDirectory: context.repoRoot,
      stepName: 'Verify Lucent OpenAPI file is committed',
    );
    stdout.writeln('');

    await runLoggedCommand(
      'git',
      [
        '-C',
        context.repoRoot.path,
        'diff',
        '--exit-code',
        '--',
        'packages/lucent_openapi',
      ],
      workingDirectory: context.repoRoot,
      stepName: 'Verify packages/lucent_openapi is committed',
    );
  } on ProcessException catch (error) {
    stderr.writeln(error.message);
    stderr.writeln(
      'OpenAPI/client contract is out of sync. Run `dart run tool/regenerate_lucent_openapi.dart` after exporting Lucent OpenAPI and commit the updated generated client.',
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

String _toGitRelativePath(Directory repoRoot, File file) {
  final repoRootPath = repoRoot.absolute.path;
  final filePath = file.absolute.path;
  if (!filePath.startsWith(repoRootPath)) {
    throw StateError(
      'OpenAPI file must live inside the Lucent repository: ${file.path}',
    );
  }

  final relative = filePath
      .substring(repoRootPath.length)
      .replaceAll('\\', '/');
  return relative.startsWith('/') ? relative.substring(1) : relative;
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
