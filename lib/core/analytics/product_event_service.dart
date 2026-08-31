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

/// Pending-sync entity type for queued product events.
const String kProductEventSyncEntityType = 'product_event';

/// Maps the running platform to the API [UserDevicePlatform] enum.
///
/// Uses [defaultTargetPlatform] instead of `dart:io` so it compiles and runs
/// on every target including web and tests.
UserDevicePlatform resolveUserDevicePlatform() {
  if (kIsWeb) return UserDevicePlatform.web;
  return switch (defaultTargetPlatform) {
    TargetPlatform.iOS => UserDevicePlatform.ios,
    TargetPlatform.android => UserDevicePlatform.android,
    TargetPlatform.windows => UserDevicePlatform.windows,
    TargetPlatform.macOS => UserDevicePlatform.macos,
    TargetPlatform.linux => UserDevicePlatform.linux,
    _ => UserDevicePlatform.other,
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
/// Flow: builds the [CreateProductEventDto] (appVersion / platform /
/// occurredAt / clientEventId) → attempts `POST /user/product-events` via the
/// generated API; on a [DioException] (offline / network / server error) the
/// event is enqueued into the pending-sync queue under
/// [kProductEventSyncEntityType] for later replay. Replays reuse the SAME
/// [CreateProductEventDto.clientEventId], so server-side idempotency prevents
/// double counting.
///
/// The queued payload is `dto.toJson()` — exactly the allowlisted attribute
/// keys, nothing else (no free text, no record values, no metadata).
///
/// Event reporting is fire-and-forget: failures never propagate to callers
/// and never break the UI.
class ProductEventService {
  ProductEventService({
    required this.api,
    this.pendingSyncDao,
    this.syncWorker,
    Future<String> Function()? versionLoader,
    UserDevicePlatform Function()? platformResolver,
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
  final UserDevicePlatform Function() _platformResolver;
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
  Future<void> trackVisitSummaryPreviewed(ProductEventResult result) async {
    await _record(VisitSummaryPreviewedEvent(result: result));
  }

  /// Tracks a visit summary export attempt — one event per server response
  /// (success or failure), no dedupe.
  Future<void> trackVisitSummaryExported(ProductEventResult result) async {
    await _record(VisitSummaryExportedEvent(result: result));
  }

  Future<void> _record(ProductEvent event) async {
    try {
      final dto = await _buildDto(event);
      try {
        await api.productEventsControllerRecordBatchV1(
          createProductEventBatchDto: CreateProductEventBatchDto(events: [dto]),
        );
      } on DioException catch (error) {
        await _enqueue(dto);
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

  Future<CreateProductEventDto> _buildDto(ProductEvent event) async {
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
  /// The payload is the DTO's own JSON — only allowlisted attribute keys.
  /// The same DTO (and therefore the same [clientEventId]) is replayed on
  /// retry, making retries idempotent.
  Future<void> _enqueue(CreateProductEventDto dto) async {
    final dao = pendingSyncDao;
    if (dao == null) return;
    await dao.enqueue(
      entityType: kProductEventSyncEntityType,
      operation: 'create',
      payload: jsonEncode(dto.toJson()),
    );
    unawaited(syncWorker?.flush());
  }
}

/// Provider for [ProductEventService].
///
/// Registers the pending-sync replay handler for
/// [kProductEventSyncEntityType]: decodes the queued payload back into a
/// [CreateProductEventDto] and re-posts it via the generated API. Decoding
/// round-trips the clientEventId, so retries stay idempotent.
@Riverpod(keepAlive: true)
ProductEventService productEventService(Ref ref) {
  final pendingSyncDao = ref.watch(pendingSyncDaoProvider);
  final syncWorker = ref.watch(syncWorkerProvider);
  final api = ref.watch(lucentClientProvider).productEvents;

  syncWorker.registerHandler(kProductEventSyncEntityType, (entry) async {
    final payload = jsonDecode(entry.payload) as Map<String, dynamic>;
    await api.productEventsControllerRecordBatchV1(
      createProductEventBatchDto: CreateProductEventBatchDto(
        events: [CreateProductEventDto.fromJson(payload)],
      ),
    );
  });

  return ProductEventService(
    api: api,
    pendingSyncDao: pendingSyncDao,
    syncWorker: syncWorker,
  );
}
