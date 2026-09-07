import 'dart:async';

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:luminous/features/record/data/providers/record_access.dart';

/// Manages the meal-analysis polling lifecycle for a single record detail view.
///
/// Exposes a simple [sync] method: the caller passes the current analyzing
/// status on every build; the poller starts / stops / reschedules itself as
/// needed, applying exponential back-off on transient failures while skipping
/// overlapping polls when the previous request is still in flight.
class MealAnalysisPoller {
  MealAnalysisPoller({required this.recordId, required this.ref});

  final String recordId;
  final WidgetRef ref;

  Timer? _analysisPoller;

  /// Guards against overlapping polls: when a refresh takes longer than the
  /// current interval, the next tick is skipped instead of stacking requests.
  bool _isPolling = false;

  /// Current poll interval. Starts at [_initialPollInterval] and backs off
  /// exponentially on failure up to [_maxPollInterval].
  Duration _pollInterval = _initialPollInterval;

  static const _initialPollInterval = Duration(seconds: 5);
  static const _maxPollInterval = Duration(seconds: 30);

  /// Dispose of any active timer. Call from [State.dispose].
  void dispose() {
    _analysisPoller?.cancel();
  }

  /// Start/stop the analysis poller based on the current meal analysis status.
  ///
  /// Safe to call from a [WidgetsBinding.addPostFrameCallback] on every build;
  /// the method is a no-op when the state has not changed.
  void sync(bool isAnalyzing) {
    if (isAnalyzing && _analysisPoller == null) {
      _pollInterval = _initialPollInterval;
      _scheduleNextPoll();
    } else if (!isAnalyzing && _analysisPoller != null) {
      _analysisPoller!.cancel();
      _analysisPoller = null;
    }
  }

  /// Schedules the next poll as a chained single-shot [Timer] instead of
  /// `Timer.periodic`, so each round can apply backoff and skip while a
  /// previous request is still in flight.
  void _scheduleNextPoll() {
    _analysisPoller?.cancel();
    _analysisPoller = Timer(_pollInterval, () async {
      if (_isPolling) return;
      _isPolling = true;
      try {
        // Invalidate + read triggers a fresh load; awaiting its future lets
        // the lock cover the whole request instead of just the tick.
        ref.invalidate(dailyRecordDetailProvider(recordId));
        await ref.read(dailyRecordDetailProvider(recordId).future);
        // Successful refresh: reset to the base interval (analysis is
        // presumably still running while this poller is active).
        _pollInterval = _initialPollInterval;
      } catch (_) {
        // Transient failure: back off so a degraded backend is not
        // hammered at the base rate.
        final doubled = Duration(seconds: _pollInterval.inSeconds * 2);
        _pollInterval = doubled > _maxPollInterval ? _maxPollInterval : doubled;
      } finally {
        _isPolling = false;
      }
      _scheduleNextPoll();
    });
  }
}
