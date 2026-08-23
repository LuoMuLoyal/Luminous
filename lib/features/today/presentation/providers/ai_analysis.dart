import 'dart:async';

import 'package:flutter/widgets.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:fpdart/fpdart.dart';
import 'package:luminous/core/auth/session_provider.dart';
import 'package:luminous/core/errors/lucent_failure.dart';
import 'package:luminous/core/logger/logger.dart';
import 'package:luminous/core/network/error_mapper.dart';
import 'package:luminous/core/providers/auth_guarded.dart';
import 'package:luminous/core/providers/data_change_bus.dart';
import 'package:luminous/features/settings/presentation/providers/user_settings.dart';
import 'package:luminous/features/today/data/repositories/lucent_ai.dart';
import 'package:luminous/features/today/domain/entities/ai_analysis.dart';

/// Manages the Today AI analysis card using the materialization pattern:
/// cache-first read, backend status mapping, stale/old-card preservation, and
/// debounced re-reads on relevant data changes.
final todayAiAnalysisControllerProvider =
    AsyncNotifierProvider<TodayAiAnalysisNotifier, TodayAiAnalysisCardState>(
      TodayAiAnalysisNotifier.new,
    );

class TodayAiAnalysisNotifier extends AsyncNotifier<TodayAiAnalysisCardState> {
  static const _refreshTopics = {
    DataChangeTopic.dailyRecords,
    DataChangeTopic.doseLogs,
    DataChangeTopic.medicineReminders,
    DataChangeTopic.healthContext,
    DataChangeTopic.currentMedicines,
    DataChangeTopic.userSettings,
    DataChangeTopic.healthEvents,
  };

  Timer? _dataChangeDebounce;
  AppLifecycleListener? _lifecycleListener;
  TodayAiAnalysisCardState? _lastState;
  bool _listenersInstalled = false;
  bool _disposed = false;

  @override
  Future<TodayAiAnalysisCardState> build() async {
    _installRefreshListeners();

    final session = ref.watch(authSessionProvider);
    if (!session.canAccessProtectedData) {
      return const TodayAiAnalysisCardState.idle();
    }

    final settings = ref.watch(userSettingsControllerProvider).asData?.value;
    if (settings?.aiSummariesEnabled == false) {
      return const TodayAiAnalysisCardState.disabled();
    }

    final state = await authGuarded(
      ref: ref,
      fetch: _fetch,
      signedOutFallback: () async => const TodayAiAnalysisCardState.idle(),
    );
    _lastState = state;
    return state;
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
    return _refreshTopics.any((topic) => previous?[topic] != next[topic]);
  }

  void _scheduleDataRefresh() {
    if (!_isAuthenticated) return;
    _dataChangeDebounce?.cancel();
    _dataChangeDebounce = Timer(const Duration(milliseconds: 300), () {
      unawaited(_refreshSilently());
    });
  }

  bool get _isAuthenticated => ref.read(authSessionProvider).isAuthenticated;

  Future<TodayAiAnalysisCardState> _fetch() async {
    final repo = ref.read(todayAiRepositoryProvider);
    final result = await repo.read(DateTime.now()).run();
    return result.fold(
      (failure) {
        if (failure.statusCode == 403) {
          return const TodayAiAnalysisCardState.disabled();
        }
        throw failure;
      },
      (analysis) {
        final state = _mapToCardState(analysis, previous: _lastState?.analysis);
        _lastState = state;
        return state;
      },
    );
  }

  TodayAiAnalysisCardState _mapToCardState(
    TodayAiAnalysis analysis, {
    TodayAiAnalysis? previous,
  }) {
    final status = analysis.materializationStatus;
    if (status == TodayAiAnalysisMaterializationStatus.empty) {
      return TodayAiAnalysisCardState.success(
        null,
        materializationStatus: status,
        computedAt: analysis.generatedAt,
        sourceVersion: analysis.sourceVersion,
        computedVersion: analysis.computedVersion,
      );
    }

    final shouldPreservePrevious =
        status == TodayAiAnalysisMaterializationStatus.pending ||
        status == TodayAiAnalysisMaterializationStatus.stale ||
        status == TodayAiAnalysisMaterializationStatus.failed;
    final effectiveAnalysis =
        (shouldPreservePrevious && analysis.summary.isEmpty && previous != null)
        ? previous
        : analysis;

    return TodayAiAnalysisCardState.success(
      effectiveAnalysis,
      materializationStatus: status,
      computedAt: analysis.generatedAt,
      sourceVersion: analysis.sourceVersion,
      computedVersion: analysis.computedVersion,
    );
  }

  Future<void> _refreshSilently() async {
    if (_disposed || !_isAuthenticated) return;
    try {
      final state = await _fetch();
      if (!_disposed) this.state = AsyncData(state);
    } catch (error, stackTrace) {
      ref
          .read(talkerProvider)
          .warning('Today AI data change refresh failed: $error', stackTrace);
    }
  }

  Future<void> _refreshOnResume() async {
    if (_disposed || !_isAuthenticated) return;
    final previous = _lastState;
    try {
      final state = await _fetch();
      if (_disposed) return;
      if (previous?.sourceVersion != state.sourceVersion ||
          previous?.computedAt != state.computedAt ||
          previous?.materializationStatus != state.materializationStatus) {
        this.state = AsyncData(state);
      }
    } catch (error, stackTrace) {
      ref
          .read(talkerProvider)
          .warning('Today AI resume refresh failed: $error', stackTrace);
    }
  }

  /// Manual refresh. The previous card is kept visible during the request.
  Future<void> refresh() async {
    if (!_isAuthenticated) return;

    final settings = ref.read(userSettingsControllerProvider).asData?.value;
    if (settings?.aiSummariesEnabled == false) {
      if (!_disposed) {
        state = const AsyncData(TodayAiAnalysisCardState.disabled());
      }
      return;
    }

    final repo = ref.read(todayAiRepositoryProvider);
    final previousAnalysis = state.asData?.value.analysis;
    final Either<LucentFailure, TodayAiAnalysis> result;
    try {
      result = await repo.refresh(DateTime.now()).run();
    } on FormatException catch (e, st) {
      // 协议不变量（非 problem+json / 畸形 body）：直接投影为错误态，不抛出。
      ref.read(talkerProvider).error('TodayAiAnalysisNotifier.refresh: $e');
      if (!_disposed) {
        state = AsyncError(LucentErrorMapper.fromObject(e), st);
      }
      return;
    }
    result.fold(
      (failure) {
        ref
            .read(talkerProvider)
            .error('TodayAiAnalysisNotifier.refresh: $failure');
        if (failure.statusCode == 403) {
          if (!_disposed) {
            state = const AsyncData(TodayAiAnalysisCardState.disabled());
          }
          return;
        }
        if (!_disposed) {
          state = AsyncError(failure, StackTrace.current);
        }
      },
      (analysis) {
        if (!_disposed) {
          state = AsyncData(
            _mapToCardState(analysis, previous: previousAnalysis),
          );
        }
      },
    );
  }

  void reset() {
    if (!_disposed) state = const AsyncData(TodayAiAnalysisCardState.idle());
  }
}
