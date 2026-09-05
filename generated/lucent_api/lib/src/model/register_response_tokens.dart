//
// AUTO-GENERATED FILE, DO NOT MODIFY!
//

// ignore_for_file: unused_element
import 'package:copy_with_extension/copy_with_extension.dart';
import 'package:json_annotation/json_annotation.dart';

part 'register_response_tokens.g.dart';

@CopyWith()
@JsonSerializable(
  checked: true,
  createToJson: true,
  disallowUnrecognizedKeys: false,
  explicitToJson: true,
)
class RegisterResponseTokens {
  /// Returns a new [RegisterResponseTokens] instance.
  RegisterResponseTokens({
    required this.accessToken,

    required this.refreshToken,

    required this.expiresIn,
  });

  /// 访问令牌
  @JsonKey(name: r'accessToken', required: true, includeIfNull: false)
  final String accessToken;

  /// 刷新令牌
  @JsonKey(name: r'refreshToken', required: true, includeIfNull: false)
  final String refreshToken;

  /// 访问令牌过期时间（秒）
  @JsonKey(name: r'expiresIn', required: true, includeIfNull: false)
  final num expiresIn;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is RegisterResponseTokens &&
          other.accessToken == accessToken &&
          other.refreshToken == refreshToken &&
          other.expiresIn == expiresIn;

  @override
  int get hashCode =>
      accessToken.hashCode + refreshToken.hashCode + expiresIn.hashCode;

  factory RegisterResponseTokens.fromJson(Map<String, dynamic> json) =>
      _$RegisterResponseTokensFromJson(json);

  Map<String, dynamic> toJson() => _$RegisterResponseTokensToJson(this);

  @override
  String toString() {
    return toJson().toString();
  }
}
