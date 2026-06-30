// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'clinic_summary_share_response_dto.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

ClinicSummaryShareResponseDto _$ClinicSummaryShareResponseDtoFromJson(
  Map<String, dynamic> json,
) => $checkedCreate('ClinicSummaryShareResponseDto', json, ($checkedConvert) {
  $checkKeys(json, requiredKeys: const ['shareUrl', 'expiresAt']);
  final val = ClinicSummaryShareResponseDto(
    shareUrl: $checkedConvert('shareUrl', (v) => v as String),
    expiresAt: $checkedConvert('expiresAt', (v) => v as String),
  );
  return val;
});

Map<String, dynamic> _$ClinicSummaryShareResponseDtoToJson(
  ClinicSummaryShareResponseDto instance,
) => <String, dynamic>{
  'shareUrl': instance.shareUrl,
  'expiresAt': instance.expiresAt,
};
