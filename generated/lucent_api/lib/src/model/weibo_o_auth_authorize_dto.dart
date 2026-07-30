//
// AUTO-GENERATED FILE, DO NOT MODIFY!
//

// ignore_for_file: unused_element
import 'package:copy_with_extension/copy_with_extension.dart';
import 'package:json_annotation/json_annotation.dart';

part 'weibo_o_auth_authorize_dto.g.dart';

@CopyWith()
@JsonSerializable(
  checked: true,
  createToJson: true,
  disallowUnrecognizedKeys: false,
  explicitToJson: true,
)
class WeiboOAuthAuthorizeDto {
  /// Returns a new [WeiboOAuthAuthorizeDto] instance.
  WeiboOAuthAuthorizeDto({this.callbackUri});

  /// 微博授权完成后的客户端回跳地址
  @JsonKey(name: r'callbackUri', required: false, includeIfNull: false)
  final String? callbackUri;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is WeiboOAuthAuthorizeDto && other.callbackUri == callbackUri;

  @override
  int get hashCode => callbackUri.hashCode;

  factory WeiboOAuthAuthorizeDto.fromJson(Map<String, dynamic> json) =>
      _$WeiboOAuthAuthorizeDtoFromJson(json);

  Map<String, dynamic> toJson() => _$WeiboOAuthAuthorizeDtoToJson(this);

  @override
  String toString() {
    return toJson().toString();
  }
}
