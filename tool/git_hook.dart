import 'dart:io';

import 'tooling_support.dart';
import 'tooling_workflows.dart';

Future<void> main(List<String> args) async {
  final context = ToolContext.fromScript(Platform.script);
  if (args.length != 1) {
    stderr.writeln('Usage: dart run tool/git_hook.dart <pre-commit|pre-push>');
    exitCode = 64;
    return;
  }

  try {
    switch (args.single) {
      case 'pre-commit':
        await runPreCommitChecks(context);
      case 'pre-push':
        await runDailyChecks(context);
      default:
        stderr.writeln('Unsupported git hook: ${args.single}');
        exitCode = 64;
    }
  } on ProcessException catch (error) {
    stderr.writeln(error.message);
    exitCode = error.errorCode;
  } on StateError catch (error) {
    stderr.writeln(error.message);
    exitCode = 1;
  }
}
