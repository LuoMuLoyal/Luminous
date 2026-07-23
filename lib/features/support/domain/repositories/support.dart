import 'package:luminous/features/support/domain/entities/support_resource.dart';

/// Repository interface for public support resources and app metadata.
///
/// These endpoints are public (no auth required).
abstract interface class SupportRepository {
  /// Returns support resources filtered by [scope] (e.g. 'help', 'about').
  Future<List<SupportResource>> getResources(String scope);

  /// Returns application metadata.
  Future<AppInfo?> getAppInfo();
}
