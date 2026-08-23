import 'package:luminous/core/i18n/locale.dart';
import 'package:luminous/core/network/client_providers.dart';
import 'package:luminous/core/providers/auth_guarded.dart';
import 'package:luminous/features/today/data/datasources/suggestion_remote.dart';
import 'package:luminous/features/today/domain/entities/suggestion.dart';
import 'package:luminous/features/today/domain/repositories/suggestion.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

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

/// Suggestion history for the Report page.
///
/// Returns `null` when the user is not authenticated.
/// Fetches the most recent 20 suggestion history items.
@riverpod
Future<TodaySuggestionHistory?> suggestionHistory(Ref ref) async {
  return authGuarded(
    ref: ref,
    fetch: () async {
      final ds = ref.watch(todaySuggestionRemoteDataSourceProvider);
      final result = await ds
          .fetchHistory(
            language:
                (ref.read(localeControllerProvider).asData?.value ??
                        AppLocale.system)
                    .acceptLanguage,
            limit: 20,
          )
          .run();
      // Left 投影到 AsyncValue.error。
      return result.fold((failure) => throw failure, (history) => history);
    },
    signedOutFallback: () async => null,
  );
}
