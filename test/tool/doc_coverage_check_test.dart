import 'dart:io';

import 'package:flutter_test/flutter_test.dart';

import '../../tool/doc_coverage.dart';

void main() {
  group('parseDocCoverageConfig', () {
    test('parses rule blocks with code and required docs', () {
      final config = parseDocCoverageConfig('''
rules:
  - name: auth
    code:
      - lib/features/auth/**
      - lib/app/router.dart
    docs_required:
      - docs/00-current/Current_State.md
      - docs/02-reference/routing.md
''');

      expect(config.rules, hasLength(1));
      expect(config.rules.single.name, 'auth');
      expect(
        config.rules.single.codePatterns,
        equals(['lib/features/auth/**', 'lib/app/router.dart']),
      );
      expect(
        config.rules.single.requiredDocs,
        equals([
          'docs/00-current/Current_State.md',
          'docs/02-reference/routing.md',
        ]),
      );
    });
  });

  group('buildDocCoverageReport', () {
    test('reports missing required docs for matched code changes', () {
      final config = const DocCoverageConfig([
        DocCoverageRule(
          name: 'auth',
          codePatterns: ['lib/features/auth/**'],
          requiredDocs: [
            'docs/00-current/Current_State.md',
            'docs/02-reference/Localization.md',
          ],
        ),
      ]);

      final report = buildDocCoverageReport(
        config: config,
        changedFiles: ['lib/features/auth/presentation/login_page.dart'],
        documentedFiles: ['docs/00-current/Current_State.md'],
      );

      expect(report.hasWarnings, isTrue);
      expect(report.matchedRules, hasLength(1));
      expect(report.matchedRules.single.missingDocs, [
        'docs/02-reference/Localization.md',
      ]);
    });

    test('ignores doc-only changes', () {
      final config = const DocCoverageConfig([
        DocCoverageRule(
          name: 'routing',
          codePatterns: ['lib/app/router.dart'],
          requiredDocs: ['docs/02-reference/routing.md'],
        ),
      ]);

      final report = buildDocCoverageReport(
        config: config,
        changedFiles: ['docs/02-reference/routing.md'],
        documentedFiles: ['docs/02-reference/routing.md'],
      );

      expect(report.hasWarnings, isFalse);
      expect(report.matchedRules, isEmpty);
    });
  });

  group('renderDocCoverageReport', () {
    test('renders a readable warning summary', () {
      final report = const DocCoverageReport([
        DocCoverageMatch(
          ruleName: 'auth',
          touchedCodeFiles: ['lib/features/auth/presentation/login_page.dart'],
          missingDocs: ['docs/00-current/Current_State.md'],
        ),
      ]);

      final output = renderDocCoverageReport(report);

      expect(output, contains('Documentation coverage warnings'));
      expect(output, contains('auth'));
      expect(output, contains('docs/00-current/Current_State.md'));
    });
  });

  group('loadDocCoverageConfig', () {
    test('loads config from disk', () {
      final tempRoot = Directory.systemTemp.createTempSync(
        'luminous-doc-coverage-test-',
      );
      addTearDown(() {
        if (tempRoot.existsSync()) {
          tempRoot.deleteSync(recursive: true);
        }
      });

      final configFile =
          File('${tempRoot.path}${Platform.pathSeparator}doc-map.yaml')
            ..writeAsStringSync('''
rules:
  - name: current
    code:
      - lib/features/report/**
    docs_required:
      - docs/00-current/Current_State.md
''');

      final config = loadDocCoverageConfig(configFile);

      expect(config.rules.single.name, 'current');
      expect(config.rules.single.requiredDocs, [
        'docs/00-current/Current_State.md',
      ]);
    });
  });
}
