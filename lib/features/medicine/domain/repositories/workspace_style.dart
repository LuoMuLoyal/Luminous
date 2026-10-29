/// Design tokens the medicine workspace repository needs, as an injectable
/// seam.
///
/// `data/` may not import `application/`, so the repository takes a token
/// provider through its constructor; `application/mappers/workspace_style.dart`
/// supplies the real one from `core/design`, and the composition root wires
/// the two together.
library;

import 'package:luminous/core/design/design.dart';
import 'package:luminous/features/medicine/domain/entities/workspace.dart';

/// Resolves the presentation tokens for workspace view models.
abstract interface class MedicineWorkspaceTokens {
  /// The plan card's primary accent.
  SemanticColor get planAccent;

  /// Colour of a plan slot's state chip.
  SemanticColor stateColor(MedicineDoseStatus status);
}
