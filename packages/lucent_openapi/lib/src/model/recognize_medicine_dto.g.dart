// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'recognize_medicine_dto.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

RecognizeMedicineDto _$RecognizeMedicineDtoFromJson(
  Map<String, dynamic> json,
) => $checkedCreate('RecognizeMedicineDto', json, ($checkedConvert) {
  $checkKeys(json, requiredKeys: const ['imageUrl']);
  final val = RecognizeMedicineDto(
    imageUrl: $checkedConvert('imageUrl', (v) => v as String),
  );
  return val;
});

Map<String, dynamic> _$RecognizeMedicineDtoToJson(
  RecognizeMedicineDto instance,
) => <String, dynamic>{'imageUrl': instance.imageUrl};
