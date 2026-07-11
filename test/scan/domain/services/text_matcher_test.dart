import 'package:flutter_test/flutter_test.dart';
import 'package:luminous/features/scan/domain/services/text_matcher.dart';

void main() {
  group('MedicineTextMatcher', () {
    const matcher = MedicineTextMatcher();

    group('extractCandidates — approval number strategy', () {
      test('matches standard 国药准字HXXXXXXXX format', () {
        const ocrText = '国药准字H12345678 生产厂家：某某制药';
        final candidates = matcher.extractCandidates(ocrText);

        expect(candidates, hasLength(1));
        expect(candidates.first.query, '国药准字H12345678');
        expect(candidates.first.matchType, MedicineMatchType.approvalNumber);
        expect(candidates.first.confidence, 1.0);
      });

      test('matches 国药准字 with letter Z', () {
        final candidates = matcher.extractCandidates('国药准字Z20001234');
        expect(candidates.first.matchType, MedicineMatchType.approvalNumber);
        expect(candidates.first.query, '国药准字Z20001234');
      });

      test('matches 国药准字 with letter S', () {
        final candidates = matcher.extractCandidates('国药准字S10002345');
        expect(candidates.first.matchType, MedicineMatchType.approvalNumber);
      });

      test('matches 国药准字 with letter B', () {
        final candidates = matcher.extractCandidates('国药准字B67890123');
        expect(candidates.first.matchType, MedicineMatchType.approvalNumber);
      });

      test('matches 国药准字 with letter J', () {
        final candidates = matcher.extractCandidates('国药准字J87654321');
        expect(candidates.first.matchType, MedicineMatchType.approvalNumber);
      });

      test('does not match with unsupported letter prefix', () {
        final candidates = matcher.extractCandidates('国药准字X12345678');
        // 'X' is not in [HZSBJ], so approval number regex should not match
        // Falls through to name fuzzy matching
        expect(
          candidates.any(
            (c) => c.matchType == MedicineMatchType.approvalNumber,
          ),
          isFalse,
        );
      });

      test('does not match with fewer than 8 digits', () {
        final candidates = matcher.extractCandidates('国药准字H1234567');
        expect(
          candidates.any(
            (c) => c.matchType == MedicineMatchType.approvalNumber,
          ),
          isFalse,
        );
      });

      test('approval number strategy takes priority over barcode', () {
        const ocrText = '国药准字H12345678 条码：6901234567890';
        final candidates = matcher.extractCandidates(ocrText);

        expect(candidates, hasLength(1));
        expect(candidates.first.matchType, MedicineMatchType.approvalNumber);
      });
    });

    group('extractCandidates — barcode strategy', () {
      test('matches standard 13-digit barcode starting with 69', () {
        const ocrText = '6901234567890';
        final candidates = matcher.extractCandidates(ocrText);

        expect(candidates, hasLength(1));
        expect(candidates.first.query, '6901234567890');
        expect(candidates.first.matchType, MedicineMatchType.barcode);
        expect(candidates.first.confidence, 0.95);
      });

      test('matches barcode embedded in text', () {
        const ocrText = '产品条码: 6909876543210 生产日期2026';
        final candidates = matcher.extractCandidates(ocrText);

        expect(candidates, hasLength(1));
        expect(candidates.first.matchType, MedicineMatchType.barcode);
        expect(candidates.first.query, '6909876543210');
      });

      test('does not match 12-digit barcode (too short)', () {
        final candidates = matcher.extractCandidates('690123456789');
        expect(
          candidates.any((c) => c.matchType == MedicineMatchType.barcode),
          isFalse,
        );
      });

      test('does not match barcode not starting with 69', () {
        final candidates = matcher.extractCandidates('6801234567890');
        expect(
          candidates.any((c) => c.matchType == MedicineMatchType.barcode),
          isFalse,
        );
      });

      test('barcode strategy takes priority over name fuzzy', () {
        const ocrText = '6901234567890 阿莫西林胶囊';
        final candidates = matcher.extractCandidates(ocrText);

        expect(candidates, hasLength(1));
        expect(candidates.first.matchType, MedicineMatchType.barcode);
      });
    });

    group('extractCandidates — name fuzzy strategy', () {
      test('extracts CJK segments as drug name candidates', () {
        const ocrText = '阿莫西林胶囊 用法用量口服';
        final candidates = matcher.extractCandidates(ocrText);

        // Should contain '阿莫西林胶囊' as a candidate (5 chars)
        expect(candidates.any((c) => c.query == '阿莫西林胶囊'), isTrue);
        expect(
          candidates.every((c) => c.matchType == MedicineMatchType.nameFuzzy),
          isTrue,
        );
      });

      test('filters out common stop words', () {
        const ocrText = '药品 用法 用量 注意 事项 禁忌 不良反应 贮藏 规格';
        final candidates = matcher.extractCandidates(ocrText);

        // All these are stop words, so no candidates should match
        // (each is 2 chars which is the minimum, but they're filtered)
        expect(candidates, isEmpty);
      });

      test('deduplicates repeated segments', () {
        const ocrText = '阿莫西林 阿莫西林 阿莫西林';
        final candidates = matcher.extractCandidates(ocrText);

        expect(candidates, hasLength(1));
        expect(candidates.first.query, '阿莫西林');
      });

      test('limits to at most 5 candidates', () {
        const ocrText = '阿莫西林 布洛芬缓释 复方甘草 氨酚烷胺 六味地黄丸 藿香正气 牛黄解毒片';
        final candidates = matcher.extractCandidates(ocrText);

        expect(candidates.length, lessThanOrEqualTo(5));
      });

      test('does not extract single CJK character', () {
        const ocrText = '药';
        final candidates = matcher.extractCandidates(ocrText);

        // Single char doesn't meet the 2-char minimum
        expect(candidates, isEmpty);
      });

      test('confidence increases with name length up to 0.85', () {
        const twoCharText = '阿莫';
        const sixCharText = '阿莫西林胶囊';

        final twoCharCandidates = matcher.extractCandidates(twoCharText);
        final sixCharCandidates = matcher.extractCandidates(sixCharText);

        expect(twoCharCandidates.first.confidence, closeTo(2 / 6.0, 0.001));
        expect(sixCharCandidates.first.confidence, closeTo(0.85, 0.001));
      });

      test('confidence caps at 0.85 for names longer than 6 chars', () {
        const ocrText = '复方氨酚烷胺那敏'; // 8 chars
        final candidates = matcher.extractCandidates(ocrText);

        expect(candidates.first.confidence, 0.85);
      });
    });

    group('extractCandidates — edge cases', () {
      test('returns empty list for empty string', () {
        final candidates = matcher.extractCandidates('');
        expect(candidates, isEmpty);
      });

      test('returns empty list for whitespace-only string', () {
        final candidates = matcher.extractCandidates('   \n\t  ');
        expect(candidates, isEmpty);
      });

      test('returns empty list for non-CJK non-barcode text', () {
        final candidates = matcher.extractCandidates('Hello World 12345');
        expect(candidates, isEmpty);
      });

      test('handles mixed Chinese and English text', () {
        const ocrText = 'Aspirin 阿司匹林肠溶片 100mg';
        final candidates = matcher.extractCandidates(ocrText);

        expect(candidates, isNotEmpty);
        expect(candidates.any((c) => c.query == '阿司匹林肠溶片'), isTrue);
      });
    });
  });

  group('MedicineMatchCandidate', () {
    test('stores query, matchType, and confidence', () {
      const candidate = MedicineMatchCandidate(
        query: '国药准字H12345678',
        matchType: MedicineMatchType.approvalNumber,
        confidence: 1.0,
      );

      expect(candidate.query, '国药准字H12345678');
      expect(candidate.matchType, MedicineMatchType.approvalNumber);
      expect(candidate.confidence, 1.0);
    });
  });

  group('MedicineMatchResult', () {
    test('stores all fields correctly', () {
      const result = MedicineMatchResult(
        name: '阿莫西林胶囊',
        approvalNumber: '国药准字H12345678',
        id: 'med-001',
        confidence: 0.95,
        matchType: MedicineMatchType.approvalNumber,
      );

      expect(result.name, '阿莫西林胶囊');
      expect(result.approvalNumber, '国药准字H12345678');
      expect(result.id, 'med-001');
      expect(result.confidence, 0.95);
      expect(result.matchType, MedicineMatchType.approvalNumber);
    });

    test('supports nullable fields', () {
      const result = MedicineMatchResult(
        name: '阿莫西林',
        confidence: 0.5,
        matchType: MedicineMatchType.nameFuzzy,
      );

      expect(result.approvalNumber, isNull);
      expect(result.id, isNull);
      expect(result.matchType, MedicineMatchType.nameFuzzy);
    });
  });

  group('MedicineMatchType', () {
    test('has all expected values', () {
      expect(MedicineMatchType.values, hasLength(3));
      expect(
        MedicineMatchType.values,
        contains(MedicineMatchType.approvalNumber),
      );
      expect(MedicineMatchType.values, contains(MedicineMatchType.barcode));
      expect(MedicineMatchType.values, contains(MedicineMatchType.nameFuzzy));
    });
  });
}
