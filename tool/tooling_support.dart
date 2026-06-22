import 'dart:io';

class ToolContext {
  ToolContext({
    required this.repoRoot,
    required this.workspaceRoot,
    required this.lucentRoot,
  });

  factory ToolContext.fromScript(Uri scriptUri) {
    final scriptFile = File.fromUri(scriptUri);
    final repoRoot = scriptFile.parent.parent.absolute;
    final workspaceRoot = repoRoot.parent.absolute;
    final lucentRoot = Directory(
      '${workspaceRoot.path}${Platform.pathSeparator}Lucent',
    );
    return ToolContext(
      repoRoot: repoRoot,
      workspaceRoot: workspaceRoot,
      lucentRoot: lucentRoot,
    );
  }

  final Directory repoRoot;
  final Directory workspaceRoot;
  final Directory lucentRoot;
}

Future<void> runLoggedCommand(
  String executable,
  List<String> arguments, {
  required Directory workingDirectory,
  String? stepName,
  Map<String, String>? environment,
}) async {
  if (stepName != null) {
    stdout.writeln('==> $stepName');
  }
  stdout.writeln('$executable ${arguments.join(' ')}');

  final process = await Process.start(
    executable,
    arguments,
    workingDirectory: workingDirectory.path,
    environment: environment,
    runInShell: true,
    mode: ProcessStartMode.inheritStdio,
  );

  final exitCode = await process.exitCode;
  if (exitCode != 0) {
    throw ProcessException(
      executable,
      arguments,
      'Command failed with exit code $exitCode.',
      exitCode,
    );
  }
}

Future<void> waitForHttpOk(
  Uri uri, {
  required Duration timeout,
  Duration pollInterval = const Duration(milliseconds: 500),
}) async {
  final deadline = DateTime.now().add(timeout);
  final client = HttpClient()..connectionTimeout = const Duration(seconds: 5);

  try {
    while (DateTime.now().isBefore(deadline)) {
      try {
        final request = await client.getUrl(uri);
        final response = await request.close();
        await response.drain<void>();
        if (response.statusCode == HttpStatus.ok) {
          return;
        }
      } on SocketException {
        // Keep polling until timeout.
      } on HttpException {
        // Keep polling until timeout.
      }

      await Future<void>.delayed(pollInterval);
    }
  } finally {
    client.close(force: true);
  }

  throw StateError('Health check did not reach 200 before timeout: $uri');
}

File resolveExistingFile(String input, {Directory? repoRoot}) {
  final directFile = File(input);
  if (directFile.isAbsolute) {
    return directFile.absolute;
  }

  final currentFile = File(
    '${Directory.current.path}${Platform.pathSeparator}$input',
  );
  if (currentFile.existsSync()) {
    return currentFile.absolute;
  }

  if (repoRoot != null) {
    return File('${repoRoot.path}${Platform.pathSeparator}$input').absolute;
  }

  return directFile.absolute;
}

Future<List<String>> captureCommandLines(
  String executable,
  List<String> arguments, {
  required Directory workingDirectory,
}) async {
  final process = await Process.start(
    executable,
    arguments,
    workingDirectory: workingDirectory.path,
    runInShell: true,
  );

  final stdoutBuffer = StringBuffer();
  final stderrBuffer = StringBuffer();
  await Future.wait([
    process.stdout
        .transform(SystemEncoding().decoder)
        .forEach(stdoutBuffer.write),
    process.stderr
        .transform(SystemEncoding().decoder)
        .forEach(stderrBuffer.write),
  ]);

  final exitCode = await process.exitCode;
  if (exitCode != 0) {
    final message = [
      if (stderrBuffer.isNotEmpty) stderrBuffer.toString().trim(),
      if (stdoutBuffer.isNotEmpty) stdoutBuffer.toString().trim(),
    ].where((part) => part.isNotEmpty).join('\n');
    throw ProcessException(
      executable,
      arguments,
      message.isEmpty ? 'Command failed with exit code $exitCode.' : message,
      exitCode,
    );
  }

  final combined = '${stdoutBuffer.toString()}\n${stderrBuffer.toString()}';
  return combined
      .split(RegExp(r'\r?\n'))
      .map((line) => line.trim())
      .where((line) => line.isNotEmpty)
      .toList(growable: false);
}
