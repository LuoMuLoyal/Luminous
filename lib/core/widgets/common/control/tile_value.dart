import 'package:flutter/material.dart';

/// The value slot ([FTile.details]) of a settings-style list row.
///
/// Forui lays a tile out as `[prefix] [title] ... [details] [suffix]` and gives
/// the *title* priority whenever `details` is a bare `Text`: a long label (or a
/// large text scale) then claims every pixel and the value collapses to zero
/// width. Wrapping the value in a capped, non-text widget flips that priority
/// back to the value — it is measured first and the label yields — while the
/// 55% cap still leaves the label room to be read.
///
/// Pass it as `details:` on an [FTile]; rows with no current value simply omit
/// the slot, which is what makes them read as pure navigation entries.
///
/// [FTile]: package:forui/forui.dart
class AppTileValue extends StatelessWidget {
  const AppTileValue(this.value, {super.key});

  /// The current value, e.g.「已设置」or an email address.
  final String value;

  /// Share of the tile's content width the value may claim before it ellipsizes.
  static const _maxValueWidthFactor = 0.55;

  @override
  Widget build(BuildContext context) => LayoutBuilder(
    builder: (context, constraints) => ConstrainedBox(
      constraints: BoxConstraints(
        maxWidth: constraints.maxWidth * _maxValueWidthFactor,
      ),
      child: Text(value, maxLines: 1, overflow: TextOverflow.ellipsis),
    ),
  );
}
