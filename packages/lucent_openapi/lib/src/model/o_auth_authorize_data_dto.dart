//
// AUTO-GENERATED FILE, DO NOT MODIFY!
//

// ignore_for_file: unused_element
import 'package:json_annotation/json_annotation.dart';

part 'o_auth_authorize_data_dto.g.dart';

@JsonSerializable(
  checked: true,
  createToJson: true,
  disallowUnrecognizedKeys: false,
  explicitToJson: true,
)
class OAuthAuthorizeDataDto {
  /// Returns a new [OAuthAuthorizeDataDto] instance.
  OAuthAuthorizeDataDto({
    required this.authorizeUrl,

    required this.state,

    required this.expiresIn,
  });

  /// 第三方授权地址
  @JsonKey(name: r'authorizeUrl', required: true, includeIfNull: false)
  final String authorizeUrl;

  /// 本次授权 state
  @JsonKey(name: r'state', required: true, includeIfNull: false)
  final String state;

  /// state 过期时间（秒）
  @JsonKey(name: r'expiresIn', required: true, includeIfNull: false)
  final num expiresIn;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is OAuthAuthorizeDataDto &&
          other.authorizeUrl == authorizeUrl &&
          other.state == state &&
          other.expiresIn == expiresIn;

  @override
  int get hashCode =>
      authorizeUrl.hashCode + state.hashCode + expiresIn.hashCode;

  factory OAuthAuthorizeDataDto.fromJson(Map<String, dynamic> json) =>
      _$OAuthAuthorizeDataDtoFromJson(json);

  Map<String, dynamic> toJson() => _$OAuthAuthorizeDataDtoToJson(this);

  @override
  String toString() {
    return toJson().toString();
  }
}
