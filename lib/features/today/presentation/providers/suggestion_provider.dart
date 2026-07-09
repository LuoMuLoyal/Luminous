import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:luminous/core/network/network_providers.dart';
import 'package:luminous/features/auth/presentation/providers/session/session_provider.dart';
import 'package:luminous/features/today/data/datasources/suggestion_remote_data_source.dart';
import 'package:luminous/features/today/domain/entities/suggestion.dart';

final todaySuggestionRemoteDataSourceProvider =
    Provider<TodaySuggestionRemoteDataSource>((ref) {
      return TodaySuggestionRemoteDataSource(
        api: ref.watch(lucentTodaySuggestionApiProvider),
      );
    });

/// Fetches today suggestion cards from the backend suggestion engine.
///
/// Returns `null` when the user is not authenticated (signed-out / preview).
final todaySuggestionProvider = FutureProvider<TodaySuggestionBundle?>((
  ref,
) async {
  final session = ref.watch(authSessionProvider);
  if (!session.canAccessProtectedData) {
    return null;
  }

  final ds = ref.watch(todaySuggestionRemoteDataSourceProvider);
  return ds.fetchSuggestions();
});
