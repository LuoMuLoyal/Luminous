import 'package:flutter_test/flutter_test.dart';
import 'package:luminous/features/scan/domain/services/text_matcher.dart';

void main() {
  group('MedicineTextMatcher', () {
    final matcher = const MedicineTextMatcher();

    group('extractCandidates – approval number strategy', () {
      test('extracts 国药准字H approval number', () {
        final result = matcher.extractCandidates('国药准字H20012345 阿莫西林胶囊');
        expect(result, hasLength(1));
        expect(result.first.query, '国药准字H20012345');
        expect(result.first.matchType, MedicineMatchType.approvalNumber);
        expect(result.first.confidence, 1.0);
      });

      test('extracts 国药准字Z approval number', () {
        final result = matcher.extractCandidates('国药准字Z20067890');
        expect(result, hasLength(1));
        expect(result.first.query, '国药准字Z20067890');
      });

      test('extracts 国药准字S approval number', () {
        final result = matcher.extractCandidates('国药准字S10980001');
        expect(result.first.matchType, MedicineMatchType.approvalNumber);
      });

      test('extracts 国药准字B approval number', () {
        final result = matcher.extractCandidates('国药准字B20020001');
        expect(result.first.matchType, MedicineMatchType.approvalNumber);
      });

      test('extracts 国药准字J approval number', () {
        final result = matcher.extractCandidates('国药准字J20180001');
        expect(result.first.matchType, MedicineMatchType.approvalNumber);
      });

      test('approval number takes priority over barcode and name', () {
        final result = matcher.extractCandidates(
          '6901234567890 国药准字H20012345 布洛芬',
        );
        expect(result, hasLength(1));
        expect(result.first.matchType, MedicineMatchType.approvalNumber);
      });
    });

    group('extractCandidates – barcode strategy', () {
      test('extracts 13-digit barcode starting with 69', () {
        final result = matcher.extractCandidates('6901234567890');
        expect(result, hasLength(1));
        expect(result.first.query, '6901234567890');
        expect(result.first.matchType, MedicineMatchType.barcode);
        expect(result.first.confidence, 0.95);
      });

      test('barcode takes priority over name fuzzy', () {
        final result = matcher.extractCandidates('6901234567890 布洛芬片');
        expect(result, hasLength(1));
        expect(result.first.matchType, MedicineMatchType.barcode);
      });

      test('does not match 12-digit code as barcode', () {
        final result = matcher.extractCandidates('690123456789');
        expect(
          result.every((r) => r.matchType != MedicineMatchType.barcode),
          isTrue,
        );
      });

      test('does not match barcode not starting with 69', () {
        final result = matcher.extractCandidates('6801234567890');
        expect(
          result.every((r) => r.matchType != MedicineMatchType.barcode),
          isTrue,
        );
      });
    });

    group('extractCandidates – name fuzzy strategy', () {
      test('extracts CJK segments as drug name candidates', () {
        final result = matcher.extractCandidates('布洛芬缓释胶囊');
        expect(result, isNotEmpty);
        expect(result.first.matchType, MedicineMatchType.nameFuzzy);
      });

      test('extracts multiple unique CJK segments', () {
        final result = matcher.extractCandidates('布洛芬 阿莫西林 头孢');
        final names = result.map((r) => r.query).toList();
        expect(names, containsAll(['布洛芬', '阿莫西林', '头孢']));
        expect(result.length, lessThanOrEqualTo(5));
      });

      test('deduplicates repeated names', () {
        final result = matcher.extractCandidates('布洛芬 布洛芬 布洛芬');
        final names = result.map((r) => r.query).toList();
        expect(names.toSet().length, names.length);
      });

      test('limits to 5 candidates', () {
        final result = matcher.extractCandidates(
          '布洛芬 阿莫西林 头孢 阿司匹林 对乙酰氨基酚 氯雷他定 红霉素',
        );
        expect(result.length, lessThanOrEqualTo(5));
      });
    });

    group('extractCandidates – stop word filtering', () {
      test('filters out common non-drug words', () {
        final result = matcher.extractCandidates('药品 用法 用量 注意 事项');
        final names = result.map((r) => r.query).toList();
        expect(names, isNot(contains('药品')));
        expect(names, isNot(contains('用法')));
        expect(names, isNot(contains('用量')));
        expect(names, isNot(contains('注意')));
        expect(names, isNot(contains('事项')));
      });

      test('filters out additional stop words', () {
        final result = matcher.extractCandidates('禁忌 不良反应 贮藏 规格 厂商');
        final names = result.map((r) => r.query).toList();
        expect(names, isNot(contains('禁忌')));
        expect(names, isNot(contains('不良反应')));
        expect(names, isNot(contains('贮藏')));
        expect(names, isNot(contains('规格')));
        expect(names, isNot(contains('厂商')));
      });

      test('filters out dosage-related stop words', () {
        final result = matcher.extractCandidates('一天 每次 每日 一次 毫克 毫升');
        final names = result.map((r) => r.query).toList();
        expect(names, isNot(contains('一天')));
        expect(names, isNot(contains('每次')));
        expect(names, isNot(contains('每日')));
        expect(names, isNot(contains('一次')));
        expect(names, isNot(contains('毫克')));
        expect(names, isNot(contains('毫升')));
      });

      test('filters out packaging-related stop words', () {
        final result = matcher.extractCandidates('包装 本品 说明书 生产 企业');
        final names = result.map((r) => r.query).toList();
        expect(names, isNot(contains('包装')));
        expect(names, isNot(contains('本品')));
        expect(names, isNot(contains('说明书')));
        expect(names, isNot(contains('生产')));
        expect(names, isNot(contains('企业')));
      });
    });

    group('extractCandidates – confidence calculation', () {
      test('longer names have higher confidence', () {
        final shortResult = matcher.extractCandidates('布洛');
        final longResult = matcher.extractCandidates('布洛芬缓释胶囊');

        final shortConf = shortResult.first.confidence;
        final longConf = longResult.first.confidence;
        expect(longConf, greaterThan(shortConf));
      });

      test('confidence is capped at 0.85 for name fuzzy', () {
        final result = matcher.extractCandidates('布洛芬缓释胶囊片');
        for (final candidate in result) {
          if (candidate.matchType == MedicineMatchType.nameFuzzy) {
            expect(candidate.confidence, lessThanOrEqualTo(0.85));
          }
        }
      });

      test('2-char name has confidence 2/6 ≈ 0.333', () {
        final result = matcher.extractCandidates('布洛');
        final nameCandidates = result.where(
          (r) => r.matchType == MedicineMatchType.nameFuzzy,
        );
        if (nameCandidates.isNotEmpty) {
          expect(nameCandidates.first.confidence, closeTo(2 / 6.0, 0.01));
        }
      });

      test('6+ char name has confidence 0.85 (capped)', () {
        final result = matcher.extractCandidates('布洛芬缓释胶囊');
        final nameCandidates = result.where(
          (r) => r.matchType == MedicineMatchType.nameFuzzy,
        );
        if (nameCandidates.isNotEmpty) {
          expect(nameCandidates.first.confidence, 0.85);
        }
      });
    });

    group('extractCandidates – edge cases', () {
      test('empty string returns no candidates', () {
        final result = matcher.extractCandidates('');
        expect(result, isEmpty);
      });

      test('whitespace-only string returns no candidates', () {
        final result = matcher.extractCandidates('   \n\t  ');
        expect(result, isEmpty);
      });

      test(
        'non-CJK text without approval number or barcode returns no candidates',
        () {
          final result = matcher.extractCandidates('ABC 123 test');
          expect(result, isEmpty);
        },
      );

      test('mixed text extracts approval number first', () {
        final result = matcher.extractCandidates(
          'Product Name: 国药准字H20012345\nManufacturer: Some Corp',
        );
        expect(result, hasLength(1));
        expect(result.first.matchType, MedicineMatchType.approvalNumber);
      });

      test('does not extract partial approval number', () {
        final result = matcher.extractCandidates('国药准字H2001234');
        // 7 digits instead of 8 — should not match
        expect(
          result.every((r) => r.matchType != MedicineMatchType.approvalNumber),
          isTrue,
        );
      });
    });

    group('MedicineMatchResult', () {
      test('can be constructed with all fields', () {
        const result = MedicineMatchResult(
          name: '阿莫西林',
          approvalNumber: '国药准字H20012345',
          id: 'med-1',
          confidence: 0.95,
          matchType: MedicineMatchType.approvalNumber,
        );
        expect(result.name, '阿莫西林');
        expect(result.approvalNumber, '国药准字H20012345');
        expect(result.id, 'med-1');
        expect(result.confidence, 0.95);
        expect(result.matchType, MedicineMatchType.approvalNumber);
      });

      test('can be constructed with minimal fields', () {
        const result = MedicineMatchResult(
          name: '布洛芬',
          confidence: 0.5,
          matchType: MedicineMatchType.nameFuzzy,
        );
        expect(result.name, '布洛芬');
        expect(result.approvalNumber, isNull);
        expect(result.id, isNull);
        expect(result.confidence, 0.5);
      });
    });

    group('MedicineMatchType enum', () {
      test('has exactly 3 values', () {
        expect(MedicineMatchType.values, hasLength(3));
      });

      test('contains approvalNumber, barcode, nameFuzzy', () {
        expect(
          MedicineMatchType.values,
          contains(MedicineMatchType.approvalNumber),
        );
        expect(MedicineMatchType.values, contains(MedicineMatchType.barcode));
        expect(MedicineMatchType.values, contains(MedicineMatchType.nameFuzzy));
      });
    });
  });
}
