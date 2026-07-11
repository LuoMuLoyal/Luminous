import 'dart:convert';

import 'package:flutter_test/flutter_test.dart';
import 'package:luminous/features/record/data/utils/daily_record_json_codec.dart';
import 'package:luminous/features/record/domain/entities/record.dart';

void main() {
  group('DailyRecordJsonCodec', () {
    DailyRecordItem createItem({
      String id = 'rec-001',
      DailyRecordKind kind = DailyRecordKind.water,
      String occurredAt = '2026-07-10',
      String? occurredTime = '08:30',
      String? title = '晨起饮水',
      String? value = '500',
      String? unit = 'ml',
      String? note = '感觉良好',
      String? source = 'manual',
      Map<String, dynamic>? payload = const {'key': 'value'},
      String? mealAnalysisStatus,
      String? mealAnalysisCoverage,
      String? mealAnalysisUpdatedAt,
      String? mealAnalysisFailureReason,
      String? mealShortDescription,
      List<String> mealTopFoods = const [],
      List<DailyRecordAttachment> attachments = const [],
      String createdAt = '2026-07-10T08:30:00.000Z',
      String updatedAt = '2026-07-10T08:30:00.000Z',
    }) {
      return DailyRecordItem(
        id: id,
        kind: kind,
        occurredAt: occurredAt,
        occurredTime: occurredTime,
        title: title,
        value: value,
        unit: unit,
        note: note,
        source: source,
        payload: payload,
        mealAnalysisStatus: mealAnalysisStatus,
        mealAnalysisCoverage: mealAnalysisCoverage,
        mealAnalysisUpdatedAt: mealAnalysisUpdatedAt,
        mealAnalysisFailureReason: mealAnalysisFailureReason,
        mealShortDescription: mealShortDescription,
        mealTopFoods: mealTopFoods,
        attachments: attachments,
        createdAt: createdAt,
        updatedAt: updatedAt,
      );
    }

    DailyRecordAttachment createAttachment({
      String id = 'att-001',
      DailyRecordAttachmentKind kind = DailyRecordAttachmentKind.image,
      String objectKey = 'uploads/2026/img-001.jpg',
      String? bucket = 'lucent-records',
      String? provider = 'oss',
      String? fileName = 'photo.jpg',
      String? contentType = 'image/jpeg',
      int? sizeBytes = 102400,
      int? width = 1080,
      int? height = 1920,
      String? publicUrl = 'https://cdn.example.com/img-001.jpg',
      String createdAt = '2026-07-10T08:00:00.000Z',
    }) {
      return DailyRecordAttachment(
        id: id,
        kind: kind,
        objectKey: objectKey,
        bucket: bucket,
        provider: provider,
        fileName: fileName,
        contentType: contentType,
        sizeBytes: sizeBytes,
        width: width,
        height: height,
        publicUrl: publicUrl,
        createdAt: createdAt,
      );
    }

    group('itemToJson / itemFromJson round-trip', () {
      test('round-trips a minimal item with only required fields', () {
        final item = DailyRecordItem(
          id: 'rec-minimal',
          kind: DailyRecordKind.note,
          occurredAt: '2026-07-10',
          createdAt: '2026-07-10T00:00:00.000Z',
          updatedAt: '2026-07-10T00:00:00.000Z',
        );

        final json = DailyRecordJsonCodec.itemToJson(item);
        final restored = DailyRecordJsonCodec.itemFromJson(json);

        expect(restored.id, 'rec-minimal');
        expect(restored.kind, DailyRecordKind.note);
        expect(restored.occurredAt, '2026-07-10');
        expect(restored.occurredTime, isNull);
        expect(restored.title, isNull);
        expect(restored.value, isNull);
        expect(restored.unit, isNull);
        expect(restored.note, isNull);
        expect(restored.source, isNull);
        expect(restored.payload, isNull);
        expect(restored.mealAnalysisStatus, isNull);
        expect(restored.mealTopFoods, isEmpty);
        expect(restored.attachments, isEmpty);
        expect(restored.createdAt, '2026-07-10T00:00:00.000Z');
        expect(restored.updatedAt, '2026-07-10T00:00:00.000Z');
      });

      test('round-trips a fully populated water record', () {
        final item = createItem();

        final json = DailyRecordJsonCodec.itemToJson(item);
        final restored = DailyRecordJsonCodec.itemFromJson(json);

        expect(restored.id, 'rec-001');
        expect(restored.kind, DailyRecordKind.water);
        expect(restored.occurredAt, '2026-07-10');
        expect(restored.occurredTime, '08:30');
        expect(restored.title, '晨起饮水');
        expect(restored.value, '500');
        expect(restored.unit, 'ml');
        expect(restored.note, '感觉良好');
        expect(restored.source, 'manual');
        expect(restored.payload, isNotNull);
        expect(restored.payload!['key'], 'value');
        expect(restored.createdAt, '2026-07-10T08:30:00.000Z');
        expect(restored.updatedAt, '2026-07-10T08:30:00.000Z');
      });

      test('round-trips a meal record with meal analysis fields', () {
        final item = createItem(
          id: 'meal-001',
          kind: DailyRecordKind.meal,
          title: '午餐',
          value: null,
          unit: null,
          mealAnalysisStatus: 'completed',
          mealAnalysisCoverage: 'full',
          mealAnalysisUpdatedAt: '2026-07-10T12:30:00.000Z',
          mealAnalysisFailureReason: null,
          mealShortDescription: '米饭配炒菜',
          mealTopFoods: ['米饭', '青菜', '鸡蛋'],
        );

        final json = DailyRecordJsonCodec.itemToJson(item);
        final restored = DailyRecordJsonCodec.itemFromJson(json);

        expect(restored.kind, DailyRecordKind.meal);
        expect(restored.mealAnalysisStatus, 'completed');
        expect(restored.mealAnalysisCoverage, 'full');
        expect(restored.mealAnalysisUpdatedAt, '2026-07-10T12:30:00.000Z');
        expect(restored.mealAnalysisFailureReason, isNull);
        expect(restored.mealShortDescription, '米饭配炒菜');
        expect(restored.mealTopFoods, ['米饭', '青菜', '鸡蛋']);
      });

      test('round-trips a meal record with analysis failure', () {
        final item = createItem(
          id: 'meal-fail',
          kind: DailyRecordKind.meal,
          mealAnalysisStatus: 'failed',
          mealAnalysisFailureReason: 'image_too_blurry',
          mealShortDescription: null,
        );

        final json = DailyRecordJsonCodec.itemToJson(item);
        final restored = DailyRecordJsonCodec.itemFromJson(json);

        expect(restored.mealAnalysisStatus, 'failed');
        expect(restored.mealAnalysisFailureReason, 'image_too_blurry');
        expect(restored.mealShortDescription, isNull);
      });

      test('round-trips all DailyRecordKind values', () {
        for (final kind in DailyRecordKind.values) {
          final item = createItem(id: 'kind-${kind.name}', kind: kind);

          final json = DailyRecordJsonCodec.itemToJson(item);
          final restored = DailyRecordJsonCodec.itemFromJson(json);

          expect(restored.kind, kind, reason: 'Failed for kind: ${kind.name}');
        }
      });

      test('unknown kind in JSON falls back to note', () {
        final item = createItem();
        final json = DailyRecordJsonCodec.itemToJson(item);
        final jsonMap = jsonDecode(json) as Map<String, dynamic>;
        jsonMap['kind'] = 'nonexistent_kind';
        final modifiedJson = jsonEncode(jsonMap);

        final restored = DailyRecordJsonCodec.itemFromJson(modifiedJson);
        expect(restored.kind, DailyRecordKind.note);
      });

      test('round-trips null payload', () {
        final item = createItem(payload: null);

        final json = DailyRecordJsonCodec.itemToJson(item);
        final restored = DailyRecordJsonCodec.itemFromJson(json);

        expect(restored.payload, isNull);
      });

      test('round-trips empty mealTopFoods list', () {
        final item = createItem(mealTopFoods: []);

        final json = DailyRecordJsonCodec.itemToJson(item);
        final restored = DailyRecordJsonCodec.itemFromJson(json);

        expect(restored.mealTopFoods, isEmpty);
      });

      test('round-trips null mealTopFoods in JSON as empty list', () {
        final item = createItem();
        final json = DailyRecordJsonCodec.itemToJson(item);
        final jsonMap = jsonDecode(json) as Map<String, dynamic>;
        jsonMap.remove('mealTopFoods');
        final modifiedJson = jsonEncode(jsonMap);

        final restored = DailyRecordJsonCodec.itemFromJson(modifiedJson);
        expect(restored.mealTopFoods, isEmpty);
      });
    });

    group('attachment serialization', () {
      test('round-trips a fully populated attachment', () {
        final attachment = createAttachment();
        final item = createItem(attachments: [attachment]);

        final json = DailyRecordJsonCodec.itemToJson(item);
        final restored = DailyRecordJsonCodec.itemFromJson(json);

        expect(restored.attachments, hasLength(1));
        final att = restored.attachments.first;
        expect(att.id, 'att-001');
        expect(att.kind, DailyRecordAttachmentKind.image);
        expect(att.objectKey, 'uploads/2026/img-001.jpg');
        expect(att.bucket, 'lucent-records');
        expect(att.provider, 'oss');
        expect(att.fileName, 'photo.jpg');
        expect(att.contentType, 'image/jpeg');
        expect(att.sizeBytes, 102400);
        expect(att.width, 1080);
        expect(att.height, 1920);
        expect(att.publicUrl, 'https://cdn.example.com/img-001.jpg');
        expect(att.createdAt, '2026-07-10T08:00:00.000Z');
      });

      test('round-trips a minimal attachment with only required fields', () {
        final attachment = DailyRecordAttachment(
          id: 'att-min',
          kind: DailyRecordAttachmentKind.image,
          objectKey: 'img/key',
          createdAt: '2026-07-10T00:00:00.000Z',
        );
        final item = createItem(attachments: [attachment]);

        final json = DailyRecordJsonCodec.itemToJson(item);
        final restored = DailyRecordJsonCodec.itemFromJson(json);

        expect(restored.attachments, hasLength(1));
        final att = restored.attachments.first;
        expect(att.id, 'att-min');
        expect(att.bucket, isNull);
        expect(att.provider, isNull);
        expect(att.fileName, isNull);
        expect(att.contentType, isNull);
        expect(att.sizeBytes, isNull);
        expect(att.width, isNull);
        expect(att.height, isNull);
        expect(att.publicUrl, isNull);
      });

      test('round-trips multiple attachments', () {
        final item = createItem(
          attachments: [
            createAttachment(id: 'att-001', objectKey: 'key-1'),
            createAttachment(id: 'att-002', objectKey: 'key-2'),
            createAttachment(id: 'att-003', objectKey: 'key-3'),
          ],
        );

        final json = DailyRecordJsonCodec.itemToJson(item);
        final restored = DailyRecordJsonCodec.itemFromJson(json);

        expect(restored.attachments, hasLength(3));
        expect(restored.attachments[0].id, 'att-001');
        expect(restored.attachments[1].id, 'att-002');
        expect(restored.attachments[2].id, 'att-003');
      });

      test('null attachments in JSON defaults to empty list', () {
        final item = createItem();
        final json = DailyRecordJsonCodec.itemToJson(item);
        final jsonMap = jsonDecode(json) as Map<String, dynamic>;
        jsonMap.remove('attachments');
        final modifiedJson = jsonEncode(jsonMap);

        final restored = DailyRecordJsonCodec.itemFromJson(modifiedJson);
        expect(restored.attachments, isEmpty);
      });

      test('unknown attachment kind falls back to image', () {
        final attachment = createAttachment();
        final item = createItem(attachments: [attachment]);

        final json = DailyRecordJsonCodec.itemToJson(item);
        final jsonMap = jsonDecode(json) as Map<String, dynamic>;
        (jsonMap['attachments'] as List)[0]['kind'] = 'unknown_kind';
        final modifiedJson = jsonEncode(jsonMap);

        final restored = DailyRecordJsonCodec.itemFromJson(modifiedJson);
        expect(
          restored.attachments.first.kind,
          DailyRecordAttachmentKind.image,
        );
      });
    });

    group('JSON structure verification', () {
      test('produces valid JSON with all expected top-level keys', () {
        final item = createItem();

        final json = DailyRecordJsonCodec.itemToJson(item);
        final map = jsonDecode(json) as Map<String, dynamic>;

        expect(map, containsPair('id', 'rec-001'));
        expect(map, containsPair('kind', 'water'));
        expect(map, containsPair('occurredAt', '2026-07-10'));
        expect(map, containsPair('occurredTime', '08:30'));
        expect(map, containsPair('title', '晨起饮水'));
        expect(map, containsPair('value', '500'));
        expect(map, containsPair('unit', 'ml'));
        expect(map, containsPair('note', '感觉良好'));
        expect(map, containsPair('source', 'manual'));
        expect(map, containsPair('payload', isNotNull));
        expect(map, containsPair('mealTopFoods', isA<List>()));
        expect(map, containsPair('attachments', isA<List>()));
        expect(map, containsPair('createdAt', '2026-07-10T08:30:00.000Z'));
        expect(map, containsPair('updatedAt', '2026-07-10T08:30:00.000Z'));
      });

      test('attachment JSON includes all expected keys', () {
        final attachment = createAttachment();
        final item = createItem(attachments: [attachment]);

        final json = DailyRecordJsonCodec.itemToJson(item);
        final map = jsonDecode(json) as Map<String, dynamic>;
        final attMap = (map['attachments'] as List).first
            as Map<String, dynamic>;

        expect(attMap, containsPair('id', 'att-001'));
        expect(attMap, containsPair('kind', 'image'));
        expect(attMap, containsPair('objectKey', 'uploads/2026/img-001.jpg'));
        expect(attMap, containsPair('bucket', 'lucent-records'));
        expect(attMap, containsPair('sizeBytes', 102400));
        expect(attMap, containsPair('width', 1080));
        expect(attMap, containsPair('height', 1920));
      });
    });
  });
}
