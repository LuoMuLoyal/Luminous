import 'package:flutter_riverpod/flutter_riverpod.dart';

final currentRecordDateTimeProvider = Provider<DateTime>((ref) {
  return DateTime.now();
});
