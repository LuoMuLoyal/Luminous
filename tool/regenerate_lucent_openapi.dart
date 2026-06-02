import 'dart:io';

const _openApiGeneratorAdditionalProperties =
    'serializationLibrary=json_serializable,'
    'pubName=lucent_openapi,'
    'pubLibrary=lucent_openapi,'
    'sourceFolder=src,'
    'finalProperties=true,'
    'skipCopyWith=true,'
    'useEnumExtension=true,'
    'enumUnknownDefaultCase=true';

Future<void> main() async {
  final scriptFile = File.fromUri(Platform.script);
  final luminousRoot = scriptFile.parent.parent;
  final lumosRoot = luminousRoot.parent;
  final lucentRoot = Directory(
    '${lumosRoot.path}${Platform.pathSeparator}Lucent',
  );
  final generatedPackageRoot = Directory(
    '${luminousRoot.path}${Platform.pathSeparator}packages'
    '${Platform.pathSeparator}lucent_openapi',
  );

  if (!lucentRoot.existsSync()) {
    stderr.writeln('Lucent directory not found: ${lucentRoot.path}');
    exitCode = 1;
    return;
  }

  if (!generatedPackageRoot.existsSync()) {
    stderr.writeln(
      'Generated package directory not found: ${generatedPackageRoot.path}',
    );
    exitCode = 1;
    return;
  }

  try {
    await _runCommand(
      'pnpm',
      ['export:openapi'],
      workingDirectory: lucentRoot.path,
      stepName: 'Export Lucent OpenAPI',
    );

    await _runCommand(
      'npx',
      [
        '@openapitools/openapi-generator-cli',
        'generate',
        '-g',
        'dart-dio',
        '-i',
        '${lucentRoot.path}${Platform.pathSeparator}docs'
            '${Platform.pathSeparator}openapi.json',
        '-o',
        generatedPackageRoot.path,
        '--additional-properties=$_openApiGeneratorAdditionalProperties',
      ],
      workingDirectory: luminousRoot.path,
      stepName: 'Generate lucent_openapi package',
    );

    final pubspecFile = File(
      '${generatedPackageRoot.path}${Platform.pathSeparator}pubspec.yaml',
    );
    final pubspecUpdated = _normalizeGeneratedPubspec(pubspecFile);
    stdout.writeln(
      pubspecUpdated
          ? 'Normalized generated pubspec constraints.'
          : 'Generated pubspec already matched pinned constraints.',
    );

    await _runCommand(
      'dart',
      ['pub', 'get'],
      workingDirectory: generatedPackageRoot.path,
      stepName: 'Install generated package dependencies',
    );

    final deletedGDotDartFiles = _deleteGeneratedModelSerializers(
      generatedPackageRoot,
    );
    stdout.writeln(
      deletedGDotDartFiles == 0
          ? 'No existing model serializers were removed before rebuild.'
          : 'Removed $deletedGDotDartFiles existing model serializer files before rebuild.',
    );

    await _runCommand(
      'dart',
      ['run', 'build_runner', 'build'],
      workingDirectory: generatedPackageRoot.path,
      stepName: 'Build generated serializers',
    );

    final patchedFiles = _patchBrokenNullableMapEntries(generatedPackageRoot);
    stdout.writeln(
      patchedFiles == 0
          ? 'No nullable map-entry patches were needed.'
          : 'Patched broken nullable map entries in $patchedFiles generated files.',
    );
    final remainingBrokenEntries = _countBrokenNullableMapEntries(
      generatedPackageRoot,
    );
    if (remainingBrokenEntries != 0) {
      throw ProcessException(
        'patch-generated-serializers',
        const [],
        'Found $remainingBrokenEntries broken nullable map entries after patching.',
        1,
      );
    }

    await _runCommand(
      'dart',
      ['format', 'lib/src/model'],
      workingDirectory: generatedPackageRoot.path,
      stepName: 'Format generated model files',
    );

    await _runCommand(
      'dart',
      ['analyze', '--no-fatal-warnings'],
      workingDirectory: generatedPackageRoot.path,
      stepName: 'Analyze generated package',
    );

    await _runCommand(
      'flutter',
      ['pub', 'get'],
      workingDirectory: luminousRoot.path,
      stepName: 'Refresh Luminous dependencies',
    );

    stdout.writeln('');
    stdout.writeln('Lucent OpenAPI regeneration finished.');
  } on ProcessException catch (error) {
    stderr.writeln(error.message);
    exitCode = error.errorCode;
  }
}

