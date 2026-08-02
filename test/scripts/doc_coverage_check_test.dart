import 'dart:io';

import 'package:flutter_test/flutter_test.dart';

import '../../scripts/doc_coverage.dart';

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
      expect(config.rules.single.anyOfDocs, isEmpty);
      expect(config.rules.single.infoDocs, isEmpty);
    });

    test('parses docs_any_of and docs_info sections', () {
      final config = parseDocCoverageConfig('''
rules:
  - name: core-network
    code:
      - lib/core/network/**
    docs_required:
      - docs/03-logs/migration-log/*.md
    docs_any_of:
      - docs/02-reference/data-layer.md
      - docs/02-reference/OpenApi_Client.md
    docs_info:
      - docs/00-current/Runtime_Snapshot.md
''');

      expect(config.rules, hasLength(1));
      expect(config.rules.single.requiredDocs, [
        'docs/03-logs/migration-log/*.md',
      ]);
      expect(config.rules.single.anyOfDocs, [
        'docs/02-reference/data-layer.md',
        'docs/02-reference/OpenApi_Client.md',
      ]);
      expect(config.rules.single.infoDocs, [
        'docs/00-current/Runtime_Snapshot.md',
      ]);
    });
  });

  group('buildDocCoverageReport', () {
    test('reports missing required docs for matched code changes', () {
      const config = DocCoverageConfig([
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
      expect(report.matchedRules.single.missingRequired, [
        'docs/02-reference/Localization.md',
      ]);
    });

    test('flags missing any-of docs when none of them is touched', () {
      const config = DocCoverageConfig([
        DocCoverageRule(
          name: 'record',
          codePatterns: ['lib/features/record/**'],
          requiredDocs: ['docs/03-logs/migration-log/*.md'],
          anyOfDocs: [
            'docs/00-current/Active_UI_Record.md',
            'docs/00-current/Active_Mobile_UI.md',
          ],
        ),
      ]);

      final report = buildDocCoverageReport(
        config: config,
        changedFiles: ['lib/features/record/presentation/page.dart'],
        documentedFiles: ['docs/03-logs/migration-log/2026-08-02.md'],
      );

      expect(report.hasWarnings, isTrue);
      expect(report.matchedRules.single.missingRequired, isEmpty);
      expect(report.matchedRules.single.missingAnyOf, [
        'docs/00-current/Active_UI_Record.md',
        'docs/00-current/Active_Mobile_UI.md',
      ]);
    });

    test('satisfies any-of when at least one target is touched', () {
      const config = DocCoverageConfig([
        DocCoverageRule(
          name: 'record',
          codePatterns: ['lib/features/record/**'],
          requiredDocs: ['docs/03-logs/migration-log/*.md'],
          anyOfDocs: [
            'docs/00-current/Active_UI_Record.md',
            'docs/00-current/Active_Mobile_UI.md',
          ],
        ),
      ]);

      final report = buildDocCoverageReport(
        config: config,
        changedFiles: ['lib/features/record/presentation/page.dart'],
        documentedFiles: [
          'docs/03-logs/migration-log/2026-08-02.md',
          'docs/00-current/Active_UI_Record.md',
        ],
      );

      expect(report.hasWarnings, isFalse);
      expect(report.matchedRules.single.missingAnyOf, isEmpty);
    });

    test('info docs are reported but do not produce warnings', () {
      const config = DocCoverageConfig([
        DocCoverageRule(
          name: 'core-config',
          codePatterns: ['lib/core/config/**'],
          requiredDocs: ['docs/03-logs/migration-log/*.md'],
          infoDocs: ['docs/00-current/Runtime_Snapshot.md'],
        ),
      ]);

      final report = buildDocCoverageReport(
        config: config,
        changedFiles: ['lib/core/config/feature_flags.dart'],
        documentedFiles: ['docs/03-logs/migration-log/2026-08-02.md'],
      );

      expect(report.hasWarnings, isFalse);
      expect(report.hasInfos, isTrue);
      expect(report.matchedRules.single.missingInfo, [
        'docs/00-current/Runtime_Snapshot.md',
      ]);
    });

    test('ignores doc-only changes', () {
      const config = DocCoverageConfig([
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
      const report = DocCoverageReport([
        DocCoverageMatch(
          ruleName: 'auth',
          touchedCodeFiles: ['lib/features/auth/presentation/login_page.dart'],
          missingRequired: ['docs/00-current/Current_State.md'],
          missingAnyOf: [],
          missingInfo: [],
        ),
      ]);

      final output = renderDocCoverageReport(report);

      expect(output, contains('Documentation coverage warnings'));
      expect(output, contains('auth'));
      expect(output, contains('docs/00-current/Current_State.md'));
      expect(output, contains('Required docs not updated'));
    });

    test('renders any-of and info sections', () {
      const report = DocCoverageReport([
        DocCoverageMatch(
          ruleName: 'record',
          touchedCodeFiles: ['lib/features/record/presentation/page.dart'],
          missingRequired: [],
          missingAnyOf: ['docs/00-current/Active_UI_Record.md'],
          missingInfo: ['docs/00-current/Runtime_Snapshot.md'],
        ),
      ]);

      final output = renderDocCoverageReport(report);

      expect(output, contains('Update at least one of'));
      expect(output, contains('Suggested docs (optional)'));
      expect(output, contains('This is warning-only and does not block'));
    });
  });

  group('analyzeDocFreshness', () {
    test('flags active docs whose updated is older than the threshold', () {
      final report = analyzeDocFreshness(
        contentByPath: {
          'docs/00-current/TODO.md': '''
---
status: active
owner: frontend
quadrant: reference
updated: 2026-01-01
---

# TODO
''',
        },
        today: '2026-08-02',
      );

      expect(report.staleActiveDocs, ['docs/00-current/TODO.md']);
      expect(report.staleStatusDocs, isEmpty);
      expect(report.hasWarnings, isTrue);
    });

    test('keeps recently updated active docs fresh', () {
      final report = analyzeDocFreshness(
        contentByPath: {
          'docs/00-current/TODO.md': '''
---
status: active
owner: frontend
quadrant: reference
updated: 2026-08-02
---

# TODO
''',
        },
        today: '2026-08-02',
      );

      expect(report.staleActiveDocs, isEmpty);
      expect(report.hasWarnings, isFalse);
    });

    test('reports docs marked status stale for archiving', () {
      final report = analyzeDocFreshness(
        contentByPath: {
          'docs/00-current/Removed.md': '''
---
status: stale
owner: frontend
quadrant: reference
updated: 2026-07-01
---

# Removed
''',
        },
        today: '2026-08-02',
      );

      expect(report.staleStatusDocs, ['docs/00-current/Removed.md']);
      expect(report.hasWarnings, isTrue);
    });

    test('ignores docs without front-matter', () {
      final report = analyzeDocFreshness(
        contentByPath: {
          'docs/03-logs/migration-log/2026-08-02.md': '# 2026-08-02 迁移日志\n',
        },
        today: '2026-08-02',
      );

      expect(report.hasWarnings, isFalse);
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
