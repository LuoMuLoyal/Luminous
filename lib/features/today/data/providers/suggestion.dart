import 'package:luminous/core/network/client/client_providers.dart';
import 'package:luminous/core/providers/session/auth_guarded.dart';
import 'package:luminous/features/today/data/datasources/suggestion_remote.dart';
import 'package:luminous/features/today/domain/repositories/suggestion.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

export 'package:luminous/app/composition/today.dart'
    show suggestionHistoryProvider;

part 'suggestion.g.dart';

@riverpod
TodaySuggestionRemoteDataSource todaySuggestionRemoteDataSource(Ref ref) {
  return TodaySuggestionRemoteDataSource(
    api: ref.watch(lucentClientProvider).todaySuggestion,
  );
}

/// Provider for [SuggestionRepository] — returns the remote data source
/// which implements the domain interface.
@riverpod
SuggestionRepository suggestionRepository(Ref ref) {
  return ref.watch(todaySuggestionRemoteDataSourceProvider);
}

/// `suggestionHistoryProvider` is composed in `lib/app/composition/today.dart`
/// and re-exported here so existing call sites keep working. It lives there
/// because it needs `authGuarded` (session state) — `data/` may not read the
/// session or the locale.
