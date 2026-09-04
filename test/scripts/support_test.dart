import 'dart:io';

import 'package:flutter_test/flutter_test.dart';

import '../../scripts/support.dart';

void main() {
  group('resolveRequiredOpenApiFile', () {
    test('uses explicit path inside repo root when provided', () {
      final tempRoot = Directory.systemTemp.createTempSync(
        'luminous-openapi-test-',
      );
      addTearDown(() {
        if (tempRoot.existsSync()) {
          tempRoot.deleteSync(recursive: true);
        }
      });

      final file = File(
        '${tempRoot.path}${Platform.pathSeparator}ci-openapi.value',
      )..writeAsStringSync('{}');

      final resolved = resolveRequiredOpenApiFile(
        'ci-openapi.value',
        defaultLucentRoot: Directory(
          '${tempRoot.path}${Platform.pathSeparator}missing-lucent',
        ),
        repoRoot: tempRoot,
      );

      expect(resolved.path, file.absolute.path);
    });

    test('falls back to default Lucent docs/openapi.json path', () {
      final tempRoot = Directory.systemTemp.createTempSync(
        'luminous-openapi-test-',
      );
      addTearDown(() {
        if (tempRoot.existsSync()) {
          tempRoot.deleteSync(recursive: true);
        }
      });

      final lucentRoot = Directory(
        '${tempRoot.path}${Platform.pathSeparator}Lucent',
      );
      final docsDir = Directory(
        '${lucentRoot.path}${Platform.pathSeparator}docs',
      )..createSync(recursive: true);
      final openApiFile = File(
        '${docsDir.path}${Platform.pathSeparator}openapi.json',
      )..writeAsStringSync('{}');

      final resolved = resolveRequiredOpenApiFile(
        null,
        defaultLucentRoot: lucentRoot,
        repoRoot: tempRoot,
      );

      expect(resolved.path, openApiFile.absolute.path);
    });

    test('throws a clear error when the explicit file does not exist', () {
      final tempRoot = Directory.systemTemp.createTempSync(
        'luminous-openapi-test-',
      );
      addTearDown(() {
        if (tempRoot.existsSync()) {
          tempRoot.deleteSync(recursive: true);
        }
      });

      expect(
        () => resolveRequiredOpenApiFile(
          'missing-openapi.value',
          defaultLucentRoot: Directory(
            '${tempRoot.path}${Platform.pathSeparator}missing-lucent',
          ),
          repoRoot: tempRoot,
        ),
        throwsA(
          isA<StateError>().having(
            (error) => error.message,
            'message',
            contains('Lucent OpenAPI file not found'),
          ),
        ),
      );
    });
  });

  group('runLoggedCommand retry gating', () {
    // runLoggedCommand 的 maxRetries 现在只重试 `executable == 'dart'` 且
    // stderr 含 Windows 文件锁特征(error 1224 / "The process cannot access
    // the file")的失败;其余确定性失败首次即上抛(2026-09-03 审查 #8)。
    // 测试用一个临时 dart 脚本按参数写 stderr 并以退出码 1 失败,计数器文件
    // 记录实际执行次数来断言是否发生重试。
    late Directory tempRoot;
    late File runner;
    late File counter;

    setUp(() {
      tempRoot = Directory.systemTemp.createTempSync(
        'luminous-runlogged-test-',
      );
      runner = File('${tempRoot.path}${Platform.pathSeparator}runner.dart')
        ..writeAsStringSync('''
import 'dart:io';

void main(List<String> args) {
  File(args[0]).writeAsStringSync('run\\n', mode: FileMode.append);
  if (args.length > 1 && args[1].isNotEmpty) {
    stderr.writeln(args[1]);
  }
  exit(1);
}
''');
      counter = File('${tempRoot.path}${Platform.pathSeparator}counter.txt');
    });

    tearDown(() {
      if (tempRoot.existsSync()) {
        tempRoot.deleteSync(recursive: true);
      }
    });

    List<String> args(String marker) => [runner.path, counter.path, marker];

    int runCount() {
      if (!counter.existsSync()) return 0;
      return counter
          .readAsStringSync()
          .split('\n')
          .where((line) => line.isNotEmpty)
          .length;
    }

    test('deterministic failure (no lock marker) is not retried', () async {
      await expectLater(
        runLoggedCommand(
          'dart',
          args('syntax error here'),
          workingDirectory: tempRoot,
          maxRetries: 1,
        ),
        throwsA(isA<ProcessException>()),
      );
      expect(runCount(), 1);
    });

    test(
      'non-dart executable failure is not retried even with the marker',
      () async {
        // Resolve a real launcher so the `executable == 'dart'` gate can be
        // observed: the literal string differs even though the binary is dart.
        final probe = await Process.run(
          Platform.isWindows ? 'where' : 'which',
          ['dart'],
        );
        final launcher = '${probe.stdout}'.trim().split(RegExp(r'\r?\n')).first;
        expect(launcher, isNotEmpty);

        await expectLater(
          runLoggedCommand(
            launcher,
            args('error 1224'),
            workingDirectory: tempRoot,
            maxRetries: 1,
          ),
          throwsA(isA<ProcessException>()),
        );
        expect(runCount(), 1);
      },
    );

    test(
      'dart + lock marker is retried once when maxRetries permits it',
      () async {
        await expectLater(
          runLoggedCommand(
            'dart',
            args('The process cannot access the file'),
            workingDirectory: tempRoot,
            maxRetries: 1,
          ),
          throwsA(isA<ProcessException>()),
        );
        expect(runCount(), 2);
      },
    );

    test(
      'dart + lock marker with maxRetries 0 fails on the first run',
      () async {
        await expectLater(
          runLoggedCommand(
            'dart',
            args('error 1224'),
            workingDirectory: tempRoot,
            maxRetries: 0,
          ),
          throwsA(isA<ProcessException>()),
        );
        expect(runCount(), 1);
      },
    );
  });
}
