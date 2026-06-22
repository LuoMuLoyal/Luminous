import 'dart:io';

import 'tooling_support.dart';
import 'tooling_workflows.dart';

Future<void> main() async {
  final context = ToolContext.fromScript(Platform.script);

  try {
    await runDailyChecks(context);
  } on ProcessException catch (error) {
    stderr.writeln(error.message);
    exitCode = error.errorCode;
  } on StateError catch (error) {
    stderr.writeln(error.message);
    exitCode = 1;
  }
}
