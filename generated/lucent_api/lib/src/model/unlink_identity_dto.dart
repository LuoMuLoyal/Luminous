//
// AUTO-GENERATED FILE, DO NOT MODIFY!
//

// ignore_for_file: unused_element
import 'package:copy_with_extension/copy_with_extension.dart';
import 'package:json_annotation/json_annotation.dart';

part 'unlink_identity_dto.g.dart';

@CopyWith()
@JsonSerializable(
  checked: true,
  createToJson: true,
  disallowUnrecognizedKeys: false,
  explicitToJson: true,
)
class UnlinkIdentityDto {
  /// Returns a new [UnlinkIdentityDto] instance.
  UnlinkIdentityDto({required this.password});

  /// 当前密码（敏感操作再认证用）
  @JsonKey(name: r'password', required: true, includeIfNull: false)
  final String password;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is UnlinkIdentityDto && other.password == password;

  @override
  int get hashCode => password.hashCode;

  factory UnlinkIdentityDto.fromJson(Map<String, dynamic> json) =>
      _$UnlinkIdentityDtoFromJson(json);

  Map<String, dynamic> toJson() => _$UnlinkIdentityDtoToJson(this);

  @override
  String toString() {
    return toJson().toString();
  }
}
