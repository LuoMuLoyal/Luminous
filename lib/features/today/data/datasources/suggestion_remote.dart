import 'package:lucent_api/lucent_api.dart';
import 'package:luminous/features/today/domain/entities/suggestion.dart';

/// Remote data source for the Today suggestion engine.
///
/// Wraps the generated [TodaySuggestionApi] and maps DTOs to domain entities.
/// The Retrofit client returns envelope-wrapped DTOs (code/message/data);
/// this class unwraps `.data` and converts to domain types.
class TodaySuggestionRemoteDataSource {
  const TodaySuggestionRemoteDataSource({required this.api});

  final TodaySuggestionApi api;

  // ── Suggestions ─────────────────────────────────────────────────────────

  /// GET /api/v1/user/today/suggestions
  Future<TodaySuggestionBundle> fetchSuggestions({
    required String language,
    String? date,
    List<String>? excludeIds,
  }) async {
    final response = await api.todaySuggestionControllerGetSuggestionsV1(
      acceptLanguage: language,
      date: date,
      excludeIds: excludeIds,
    );
    return _mapBundle(response.data!.data);
  }

  // ── Feedback ───────────────────────────────────────────────────────────

  /// POST /api/v1/user/today/suggestions/:id/feedback
  Future<TodaySuggestionFeedbackResult> submitFeedback({
    required String id,
    required TodaySuggestionFeedback feedback,
  }) async {
    final response = await api.todaySuggestionControllerSubmitFeedbackV1(
      id: id,
      suggestionFeedbackDto: SuggestionFeedbackDto(
        feedback: _mapFeedbackToDto(feedback),
      ),
    );
    final data = response.data!.data;
    return TodaySuggestionFeedbackResult(
      suggestionId: data.suggestionId,
      feedback: _mapFeedbackFromString(data.feedback.value),
      appliedEffect: TodaySuggestionFeedbackEffect.fromJson(
        data.appliedEffect.value,
      ),
      expiresAt: data.expiresAt,
    );
  }

  // ── Explanation ────────────────────────────────────────────────────────

  /// POST /api/v1/user/today/suggestions/:id/explain
  Future<TodaySuggestionExplanation> explainSuggestion({
    required String id,
    required String language,
  }) async {
    final response = await api.todaySuggestionControllerExplainSuggestionV1(
      id: id,
      acceptLanguage: language,
    );
    final data = response.data!.data;
    return TodaySuggestionExplanation(
      suggestionId: data.suggestionId,
      reason: data.reason,
      boundary: data.boundary,
      aiGenerated: data.aiGenerated,
      locale: data.locale,
    );
  }

  // ── History ────────────────────────────────────────────────────────────

  /// GET /api/v1/user/today/suggestions/history
  Future<TodaySuggestionHistory> fetchHistory({
    String? startDate,
    String? endDate,
    String? lifecycleState,
    String? type,
    int? limit,
  }) async {
    final response = await api.todaySuggestionControllerGetHistoryV1(
      startDate: startDate,
      endDate: endDate,
      lifecycleState: lifecycleState,
      type: type,
      limit: limit,
    );
    final data = response.data!.data;
    return TodaySuggestionHistory(
      items: data.items.map(_mapHistoryItem).toList(growable: false),
      total: data.total.toInt(),
      startDate: data.startDate,
      endDate: data.endDate,
    );
  }

  // ── Mapping helpers ────────────────────────────────────────────────────

  TodaySuggestionBundle _mapBundle(TodaySuggestionsDataDto dto) {
    return TodaySuggestionBundle(
      generatedAt: dto.generatedAt,
      primary: dto.primary != null ? _mapCard(dto.primary!) : null,
      secondary: dto.secondary?.map(_mapCard).toList(growable: false),
      observations: dto.observations?.map(_mapCard).toList(growable: false),
    );
  }

  TodaySuggestionCard _mapCard(SuggestionItemDto dto) {
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
      secondaryActions: dto.secondaryActions?.map(_mapAction).toList(),
      confidence: _mapConfidenceFromString(dto.confidence.value),
      ruleId: dto.ruleId,
      ruleVersion: dto.ruleVersion,
      triggerType: _mapTriggerTypeFromString(dto.triggerType.value),
      lifecycleState: TodaySuggestionLifecycleState.fromJson(
        dto.lifecycleState.value,
      ),
      notificationEligible: dto.notificationEligible is bool
          ? dto.notificationEligible as bool
          : null,
      feedbackOptions: dto.feedbackOptions
          ?.map(_mapFeedbackFromString)
          .toList(),
      subtype: dto.subtype is String ? dto.subtype as String : null,
    );
  }

  TodaySuggestionEvidence _mapEvidence(EvidenceItemDto dto) {
    return TodaySuggestionEvidence(
      kind: TodaySuggestionEvidenceKind.fromJson(dto.kind.value),
      label: dto.label,
      value: dto.value,
      recordId: dto.recordId is String ? dto.recordId as String : null,
      medicineId: dto.medicineId is String ? dto.medicineId as String : null,
    );
  }

  TodaySuggestionAction _mapAction(SuggestionActionDto dto) {
    return TodaySuggestionAction(
      actionId: dto.actionId,
      label: dto.label,
      route: dto.route,
      authRequired: dto.authRequired,
    );
  }

  TodaySuggestionHistoryItem _mapHistoryItem(SuggestionHistoryItemDto dto) {
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
      subtype: dto.subtype is String ? dto.subtype as String : null,
      feedback: dto.feedback != null
          ? _mapFeedbackFromString(dto.feedback!.value)
          : null,
      feedbackAt: dto.feedbackAt is String ? dto.feedbackAt as String : null,
      expiredAt: dto.expiredAt is String ? dto.expiredAt as String : null,
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

  SuggestionFeedbackDtoFeedbackEnum _mapFeedbackToDto(
    TodaySuggestionFeedback feedback,
  ) {
    return switch (feedback) {
      TodaySuggestionFeedback.accepted =>
        SuggestionFeedbackDtoFeedbackEnum.accepted,
      TodaySuggestionFeedback.later => SuggestionFeedbackDtoFeedbackEnum.later,
      TodaySuggestionFeedback.notApplicable =>
        SuggestionFeedbackDtoFeedbackEnum.notApplicable,
      TodaySuggestionFeedback.suppress =>
        SuggestionFeedbackDtoFeedbackEnum.suppress,
    };
  }
}
