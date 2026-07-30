//
// AUTO-GENERATED FILE, DO NOT MODIFY!
//

// ignore_for_file: unused_element
import 'package:copy_with_extension/copy_with_extension.dart';
import 'package:json_annotation/json_annotation.dart';

part 'google_o_auth_authorize_dto.g.dart';

@CopyWith()
@JsonSerializable(
  checked: true,
  createToJson: true,
  disallowUnrecognizedKeys: false,
  explicitToJson: true,
)
class GoogleOAuthAuthorizeDto {
  /// Returns a new [GoogleOAuthAuthorizeDto] instance.
  GoogleOAuthAuthorizeDto({this.callbackUri});

  /// Google 授权完成后的客户端回跳地址
  @JsonKey(name: r'callbackUri', required: false, includeIfNull: false)
  final String? callbackUri;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is GoogleOAuthAuthorizeDto && other.callbackUri == callbackUri;

  @override
  int get hashCode => callbackUri.hashCode;

  factory GoogleOAuthAuthorizeDto.fromJson(Map<String, dynamic> json) =>
      _$GoogleOAuthAuthorizeDtoFromJson(json);

  Map<String, dynamic> toJson() => _$GoogleOAuthAuthorizeDtoToJson(this);

  @override
  String toString() {
    return toJson().toString();
  }
}
