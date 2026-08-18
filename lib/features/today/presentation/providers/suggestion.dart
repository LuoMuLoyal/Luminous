import 'dart:async';

import 'package:flutter/widgets.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:luminous/core/auth/session_provider.dart';
import 'package:luminous/core/database/connection_providers.dart';
import 'package:luminous/core/i18n/locale.dart';
import 'package:luminous/core/logger/logger.dart';
import 'package:luminous/core/providers/auth_guarded.dart';
import 'package:luminous/core/providers/data_change_bus.dart';
import 'package:luminous/features/today/data/providers/suggestion.dart';
import 'package:luminous/features/today/data/utils/suggestion_json_codec.dart';
import 'package:luminous/features/today/domain/entities/suggestion.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

part 'suggestion.g.dart';

/// Manages the lifecycle of Today suggestion cards: fetch, dismiss, feedback.
///
/// Cache-first: on build, returns cached bundle immediately (if available),
/// then fetches fresh data from the network in the background.
/// After [dismiss] or [refresh], the provider shows a loading state and
/// re-fetches. [submitFeedback] keeps the current card visible (the feedback
/// row supplies its own local loading indicator) and refreshes silently in the
/// background after a successful submission.
///
/// Returns `null` when the user is not authenticated (signed-out / preview).
final todaySuggestionProvider =
    AsyncNotifierProvider<TodaySuggestionNotifier, TodaySuggestionBundle?>(
      TodaySuggestionNotifier.new,
    );

class TodaySuggestionNotifier extends AsyncNotifier<TodaySuggestionBundle?> {
  /// Locally dismissed suggestion IDs — passed as `excludeIds` on re-fetch.
  final List<String> _dismissedIds = [];
  Timer? _dataChangeDebounce;
  AppLifecycleListener? _lifecycleListener;
  TodaySuggestionBundle? _lastBundle;
  Future<void> _fetchTail = Future<void>.value();
  bool _listenersInstalled = false;
  bool _disposed = false;

  static const _suggestionTopics = {
    DataChangeTopic.dailyRecords,
    DataChangeTopic.doseLogs,
    DataChangeTopic.medicineReminders,
    DataChangeTopic.healthContext,
    DataChangeTopic.currentMedicines,
    DataChangeTopic.userSettings,
    DataChangeTopic.healthEvents,
  };

  @override
  Future<TodaySuggestionBundle?> build() async {
    _installRefreshListeners();
    final bundle = await authGuarded(
      ref: ref,
      fetch: _fetch,
      signedOutFallback: () async => null,
    );
    _lastBundle = bundle;
    return bundle;
  }

  void _installRefreshListeners() {
    if (_listenersInstalled) return;
    _listenersInstalled = true;
    ref.listen(dataChangeBusProvider, (previous, next) {
      if (!_hasRelevantDataChange(previous, next)) return;
      _scheduleDataRefresh();
    });
    _lifecycleListener = AppLifecycleListener(
      onStateChange: (state) {
        if (state == AppLifecycleState.resumed) {
          unawaited(_refreshOnResume());
        }
      },
    );
    ref.onDispose(() {
      _disposed = true;
      _dataChangeDebounce?.cancel();
      _lifecycleListener?.dispose();
    });
  }

  bool _hasRelevantDataChange(
    Map<String, int>? previous,
    Map<String, int> next,
  ) {
    return _suggestionTopics.any((topic) => previous?[topic] != next[topic]);
  }

  void _scheduleDataRefresh() {
    if (!_isAuthenticated) return;
    _dataChangeDebounce?.cancel();
    _dataChangeDebounce = Timer(const Duration(milliseconds: 300), () {
      unawaited(_refreshSilently());
    });
  }

  bool get _isAuthenticated => ref.read(authSessionProvider).isAuthenticated;

  Future<void> _refreshSilently() async {
    if (_disposed || !_isAuthenticated) return;
    try {
      final bundle = await _fetch();
      if (!_disposed) state = AsyncData(bundle);
    } catch (error, stackTrace) {
      ref
          .read(talkerProvider)
          .warning('Suggestion data change refresh failed: $error', stackTrace);
    }
  }

  Future<void> _refreshOnResume() async {
    if (_disposed || !_isAuthenticated) return;
    final previous = _lastBundle;
    try {
      final bundle = await _fetch();
      if (_disposed) return;
      if (previous?.sourceVersion != bundle?.sourceVersion ||
          previous?.materializationStatus != bundle?.materializationStatus ||
          previous?.computedAt != bundle?.computedAt) {
        state = AsyncData(bundle);
      }
    } catch (error, stackTrace) {
      ref
          .read(talkerProvider)
          .warning('Suggestion resume refresh failed: $error', stackTrace);
    }
  }

  /// Serializes all reads so an older response cannot overwrite a newer one.
  Future<TodaySuggestionBundle?> _fetch() {
    final result = Completer<TodaySuggestionBundle?>();
    _fetchTail = _fetchTail.then<void>((_) => _runFetch(result));
    return result.future;
  }

  Future<void> _runFetch(Completer<TodaySuggestionBundle?> result) async {
    try {
      result.complete(await _performFetch());
    } catch (error, stackTrace) {
      result.completeError(error, stackTrace);
    }
  }

