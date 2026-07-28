import 'dart:typed_data';

import 'package:flutter_test/flutter_test.dart';
import 'package:luminous/core/providers/data_change_bus.dart';
import 'package:luminous/features/record/domain/entities/inputs.dart';
import 'package:luminous/features/record/domain/entities/record.dart';
import 'package:luminous/features/record/presentation/quick_entry/meal_flow.dart';

void main() {
  group('MealQuickEntryFlow', () {
    test(
      'camera cancel returns cancelled outcome and writes nothing',
      () async {
        final created = <DailyRecordCreateInput>[];
        final flow = MealQuickEntryFlow(
          pickImage: (_) async => null,
          uploadImage: (_) async => throw StateError('unused'),
          createRecord: (input) async {
            created.add(input);
            return _record(id: 'meal-1', input: input);
          },
          emitDataChange: (_) {},
        );

        final outcome = await flow.startWithCamera(
          const MealQuickEntryContext(
            occurredAt: '2026-07-28',
            occurredTime: '12:30',
          ),
        );

        expect(outcome.type, MealQuickEntryOutcomeType.cancelled);
        expect(created, isEmpty);
      },
    );

    test('camera image returns a confirmation draft', () async {
      final image = MealQuickImage(
        bytes: Uint8List.fromList([1, 2, 3]),
        fileName: 'lunch.jpg',
        contentType: 'image/jpeg',
      );
      final flow = MealQuickEntryFlow(
        pickImage: (_) async => image,
        uploadImage: (_) async => throw StateError('unused'),
        createRecord: (input) async => _record(id: 'meal-1', input: input),
        emitDataChange: (_) {},
      );

      final outcome = await flow.startWithCamera(
        const MealQuickEntryContext(
          occurredAt: '2026-07-28',
          occurredTime: '12:30',
          defaultTitle: '午餐',
        ),
      );

      expect(outcome.type, MealQuickEntryOutcomeType.needsConfirmation);
      expect(outcome.draft?.image, image);
      expect(outcome.draft?.title, '午餐');
    });

    test(
      'confirmed camera draft uploads image and creates meal record',
      () async {
        DailyRecordImageUploadInput? uploaded;
        DailyRecordCreateInput? created;
        final emitted = <String>[];
        final image = MealQuickImage(
          bytes: Uint8List.fromList([1, 2, 3]),
          fileName: 'lunch.jpg',
          contentType: 'image/jpeg',
        );
        final flow = MealQuickEntryFlow(
          pickImage: (_) async => image,
          uploadImage: (input) async {
            uploaded = input;
            return const DailyRecordAttachmentInput(
              objectKey: 'daily-records/user-1/lunch.jpg',
              fileName: 'lunch.jpg',
              contentType: 'image/jpeg',
              sizeBytes: 3,
              publicUrl: 'https://cdn.example.com/lunch.jpg',
            );
          },
          createRecord: (input) async {
            created = input;
            return _record(id: 'meal-1', input: input);
          },
          emitDataChange: emitted.add,
        );

        final draft = MealQuickEntryDraft(
          occurredAt: '2026-07-28',
          occurredTime: '12:30',
          title: '午餐',
          value: '番茄炒蛋',
          note: '少油',
          image: image,
        );
        await flow.saveDraft(draft);

        expect(uploaded?.bytes, image.bytes);
        expect(uploaded?.contentType, 'image/jpeg');
        expect(uploaded?.sizeBytes, 3);
        expect(created?.kind, DailyRecordKind.meal);
        expect(created?.occurredAt, '2026-07-28');
        expect(created?.occurredTime, '12:30');
        expect(created?.title, '午餐');
        expect(created?.value, '番茄炒蛋');
        expect(created?.note, '少油');
        expect(created?.attachments, hasLength(1));
        expect(emitted, [DataChangeTopic.dailyRecords]);
      },
    );

    test(
      'confirmed manual draft creates meal record without attachment',
      () async {
        DailyRecordCreateInput? created;
        final flow = MealQuickEntryFlow(
          pickImage: (_) async => null,
          uploadImage: (_) async => throw StateError('unused'),
          createRecord: (input) async {
            created = input;
            return _record(id: 'meal-1', input: input);
          },
          emitDataChange: (_) {},
        );

        await flow.saveDraft(
          const MealQuickEntryDraft(
            occurredAt: '2026-07-28',
            occurredTime: '12:30',
            title: '午餐',
            value: '手动记录',
          ),
        );

        expect(created?.attachments, isEmpty);
        expect(created?.title, '午餐');
        expect(created?.value, '手动记录');
      },
    );
  });
}

DailyRecordItem _record({
  required String id,
  required DailyRecordCreateInput input,
}) {
  return DailyRecordItem(
    id: id,
    kind: input.kind,
    occurredAt: input.occurredAt,
    occurredTime: input.occurredTime,
    title: input.title,
    value: input.value,
    unit: input.unit,
    note: input.note,
    payload: input.payload,
    attachments: [
      for (final attachment in input.attachments)
        DailyRecordAttachment(
          id: 'attachment-${attachment.objectKey}',
          kind: DailyRecordAttachmentKind.image,
          objectKey: attachment.objectKey,
          fileName: attachment.fileName,
          contentType: attachment.contentType,
          sizeBytes: attachment.sizeBytes,
          publicUrl: attachment.publicUrl,
          createdAt: '2026-07-28T00:00:00.000Z',
        ),
    ],
    createdAt: '2026-07-28T00:00:00.000Z',
    updatedAt: '2026-07-28T00:00:00.000Z',
  );
}
