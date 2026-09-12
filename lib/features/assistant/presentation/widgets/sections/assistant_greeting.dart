import 'package:flow_ui/flow_ui.dart';
import 'package:flutter/material.dart';
import 'package:luminous/core/design/design.dart';

/// Assistant 欢迎区 headline:SVG 版 [FlowGreeting]。
///
/// flow_ui 的 [FlowGreeting] 只接受 [IconData],而 assistant 欢迎区要放
/// iconMind 的 SVG AI 图标,因此此处自渲染一个同布局的 greeting:宽屏
/// 图标(40px)+ 文本并排底对齐,窄屏上下堆叠 —— 与 flow_ui 的默认视觉
/// 保持一致(40px glyph / 16 间隔 / 32px 文本,compact 下 21px 文本 / 4
/// 间隔),只是 glyph 换成 [SemanticIconSvg.aiGenerated]。
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
    final flowColors = context.flowColors;

    return LayoutBuilder(
      builder: (context, constraints) {
        final compact = constraints.maxWidth < _compactBreakpoint;
        final style = context.flowTypography.headlineLarge.copyWith(
          color: flowColors.onSurface,
          fontSize: compact ? _narrowFontSize : null,
        );
        final label = Text(text, style: style, textAlign: TextAlign.center);
        final glyph = SemanticIconSvg.aiGenerated(
          size: _iconSize,
          color: flowColors.primary,
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
