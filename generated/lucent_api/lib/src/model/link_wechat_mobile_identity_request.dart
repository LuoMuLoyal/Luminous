//
// AUTO-GENERATED FILE, DO NOT MODIFY!
//

// ignore_for_file: unused_element
import 'package:copy_with_extension/copy_with_extension.dart';
import 'package:json_annotation/json_annotation.dart';

part 'link_wechat_mobile_identity_request.g.dart';

@CopyWith()
@JsonSerializable(
  checked: true,
  createToJson: true,
  disallowUnrecognizedKeys: false,
  explicitToJson: true,
)
class LinkWechatMobileIdentityRequest {
  /// Returns a new [LinkWechatMobileIdentityRequest] instance.
  LinkWechatMobileIdentityRequest({required this.code});

  /// OAuth 授权码
  @JsonKey(name: r'code', required: true, includeIfNull: false)
  final String code;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is LinkWechatMobileIdentityRequest && other.code == code;

  @override
  int get hashCode => code.hashCode;

  factory LinkWechatMobileIdentityRequest.fromJson(Map<String, dynamic> json) =>
      _$LinkWechatMobileIdentityRequestFromJson(json);

  Map<String, dynamic> toJson() =>
      _$LinkWechatMobileIdentityRequestToJson(this);

  @override
  String toString() {
    return toJson().toString();
  }
}
