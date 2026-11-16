import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:luminous/app/composition/generative/generation_repository.dart';
import 'package:luminous/features/generative/domain/entities/slot_spec.dart';
import 'package:luminous/shared/domain/composition/surface.dart';

/// 当前 surface 的自定义 genui 区块声明；没配置过时为 `null`。
///
/// 编排页用它决定那一行显示「用户起的标题」还是「未配置」；页面用它决定
/// 区块的标题，以及要不要显示触发入口。
final generativeSlotSpecProvider =
    NotifierProvider.family<
      GenerativeSlotSpecController,
      GenerativeSlotSpec?,
      SurfaceId
    >(GenerativeSlotSpecController.new, name: 'generativeSlotSpec');

class GenerativeSlotSpecController extends Notifier<GenerativeSlotSpec?> {
  GenerativeSlotSpecController(this.surface);

  final SurfaceId surface;

  /// 首次读取把声明从本地读出来：KV 是同步接口，首帧就能决定标题与入口是否
  /// 显示，不需要异步状态。仓储把坏数据收敛成 `Right(null)`，读失败与
  /// 「没配过」在这里是同一种结果。
  @override
  GenerativeSlotSpec? build() => ref
      .watch(slotSpecRepositoryProvider)
      .read(surface)
      .getRight()
      .toNullable();

  /// 保存（或覆盖）声明。
  ///
  /// 只写声明，不触发生成：用户可能只是想先把「这块地方要放什么」记下来，
  /// 真正生成由页面上的入口或编排页的「生成」按钮发起。保存即生成会把一次
  /// LLM 调用藏进写操作里，失败时用户看到的是「保存失败」而不是「生成失败」，
  /// 语义就混了。
  Future<void> save(GenerativeSlotSpec spec) async {
    await ref.read(slotSpecRepositoryProvider).write(surface, spec);
    state = spec;
  }

  /// 清掉声明：这一行回到「未配置」，同时作废已有的生成结果。
  ///
  /// 结果一并清掉是有意的：没有声明的结果是一块**无主**的区块——编排页上
  /// 它没有名字，用户也没法再生成一次，留着只会让人困惑。
  Future<void> clear() async {
    await ref.read(slotSpecRepositoryProvider).clear(surface);
    state = null;
  }
}
