import 'dart:io';

import 'tooling_support.dart';

Future<void> main() async {
  final context = ToolContext.fromScript(Platform.script);
  final gitDir = Directory(
    '${context.repoRoot.path}${Platform.pathSeparator}.git',
  );

  if (!gitDir.existsSync()) {
    stderr.writeln('Git repository not found at ${context.repoRoot.path}');
    exitCode = 1;
    return;
  }

  try {
    await runLoggedCommand(
      'git',
      ['-C', context.repoRoot.path, 'config', 'core.hooksPath', '.githooks'],
      workingDirectory: context.repoRoot,
      stepName: 'Configure core.hooksPath',
    );
    stdout.writeln('');
    stdout.writeln('Configured core.hooksPath to .githooks');
    stdout.writeln('Git hooks are now shared from .githooks/');
  } on ProcessException catch (error) {
    stderr.writeln(error.message);
    exitCode = error.errorCode;
  }
}