Future<void> _runCommand(
  String executable,
  List<String> arguments, {
  required String workingDirectory,
  required String stepName,
}) async {
  stdout.writeln('');
  stdout.writeln('==> $stepName');
  stdout.writeln('$executable ${arguments.join(' ')}');

  final process = await Process.start(
    executable,
    arguments,
    workingDirectory: workingDirectory,
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

bool _normalizeGeneratedPubspec(File pubspecFile) {
  final original = pubspecFile.readAsStringSync();
  var updated = original;

  updated = _replaceYamlLine(
    updated,
    RegExp(r"^(\s*)sdk:\s*'[^']+'", multiLine: true),
    "sdk: '>=3.12.0 <4.0.0'",
  );
  updated = _replaceYamlLine(
    updated,
    RegExp(r"^(\s*)json_annotation:\s*.+$", multiLine: true),
    "json_annotation: '4.12.0'",
  );
  updated = _replaceYamlLine(
    updated,
    RegExp(r"^(\s*)build_runner:\s*.+$", multiLine: true),
    "build_runner: '2.15.0'",
  );
  updated = _replaceYamlLine(
    updated,
    RegExp(r"^(\s*)json_serializable:\s*.+$", multiLine: true),
    "json_serializable: '6.14.0'",
  );

  if (updated == original) {
    return false;
  }

  pubspecFile.writeAsStringSync(updated);
  return true;
}

String _replaceYamlLine(String input, RegExp pattern, String replacement) {
  return input.replaceFirstMapped(pattern, (match) {
    final indentation = match.group(1) ?? '';
    return '$indentation$replacement';
  });
}

int _patchBrokenNullableMapEntries(Directory generatedPackageRoot) {
  final modelDirectory = _generatedModelDirectory(generatedPackageRoot);

  if (!modelDirectory.existsSync()) {
    return 0;
  }

  var patchedFiles = 0;
  for (final entity in modelDirectory.listSync(recursive: true)) {
    if (entity is! File || !entity.path.endsWith('.g.dart')) {
      continue;
    }

    final original = entity.readAsStringSync();
    final newline = original.contains('\r\n') ? '\r\n' : '\n';
    final lines = original.split(RegExp(r'\r?\n'));
    var changed = false;

    final updatedLines = <String>[];
    for (final line in lines) {
      final match = _brokenNullableMapEntryPattern.firstMatch(line);
      if (match == null) {
        updatedLines.add(line);
        continue;
      }

      final indent = match.group(1)!;
      final key = match.group(2)!;
      final expression = match.group(3)!.trim();
      updatedLines.add('${indent}if ($expression != null) $key: $expression,');
      changed = true;
    }

    if (!changed) {
      continue;
    }

    entity.writeAsStringSync(updatedLines.join(newline));
    patchedFiles += 1;
  }

  return patchedFiles;
}

int _deleteGeneratedModelSerializers(Directory generatedPackageRoot) {
  final modelDirectory = _generatedModelDirectory(generatedPackageRoot);
  if (!modelDirectory.existsSync()) {
    return 0;
  }

  var deletedFiles = 0;
  for (final entity in modelDirectory.listSync(recursive: true)) {
    if (entity is! File || !entity.path.endsWith('.g.dart')) {
      continue;
    }

    entity.deleteSync();
    deletedFiles += 1;
  }

  return deletedFiles;
}

int _countBrokenNullableMapEntries(Directory generatedPackageRoot) {
  final modelDirectory = _generatedModelDirectory(generatedPackageRoot);
  if (!modelDirectory.existsSync()) {
    return 0;
  }

  var brokenEntries = 0;
  for (final entity in modelDirectory.listSync(recursive: true)) {
    if (entity is! File || !entity.path.endsWith('.g.dart')) {
      continue;
    }

    final lines = entity.readAsLinesSync();
    for (final line in lines) {
      if (_brokenNullableMapEntryPattern.hasMatch(line)) {
        brokenEntries += 1;
      }
    }
  }

  return brokenEntries;
}

Directory _generatedModelDirectory(Directory generatedPackageRoot) {
  return Directory(
    '${generatedPackageRoot.path}${Platform.pathSeparator}lib'
    '${Platform.pathSeparator}src${Platform.pathSeparator}model',
  );
}

final _brokenNullableMapEntryPattern = RegExp(
  r"^(\s*)('(?:[^'\\]|\\.)*'):\s\?(.+),\s*$",
);
