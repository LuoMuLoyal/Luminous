import 'package:flutter/material.dart';
import 'package:forui/forui.dart';

FTileGroupStyle settingsSubpageTileGroupStyle(FThemeData theme) {
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
