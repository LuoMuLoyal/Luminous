import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:luminous/core/composition/composition.dart';
import 'package:luminous/features/customizer/application/layout_store.dart';
import 'package:luminous/features/customizer/application/orchestrators/session.dart';
import 'package:luminous/features/customizer/application/usecases/edit_session.dart';
import 'package:luminous/features/customizer/domain/entities/draft.dart';
import 'package:luminous/features/customizer/domain/entities/edit.dart';

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

  @override
  LayoutDraft? build() => null;

  /// 进入编排：读现有布局生成草稿。读取失败时 use case 已回退为默认布局，
  /// 所以编排本身永远可进入——只有保存才依赖网络。
  Future<void> begin(SurfaceCatalog catalog) async {
    final initial = await StartDraft(
      ref.read(layoutRepositoryProvider),
    ).call(catalog);
    _session = EditSession(initial: initial, catalog: catalog);
    state = _session!.current;
  }

  void applyEdit(LayoutEdit edit) {
    final session = _session;
    if (session == null) return;
    session.apply(edit);
    state = session.current;
  }

  void resetToDefaults() {
    _session?.resetToDefaults();
    state = _session?.current;
  }

  void resetToInitial() {
    _session?.resetToInitial();
    state = _session?.current;
  }

  bool get isDirty => _session?.isDirty ?? false;

  /// 点「完成」：把草稿写进布局 store，页面随即按新布局重排。
  ///
  /// 写的是会话开始时那份 catalog 里的**每一个** surface：编排页虽然只显示
  /// 当前 surface，但跨 tab 面板可以把组件搬到别的 surface，只存当前这一张
  /// 会让另一半改动静默丢失。
  Future<void> commit() async {
    final session = _session;
    if (session == null) return;
    await ref.read(surfaceLayoutsProvider.notifier).commit(session.current);
  }
}
