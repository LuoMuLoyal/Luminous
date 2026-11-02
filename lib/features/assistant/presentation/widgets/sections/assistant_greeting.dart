import 'package:flutter/material.dart';
import 'package:forui/forui.dart';
import 'package:luminous/core/design/design.dart';

/// Assistant 欢迎区 headline:图标 + 文案。
///
/// 宽屏图标(40px)+ 文本并排底对齐,窄屏上下堆叠。glyph 使用
/// [SemanticIcons.aiGenerated];颜色与字号取自 Forui 主题 token
/// (`context.theme.colors` / `context.theme.typography.display`)。
class AssistantSvgGreeting extends StatelessWidget {
  const AssistantSvgGreeting({super.key, required this.text});

  final String text;

  static const double _iconSize = 40;
  static const double _wideGap = 16;
  static const double _narrowGap = 4;
  static const double _narrowFontSize = 21;
  static const double _compactBreakpoint = 600;

  @override
  Widget build(BuildContext context) {
    final colors = context.theme.colors;

    return LayoutBuilder(
      builder: (context, constraints) {
        final compact = constraints.maxWidth < _compactBreakpoint;
        final style = context.theme.typography.display.xl3.copyWith(
          color: colors.foreground,
          fontSize: compact ? _narrowFontSize : null,
        );
        final label = Text(text, style: style, textAlign: TextAlign.center);
        final glyph = Icon(
          SemanticIcons.aiGenerated,
          size: _iconSize,
          color: colors.primary,
        );
        if (compact) {
          return Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              glyph,
              const SizedBox(height: _narrowGap),
              label,
            ],
          );
        }
        return Row(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.end,
          children: [
            glyph,
            const SizedBox(width: _wideGap),
            label,
          ],
        );
      },
    );
  }
}
