//
// AUTO-GENERATED FILE, DO NOT MODIFY!
//

// ignore_for_file: unused_element
import 'package:copy_with_extension/copy_with_extension.dart';
import 'package:json_annotation/json_annotation.dart';

part 'weibo_o_auth_callback_dto.g.dart';

@CopyWith()
@JsonSerializable(
  checked: true,
  createToJson: true,
  disallowUnrecognizedKeys: false,
  explicitToJson: true,
)
class WeiboOAuthCallbackDto {
  /// Returns a new [WeiboOAuthCallbackDto] instance.
  WeiboOAuthCallbackDto({required this.code, required this.state});

  /// 微博授权码
  @JsonKey(name: r'code', required: true, includeIfNull: false)
  final String code;

  /// 授权时生成的 state
  @JsonKey(name: r'state', required: true, includeIfNull: false)
  final String state;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is WeiboOAuthCallbackDto &&
          other.code == code &&
          other.state == state;

  @override
  int get hashCode => code.hashCode + state.hashCode;

  factory WeiboOAuthCallbackDto.fromJson(Map<String, dynamic> json) =>
      _$WeiboOAuthCallbackDtoFromJson(json);

  Map<String, dynamic> toJson() => _$WeiboOAuthCallbackDtoToJson(this);

  @override
  String toString() {
    return toJson().toString();
  }
}
