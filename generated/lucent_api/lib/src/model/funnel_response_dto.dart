//
// AUTO-GENERATED FILE, DO NOT MODIFY!
//

// ignore_for_file: unused_element
import 'package:lucent_api/src/model/funnel_data_dto.dart';
import 'package:copy_with_extension/copy_with_extension.dart';
import 'package:json_annotation/json_annotation.dart';

part 'funnel_response_dto.g.dart';

@CopyWith()
@JsonSerializable(
  checked: true,
  createToJson: true,
  disallowUnrecognizedKeys: false,
  explicitToJson: true,
)
class FunnelResponseDto {
  /// Returns a new [FunnelResponseDto] instance.
  FunnelResponseDto({
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
  final FunnelDataDto data;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is FunnelResponseDto &&
          other.code == code &&
          other.message == message &&
          other.data == data;

  @override
  int get hashCode => code.hashCode + message.hashCode + data.hashCode;

  factory FunnelResponseDto.fromJson(Map<String, dynamic> json) =>
      _$FunnelResponseDtoFromJson(json);

  Map<String, dynamic> toJson() => _$FunnelResponseDtoToJson(this);

  @override
  String toString() {
    return toJson().toString();
  }
}
