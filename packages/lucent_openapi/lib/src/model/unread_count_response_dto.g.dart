// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'unread_count_response_dto.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

UnreadCountResponseDto _$UnreadCountResponseDtoFromJson(
  Map<String, dynamic> json,
) => $checkedCreate('UnreadCountResponseDto', json, ($checkedConvert) {
  $checkKeys(json, requiredKeys: const ['code', 'message', 'count']);
  final val = UnreadCountResponseDto(
    code: $checkedConvert('code', (v) => v as num),
    message: $checkedConvert('message', (v) => v as String),
    count: $checkedConvert('count', (v) => v as num),
  );
  return val;
});

Map<String, dynamic> _$UnreadCountResponseDtoToJson(
  UnreadCountResponseDto instance,
) => <String, dynamic>{
  'code': instance.code,
  'message': instance.message,
  'count': instance.count,
};
