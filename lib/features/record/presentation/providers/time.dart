import 'package:clock/clock.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

part 'time.g.dart';

@riverpod
DateTime currentRecordDateTime(Ref ref) {
  return clock.now();
}
