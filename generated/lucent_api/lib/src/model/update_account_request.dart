//
// AUTO-GENERATED FILE, DO NOT MODIFY!
//

// ignore_for_file: unused_element
import 'package:copy_with_extension/copy_with_extension.dart';
import 'package:json_annotation/json_annotation.dart';

part 'update_account_request.g.dart';

@CopyWith()
@JsonSerializable(
  checked: true,
  createToJson: true,
  disallowUnrecognizedKeys: false,
  explicitToJson: true,
)
class UpdateAccountRequest {
  /// Returns a new [UpdateAccountRequest] instance.
  UpdateAccountRequest({this.nickname, this.avatar});

  /// Display nickname. Send an empty string to clear it.
  @JsonKey(name: r'nickname', required: false, includeIfNull: false)
  final String? nickname;

  /// Avatar URL. Send an empty string to clear it.
  @JsonKey(name: r'avatar', required: false, includeIfNull: false)
  final String? avatar;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is UpdateAccountRequest &&
          other.nickname == nickname &&
          other.avatar == avatar;

  @override
  int get hashCode => nickname.hashCode + avatar.hashCode;

  factory UpdateAccountRequest.fromJson(Map<String, dynamic> json) =>
      _$UpdateAccountRequestFromJson(json);

  Map<String, dynamic> toJson() => _$UpdateAccountRequestToJson(this);

  @override
  String toString() {
    return toJson().toString();
  }
}
