import 'dart:ui';

import 'package:flutter_test/flutter_test.dart';
import 'package:luminous/features/scan/domain/entities/scan_result.dart';
import 'package:luminous/features/scan/domain/services/medicine_ocr_extractor.dart';

OcrTextBlock _block({
  required String text,
  double confidence = 0.9,
  Rect? boundingBox,
}) {
  final rect = boundingBox ?? const Rect.fromLTWH(10, 10, 100, 30);
  return OcrTextBlock(
    text: text,
    confidence: confidence,
    boundingBox: rect,
    points: [
      Offset(rect.left, rect.top),
      Offset(rect.right, rect.top),
      Offset(rect.right, rect.bottom),
      Offset(rect.left, rect.bottom),
    ],
  );
}

void main() {
  const extractor = MedicineOcrExtractor();

  group('MedicineOcrExtractor.extractCandidates', () {
    group('approval number fuzzy matching', () {
      test('exact approval number is matched', () {
        final blocks = [_block(text: '国药准字H12345678')];
        final result = extractor.extractCandidates(blocks);
        expect(result, hasLength(1));
        expect(result.first.query, contains('国药准字'));
        expect(result.first.matchType, MedicineMatchType.approvalNumber);
        expect(result.first.confidence, closeTo(0.9, 0.01));
      });

      test('approval number with OCR confusion (准→淮)', () {
        final blocks = [_block(text: '国药淮字H12345678')];
        final result = extractor.extractCandidates(blocks);
        expect(result, hasLength(1));
        expect(result.first.matchType, MedicineMatchType.approvalNumber);
        expect(result.first.query, contains('准'));
      });

      test('approval number with spaces is normalised', () {
        final blocks = [_block(text: '国药准字 H12345678')];
        final result = extractor.extractCandidates(blocks);
        expect(result, hasLength(1));
        expect(result.first.matchType, MedicineMatchType.approvalNumber);
      });

      test('approval number in mixed text is extracted', () {
        final blocks = [
          _block(text: '某药品'),
          _block(text: '国药准字Z20010001'),
          _block(text: '用法用量'),
        ];
        final result = extractor.extractCandidates(blocks);
        expect(result, hasLength(1));
        expect(result.first.matchType, MedicineMatchType.approvalNumber);
      });
    });

    group('name extraction via spatial scoring', () {
      test('larger bounding box scores higher than smaller', () {
        final blocks = [
          _block(
            text: '用法用量',
            boundingBox: const Rect.fromLTWH(0, 200, 50, 15),
            confidence: 0.9,
          ),
          _block(
            text: '阿莫西林胶囊',
            boundingBox: const Rect.fromLTWH(0, 10, 300, 80),
            confidence: 0.9,
          ),
        ];
        final result = extractor.extractCandidates(blocks);
        expect(result, isNotEmpty);
        // The large "阿莫西林胶囊" block should rank first
        expect(result.first.query, '阿莫西林胶囊');
      });

      test('upper position scores higher than lower', () {
        final blocks = [
          _block(
            text: '布洛芬缓释胶囊',
            boundingBox: const Rect.fromLTWH(10, 5, 100, 30),
            confidence: 0.9,
          ),
          _block(
            text: '生产厂商',
            boundingBox: const Rect.fromLTWH(10, 500, 100, 30),
            confidence: 0.9,
          ),
        ];
        final result = extractor.extractCandidates(blocks);
        expect(result, isNotEmpty);
        expect(result.first.query, '布洛芬缓释胶囊');
      });

      test('stop words are penalised', () {
        final blocks = [
          _block(
            text: '用法用量',
            boundingBox: const Rect.fromLTWH(10, 5, 300, 80),
            confidence: 0.95,
          ),
          _block(
            text: '对乙酰氨基酚片',
            boundingBox: const Rect.fromLTWH(10, 50, 100, 30),
            confidence: 0.8,
          ),
        ];
        final result = extractor.extractCandidates(blocks);
        expect(result, isNotEmpty);
        // "用法用量" is a stop word with a huge area but should be penalised
        expect(result.first.query, '对乙酰氨基酚片');
      });

      test('high confidence beats low confidence with equal layout', () {
        final blocks = [
          _block(
            text: '阿司匹林',
            boundingBox: const Rect.fromLTWH(10, 10, 100, 30),
            confidence: 0.95,
          ),
          _block(
            text: '低置信度',
            boundingBox: const Rect.fromLTWH(10, 10, 100, 30),
            confidence: 0.3,
          ),
        ];
        final result = extractor.extractCandidates(blocks);
        expect(result, isNotEmpty);
        expect(result.first.query, '阿司匹林');
      });
    });

    group('edge cases', () {
      test('empty input returns empty list', () {
        final result = extractor.extractCandidates([]);
        expect(result, isEmpty);
      });

      test('single short text returns candidate', () {
        final blocks = [_block(text: '阿莫西林')];
        final result = extractor.extractCandidates(blocks);
        expect(result, hasLength(1));
        expect(result.first.matchType, MedicineMatchType.nameFuzzy);
      });

      test('takes at most 5 candidates', () {
        final blocks = List.generate(10, (i) {
          return _block(
            text: '药品$i',
            boundingBox: Rect.fromLTWH(10.0 + i * 50, 10.0 + i * 30, 80, 25),
            confidence: 0.8,
          );
        });
        final result = extractor.extractCandidates(blocks);
        expect(result.length, lessThanOrEqualTo(5));
      });

      test('very short text (< 2 chars) is penalised', () {
        final blocks = [
          _block(
            text: 'A',
            boundingBox: const Rect.fromLTWH(10, 10, 300, 80),
            confidence: 0.95,
          ),
          _block(
            text: '复方甘草片',
            boundingBox: const Rect.fromLTWH(10, 50, 100, 30),
            confidence: 0.7,
          ),
        ];
        final result = extractor.extractCandidates(blocks);
        expect(result, isNotEmpty);
        // Single char "A" should be penalised despite large bounding box
        expect(result.first.query, '复方甘草片');
      });
    });
  });
}
