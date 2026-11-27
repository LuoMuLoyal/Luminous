import 'package:luminous/features/review/domain/entities/digest.dart';

sealed class ReviewDigestEvent {
  const ReviewDigestEvent();
}

class ReviewDigestSummaryEvent extends ReviewDigestEvent {
  const ReviewDigestSummaryEvent(this.summary);

  final String summary;
}

class ReviewDigestResultEvent extends ReviewDigestEvent {
  const ReviewDigestResultEvent(this.summary);

  final ReviewDigest summary;
}

abstract interface class ReviewDigestRepository {
  Stream<ReviewDigestEvent> generateStream(
    ReviewDigestRange range, {
    String? startDate,
    String? endDate,
  });
}
