//
// AUTO-GENERATED FILE, DO NOT MODIFY!
//

// ignore_for_file: unused_element
import 'package:json_annotation/json_annotation.dart';

part 'update_account_dto.g.dart';

@JsonSerializable(
  checked: true,
  createToJson: true,
  disallowUnrecognizedKeys: false,
  explicitToJson: true,
)
class UpdateAccountDto {
  /// Returns a new [UpdateAccountDto] instance.
  UpdateAccountDto({this.nickname, this.avatar});

  /// Display nickname. Send an empty string to clear it.
  @JsonKey(name: r'nickname', required: false, includeIfNull: false)
  final String? nickname;

  /// Avatar URL. Send an empty string to clear it.
  @JsonKey(name: r'avatar', required: false, includeIfNull: false)
  final String? avatar;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is UpdateAccountDto &&
          other.nickname == nickname &&
          other.avatar == avatar;

  @override
  int get hashCode => nickname.hashCode + avatar.hashCode;

  factory UpdateAccountDto.fromJson(Map<String, dynamic> json) =>
      _$UpdateAccountDtoFromJson(json);

  Map<String, dynamic> toJson() => _$UpdateAccountDtoToJson(this);

  @override
  String toString() {
    return toJson().toString();
  }
}
