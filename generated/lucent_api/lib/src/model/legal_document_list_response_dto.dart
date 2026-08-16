//
// AUTO-GENERATED FILE, DO NOT MODIFY!
//

// ignore_for_file: unused_element
import 'package:lucent_api/src/model/legal_document_list_data_dto.dart';
import 'package:copy_with_extension/copy_with_extension.dart';
import 'package:json_annotation/json_annotation.dart';

part 'legal_document_list_response_dto.g.dart';

@CopyWith()
@JsonSerializable(
  checked: true,
  createToJson: true,
  disallowUnrecognizedKeys: false,
  explicitToJson: true,
)
class LegalDocumentListResponseDto {
  /// Returns a new [LegalDocumentListResponseDto] instance.
  LegalDocumentListResponseDto({
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
  final LegalDocumentListDataDto data;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is LegalDocumentListResponseDto &&
          other.code == code &&
          other.message == message &&
          other.data == data;

  @override
  int get hashCode => code.hashCode + message.hashCode + data.hashCode;

  factory LegalDocumentListResponseDto.fromJson(Map<String, dynamic> json) =>
      _$LegalDocumentListResponseDtoFromJson(json);

  Map<String, dynamic> toJson() => _$LegalDocumentListResponseDtoToJson(this);

  @override
  String toString() {
    return toJson().toString();
  }
}
