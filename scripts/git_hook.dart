import 'dart:io';

import 'tooling_support.dart';
import 'tooling_workflows.dart';

Future<void> main(List<String> args) async {
  final context = ToolContext.fromScript(Platform.script);
  if (args.isEmpty) {
    stderr.writeln(
      'Usage: dart run scripts/git_hook.dart <pre-commit|commit-msg|pre-push> [args]',
    );
    exitCode = 64;
    return;
  }

  try {
    switch (args.first) {
      case 'pre-commit':
        await runPreCommitChecks(context);
      case 'pre-push':
        await runPrePushChecks(context);
      case 'commit-msg':
        if (args.length < 2) {
          stderr.writeln(
            'commit-msg hook requires a commit message file path argument.',
          );
          exitCode = 64;
          return;
        }
        validateCommitMessage(args[1]);
      default:
        stderr.writeln('Unsupported git hook: ${args.first}');
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
