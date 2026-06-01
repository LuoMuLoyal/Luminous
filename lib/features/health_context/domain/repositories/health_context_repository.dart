import 'package:luminous/features/health_context/domain/entities/health_context_snapshot.dart';

/// Repository interface for fetching the authenticated user health context.
abstract class HealthContextRepository {
  /// Fetches the aggregated health context snapshot for the current user.
  ///
  /// Throws [LucentApiException] on network or server errors.
  Future<HealthContextSnapshot> fetchHealthContext();
}
