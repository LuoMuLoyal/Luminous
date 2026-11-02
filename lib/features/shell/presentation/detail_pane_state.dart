import 'package:flutter_riverpod/flutter_riverpod.dart';

/// 桌面端右侧详情面板里正在展示的内容。
///
/// 面板是**桌面专属的第二种详情呈现**：同一个详情在手机上仍旧整页 push，
/// 桌面上则在内容右侧推开一块 22rem 的面板，列表的滚动位置和上下文都还在。
///
/// 用密封类而不是「一个 Object? + 调用方自己判断」：面板内容的种类会越来越多，
/// 每种需要的参数不同（药品要 source + id，记录要 recordId），写成密封类之后
/// 新增类型会逼编译器在渲染处报错，而不是在运行时渲染出一块空白。
sealed class DetailPaneTarget {
  const DetailPaneTarget();
}

/// 打开一个药品详情（包说明 / DrugBank 两种来源）。
final class MedicineDetailTarget extends DetailPaneTarget {
  const MedicineDetailTarget({required this.source, required this.id});

  /// `cn` | `drugbank`，与 `MedicineDetailRoute` 的参数一致。
  final String source;
  final String id;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is MedicineDetailTarget && other.source == source && other.id == id;

  @override
  int get hashCode => Object.hash(source, id);
}

/// 面板的开关状态。
///
/// `null` 表示关闭。关闭时不渲染面板容器，内容区占满——不做「留一条空边」，
/// 那会让关闭态和打开态的内容宽度不一致，页面切换时文字重排。
class DetailPaneController extends Notifier<DetailPaneTarget?> {
  @override
  DetailPaneTarget? build() => null;

  /// 打开面板；同一个目标重复打开是幂等的（不会触发重建）。
  void open(DetailPaneTarget target) {
    if (state == target) return;
    state = target;
  }

  void close() => state = null;

  /// 切换：已经在看这个目标就关掉。
  void toggle(DetailPaneTarget target) {
    state = state == target ? null : target;
  }
}

final detailPaneProvider =
    NotifierProvider<DetailPaneController, DetailPaneTarget?>(
      DetailPaneController.new,
    );
