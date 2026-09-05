import 'dart:async';
import 'dart:convert';
import 'dart:math';

import 'package:dio/dio.dart';
import 'package:flutter/foundation.dart'
    show TargetPlatform, defaultTargetPlatform, kIsWeb;
import 'package:lucent_api/lucent_api.dart';
import 'package:luminous/core/database/connection_providers.dart';
import 'package:luminous/core/database/daos/pending_sync.dart';
import 'package:luminous/core/database/sync/worker.dart';
import 'package:luminous/core/logger/log_level.dart';
import 'package:luminous/core/network/client/client_providers.dart';
import 'package:package_info_plus/package_info_plus.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

import 'product_event.dart';

part 'product_event_service.g.dart';

/// File-level shorthand for the generated request-scoped platform enum
/// (2026-09-03 审查 #4 readability closure; no behavior change).
typedef _ProductEventPlatform = RecordBatchRequestEventsPlatformEnum;

/// Pending-sync entity type for queued product events.
const String kProductEventSyncEntityType = 'product_event';

/// Maps the running platform to the API platform enum (currently inlined as
/// [RecordBatchRequestEventsPlatformEnum]).
///
/// Uses [defaultTargetPlatform] instead of `dart:io` so it compiles and runs
/// on every target including web and tests.
RecordBatchRequestEventsPlatformEnum resolveUserDevicePlatform() {
  if (kIsWeb) {
    return _ProductEventPlatform.web;
  }
  return switch (defaultTargetPlatform) {
    TargetPlatform.iOS => _ProductEventPlatform.ios,
    TargetPlatform.android => _ProductEventPlatform.android,
    TargetPlatform.windows => _ProductEventPlatform.windows,
    TargetPlatform.macOS => _ProductEventPlatform.macos,
    TargetPlatform.linux => _ProductEventPlatform.linux,
    _ => _ProductEventPlatform.other,
  };
}

Future<String> _loadAppVersion() async {
  final info = await PackageInfo.fromPlatform();
  return info.version;
}

String _generateEventId() {
  // Collision-resistant client event id — the server treats it as a unique
  // per-user idempotency key, so it only needs local uniqueness.
  return 'pe_${DateTime.now().microsecondsSinceEpoch}_'
      '${Random.secure().nextInt(1 << 32)}';
}

/// Records privacy-minimal product events at their actual success boundaries.
///
/// Flow: builds the request event (appVersion / platform / occurredAt /
/// clientEventId) → attempts `POST /user/product-events` via the generated
/// API; on a [DioException] (offline / network / server error) the event is
/// enqueued into the pending-sync queue under
/// [kProductEventSyncEntityType] for later replay. Replays reuse the SAME
/// clientEventId, so server-side idempotency prevents double counting.
///
/// The queued payload is the event's `toJson()` — exactly the allowlisted
/// attribute keys, nothing else (no free text, no record values, no
/// metadata).
///
/// Event reporting is fire-and-forget: failures never propagate to callers
/// and never break the UI.
class ProductEventService {
  ProductEventService({
    required this.api,
    this.pendingSyncDao,
    this.syncWorker,
    Future<String> Function()? versionLoader,
    RecordBatchRequestEventsPlatformEnum Function()? platformResolver,
    DateTime Function()? clock,
    String Function()? eventIdGenerator,
  }) : _versionLoader = versionLoader ?? _loadAppVersion,
       _platformResolver = platformResolver ?? resolveUserDevicePlatform,
       _clock = clock ?? DateTime.now,
       _eventIdGenerator = eventIdGenerator ?? _generateEventId;

  final ProductEventsApi api;

  /// Optional — null disables offline queueing (used by tests).
  final PendingSyncDao? pendingSyncDao;

  /// Optional — when present, a flush is triggered after enqueueing.
  final SyncWorker? syncWorker;

  final Future<String> Function() _versionLoader;
  final _ProductEventPlatform Function() _platformResolver;
  final DateTime Function() _clock;
  final String Function() _eventIdGenerator;

  /// Impression keys seen this session (suggestion rule codes). Impression
  /// is reported at most once per session per rule code — build/rebuild of
  /// the card must not re-emit.
  final Set<String> _seenImpressionKeys = {};

