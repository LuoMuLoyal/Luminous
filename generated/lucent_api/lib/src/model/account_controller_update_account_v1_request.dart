//
// AUTO-GENERATED FILE, DO NOT MODIFY!
//

// ignore_for_file: unused_element
import 'package:copy_with_extension/copy_with_extension.dart';
import 'package:json_annotation/json_annotation.dart';

part 'account_controller_update_account_v1_request.g.dart';

@CopyWith()
@JsonSerializable(
  checked: true,
  createToJson: true,
  disallowUnrecognizedKeys: false,
  explicitToJson: true,
)
class AccountControllerUpdateAccountV1Request {
  /// Returns a new [AccountControllerUpdateAccountV1Request] instance.
  AccountControllerUpdateAccountV1Request({this.nickname, this.avatar});

  /// Display nickname. Send an empty string to clear it.
  @JsonKey(name: r'nickname', required: false, includeIfNull: false)
  final String? nickname;

  /// Avatar URL. Send an empty string to clear it.
  @JsonKey(name: r'avatar', required: false, includeIfNull: false)
  final String? avatar;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is AccountControllerUpdateAccountV1Request &&
          other.nickname == nickname &&
          other.avatar == avatar;

  @override
  int get hashCode => nickname.hashCode + avatar.hashCode;

  factory AccountControllerUpdateAccountV1Request.fromJson(
    Map<String, dynamic> json,
  ) => _$AccountControllerUpdateAccountV1RequestFromJson(json);

  Map<String, dynamic> toJson() =>
      _$AccountControllerUpdateAccountV1RequestToJson(this);

  @override
  String toString() {
    return toJson().toString();
  }
}
