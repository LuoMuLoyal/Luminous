import 'package:flutter_test/flutter_test.dart';

import '../../scripts/docs/coverage.dart';

void main() {
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

  group('isActiveDoc / isFrontMatterRequired', () {
    test('classifies the de-numbered layout', () {
      expect(isActiveDoc('docs/README.md'), isTrue);
      expect(isActiveDoc('docs/TODO.md'), isTrue);
      expect(isActiveDoc('docs/reference/routing.md'), isTrue);
      expect(isActiveDoc('docs/howto/add-localization.md'), isTrue);
      expect(isActiveDoc('docs/reference/adr/0001-x.md'), isTrue);
      expect(isActiveDoc('docs/logs/migration-log/2026-09-15.md'), isFalse);
      expect(isActiveDoc('docs/archive/old-note.md'), isFalse);

      expect(isFrontMatterRequired('docs/reference/routing.md'), isTrue);
      expect(isFrontMatterRequired('docs/reference/adr/0001-x.md'), isFalse);
      expect(isFrontMatterRequired('docs/README.md'), isFalse);
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
    test('flags subjects not linked from other docs', () {
      final unreferenced = findUnreferencedActiveDocs(
        subjectPaths: [
          'docs/reference/routing.md',
          'docs/reference/Forui_Reference.md',
        ],
        linkedPaths: <String>{'docs/reference/routing.md'},
      );

      expect(unreferenced, ['docs/reference/Forui_Reference.md']);
    });

    test('a linked subject passes the readership rule', () {
      final unreferenced = findUnreferencedActiveDocs(
        subjectPaths: ['docs/reference/routing.md'],
        linkedPaths: <String>{'docs/reference/routing.md'},
      );

      expect(unreferenced, isEmpty);
    });
  });

  group('findUncoveredFeatureDirs', () {
    test('flags feature dirs without a README', () {
      expect(
        findUncoveredFeatureDirs([
          'auth',
          'health_data',
          'shell',
        ], (dir) => dir == 'auth'),
        ['health_data', 'shell'],
      );
    });

    test('exemptions are honored', () {
      expect(
        findUncoveredFeatureDirs(
          ['legacy'],
          (_) => false,
          exemptions: ['legacy'],
        ),
        isEmpty,
      );
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
