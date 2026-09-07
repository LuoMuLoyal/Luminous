import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:luminous/features/review/domain/entities/dashboard.dart';

/// 单维趋势卡当前选中的维度（覆盖概览行点击与趋势卡 chips 共享）。
///
/// null 表示未显式选择（趋势卡内部默认第一个有数据的维度）。
class ReviewTrendDimensionNotifier extends Notifier<ReviewDataKind?> {
  @override
  ReviewDataKind? build() => null;

  void select(ReviewDataKind kind) {
    state = kind;
  }
}

final reviewTrendDimensionProvider =
    NotifierProvider<ReviewTrendDimensionNotifier, ReviewDataKind?>(
      ReviewTrendDimensionNotifier.new,
    );
