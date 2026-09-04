import 'dart:convert';
import 'dart:io';

class ToolContext {
  ToolContext({
    required this.repoRoot,
    required this.workspaceRoot,
    required this.lucentRoot,
  });

  factory ToolContext.fromScript(Uri scriptUri) {
    final scriptFile = File.fromUri(scriptUri);
    // Walk up from the script location to the repo root (pubspec.yaml), so
    // scripts nested in subdirectories (docs/, contract/, workflows/, ...)
    // resolve correctly.
    var dir = scriptFile.parent.absolute;
    while (!File(
      '${dir.path}${Platform.pathSeparator}pubspec.yaml',
    ).existsSync()) {
      final parent = dir.parent.absolute;
      if (parent.path == dir.path) {
        throw StateError('pubspec.yaml not found above ${scriptFile.path}');
      }
      dir = parent;
    }
    final repoRoot = dir;
    final workspaceRoot = repoRoot.parent;
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
  int maxRetries = 0,
}) async {
  if (stepName != null) {
    stdout.writeln('==> $stepName');
  }
  stdout.writeln('$executable ${arguments.join(' ')}');

  var attempt = 0;
  while (true) {
    attempt += 1;
    final process = await Process.start(
      executable,
      arguments,
      workingDirectory: workingDirectory.path,
      environment: environment,
      runInShell: true,
    );

    // Forward both streams to the console (identical to inheritStdio) while
    // retaining stderr text for the retry decision below.
    final stderrBuffer = StringBuffer();
    final stdoutDone = process.stdout
        .transform(const SystemEncoding().decoder)
        .forEach(stdout.write);
    final stderrDone = process.stderr
        .transform(const SystemEncoding().decoder)
        .forEach((chunk) {
          stderr.write(chunk);
          stderrBuffer.write(chunk);
        });

    final exitCode = await process.exitCode;
    await Future.wait([stdoutDone, stderrDone]);
    if (exitCode == 0) return;

    if (attempt > maxRetries) {
      throw ProcessException(
        executable,
        arguments,
        'Command failed with exit code $exitCode.',
        exitCode,
      );
    }

    if (!_isWindowsFileLockRetryable(executable, stderrBuffer.toString())) {
      // Deterministic failures (including `dart analyze` semantic errors that
      // exit 1 without a lock marker) surface immediately, on the first run.
      throw ProcessException(
        executable,
        arguments,
        'Command failed with exit code $exitCode.',
        exitCode,
      );
    }

    // Transient failures (e.g. Windows file-lock contention during
    // build_runner hooks / format) recover on a rerun; a deterministic
    // failure simply fails the retry too and still surfaces below.
    stdout.writeln(
      '[warn] $executable ${arguments.join(' ')} exited with code '
      '$exitCode (attempt $attempt of ${maxRetries + 1}); retrying.',
    );
    await Future<void>.delayed(const Duration(seconds: 3));
    stdout.writeln('$executable ${arguments.join(' ')}');
  }
}

/// Whether a failed command is the transient Windows file-lock contention
/// (error 1224 / "The process cannot access the file") that build_runner can
/// hit under concurrent runs. Only `dart` invocations qualify: retrying other
/// tools — or a deterministic `dart` semantic failure — would only delay the
/// real error.
bool _isWindowsFileLockRetryable(String executable, String stderr) {
  if (executable != 'dart') return false;
  final text = stderr.toLowerCase();
  return text.contains('error 1224') ||
      text.contains('the process cannot access the file');
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

File resolveRequiredOpenApiFile(
  String? explicitPath, {
  required Directory defaultLucentRoot,
  Directory? repoRoot,
}) {
  if (explicitPath != null && explicitPath.trim().isNotEmpty) {
    final file = resolveExistingFile(explicitPath.trim(), repoRoot: repoRoot);
    if (!file.existsSync()) {
      throw StateError('Lucent OpenAPI file not found: ${file.path}');
    }
    return file;
  }

  // Lucent's generated artifact moved to docs/reference/generated/ in the
  // 2026-08-31 governance rebuild; fall back for checkouts of either layout.
  const candidates = [
    ['docs', 'reference', 'generated', 'openapi.json'],
    ['docs', 'openapi.json'],
  ];
  for (final segments in candidates) {
    final file = File(
      '${defaultLucentRoot.path}${Platform.pathSeparator}${segments.join(Platform.pathSeparator)}',
    ).absolute;
    if (file.existsSync()) return file;
  }
  throw StateError(
    'Lucent OpenAPI file not found under: ${defaultLucentRoot.path}/docs',
  );
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
        .transform(const SystemEncoding().decoder)
        .forEach(stdoutBuffer.write),
    process.stderr
        .transform(const SystemEncoding().decoder)
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

/// Verifies that [openApiFile] is a valid OpenAPI JSON document with a
/// top-level `openapi` key. Throws [StateError] if validation fails.
void verifyOpenApiJson(File openApiFile) {
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
