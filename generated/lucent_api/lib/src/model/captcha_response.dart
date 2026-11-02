//
// AUTO-GENERATED FILE, DO NOT MODIFY!
//

// ignore_for_file: unused_element
import 'package:copy_with_extension/copy_with_extension.dart';
import 'package:json_annotation/json_annotation.dart';

part 'captcha_response.g.dart';

@CopyWith()
@JsonSerializable(
  checked: true,
  createToJson: true,
  disallowUnrecognizedKeys: false,
  explicitToJson: true,
)
class CaptchaResponse {
  /// Returns a new [CaptchaResponse] instance.
  CaptchaResponse({required this.enabled, required this.siteKey});

  /// 是否启用
  @JsonKey(name: r'enabled', required: true, includeIfNull: false)
  final bool enabled;

  /// 站点密钥
  @JsonKey(name: r'siteKey', required: true, includeIfNull: false)
  final String siteKey;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is CaptchaResponse &&
          other.enabled == enabled &&
          other.siteKey == siteKey;

  @override
  int get hashCode => enabled.hashCode + siteKey.hashCode;

  factory CaptchaResponse.fromJson(Map<String, dynamic> json) =>
      _$CaptchaResponseFromJson(json);

  Map<String, dynamic> toJson() => _$CaptchaResponseToJson(this);

  @override
  String toString() {
    return toJson().toString();
  }
}
