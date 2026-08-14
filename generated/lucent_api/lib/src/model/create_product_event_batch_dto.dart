//
// AUTO-GENERATED FILE, DO NOT MODIFY!
//

// ignore_for_file: unused_element
import 'package:lucent_api/src/model/create_product_event_dto.dart';
import 'package:copy_with_extension/copy_with_extension.dart';
import 'package:json_annotation/json_annotation.dart';

part 'create_product_event_batch_dto.g.dart';

@CopyWith()
@JsonSerializable(
  checked: true,
  createToJson: true,
  disallowUnrecognizedKeys: false,
  explicitToJson: true,
)
class CreateProductEventBatchDto {
  /// Returns a new [CreateProductEventBatchDto] instance.
  CreateProductEventBatchDto({required this.events});

  /// 1..50 events per request.
  @JsonKey(name: r'events', required: true, includeIfNull: false)
  final List<CreateProductEventDto> events;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is CreateProductEventBatchDto && other.events == events;

  @override
  int get hashCode => events.hashCode;

  factory CreateProductEventBatchDto.fromJson(Map<String, dynamic> json) =>
      _$CreateProductEventBatchDtoFromJson(json);

  Map<String, dynamic> toJson() => _$CreateProductEventBatchDtoToJson(this);

  @override
  String toString() {
    return toJson().toString();
  }
}
