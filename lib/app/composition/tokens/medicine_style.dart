import 'package:luminous/features/medicine/domain/entities/workspace.dart';
import 'package:luminous/shared/design/medicine_workspace.dart';

/// Design tokens for the medicine workspace view models.
///
/// The workspace repository maps wire data; icon/colour tokens are a
/// presentation concern, so it receives this table through its constructor
/// instead of importing `core/design` from `data/`.
final class MedicineWorkspaceStyle implements MedicineWorkspaceTokens {
  const MedicineWorkspaceStyle();

  @override
  SemanticColor get planAccent => SemanticColor.primary;

  @override
  SemanticColor stateColor(MedicineDoseStatus status) {
    return switch (status) {
      MedicineDoseStatus.taken => SemanticColor.success,
      MedicineDoseStatus.skipped => SemanticColor.neutral,
      MedicineDoseStatus.pending => SemanticColor.warning,
    };
  }
}
