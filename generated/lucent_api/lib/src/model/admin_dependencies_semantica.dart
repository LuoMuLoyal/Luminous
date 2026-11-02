//
// AUTO-GENERATED FILE, DO NOT MODIFY!
//

// ignore_for_file: unused_element
import 'package:copy_with_extension/copy_with_extension.dart';
import 'package:json_annotation/json_annotation.dart';

part 'admin_dependencies_semantica.g.dart';

@CopyWith()
@JsonSerializable(
  checked: true,
  createToJson: true,
  disallowUnrecognizedKeys: false,
  explicitToJson: true,
)
class AdminDependenciesSemantica {
  /// Returns a new [AdminDependenciesSemantica] instance.
  AdminDependenciesSemantica({required this.enabled});

  /// Whether SEMANTICA_ENABLED is on for this process.
  @JsonKey(name: r'enabled', required: true, includeIfNull: false)
  final bool enabled;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is AdminDependenciesSemantica && other.enabled == enabled;

  @override
  int get hashCode => enabled.hashCode;

  factory AdminDependenciesSemantica.fromJson(Map<String, dynamic> json) =>
      _$AdminDependenciesSemanticaFromJson(json);

  Map<String, dynamic> toJson() => _$AdminDependenciesSemanticaToJson(this);

  @override
  String toString() {
    return toJson().toString();
  }
}
