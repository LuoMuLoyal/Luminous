import 'package:fpdart/fpdart.dart';
import 'package:lucent_api/lucent_api.dart';
import 'package:luminous/core/errors/lucent_failure.dart';
import 'package:luminous/core/network/contract/error_mapper.dart';
import 'package:luminous/core/network/contract/response_body.dart';
import 'package:luminous/features/today/domain/entities/suggestion.dart';
import 'package:luminous/features/today/domain/repositories/suggestion.dart';

/// Remote data source for the Today suggestion engine.
///
/// Wraps the generated [TodaySuggestionApi] and maps DTOs to domain entities.
/// The Retrofit client returns direct resource DTOs, which this class maps to
/// domain types. As the sole implementation of [SuggestionRepository] it
/// returns [TaskEither]; transport errors are normalized through
/// [LucentErrorMapper] (server business failures keep their Problem Details
/// code, network failures become network Lefts).
class TodaySuggestionRemoteDataSource implements SuggestionRepository {
  const TodaySuggestionRemoteDataSource({required this.api});

  final TodaySuggestionApi api;

  // ── Suggestions ─────────────────────────────────────────────────────────

  /// GET /api/v1/user/today/suggestions
  @override
  TaskEither<LucentFailure, TodaySuggestionBundle> fetchSuggestions({
    required String language,
    String? date,
    List<String>? excludeIds,
  }) {
    return TaskEither.tryCatch(() async {
      final response = await api.getSuggestions(
        acceptLanguage: language,
        date: date,
        excludeIds: excludeIds,
      );
      return _mapBundle(
        requireData(response.data, operation: 'fetchSuggestions'),
      );
    }, (error, stackTrace) => LucentErrorMapper.fromObject(error));
  }

  // ── Feedback ───────────────────────────────────────────────────────────

  /// POST /api/v1/user/today/suggestions/:id/feedback
  @override
  TaskEither<LucentFailure, TodaySuggestionFeedbackResult> submitFeedback({
    required String id,
    required TodaySuggestionFeedback feedback,
  }) {
    return TaskEither.tryCatch(() async {
      final response = await api.submitFeedback(
        id: id,
        submitFeedbackRequest:
            SubmitFeedbackRequest(
              feedback: _mapFeedbackToDto(feedback),
            ),
      );
      final data = requireData(response.data, operation: 'submitFeedback');
      return TodaySuggestionFeedbackResult(
        suggestionId: data.suggestionId,
        feedback: _mapFeedbackFromString(data.feedback.value),
        appliedEffect: TodaySuggestionFeedbackEffect.fromJson(
          data.appliedEffect.value,
        ),
        expiresAt: data.expiresAt,
      );
    }, (error, stackTrace) => LucentErrorMapper.fromObject(error));
  }

  // ── Explanation ────────────────────────────────────────────────────────

  /// POST /api/v1/user/today/suggestions/:id/explain
  @override
  TaskEither<LucentFailure, TodaySuggestionExplanation> explainSuggestion({
    required String id,
    required String language,
  }) {
    return TaskEither.tryCatch(() async {
      final response = await api.explainSuggestion(
        id: id,
        acceptLanguage: language,
      );
      final data = requireData(response.data, operation: 'explainSuggestion');
      return TodaySuggestionExplanation(
        suggestionId: data.suggestionId,
        reason: data.reason,
        boundary: data.boundary,
        aiGenerated: data.aiGenerated,
        locale: data.locale,
      );
    }, (error, stackTrace) => LucentErrorMapper.fromObject(error));
  }

  // ── History ────────────────────────────────────────────────────────────

  /// GET /api/v1/user/today/suggestions/history
  @override
  TaskEither<LucentFailure, TodaySuggestionHistory> fetchHistory({
    required String language,
    String? startDate,
    String? endDate,
    String? lifecycleState,
    String? type,
    int? limit,
  }) {
    return TaskEither.tryCatch(() async {
      final response = await api.getHistory(
        acceptLanguage: language,
        startDate: startDate,
        endDate: endDate,
        lifecycleState: lifecycleState,
        type: type,
        limit: limit,
      );
      final data = requireData(response.data, operation: 'fetchHistory');
      return TodaySuggestionHistory(
        items: data.items.map(_mapHistoryItem).toList(growable: false),
        total: data.total.toInt(),
        startDate: data.startDate,
        endDate: data.endDate,
      );
    }, (error, stackTrace) => LucentErrorMapper.fromObject(error));
  }

  // ── Mapping helpers ────────────────────────────────────────────────────

  TodaySuggestionBundle _mapBundle(TodaySuggestionsResponse dto) {
    return TodaySuggestionBundle(
      generatedAt: dto.generatedAt,
      materializationStatus: TodaySuggestionMaterializationStatus.fromJson(
        dto.materializationStatus.value,
      ),
      sourceVersion: _safeInt(dto.sourceVersion) ?? 0,
      computedAt: _parseDateTime(dto.computedAt),
      retryAfterSeconds: _safeInt(dto.retryAfterSeconds),
      primary: dto.primary != null ? _mapPrimaryCard(dto.primary!) : null,
      secondary: dto.secondary?.map(_mapCard).toList(growable: false),
      observations: dto.observations
          ?.map(
            (item) => _mapCard(
              TodaySuggestionsResponseSecondary.fromJson(item.toJson()),
            ),
          )
          .toList(growable: false),
    );
  }

  DateTime? _parseDateTime(String? value) {
    if (value == null) return null;
    return DateTime.tryParse(value);
  }

