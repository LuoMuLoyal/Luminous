// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'daily_record_candidate_data_dto.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

DailyRecordCandidateDataDto _$DailyRecordCandidateDataDtoFromJson(
  Map<String, dynamic> json,
) => $checkedCreate('DailyRecordCandidateDataDto', json, ($checkedConvert) {
  $checkKeys(
    json,
    requiredKeys: const ['locale', 'generatedAt', 'confirmationHint', 'items'],
  );
  final val = DailyRecordCandidateDataDto(
    locale: $checkedConvert('locale', (v) => v as String),
    generatedAt: $checkedConvert('generatedAt', (v) => v as String),
    confirmationHint: $checkedConvert('confirmationHint', (v) => v as String),
    items: $checkedConvert(
      'items',
      (v) => (v as List<dynamic>)
          .map(
            (e) =>
                DailyRecordCandidateItemDto.fromJson(e as Map<String, dynamic>),
          )
          .toList(),
    ),
  );
  return val;
});

Map<String, dynamic> _$DailyRecordCandidateDataDtoToJson(
  DailyRecordCandidateDataDto instance,
) => <String, dynamic>{
  'locale': instance.locale,
  'generatedAt': instance.generatedAt,
  'confirmationHint': instance.confirmationHint,
  'items': instance.items.map((e) => e.toJson()).toList(),
};
