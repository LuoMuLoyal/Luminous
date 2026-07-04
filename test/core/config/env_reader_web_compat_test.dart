import 'dart:io';

import 'package:flutter_test/flutter_test.dart';
import 'package:path/path.dart' as p;

void main() {
  test(
    'EnvReader works after dart compile js with dart defines',
    () async {
      final tempRoot = Directory(
        p.join(Directory.current.path, '.dart_tool', 'env_reader_web_compat'),
      );
      await tempRoot.create(recursive: true);
      final tempDir = await tempRoot.createTemp('probe-');
      addTearDown(() async {
        if (await tempDir.exists()) {
          await tempDir.delete(recursive: true);
        }
      });

      final scriptPath = p.join(tempDir.path, 'probe.dart');
      final outputPath = p.join(tempDir.path, 'probe.js');
      final script = File(scriptPath);
      await script.writeAsString('''
import 'package:luminous/core/config/env_keys.dart';
import 'package:luminous/core/config/env_reader.dart';

void main() {
  print(EnvReader.string(EnvKey.lucentBaseUrl));
  print(EnvReader.string(EnvKey.e2eTestEmail));
}
''');

      final flutterRoot = Platform.environment['FLUTTER_ROOT'];
      final dartExecutable = flutterRoot == null || flutterRoot.trim().isEmpty
          ? Platform.resolvedExecutable
          : p.join(
              flutterRoot,
              'bin',
              'cache',
              'dart-sdk',
              'bin',
              Platform.isWindows ? 'dart.exe' : 'dart',
            );

      final compile = await Process.run(dartExecutable, [
        'compile',
        'js',
        '-DLUCENT_BASE_URL=https://api.lumos.test',
        '-DE2E_LUCENT_BASE_URL=http://10.0.2.2:3000',
        '-DE2E_TEST_EMAIL=fullstack@example.com',
        script.path,
        '-o',
        outputPath,
      ], workingDirectory: Directory.current.path);

      expect(
        compile.exitCode,
        0,
        reason:
            'dart compile js failed using $dartExecutable:\n${compile.stdout}\n${compile.stderr}',
      );

      final run = await Process.run('node', [
        outputPath,
      ], workingDirectory: Directory.current.path);

      expect(
        run.exitCode,
        0,
        reason: 'node execution failed:\n${run.stdout}\n${run.stderr}',
      );
      expect(run.stdout, contains('https://api.lumos.test'));
      expect(run.stdout, contains('fullstack@example.com'));
    },
    timeout: const Timeout(Duration(minutes: 2)),
  );
}