  int? _safeInt(num? value) {
    if (value == null || !value.isFinite || value != value.truncate()) {
      return null;
    }
    return value.toInt();
  }

  /// Maps the primary card to the shared card mapper. The zod contract emits
  /// one class per array/card slot (primary vs secondary/observations) that
  /// shares the same JSON shape, so the primary payload is normalized onto the
  /// canonical card DTO before mapping.
  TodaySuggestionCard _mapPrimaryCard(TodaySuggestionsResponsePrimary dto) {
    return _mapCard(
      TodaySuggestionsResponseSecondary.fromJson(dto.toJson()),
    );
  }

  TodaySuggestionCard _mapCard(TodaySuggestionsResponseSecondary dto) {
    return TodaySuggestionCard(
      id: dto.id,
      type: TodaySuggestionType.fromJson(dto.type.value),
      cardTone: TodaySuggestionCardTone.fromJson(dto.cardTone.value),
      icon: dto.icon,
      title: dto.title,
      reason: dto.reason,
      evidence: dto.evidence.map(_mapEvidence).toList(growable: false),
      boundary: dto.boundary,
      primaryAction: _mapAction(dto.primaryAction),
      secondaryActions: dto.secondaryActions?.map(_mapSecondaryAction).toList(),
      confidence: _mapConfidenceFromString(dto.confidence.value),
      ruleId: dto.ruleId,
      ruleVersion: dto.ruleVersion,
      triggerType: _mapTriggerTypeFromString(dto.triggerType.value),
      lifecycleState: TodaySuggestionLifecycleState.fromJson(
        dto.lifecycleState.value,
      ),
      notificationEligible: dto.notificationEligible,
      feedbackOptions: dto.feedbackOptions
          ?.map((option) => _mapFeedbackFromString(option.value))
          .toList(),
      subtype: dto.subtype,
    );
  }

  TodaySuggestionEvidence _mapEvidence(
    TodaySuggestionsResponseSecondaryEvidence dto,
  ) {
    return TodaySuggestionEvidence(
      kind: TodaySuggestionEvidenceKind.fromJson(dto.kind),
      label: dto.label,
      value: dto.value,
      recordId: dto.recordId,
      medicineId: dto.medicineId,
    );
  }

  TodaySuggestionAction _mapAction(
    TodaySuggestionsResponseSecondaryPrimaryAction dto,
  ) {
    return TodaySuggestionAction(
      actionId: dto.actionId,
      label: dto.label,
      route: dto.route,
      authRequired: dto.authRequired,
    );
  }

  /// Secondary actions reuse the primary action JSON shape under a separate
  /// per-slot class, so they are normalized before mapping.
  TodaySuggestionAction _mapSecondaryAction(
    TodaySuggestionsResponseSecondarySecondaryActions dto,
  ) {
    return _mapAction(
      TodaySuggestionsResponseSecondaryPrimaryAction.fromJson(dto.toJson()),
    );
  }

  TodaySuggestionHistoryItem _mapHistoryItem(
    SuggestionHistoryResponseItems dto,
  ) {
    return TodaySuggestionHistoryItem(
      id: dto.id,
      date: dto.date,
      type: TodaySuggestionType.fromJson(dto.type.value),
      title: dto.title,
      reason: dto.reason,
      ruleId: dto.ruleId,
      ruleVersion: dto.ruleVersion,
      triggerType: _mapTriggerTypeFromString(dto.triggerType.value),
      lifecycleState: TodaySuggestionLifecycleState.fromJson(
        dto.lifecycleState.value,
      ),
      confidence: _mapConfidenceFromString(dto.confidence.value),
      generatedAt: dto.generatedAt,
      subtype: dto.subtype,
      feedback: dto.feedback != null
          ? _mapFeedbackFromString(dto.feedback!)
          : null,
      feedbackAt: dto.feedbackAt,
      expiredAt: dto.expiredAt,
    );
  }

  // ── String-based enum mapping (works across different generated enum types) ──

  TodaySuggestionConfidence _mapConfidenceFromString(String value) {
    return switch (value) {
      'high' => TodaySuggestionConfidence.high,
      'medium' => TodaySuggestionConfidence.medium,
      'low' => TodaySuggestionConfidence.low,
      _ => TodaySuggestionConfidence.medium,
    };
  }

  TodaySuggestionTriggerType _mapTriggerTypeFromString(String value) {
    return switch (value) {
      'event' => TodaySuggestionTriggerType.event,
      'timer' => TodaySuggestionTriggerType.timer,
      _ => TodaySuggestionTriggerType.timer,
    };
  }

  TodaySuggestionFeedback _mapFeedbackFromString(String value) {
    return switch (value) {
      'accepted' => TodaySuggestionFeedback.accepted,
      'later' => TodaySuggestionFeedback.later,
      'not_applicable' => TodaySuggestionFeedback.notApplicable,
      'suppress' => TodaySuggestionFeedback.suppress,
      _ => TodaySuggestionFeedback.later,
    };
  }

  SubmitFeedbackRequestFeedbackEnum
  _mapFeedbackToDto(TodaySuggestionFeedback feedback) {
    return switch (feedback) {
      TodaySuggestionFeedback.accepted =>
        SubmitFeedbackRequestFeedbackEnum.accepted,
      TodaySuggestionFeedback.later =>
        SubmitFeedbackRequestFeedbackEnum.later,
      TodaySuggestionFeedback.notApplicable =>
        SubmitFeedbackRequestFeedbackEnum.notApplicable,
      TodaySuggestionFeedback.suppress =>
        SubmitFeedbackRequestFeedbackEnum.suppress,
    };
  }
}
