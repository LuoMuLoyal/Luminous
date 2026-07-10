import 'package:clock/clock.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

part 'time_provider.g.dart';

@riverpod
DateTime currentRecordDateTime(Ref ref) {
  return clock.now();
}
