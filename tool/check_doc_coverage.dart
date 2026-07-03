import 'dart:io';

import 'doc_coverage.dart';
import 'tooling_support.dart';

Future<void> main(List<String> args) async {
  final context = ToolContext.fromScript(Platform.script);

  try {
    final options = _parseArgs(args);
    if (options.showHelp) {
      stdout.writeln(_usage);
      return;
    }
    final configFile = resolveExistingFile(
      options.configPath ?? defaultDocCoverageConfigPath(context.repoRoot),
      repoRoot: context.repoRoot,
    );
    final config = loadDocCoverageConfig(configFile);
    final changedFiles = await collectChangedFiles(
      context.repoRoot,
      stagedOnly: options.stagedOnly,
    );

    if (changedFiles.isEmpty) {
      stdout.writeln('Documentation coverage: no changed files detected.');
      return;
    }

    final documentedFiles = changedFiles
        .map((file) => file.replaceAll('\\', '/'))
        .where((file) => file.startsWith('docs/'))
        .toList(growable: false);

    final report = buildDocCoverageReport(
      config: config,
      changedFiles: changedFiles,
      documentedFiles: documentedFiles,
    );
    stdout.writeln(renderDocCoverageReport(report));
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

_ParsedArgs _parseArgs(List<String> args) {
  var stagedOnly = false;
  String? configPath;
  var showHelp = false;

  for (var index = 0; index < args.length; index += 1) {
    final argument = args[index];
    if (argument == '--staged') {
      stagedOnly = true;
      continue;
    }
    if (argument == '--help' || argument == '-h') {
      showHelp = true;
      continue;
    }
    if (argument == '--config') {
      if (index + 1 >= args.length) {
        throw const FormatException('Missing value for argument: --config');
      }
      configPath = args[index + 1];
      index += 1;
      continue;
    }
    if (argument.startsWith('--config=')) {
      final value = argument.substring('--config='.length);
      if (value.isEmpty) {
        throw const FormatException('Missing value for argument: --config');
      }
      configPath = value;
      continue;
    }
    throw FormatException('Unexpected argument: $argument');
  }

  return _ParsedArgs(
    stagedOnly: stagedOnly,
    configPath: configPath,
    showHelp: showHelp,
  );
}

class _ParsedArgs {
  const _ParsedArgs({
    required this.stagedOnly,
    required this.configPath,
    required this.showHelp,
  });

  final bool stagedOnly;
  final String? configPath;
  final bool showHelp;
}

const _usage = '''
Usage: dart run tool/check_doc_coverage.dart [options]

Options:
  --staged            Read staged changes instead of the working tree.
  --config <path>     Use an explicit doc coverage config path.
  --help              Show this help text.
''';
