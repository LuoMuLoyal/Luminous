//
// AUTO-GENERATED FILE, DO NOT MODIFY!
//

// ignore_for_file: unused_element
import 'package:json_annotation/json_annotation.dart';

part 'qq_o_auth_authorize_dto.g.dart';

@JsonSerializable(
  checked: true,
  createToJson: true,
  disallowUnrecognizedKeys: false,
  explicitToJson: true,
)
class QqOAuthAuthorizeDto {
  /// Returns a new [QqOAuthAuthorizeDto] instance.
  QqOAuthAuthorizeDto({this.callbackUri});

  /// QQ 授权完成后的客户端回跳地址
  @JsonKey(name: r'callbackUri', required: false, includeIfNull: false)
  final String? callbackUri;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is QqOAuthAuthorizeDto && other.callbackUri == callbackUri;

  @override
  int get hashCode => callbackUri.hashCode;

  factory QqOAuthAuthorizeDto.fromJson(Map<String, dynamic> json) =>
      _$QqOAuthAuthorizeDtoFromJson(json);

  Map<String, dynamic> toJson() => _$QqOAuthAuthorizeDtoToJson(this);

  @override
  String toString() {
    return toJson().toString();
  }
}
