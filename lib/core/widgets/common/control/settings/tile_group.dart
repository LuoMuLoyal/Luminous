import 'package:forui/forui.dart';
import 'package:material_ui/material_ui.dart';

/// Tile-group style for grouped sub-pages: card-coloured rows on the page
/// background instead of the default tile fill.
FTileGroupStyle settingsTileGroup(FThemeData theme) {
  final base = theme.tileGroupStyle;

  return base.copyWith(
    tileStyles: .delta([
      .all(
        .delta(
          contentDecoration: .delta([
            .base(
              .shapeDelta(
                color: theme.colors.card,
                shape: RoundedRectangleBorder(
                  borderRadius: theme.style.borderRadius.md,
                ),
              ),
            ),
          ]),
        ),
      ),
    ]),
  );
}
