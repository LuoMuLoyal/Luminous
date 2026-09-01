import 'dart:io';

import 'package:flutter_test/flutter_test.dart';

import '../../scripts/check_doc_coverage.dart';
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
      - docs/explanation/Project_Governance.md
      - docs/reference/routing.md
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
          'docs/explanation/Project_Governance.md',
          'docs/reference/routing.md',
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
      - docs/logs/migration-log/*.md
    docs_any_of:
      - docs/reference/data-layer.md
      - docs/reference/OpenApi_Client.md
    docs_info:
      - docs/TODO.md
''');

      expect(config.rules, hasLength(1));
      expect(config.rules.single.requiredDocs, [
        'docs/logs/migration-log/*.md',
      ]);
      expect(config.rules.single.anyOfDocs, [
        'docs/reference/data-layer.md',
        'docs/reference/OpenApi_Client.md',
      ]);
      expect(config.rules.single.infoDocs, ['docs/TODO.md']);
    });
  });

  group('buildDocCoverageReport', () {
    test('reports missing required docs for matched code changes', () {
      const config = DocCoverageConfig([
        DocCoverageRule(
          name: 'auth',
          codePatterns: ['lib/features/auth/**'],
          requiredDocs: [
            'docs/explanation/Project_Governance.md',
            'docs/reference/Localization.md',
          ],
        ),
      ]);

      final report = buildDocCoverageReport(
        config: config,
        changedFiles: ['lib/features/auth/presentation/login_page.dart'],
        documentedFiles: ['docs/explanation/Project_Governance.md'],
      );

      expect(report.hasWarnings, isTrue);
      expect(report.matchedRules, hasLength(1));
      expect(report.matchedRules.single.missingRequired, [
        'docs/reference/Localization.md',
      ]);
    });

    test('flags missing any-of docs when none of them is touched', () {
      const config = DocCoverageConfig([
        DocCoverageRule(
          name: 'record',
          codePatterns: ['lib/features/record/**'],
          requiredDocs: ['docs/logs/migration-log/*.md'],
          anyOfDocs: [
            'docs/reference/routing.md',
            'docs/reference/state-management.md',
          ],
        ),
      ]);

      final report = buildDocCoverageReport(
        config: config,
        changedFiles: ['lib/features/record/presentation/page.dart'],
        documentedFiles: ['docs/logs/migration-log/2026-08-02.md'],
      );

      expect(report.hasWarnings, isTrue);
      expect(report.matchedRules.single.missingRequired, isEmpty);
      expect(report.matchedRules.single.missingAnyOf, [
        'docs/reference/routing.md',
        'docs/reference/state-management.md',
      ]);
    });

    test('satisfies any-of when at least one target is touched', () {
      const config = DocCoverageConfig([
        DocCoverageRule(
          name: 'record',
          codePatterns: ['lib/features/record/**'],
          requiredDocs: ['docs/logs/migration-log/*.md'],
          anyOfDocs: [
            'docs/reference/routing.md',
            'docs/reference/state-management.md',
          ],
        ),
      ]);

      final report = buildDocCoverageReport(
        config: config,
        changedFiles: ['lib/features/record/presentation/page.dart'],
        documentedFiles: [
          'docs/logs/migration-log/2026-08-02.md',
          'docs/reference/routing.md',
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
          requiredDocs: ['docs/logs/migration-log/*.md'],
          infoDocs: ['docs/TODO.md'],
        ),
      ]);

      final report = buildDocCoverageReport(
        config: config,
        changedFiles: ['lib/core/config/feature_flags.dart'],
        documentedFiles: ['docs/logs/migration-log/2026-08-02.md'],
      );

      expect(report.hasWarnings, isFalse);
      expect(report.hasInfos, isTrue);
      expect(report.matchedRules.single.missingInfo, ['docs/TODO.md']);
    });

    test('ignores doc-only changes', () {
      const config = DocCoverageConfig([
        DocCoverageRule(
          name: 'routing',
          codePatterns: ['lib/app/router.dart'],
          requiredDocs: ['docs/reference/routing.md'],
        ),
      ]);

      final report = buildDocCoverageReport(
        config: config,
        changedFiles: ['docs/reference/routing.md'],
        documentedFiles: ['docs/reference/routing.md'],
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
          missingRequired: ['docs/explanation/Project_Governance.md'],
          missingAnyOf: [],
          missingInfo: [],
        ),
      ]);

      final output = renderDocCoverageReport(report);

      expect(output, contains('Documentation coverage warnings'));
      expect(output, contains('auth'));
      expect(output, contains('docs/explanation/Project_Governance.md'));
      expect(output, contains('Required docs not updated'));
    });

    test('renders any-of and info sections', () {
      const report = DocCoverageReport([
        DocCoverageMatch(
          ruleName: 'record',
          touchedCodeFiles: ['lib/features/record/presentation/page.dart'],
          missingRequired: [],
          missingAnyOf: ['docs/reference/routing.md'],
          missingInfo: ['docs/TODO.md'],
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
          'docs/TODO.md': '''
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

      expect(report.staleActiveDocs, ['docs/TODO.md']);
      expect(report.staleStatusDocs, isEmpty);
      expect(report.hasWarnings, isTrue);
    });

    test('keeps recently updated active docs fresh', () {
      final report = analyzeDocFreshness(
        contentByPath: {
          'docs/TODO.md': '''
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
          'docs/reference/Removed.md': '''
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

      expect(report.staleStatusDocs, ['docs/reference/Removed.md']);
      expect(report.hasWarnings, isTrue);
    });

    test('ignores docs without front-matter', () {
      final report = analyzeDocFreshness(
        contentByPath: {
          'docs/logs/migration-log/2026-08-02.md': '# 2026-08-02 迁移日志\n',
        },
        today: '2026-08-02',
      );

      expect(report.hasWarnings, isFalse);
    });

    test('exempts status: frozen docs from freshness', () {
      // updated is >120 days old — would be stale if it were active.
      const frozenDoc = '''
---
status: frozen
owner: frontend
quadrant: reference
updated: 2026-01-01
---

# Doc
''';
      final report = analyzeDocFreshness(
        contentByPath: {'docs/reference/Forui_Reference.md': frozenDoc},
        today: '2026-08-02',
      );

      expect(report.staleActiveDocs, isEmpty);
      expect(report.staleStatusDocs, isEmpty);
      expect(report.hasWarnings, isFalse);
    });

    test('flags the same doc when it is active instead of frozen', () {
      const activeDoc = '''
---
status: active
owner: frontend
quadrant: reference
updated: 2026-01-01
---

# Doc
''';
      final report = analyzeDocFreshness(
        contentByPath: {'docs/reference/Forui_Reference.md': activeDoc},
        today: '2026-08-02',
      );

      expect(report.staleActiveDocs, ['docs/reference/Forui_Reference.md']);
      expect(report.hasWarnings, isTrue);
    });
  });

  group('isFrozenDoc', () {
    test('true only for status: frozen front-matter', () {
      expect(
        isFrozenDoc(_frontMatter(status: 'frozen', quadrant: 'reference')),
        isTrue,
      );
      expect(
        isFrozenDoc(_frontMatter(status: 'active', quadrant: 'reference')),
        isFalse,
      );
      expect(isFrozenDoc('# no front-matter'), isFalse);
      expect(isFrozenDoc(null), isFalse);
    });
  });

  group('findDocsMissingFrontMatter', () {
    test('flags required docs without complete front-matter', () {
      final missing = findDocsMissingFrontMatter(
        ['docs/TODO.md', 'docs/reference/routing.md'],
        {
          'docs/TODO.md': _frontMatter(status: 'active', quadrant: 'reference'),
          'docs/reference/routing.md': '# Routing\n',
        },
      );

      expect(missing, ['docs/reference/routing.md']);
    });

    test('exempts ADRs from the front-matter requirement', () {
      final missing = findDocsMissingFrontMatter(
        ['docs/reference/adr/0001-x.md'],
        {'docs/reference/adr/0001-x.md': '# ADR\n'},
      );

      expect(missing, isEmpty);
    });
  });

  group('findDocMapOrphans', () {
    test('flags literal doc references that do not exist', () {
      const config = DocCoverageConfig([
        DocCoverageRule(
          name: 'auth',
          codePatterns: ['lib/features/auth/**'],
          requiredDocs: ['docs/logs/migration-log/*.md'],
          anyOfDocs: ['docs/reference/Missing.md'],
        ),
      ]);

      final orphans = findDocMapOrphans(config, ['docs/TODO.md']);

      expect(orphans, ['auth: "docs/reference/Missing.md" does not exist']);
    });

    test('skips glob patterns', () {
      const config = DocCoverageConfig([
        DocCoverageRule(
          name: 'auth',
          codePatterns: ['lib/features/auth/**'],
          requiredDocs: ['docs/logs/migration-log/*.md'],
        ),
      ]);

      expect(findDocMapOrphans(config, []), isEmpty);
    });
  });

  group('findDocMapGlobOrphans', () {
    test('flags glob patterns that match no existing file', () {
      const config = DocCoverageConfig([
        DocCoverageRule(
          name: 'auth',
          codePatterns: ['lib/features/auth/**'],
          requiredDocs: ['docs/howto/*.md'],
        ),
      ]);

      final orphans = findDocMapGlobOrphans(config, ['docs/TODO.md']);

      expect(orphans, [
        'auth: glob "docs/howto/*.md" matches no existing file',
      ]);
    });
  });

  group('readershipSubjectPaths', () {
    final contentByPath = <String, String>{
      'docs/TODO.md': _frontMatter(status: 'active', quadrant: 'reference'),
      'docs/product/Product_Vision.md': _frontMatter(
        status: 'active',
        quadrant: 'explanation',
      ),
      'docs/howto/add-localization.md': _frontMatter(
        status: 'active',
        quadrant: 'how-to',
      ),
      'docs/reference/Forui_Reference.md': _frontMatter(
        status: 'frozen',
        quadrant: 'reference',
      ),
      'docs/reference/adr/0001-x.md': '# ADR\n',
    };

    test('includes active reference/explanation docs', () {
      final subjects = readershipSubjectPaths([
        'docs/TODO.md',
        'docs/product/Product_Vision.md',
      ], contentByPath);

      expect(
        subjects,
        containsAll(['docs/TODO.md', 'docs/product/Product_Vision.md']),
      );
    });

    test('excludes frozen, how-to, ADR and README docs', () {
      final subjects = readershipSubjectPaths([
        'docs/reference/Forui_Reference.md',
        'docs/howto/add-localization.md',
        'docs/reference/adr/0001-x.md',
        'docs/howto/README.md',
      ], contentByPath);

      expect(subjects, isEmpty);
    });
  });

  group('findUnreferencedActiveDocs', () {
    test('flags subjects not in doc-map and not linked from other docs', () {
      const config = DocCoverageConfig([
        DocCoverageRule(
          name: 'record',
          codePatterns: ['lib/features/record/**'],
          requiredDocs: ['docs/reference/routing.md'],
        ),
      ]);

      final unreferenced = findUnreferencedActiveDocs(
        config: config,
        subjectPaths: [
          'docs/reference/routing.md',
          'docs/reference/Forui_Reference.md',
        ],
        linkedPaths: <String>{'docs/reference/routing.md'},
      );

      expect(unreferenced, ['docs/reference/Forui_Reference.md']);
    });

    test('doc-map listing satisfies the reference requirement', () {
      const config = DocCoverageConfig([
        DocCoverageRule(
          name: 'app-shell',
          codePatterns: ['lib/features/shell/**'],
          requiredDocs: ['docs/reference/Forui_Reference.md'],
        ),
      ]);

      final unreferenced = findUnreferencedActiveDocs(
        config: config,
        subjectPaths: ['docs/reference/Forui_Reference.md'],
        linkedPaths: <String>{},
      );

      expect(unreferenced, isEmpty);
    });
  });

  group('findUncoveredFeatureDirs', () {
    test('flags feature dirs not matched by any rule', () {
      const rules = [
        DocCoverageRule(
          name: 'auth',
          codePatterns: ['lib/features/auth/**'],
          requiredDocs: ['docs/logs/migration-log/*.md'],
        ),
      ];

      expect(
        findUncoveredFeatureDirs(rules, ['auth', 'health_data', 'shell']),
        ['health_data', 'shell'],
      );
    });

    test('exemptions are honored', () {
      const rules = [
        DocCoverageRule(
          name: 'auth',
          codePatterns: ['lib/features/auth/**'],
          requiredDocs: ['docs/logs/migration-log/*.md'],
        ),
      ];

      expect(
        findUncoveredFeatureDirs(rules, ['legacy'], exemptions: ['legacy']),
        isEmpty,
      );
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
      - lib/features/review/**
    docs_required:
      - docs/explanation/Project_Governance.md
''');

      final config = loadDocCoverageConfig(configFile);

      expect(config.rules.single.name, 'current');
      expect(config.rules.single.requiredDocs, [
        'docs/explanation/Project_Governance.md',
      ]);
    });
  });
  group('findOverlongModuleReadmes', () {
    test('flags module READMEs beyond the 60-line budget', () {
      final libDir = _createLibDir({
        'features/record/README.md': _readmeOfLines(61),
        'core/network/README.md': _readmeOfLines(75),
      });

      final problems = findOverlongModuleReadmes(libDir);

      expect(problems, hasLength(2));
      expect(problems[0], contains('lib/core/network/README.md: 75 lines'));
      expect(problems[1], contains('lib/features/record/README.md: 61 lines'));
      expect(problems[1], contains('60-line module README budget'));
    });

    test('accepts READMEs at or under the budget', () {
      final libDir = _createLibDir({
        'features/record/README.md': _readmeOfLines(60),
        'core/network/README.md': _readmeOfLines(1),
        'core/empty/README.md': '',
      });

      expect(findOverlongModuleReadmes(libDir), isEmpty);
    });

    test('ignores missing READMEs and non-module README locations', () {
      final libDir = _createLibDir({
        // features/ without a README — out of scope for this assertion.
        'features/no_readme/.gitkeep': '',
        // Nested README deeper than one level — not a module README.
        'features/nested/deep/README.md': _readmeOfLines(100),
        // Outside features/ and core/ entirely.
        'theme/README.md': _readmeOfLines(100),
      });

      expect(findOverlongModuleReadmes(libDir), isEmpty);
    });
  });
}

/// Builds a YAML front-matter block with the given status and quadrant.
String _frontMatter({required String status, required String quadrant}) =>
    '''
---
status: $status
owner: frontend
quadrant: $quadrant
updated: 2026-08-01
---

# Doc
''';

/// Creates a temp `lib/` directory containing [readmes] keyed by
/// lib-relative paths (e.g. `features/record/README.md`).
Directory _createLibDir(Map<String, String> readmes) {
  final tempRoot = Directory.systemTemp.createTempSync(
    'luminous-readme-budget-test-',
  );
  addTearDown(() {
    if (tempRoot.existsSync()) {
      tempRoot.deleteSync(recursive: true);
    }
  });
  final libDir = Directory('${tempRoot.path}${Platform.pathSeparator}lib')
    ..createSync(recursive: true);
  readmes.forEach((relative, content) {
    File(
        '${libDir.path}${Platform.pathSeparator}'
        '${relative.replaceAll('/', Platform.pathSeparator)}',
      )
      ..createSync(recursive: true)
      ..writeAsStringSync(content);
  });
  return libDir;
}

/// A README body with exactly [count] lines (trailing newline terminated).
String _readmeOfLines(int count) {
  if (count <= 0) {
    return '';
  }
  return '${List.generate(count, (index) => 'line ${index + 1}').join('\n')}\n';
}
