import 'dart:io';

import 'tooling_support.dart';

Future<void> main() async {
  final context = ToolContext.fromScript(Platform.script);

  try {
    final lucentOpenApi = File(
      '${context.lucentRoot.path}${Platform.pathSeparator}docs'
      '${Platform.pathSeparator}openapi.json',
    );
    final generatedClientRoot = Directory(
      '${context.repoRoot.path}${Platform.pathSeparator}packages'
      '${Platform.pathSeparator}lucent_openapi',
    );

    if (!lucentOpenApi.existsSync()) {
      throw StateError('Lucent OpenAPI file not found: ${lucentOpenApi.path}');
    }
    if (!generatedClientRoot.existsSync()) {
      throw StateError(
        'Generated client directory not found: ${generatedClientRoot.path}',
      );
    }

    await runLoggedCommand(
      'git',
      [
        '-C',
        context.lucentRoot.path,
        'diff',
        '--exit-code',
        '--',
        'docs/openapi.json',
      ],
      workingDirectory: context.repoRoot,
      stepName: 'Verify Lucent docs/openapi.json is committed',
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
  } on StateError catch (error) {
    stderr.writeln(error.message);
    exitCode = 1;
  }
}
