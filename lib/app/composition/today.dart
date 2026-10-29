import 'package:luminous/core/i18n/locale.dart';
import 'package:luminous/core/providers/auth_guarded.dart';
import 'package:luminous/features/today/data/providers/suggestion.dart';
import 'package:luminous/features/today/domain/entities/suggestion.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

part 'today.g.dart';

/// Composition-root glue for the today feature.
///
/// Providers that need session state or locale state live here: `data/` may
/// not read `core/auth` / `core/providers` / `core/i18n`. The data provider
/// file re-exports them, so call sites keep their existing imports.

/// The wire language tag for localized suggestion history.
@riverpod
String suggestionHistoryLanguage(Ref ref) {
  final locale = ref.watch(localeControllerProvider).asData?.value;
  return (locale ?? AppLocale.system).acceptLanguage;
}

/// Suggestion history for the Report page.
///
/// Returns `null` when the user is not authenticated.
/// Fetches the most recent 20 suggestion history items.
@riverpod
Future<TodaySuggestionHistory?> suggestionHistory(Ref ref) async {
  final language = ref.watch(suggestionHistoryLanguageProvider);
  return authGuarded(
    ref: ref,
    fetch: () async {
      final ds = ref.watch(todaySuggestionRemoteDataSourceProvider);
      final result = await ds.fetchHistory(language: language, limit: 20).run();
      // Left 投影到 AsyncValue.error。
      return result.fold((failure) => throw failure, (history) => history);
    },
    signedOutFallback: () async => null,
  );
}
