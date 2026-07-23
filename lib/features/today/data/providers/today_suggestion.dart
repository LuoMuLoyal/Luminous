import 'package:luminous/features/today/data/repositories/lucent.dart';
import 'package:luminous/features/today/domain/repositories/dashboard.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

part 'today_suggestion.g.dart';

@riverpod
TodayRepository todayRepository(Ref ref) {
  return LucentTodayRepository(ref: ref);
}
