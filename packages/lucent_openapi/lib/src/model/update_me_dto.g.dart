// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'update_me_dto.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

UpdateMeDto _$UpdateMeDtoFromJson(Map<String, dynamic> json) =>
    $checkedCreate('UpdateMeDto', json, ($checkedConvert) {
      final val = UpdateMeDto(
        nickname: $checkedConvert('nickname', (v) => v as String?),
        avatar: $checkedConvert('avatar', (v) => v as String?),
      );
      return val;
    });

Map<String, dynamic> _$UpdateMeDtoToJson(UpdateMeDto instance) =>
    <String, dynamic>{
      if (instance.nickname != null) 'nickname': instance.nickname,
      if (instance.avatar != null) 'avatar': instance.avatar,
    };