  /// review_opened is reported at most once per session.
  bool _reviewOpenedRecorded = false;

  /// Tracks a suggestion card impression, deduplicated per session and per
  /// rule code. Returns whether the event was actually recorded.
  ///
  /// Impressions for rule codes outside [kAllowlistedSuggestionRuleCodes] are
  /// dropped (the server would reject them with 400 and the queue would only
  /// accumulate doomed retries).
  bool trackSuggestionImpression(String ruleCode) {
    if (!kAllowlistedSuggestionRuleCodes.contains(ruleCode)) return false;
    if (!_seenImpressionKeys.add(ruleCode)) return false;
    unawaited(_record(SuggestionImpressionEvent(suggestionRuleCode: ruleCode)));
    return true;
  }

  /// Tracks that the review page presented data. Deduplicated per session —
  /// subsequent presentations (refresh, tab switches) do not re-emit.
  Future<void> trackReviewOpened() async {
    if (_reviewOpenedRecorded) return;
    _reviewOpenedRecorded = true;
    await _record(const ReviewOpenedEvent());
  }

  /// Tracks a visit summary preview attempt — one event per server response
  /// (success or failure), no dedupe.
  Future<void> trackVisitSummaryPreviewed(
    RecordBatchRequestEventsResultEnum result,
  ) async {
    await _record(VisitSummaryPreviewedEvent(result: result));
  }

  /// Tracks a visit summary export attempt — one event per server response
  /// (success or failure), no dedupe.
  Future<void> trackVisitSummaryExported(
    RecordBatchRequestEventsResultEnum result,
  ) async {
    await _record(VisitSummaryExportedEvent(result: result));
  }

  Future<void> _record(ProductEvent event) async {
    try {
      final eventPayload = await _buildEvent(event);
      try {
        await api.recordBatch(
          recordBatchRequest: RecordBatchRequest(events: [eventPayload]),
        );
      } on DioException catch (error) {
        await _enqueue(eventPayload);
        appTalker.warning(
          'ProductEventService: ${event.name} failed, queued for sync: '
          '$error',
        );
      }
    } catch (error, stackTrace) {
      // Measurement must never break the app — drop the event.
      appTalker.warning(
        'ProductEventService: drop ${event.name}: $error',
        stackTrace,
      );
    }
  }

  Future<RecordBatchRequestEvents> _buildEvent(ProductEvent event) async {
    final version = await _versionLoader();
    return event.toDto(
      appVersion: version,
      platform: _platformResolver(),
      occurredAt: _clock().toUtc().toIso8601String(),
      clientEventId: _eventIdGenerator(),
    );
  }

  /// Enqueues the failed event into the pending-sync queue.
  ///
  /// The payload is the event's own JSON — only allowlisted attribute keys.
  /// The same event (and therefore the same clientEventId) is replayed on
  /// retry, making retries idempotent.
  Future<void> _enqueue(RecordBatchRequestEvents event) async {
    final dao = pendingSyncDao;
    if (dao == null) return;
    await dao.enqueue(
      entityType: kProductEventSyncEntityType,
      operation: 'create',
      payload: jsonEncode(event.toJson()),
    );
    unawaited(syncWorker?.flush());
  }
}

/// Provider for [ProductEventService].
///
/// Registers the pending-sync replay handler for
/// [kProductEventSyncEntityType]: decodes the queued payload back into a
/// [RecordBatchRequestEvents] and re-posts it
/// via the generated API. Decoding round-trips the clientEventId, so retries
/// stay idempotent.
@Riverpod(keepAlive: true)
ProductEventService productEventService(Ref ref) {
  final pendingSyncDao = ref.watch(pendingSyncDaoProvider);
  final syncWorker = ref.watch(syncWorkerProvider);
  final api = ref.watch(lucentClientProvider).productEvents;

  syncWorker.registerHandler(kProductEventSyncEntityType, (entry) async {
    final payload = jsonDecode(entry.payload) as Map<String, dynamic>;
    await api.recordBatch(
      recordBatchRequest: RecordBatchRequest(
        events: [RecordBatchRequestEvents.fromJson(payload)],
      ),
    );
  });

  return ProductEventService(
    api: api,
    pendingSyncDao: pendingSyncDao,
    syncWorker: syncWorker,
  );
}
