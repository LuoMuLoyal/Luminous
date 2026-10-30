import 'package:luminous/core/composition/composition.dart';
import 'package:luminous/features/customizer/domain/entities/draft.dart';
import 'package:luminous/features/customizer/domain/entities/edit.dart';
import 'package:luminous/features/customizer/domain/services/draft_rules.dart';

/// 编排会话：进入 → 一系列编辑 → 提交或取消。
///
/// 收在一处的理由：UI 只需表达"用户做了什么"，不该知道什么时候读、什么时候写、
/// 什么时候回退默认。编排页因此只是一块哑 UI。
class EditSession {
  EditSession({required this.initial, required this.catalog})
    : _current = initial;

  /// 进入时的快照，用于「恢复默认」。
  final LayoutDraft initial;

  final SurfaceCatalog catalog;

  LayoutDraft _current;

  LayoutDraft get current => _current;

  /// 会话内是否有未提交改动。
  bool get isDirty => _current != initial;

  /// 应用一次编辑。非法编辑由 [applyEdit] 拒绝并返回原草稿。
  void apply(LayoutEdit edit) {
    _current = applyEdit(_current, edit, catalog);
  }

  /// 丢弃全部改动，回到进来时的样子。
  void resetToInitial() {
    _current = initial;
  }

  /// 恢复到各 surface 的出厂默认布局。
  void resetToDefaults() {
    _current = LayoutDraft(
      surfaces: {
        for (final definition in catalog.definitions)
          definition.surface: definition.defaultLayout,
      },
    );
  }
}
