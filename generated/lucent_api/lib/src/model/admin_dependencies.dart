//
// AUTO-GENERATED FILE, DO NOT MODIFY!
//

// ignore_for_file: unused_element
import 'package:lucent_api/src/model/admin_dependencies_lightrag.dart';
import 'package:lucent_api/src/model/admin_dependencies_semantica.dart';
import 'package:copy_with_extension/copy_with_extension.dart';
import 'package:json_annotation/json_annotation.dart';

part 'admin_dependencies.g.dart';

@CopyWith()
@JsonSerializable(
  checked: true,
  createToJson: true,
  disallowUnrecognizedKeys: false,
  explicitToJson: true,
)
class AdminDependencies {
  /// Returns a new [AdminDependencies] instance.
  AdminDependencies({
    required this.lightrag,

    required this.semantica,

    required this.generatedAt,
  });

  @JsonKey(name: r'lightrag', required: true, includeIfNull: false)
  final AdminDependenciesLightrag lightrag;

  @JsonKey(name: r'semantica', required: true, includeIfNull: false)
  final AdminDependenciesSemantica semantica;

  /// Response generation time (ISO 8601).
  @JsonKey(name: r'generatedAt', required: true, includeIfNull: false)
  final String generatedAt;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is AdminDependencies &&
          other.lightrag == lightrag &&
          other.semantica == semantica &&
          other.generatedAt == generatedAt;

  @override
  int get hashCode =>
      lightrag.hashCode + semantica.hashCode + generatedAt.hashCode;

  factory AdminDependencies.fromJson(Map<String, dynamic> json) =>
      _$AdminDependenciesFromJson(json);

  Map<String, dynamic> toJson() => _$AdminDependenciesToJson(this);

  @override
  String toString() {
    return toJson().toString();
  }
}
