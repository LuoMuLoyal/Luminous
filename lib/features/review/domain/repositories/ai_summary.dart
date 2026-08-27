import 'package:luminous/features/review/domain/entities/ai_summary.dart';

sealed class ReviewAiGenerationEvent {
  const ReviewAiGenerationEvent();
}

class ReviewAiGenerationSummaryEvent extends ReviewAiGenerationEvent {
  const ReviewAiGenerationSummaryEvent(this.summary);

  final String summary;
}

class ReviewAiGenerationResultEvent extends ReviewAiGenerationEvent {
  const ReviewAiGenerationResultEvent(this.summary);

  final ReviewAiSummary summary;
}

abstract interface class ReviewAiSummaryRepository {
  Stream<ReviewAiGenerationEvent> generateStream(
    ReviewAiSummaryRange range, {
    String? startDate,
    String? endDate,
  });
}
