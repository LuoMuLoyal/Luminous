import 'package:luminous/features/mine/data/repositories/lucent.dart';
import 'package:luminous/features/mine/domain/repositories/profile.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

part 'mine.g.dart';

@riverpod
MineRepository mineRepository(Ref ref) {
  return LucentMineRepository(ref);
}
