// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'update_account_dto.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

UpdateAccountDto _$UpdateAccountDtoFromJson(Map<String, dynamic> json) =>
    $checkedCreate('UpdateAccountDto', json, ($checkedConvert) {
      final val = UpdateAccountDto(
        nickname: $checkedConvert('nickname', (v) => v as String?),
        avatar: $checkedConvert('avatar', (v) => v as String?),
      );
      return val;
    });

Map<String, dynamic> _$UpdateAccountDtoToJson(UpdateAccountDto instance) =>
    <String, dynamic>{
      if (instance.nickname != null) 'nickname': instance.nickname,
      if (instance.avatar != null) 'avatar': instance.avatar,
    };
