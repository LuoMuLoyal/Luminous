// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'generate_daily_record_candidates_dto.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

GenerateDailyRecordCandidatesDto _$GenerateDailyRecordCandidatesDtoFromJson(
  Map<String, dynamic> json,
) =>
    $checkedCreate('GenerateDailyRecordCandidatesDto', json, ($checkedConvert) {
      $checkKeys(json, requiredKeys: const ['text', 'occurredAt']);
      final val = GenerateDailyRecordCandidatesDto(
        text: $checkedConvert('text', (v) => v as String),
        occurredAt: $checkedConvert('occurredAt', (v) => v as String),
        timezone: $checkedConvert('timezone', (v) => v as String?),
      );
      return val;
    });

Map<String, dynamic> _$GenerateDailyRecordCandidatesDtoToJson(
  GenerateDailyRecordCandidatesDto instance,
) => <String, dynamic>{
  'text': instance.text,
  'occurredAt': instance.occurredAt,
  if (instance.timezone != null) 'timezone': instance.timezone,
};
