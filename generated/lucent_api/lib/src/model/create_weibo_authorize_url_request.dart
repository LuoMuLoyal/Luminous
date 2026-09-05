//
// AUTO-GENERATED FILE, DO NOT MODIFY!
//

// ignore_for_file: unused_element
import 'package:copy_with_extension/copy_with_extension.dart';
import 'package:json_annotation/json_annotation.dart';

part 'create_weibo_authorize_url_request.g.dart';

@CopyWith()
@JsonSerializable(
  checked: true,
  createToJson: true,
  disallowUnrecognizedKeys: false,
  explicitToJson: true,
)
class CreateWeiboAuthorizeUrlRequest {
  /// Returns a new [CreateWeiboAuthorizeUrlRequest] instance.
  CreateWeiboAuthorizeUrlRequest({this.callbackUri});

  /// 微博授权完成后的客户端回跳地址
  @JsonKey(name: r'callbackUri', required: false, includeIfNull: false)
  final String? callbackUri;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is CreateWeiboAuthorizeUrlRequest &&
          other.callbackUri == callbackUri;

  @override
  int get hashCode => callbackUri.hashCode;

  factory CreateWeiboAuthorizeUrlRequest.fromJson(Map<String, dynamic> json) =>
      _$CreateWeiboAuthorizeUrlRequestFromJson(json);

  Map<String, dynamic> toJson() => _$CreateWeiboAuthorizeUrlRequestToJson(this);

  @override
  String toString() {
    return toJson().toString();
  }
}
