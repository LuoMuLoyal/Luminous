import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:luminous/app/composition/customizer/layout_repository.dart';
import 'package:luminous/core/composition/composition.dart';
import 'package:luminous/features/customizer/application/orchestrators/session.dart';
import 'package:luminous/features/customizer/application/usecases/edit_session.dart';
import 'package:luminous/features/customizer/domain/entities/draft.dart';
import 'package:luminous/features/customizer/domain/entities/edit.dart';
import 'package:luminous/features/customizer/presentation/providers/layout_store.dart';

/// 编排会话状态。
///
/// autoDispose：草稿只在编排页存活期内存在。用户退出再进来，看到的是已保存
/// 的布局，而不是上次没提交的半成品——这比"记住未提交草稿"更符合预期，
/// 因为编排是显式的、有「完成 / 取消」的。
final editSessionProvider = NotifierProvider<EditSessionNotifier, LayoutDraft?>(
  EditSessionNotifier.new,
  isAutoDispose: true,
  name: 'editSession',
);

class EditSessionNotifier extends Notifier<LayoutDraft?> {
  EditSession? _session;

  /// `begin()` 的代次：每次调用 +1。
  ///
  /// provider 重建后 Notifier 实例会被复用、`ref` 也换成新的，上一代
  /// `begin()` 的 `ref.mounted` 会重新变成 true。只看 `ref.mounted` 不够，
  /// 还得靠代次挡住「旧会话的读取结果覆盖新会话草稿」。
  int _generation = 0;

  /// 当前这一代是否已被销毁（autoDispose 触发或 provider 重建）。
  bool _disposed = false;

  @override
  LayoutDraft? build() {
    _session = null;
    _generation = 0;
    _disposed = false;
    ref.onDispose(() {
      // 销毁即丢弃草稿，并让所有在飞的 begin() 在 await 之后短路返回：
      // 继续写 state 会抛 UnmountedRefException。
      _disposed = true;
      _session = null;
    });
    return null;
  }

  /// 进入编排：读现有布局生成草稿。读取失败时 use case 已回退为默认布局，
  /// 所以编排本身永远可进入——只有保存才依赖网络。
  ///
  /// 读取是异步的（cache-first 仓储，可能附带一次远端刷新），而本 provider 是
  /// autoDispose：await 期间用户退出编排页、或 provider 因依赖变更重建，都会让
  /// 这个 Ref 失效。await 之后必须先确认还该不该写状态。
  Future<void> begin(SurfaceCatalog catalog) async {
    final generation = ++_generation;
    final initial = await StartDraft(
      ref.read(layoutRepositoryProvider),
    ).call(catalog);
    if (!_isCurrent(generation)) return;
    _session = EditSession(initial: initial, catalog: catalog);
    _publish(_session!.current);
  }

  void applyEdit(LayoutEdit edit) {
    final session = _session;
    if (session == null) return;
    session.apply(edit);
    _publish(session.current);
  }

  void resetToDefaults() {
    _session?.resetToDefaults();
    _publish(_session?.current);
  }

  void resetToInitial() {
    _session?.resetToInitial();
    _publish(_session?.current);
  }

  bool get isDirty => _session?.isDirty ?? false;

  /// 点「完成」：把草稿写进布局 store，页面随即按新布局重排。
  ///
  /// 写的是会话开始时那份 catalog 里的**每一个** surface：编排页虽然只显示
  /// 当前 surface，但跨 tab 面板可以把组件搬到别的 surface，只存当前这一张
  /// 会让另一半改动静默丢失。
  ///
  /// 落盘发生在 `surfaceLayoutsProvider`（非 autoDispose）上，本 provider 在
  /// 等待期间被销毁不影响写入；因此这里 await 之后不再触碰 `ref`。
  Future<void> commit() async {
    final session = _session;
    if (session == null) return;
    await ref.read(surfaceLayoutsProvider.notifier).commit(session.current);
  }

  /// await 之后是否还能写状态：Ref 没被销毁、没被重建，且没有更新的 `begin()`。
  bool _isCurrent(int generation) =>
      !_disposed && ref.mounted && generation == _generation;

  /// 唯一的状态出口。edit 回调可能晚于页面销毁（例如拖拽落点在手势收尾时
  /// 才回调），直接写 `state` 会抛同一个未挂载异常。
  void _publish(LayoutDraft? next) {
    if (_disposed) return;
    state = next;
  }
}
