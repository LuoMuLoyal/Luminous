import 'package:flutter_test/flutter_test.dart';
import 'package:luminous/features/record/domain/entities/record.dart';

void main() {
  // ── DailyRecordAttachment.displayUrl ──────────────────────────
  group('DailyRecordAttachment.displayUrl', () {
    test('returns publicUrl when it is a non-empty string', () {
      const attachment = DailyRecordAttachment(
        id: 'att-1',
        kind: DailyRecordAttachmentKind.image,
        objectKey: 'uploads/123.jpg',
        publicUrl: 'https://cdn.example.com/123.jpg',
        createdAt: '2026-07-14T10:00:00Z',
      );
      expect(attachment.displayUrl, 'https://cdn.example.com/123.jpg');
    });

    test('returns null when publicUrl is null', () {
      const attachment = DailyRecordAttachment(
        id: 'att-2',
        kind: DailyRecordAttachmentKind.image,
        objectKey: 'uploads/456.jpg',
        publicUrl: null,
        createdAt: '2026-07-14T10:00:00Z',
      );
      expect(attachment.displayUrl, isNull);
    });

    test('returns null when publicUrl is empty string', () {
      const attachment = DailyRecordAttachment(
        id: 'att-3',
        kind: DailyRecordAttachmentKind.image,
        objectKey: 'uploads/789.jpg',
        publicUrl: '',
        createdAt: '2026-07-14T10:00:00Z',
      );
      expect(attachment.displayUrl, isNull);
    });

    test('returns null when publicUrl is whitespace-only', () {
      const attachment = DailyRecordAttachment(
        id: 'att-4',
        kind: DailyRecordAttachmentKind.image,
        objectKey: 'uploads/abc.jpg',
        publicUrl: '   ',
        createdAt: '2026-07-14T10:00:00Z',
      );
      expect(attachment.displayUrl, isNull);
    });

    test(
      'returns trimmed publicUrl when it has leading/trailing whitespace',
      () {
        const attachment = DailyRecordAttachment(
          id: 'att-5',
          kind: DailyRecordAttachmentKind.image,
          objectKey: 'uploads/def.jpg',
          publicUrl: '  https://cdn.example.com/def.jpg  ',
          createdAt: '2026-07-14T10:00:00Z',
        );
        expect(attachment.displayUrl, 'https://cdn.example.com/def.jpg');
      },
    );
  });

  // ── DailyRecordKind enum ─────────────────────────────────────
  group('DailyRecordKind', () {
    test('contains all expected values', () {
      expect(
        DailyRecordKind.values,
        containsAll([
          DailyRecordKind.water,
          DailyRecordKind.meal,
          DailyRecordKind.vital,
          DailyRecordKind.mood,
          DailyRecordKind.symptom,
          DailyRecordKind.activity,
          DailyRecordKind.note,
          DailyRecordKind.sleep,
        ]),
      );
    });

    test('has exactly 8 values', () {
      expect(DailyRecordKind.values, hasLength(8));
    });
  });

  // ── DailyRecordAttachmentKind enum ───────────────────────────
  group('DailyRecordAttachmentKind', () {
    test('contains image value', () {
      expect(
        DailyRecordAttachmentKind.values,
        contains(DailyRecordAttachmentKind.image),
      );
    });
  });

  // ── DailyRecordItem construction ─────────────────────────────
  group('DailyRecordItem', () {
    test('can be constructed with minimal required fields', () {
      const item = DailyRecordItem(
        id: 'rec-1',
        kind: DailyRecordKind.water,
        occurredAt: '2026-07-14',
        createdAt: '2026-07-14T10:00:00Z',
        updatedAt: '2026-07-14T10:00:00Z',
      );
      expect(item.id, 'rec-1');
      expect(item.kind, DailyRecordKind.water);
      expect(item.occurredAt, '2026-07-14');
      expect(item.occurredTime, isNull);
      expect(item.title, isNull);
      expect(item.value, isNull);
      expect(item.unit, isNull);
      expect(item.note, isNull);
      expect(item.source, isNull);
      expect(item.payload, isNull);
      expect(item.mealAnalysisStatus, isNull);
      expect(item.mealAnalysisCoverage, isNull);
      expect(item.mealAnalysisUpdatedAt, isNull);
      expect(item.mealAnalysisFailureReason, isNull);
      expect(item.mealShortDescription, isNull);
      expect(item.mealTopFoods, isEmpty);
      expect(item.attachments, isEmpty);
    });

    test('can be constructed with all fields populated', () {
      const attachment = DailyRecordAttachment(
        id: 'att-1',
        kind: DailyRecordAttachmentKind.image,
        objectKey: 'uploads/photo.jpg',
        publicUrl: 'https://cdn.example.com/photo.jpg',
        createdAt: '2026-07-14T10:00:00Z',
      );
      final item = const DailyRecordItem(
        id: 'rec-2',
        kind: DailyRecordKind.meal,
        occurredAt: '2026-07-14',
        occurredTime: '12:30',
        title: 'Lunch',
        value: '500',
        unit: 'kcal',
        note: 'Felt full',
        source: 'manual',
        payload: {'key': 'value'},
        mealAnalysisStatus: 'confirmed',
        mealAnalysisCoverage: 'complete',
        mealAnalysisUpdatedAt: '2026-07-14T12:35:00Z',
        mealAnalysisFailureReason: null,
        mealShortDescription: 'Rice with chicken',
        mealTopFoods: ['Rice', 'Chicken'],
        attachments: [attachment],
        createdAt: '2026-07-14T12:30:00Z',
        updatedAt: '2026-07-14T12:35:00Z',
      );

      expect(item.id, 'rec-2');
      expect(item.kind, DailyRecordKind.meal);
      expect(item.occurredTime, '12:30');
      expect(item.title, 'Lunch');
      expect(item.value, '500');
      expect(item.unit, 'kcal');
      expect(item.note, 'Felt full');
      expect(item.source, 'manual');
      expect(item.payload, {'key': 'value'});
      expect(item.mealAnalysisStatus, 'confirmed');
      expect(item.mealAnalysisCoverage, 'complete');
      expect(item.mealAnalysisUpdatedAt, '2026-07-14T12:35:00Z');
      expect(item.mealShortDescription, 'Rice with chicken');
      expect(item.mealTopFoods, ['Rice', 'Chicken']);
      expect(item.attachments, hasLength(1));
      expect(
        item.attachments.first.displayUrl,
        'https://cdn.example.com/photo.jpg',
      );
    });
  });

  // ── DailyRecordSummary ───────────────────────────────────────
  group('DailyRecordSummary', () {
    test('can be constructed without latest item', () {
      const summary = DailyRecordSummary(kind: DailyRecordKind.water, count: 5);
      expect(summary.kind, DailyRecordKind.water);
      expect(summary.count, 5);
      expect(summary.latest, isNull);
    });

    test('can be constructed with latest item', () {
      const item = DailyRecordItem(
        id: 'rec-1',
        kind: DailyRecordKind.water,
        occurredAt: '2026-07-14',
        createdAt: '2026-07-14T10:00:00Z',
        updatedAt: '2026-07-14T10:00:00Z',
      );
      final summary = const DailyRecordSummary(
        kind: DailyRecordKind.water,
        count: 1,
        latest: item,
      );
      expect(summary.latest, isNotNull);
      expect(summary.latest!.id, 'rec-1');
    });
  });

  // ── DailyRecordListData ──────────────────────────────────────
  group('DailyRecordListData', () {
    test('can be constructed with empty items', () {
      const data = DailyRecordListData(items: [], total: 0);
      expect(data.items, isEmpty);
      expect(data.total, 0);
    });

    test('can be constructed with items and total', () {
      const item = DailyRecordItem(
        id: 'rec-1',
        kind: DailyRecordKind.water,
        occurredAt: '2026-07-14',
        createdAt: '2026-07-14T10:00:00Z',
        updatedAt: '2026-07-14T10:00:00Z',
      );
      const data = DailyRecordListData(items: [item], total: 1);
      expect(data.items, hasLength(1));
      expect(data.total, 1);
    });
  });

  // ── DailyRecordSummaryData ───────────────────────────────────
  group('DailyRecordSummaryData', () {
    test('can be constructed with empty summaries', () {
      const data = DailyRecordSummaryData(summaries: []);
      expect(data.summaries, isEmpty);
    });

    test('can be constructed with summaries', () {
      const summary = DailyRecordSummary(kind: DailyRecordKind.water, count: 3);
      const data = DailyRecordSummaryData(summaries: [summary]);
      expect(data.summaries, hasLength(1));
      expect(data.summaries.first.kind, DailyRecordKind.water);
    });
  });
}
