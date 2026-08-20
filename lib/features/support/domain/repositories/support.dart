import 'package:luminous/features/support/domain/entities/app_info.dart';

/// Repository interface for public app metadata.
///
/// These endpoints are public (no auth required).
abstract interface class SupportRepository {
  /// Returns application metadata.
  Future<AppInfo?> getAppInfo();
}
