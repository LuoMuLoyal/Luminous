// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'environment_snapshot_response_dto.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

EnvironmentSnapshotResponseDto _$EnvironmentSnapshotResponseDtoFromJson(
  Map<String, dynamic> json,
) => $checkedCreate('EnvironmentSnapshotResponseDto', json, ($checkedConvert) {
  $checkKeys(json, requiredKeys: const ['code', 'message', 'data']);
  final val = EnvironmentSnapshotResponseDto(
    code: $checkedConvert('code', (v) => v as num),
    message: $checkedConvert('message', (v) => v as String),
    data: $checkedConvert(
      'data',
      (v) => EnvironmentSnapshotDto.fromJson(v as Map<String, dynamic>),
    ),
  );
  return val;
});

Map<String, dynamic> _$EnvironmentSnapshotResponseDtoToJson(
  EnvironmentSnapshotResponseDto instance,
) => <String, dynamic>{
  'code': instance.code,
  'message': instance.message,
  'data': instance.data.toJson(),
};
