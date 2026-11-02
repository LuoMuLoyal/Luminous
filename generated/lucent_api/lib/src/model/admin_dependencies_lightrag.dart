//
// AUTO-GENERATED FILE, DO NOT MODIFY!
//

// ignore_for_file: unused_element
import 'package:copy_with_extension/copy_with_extension.dart';
import 'package:json_annotation/json_annotation.dart';

part 'admin_dependencies_lightrag.g.dart';

@CopyWith()
@JsonSerializable(
  checked: true,
  createToJson: true,
  disallowUnrecognizedKeys: false,
  explicitToJson: true,
)
class AdminDependenciesLightrag {
  /// Returns a new [AdminDependenciesLightrag] instance.
  AdminDependenciesLightrag({required this.enabled});

  /// Whether LIGHTRAG_ENABLED is on for this process.
  @JsonKey(name: r'enabled', required: true, includeIfNull: false)
  final bool enabled;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is AdminDependenciesLightrag && other.enabled == enabled;

  @override
  int get hashCode => enabled.hashCode;

  factory AdminDependenciesLightrag.fromJson(Map<String, dynamic> json) =>
      _$AdminDependenciesLightragFromJson(json);

  Map<String, dynamic> toJson() => _$AdminDependenciesLightragToJson(this);

  @override
  String toString() {
    return toJson().toString();
  }
}
