import 'package:luminous/features/record/domain/entities/dashboard.dart';

/// Payload carried by [Draggable] when a timeline card is dragged onto a
/// calendar day cell.
///
/// Only entries with a non-null [RecordTimelineEntry.recordId] are draggable
/// — entries without a recordId are placeholders or preview data that cannot
/// be re-dated via the API.
class TimelineDragData {
  const TimelineDragData({required this.recordId, required this.entry});

  /// The server-side ID of the daily record being dragged.
  final String recordId;

  /// The timeline entry being dragged, used for rendering the drag feedback.
  final RecordTimelineEntry entry;
}
