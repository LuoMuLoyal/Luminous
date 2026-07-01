import 'dart:io';

import 'package:flutter_test/flutter_test.dart';

import '../../tool/tooling_support.dart';

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
        '${tempRoot.path}${Platform.pathSeparator}ci-openapi.json',
      )..writeAsStringSync('{}');

      final resolved = resolveRequiredOpenApiFile(
        'ci-openapi.json',
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
          'missing-openapi.json',
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
}
