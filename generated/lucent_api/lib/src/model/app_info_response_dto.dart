//
// AUTO-GENERATED FILE, DO NOT MODIFY!
//

// ignore_for_file: unused_element
import 'package:lucent_api/src/model/app_info_data_dto.dart';
import 'package:copy_with_extension/copy_with_extension.dart';
import 'package:json_annotation/json_annotation.dart';

part 'app_info_response_dto.g.dart';

@CopyWith()
@JsonSerializable(
  checked: true,
  createToJson: true,
  disallowUnrecognizedKeys: false,
  explicitToJson: true,
)
class AppInfoResponseDto {
  /// Returns a new [AppInfoResponseDto] instance.
  AppInfoResponseDto({
    required this.code,
    required this.message,
    required this.data,
  });

  /// Result code.
  @JsonKey(name: r'code', required: true, includeIfNull: false)
  final num code;

  /// Message.
  @JsonKey(name: r'message', required: true, includeIfNull: false)
  final String message;

  @JsonKey(name: r'data', required: true, includeIfNull: false)
  final AppInfoDataDto data;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is AppInfoResponseDto &&
          other.code == code &&
          other.message == message &&
          other.data == data;

  @override
  int get hashCode => code.hashCode + message.hashCode + data.hashCode;

  factory AppInfoResponseDto.fromJson(Map<String, dynamic> json) =>
      _$AppInfoResponseDtoFromJson(json);

  Map<String, dynamic> toJson() => _$AppInfoResponseDtoToJson(this);

  @override
  String toString() {
    return toJson().toString();
  }
}
