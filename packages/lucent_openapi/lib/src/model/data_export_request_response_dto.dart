//
// AUTO-GENERATED FILE, DO NOT MODIFY!
//

// ignore_for_file: unused_element
import 'package:lucent_openapi/src/model/data_export_request_data_dto.dart';
import 'package:json_annotation/json_annotation.dart';

part 'data_export_request_response_dto.g.dart';

@JsonSerializable(
  checked: true,
  createToJson: true,
  disallowUnrecognizedKeys: false,
  explicitToJson: true,
)
class DataExportRequestResponseDto {
  /// Returns a new [DataExportRequestResponseDto] instance.
  DataExportRequestResponseDto({
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
  final DataExportRequestDataDto data;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is DataExportRequestResponseDto &&
          other.code == code &&
          other.message == message &&
          other.data == data;

  @override
  int get hashCode => code.hashCode + message.hashCode + data.hashCode;

  factory DataExportRequestResponseDto.fromJson(Map<String, dynamic> json) =>
      _$DataExportRequestResponseDtoFromJson(json);

  Map<String, dynamic> toJson() => _$DataExportRequestResponseDtoToJson(this);

  @override
  String toString() {
    return toJson().toString();
  }
}