  Future<TodaySuggestionBundle?> _performFetch() async {
    final ds = ref.read(todaySuggestionRemoteDataSourceProvider);
    final dao = ref.read(todaySuggestionDaoProvider);
    TodaySuggestionBundle? cachedBundle;
    var cacheWasRead = false;
    var cacheWasInvalid = false;

    // Load the last materialized content before the first GET so a cold-start
    // response of pending/stale/failed can still retain the previous card.
    if (_lastBundle == null) {
      try {
        final cached = await dao.fetch();
        cacheWasRead = true;
        if (cached != null) {
          try {
            cachedBundle = TodaySuggestionJsonCodec.bundleFromJson(cached);
            _lastBundle = cachedBundle;
          } catch (error) {
            cacheWasInvalid = true;
            ref
                .read(talkerProvider)
                .warning(
                  'Suggestion cache deserialization failed, clearing stale cache: $error',
                );
            await dao.clear();
          }
        }
      } catch (error, stackTrace) {
        ref
            .read(talkerProvider)
            .warning('Suggestion cache prefetch failed: $error', stackTrace);
      }
    }

    try {
      final bundle = await ds.fetchSuggestions(
        language:
            (ref.read(localeControllerProvider).asData?.value ??
                    AppLocale.system)
                .acceptLanguage,
        excludeIds: _dismissedIds.isEmpty ? null : _dismissedIds,
      );
      final materialized = _preservePreviousContent(bundle);
      // Persist to cache
      await dao.replace(TodaySuggestionJsonCodec.bundleToJson(materialized));
      _lastBundle = materialized;
      return materialized;
    } catch (e) {
      // Network failed — try cache as fallback (stale-while-error)
      if (cacheWasInvalid) rethrow;
      if (cacheWasRead && cachedBundle != null) return cachedBundle;

      final cached = cacheWasRead ? null : await dao.fetch();
      if (cached != null) {
        try {
          final bundle = TodaySuggestionJsonCodec.bundleFromJson(cached);
          _lastBundle = bundle;
          return bundle;
        } catch (e) {
          // Cache format is incompatible (likely after an app update).
          // Clear the stale cache so subsequent fetches don't hit the same
          // error, then fall through to rethrow the original network error.
          ref
              .read(talkerProvider)
              .warning(
                'Suggestion cache deserialization failed, clearing stale cache: $e',
              );
          await dao.clear();
        }
      }
      rethrow;
    }
  }

  TodaySuggestionBundle _preservePreviousContent(TodaySuggestionBundle bundle) {
    final previous = _lastBundle;
    final status = bundle.materializationStatus;
    if (previous == null ||
        status == TodaySuggestionMaterializationStatus.ready ||
        status == TodaySuggestionMaterializationStatus.empty) {
      return bundle;
    }
    return bundle.copyWith(
      primary: bundle.primary ?? previous.primary,
      secondary: bundle.secondary ?? previous.secondary,
      observations: bundle.observations ?? previous.observations,
    );
  }

  /// Submit user feedback for a suggestion card, then refresh silently.
  ///
  /// The provider state is *not* set to loading, so the existing card remains
  /// visible while the caller (e.g. [SuggestionFeedbackRow]) shows its own
  /// local loading indicator. After a successful submission the provider fetches
  /// a new bundle in the background and replaces the state. If that fetch fails,
  /// the error is only logged and the existing state is preserved, because the
  /// feedback has already been applied and the UI has already shown "submitted".
  ///
  /// If [submitFeedback] itself fails, the exception is rethrown so the UI can
  /// display a failure toast and avoid marking the feedback as submitted.
  Future<void> submitFeedback({
    required String suggestionId,
    required TodaySuggestionFeedback feedback,
  }) async {
    final ds = ref.read(todaySuggestionRemoteDataSourceProvider);
    await ds.submitFeedback(id: suggestionId, feedback: feedback);

    if (feedback == TodaySuggestionFeedback.suppress) {
      _dismissedIds.add(suggestionId);
    }

    try {
      final bundle = await _fetch();
      if (!_disposed) state = AsyncData(bundle);
    } catch (error, stackTrace) {
      ref
          .read(talkerProvider)
          .warning('Suggestion feedback refresh failed: $error', stackTrace);
    }
  }

  /// Dismiss a card locally (no API call) and re-fetch without it.
  Future<void> dismiss(String suggestionId) async {
    _dismissedIds.add(suggestionId);
    state = const AsyncValue.loading();
    state = await AsyncValue.guard(_fetch);
  }

  /// Manual refresh.
  Future<void> refresh() async {
    state = const AsyncValue.loading();
    state = await AsyncValue.guard(_fetch);
  }
}

/// AI explanation for a single suggestion, loaded on demand.
///
/// The [language] parameter should be the current locale tag (e.g. `zh-CN`).
/// Returns `null` if the user is not authenticated.
@riverpod
Future<TodaySuggestionExplanation?> suggestionExplanation(
  Ref ref,
  ({String suggestionId, String language}) params,
) async {
  return authGuarded(
    ref: ref,
    fetch: () {
      final ds = ref.watch(todaySuggestionRemoteDataSourceProvider);
      return ds.explainSuggestion(
        id: params.suggestionId,
        language: params.language,
      );
    },
    signedOutFallback: () async => null,
  );
}
