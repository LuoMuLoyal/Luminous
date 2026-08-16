import 'package:flutter_test/flutter_test.dart';
import 'package:luminous/features/scan/domain/entities/scan_result.dart';
import 'package:luminous/features/scan/domain/services/candidate_merger.dart';

void main() {
  MedicineMatchCandidate candidate(
    String query,
    double confidence, {
    MedicineMatchType matchType = MedicineMatchType.nameFuzzy,
  }) {
    return MedicineMatchCandidate(
      query: query,
      confidence: confidence,
      matchType: matchType,
    );
  }

  MedicineMatchResult result(
    String name, {
    String? id,
    double? confidence,
    MedicineMatchType matchType = MedicineMatchType.nameFuzzy,
  }) {
    return MedicineMatchResult(
      name: name,
      id: id,
      confidence: confidence,
      matchType: matchType,
    );
  }

  group('dedupeCandidates', () {
    test(
      'keeps only the highest-confidence candidate per normalized query',
      () {
        final candidates = [
          candidate('阿莫西林胶囊', 0.5),
          candidate('阿莫西林胶囊', 0.9),
          candidate('阿莫西林胶囊', 0.7),
        ];

        final deduped = dedupeCandidates(candidates);

        expect(deduped, hasLength(1));
        expect(deduped.single.query, '阿莫西林胶囊');
        expect(deduped.single.confidence, 0.9);
      },
    );

    test(
      'treats whitespace and case variants of the same query as duplicates',
      () {
        final candidates = [
          candidate('Amoxicillin', 0.6),
          candidate('  AMOXICILLIN ', 0.9),
          candidate('amoxicillin', 0.4),
        ];

        final deduped = dedupeCandidates(candidates);

        expect(deduped, hasLength(1));
        expect(deduped.single.query, '  AMOXICILLIN ');
        expect(deduped.single.confidence, 0.9);
      },
    );

    test('keeps distinct queries in first-appearance order', () {
      final candidates = [
        candidate('阿莫西林胶囊', 0.8),
        candidate('阿莫西林颗粒', 0.7),
        candidate('头孢克肟', 0.6),
      ];

      final deduped = dedupeCandidates(candidates);

      expect(deduped.map((c) => c.query), ['阿莫西林胶囊', '阿莫西林颗粒', '头孢克肟']);
    });

    test('keeps the first candidate on a confidence tie (deterministic)', () {
      final first = candidate('阿莫西林胶囊', 0.7);
      final second = candidate('阿莫西林胶囊', 0.7);

      final deduped = dedupeCandidates([first, second]);

      expect(deduped, hasLength(1));
      expect(identical(deduped.single, first), isTrue);
    });

    test('returns an empty list for an empty input', () {
      expect(dedupeCandidates([]), isEmpty);
    });

    test('keeps every candidate when all queries are distinct', () {
      final candidates = [candidate('A', 0.9), candidate('B', 0.8)];
      final deduped = dedupeCandidates(candidates);
      expect(deduped.map((c) => c.query), ['A', 'B']);
      // 元素原样保留（同实例），仅列表容器为新建。
      expect(identical(deduped[0], candidates[0]), isTrue);
      expect(identical(deduped[1], candidates[1]), isTrue);
    });
  });

  group('mergeSearchResults', () {
    test('merges results with the same id, keeping the highest confidence', () {
      final merged = mergeSearchResults([
        result('阿莫西林胶囊', id: 'med-1', confidence: 0.6),
        result('阿莫西林颗粒', id: 'med-1', confidence: 0.9),
        result('阿莫西林胶囊', id: 'med-1', confidence: 0.7),
      ]);

      expect(merged, hasLength(1));
      final kept = merged.single;
      // 保留 confidence 最高者，其 name/matchType 随保留结果。
      expect(kept.name, '阿莫西林颗粒');
      expect(kept.id, 'med-1');
      expect(kept.confidence, 0.9);
    });

    test('keeps the first result on an id/confidence tie (deterministic)', () {
      final first = result('阿莫西林胶囊', id: 'med-1', confidence: 0.8);
      final second = result('阿莫西林胶囊', id: 'med-1', confidence: 0.8);

      final merged = mergeSearchResults([first, second]);

      expect(merged, hasLength(1));
      expect(identical(merged.single, first), isTrue);
    });

    test('merges id-less results by name, keeping the highest confidence', () {
      final merged = mergeSearchResults([
        result('阿莫西林胶囊', confidence: 0.5),
        result('阿莫西林胶囊', confidence: 0.8),
        result('阿莫西林颗粒', confidence: 0.6),
      ]);

      expect(merged, hasLength(2));
      expect(merged[0].name, '阿莫西林胶囊');
      expect(merged[0].confidence, 0.8);
      expect(merged[1].name, '阿莫西林颗粒');
      expect(merged[1].confidence, 0.6);
    });

    test('treats a null confidence as 0 when comparing', () {
      final merged = mergeSearchResults([
        result('阿莫西林胶囊', id: 'med-1', confidence: null),
        result('阿莫西林胶囊', id: 'med-1', confidence: 0.1),
      ]);

      expect(merged, hasLength(1));
      expect(merged.single.confidence, 0.1);
    });

    test(
      'does not merge an id result with an id-less result of the same name',
      () {
        final merged = mergeSearchResults([
          result('阿莫西林胶囊', id: 'med-1', confidence: 0.9),
          result('阿莫西林胶囊', confidence: 0.8),
        ]);

        expect(merged, hasLength(2));
        expect(merged[0].id, 'med-1');
        expect(merged[1].id, isNull);
      },
    );

    test('keeps first-appearance order and the kept result fields', () {
      final merged = mergeSearchResults([
        result('头孢克肟', id: 'med-3', confidence: 0.6),
        result('阿莫西林胶囊', id: 'med-1', confidence: 0.9),
        result('阿莫西林颗粒', id: 'med-1', confidence: 0.5),
      ]);

      expect(merged, hasLength(2));
      expect(merged[0].name, '头孢克肟');
      expect(merged[0].matchType, MedicineMatchType.nameFuzzy);
      expect(merged[1].name, '阿莫西林胶囊');
      expect(merged[1].confidence, 0.9);
    });

    test('returns an empty list for an empty input', () {
      expect(mergeSearchResults([]), isEmpty);
    });
  });
}
