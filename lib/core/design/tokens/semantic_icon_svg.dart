import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';

import 'icon_size.dart';

/// AI 语义 SVG 图标注册表(iconMind 资产)
///
/// 业务代码通过 [SemanticIconSvg] 引用 iconMind 的 SVG 图标,而非直接拼
/// asset 路径。与 [SemanticIcons](IconData 字体图标)并存:AI 语义图标用
/// SVG(iconMind 提供 Lucide 没有的 AI 专业词汇),通用图标仍走
/// [SemanticIcons]。
///
/// 每个图标返回 [Widget](内置 [SvgPicture.asset]),调用方传入 size/color。
/// 资产目录 `assets/icon/iconmind/`,来源 iconMind v0.8.1(MIT,见同目录
/// LICENSE)。
abstract final class SemanticIconSvg {
  static const String _base = 'assets/icon/iconmind';

  /// 绘制一个 iconMind SVG 图标。
  ///
  /// [size] 默认 [IconSizeTokens.md](20)。SVG 内部是 `stroke="currentColor"`,
  /// 经 [SvgPicture.colorFilter] 染色,因此 [color] 传入图标笔画色;不传时
  /// 跟随主题的 IconTheme。
  static Widget icon(
    String asset, {
    double size = IconSizeTokens.md,
    Color? color,
    BoxFit fit = BoxFit.contain,
  }) {
    return SvgPicture.asset(
      '$_base/$asset.svg',
      width: size,
      height: size,
      colorFilter: color == null
          ? null
          : ColorFilter.mode(color, BlendMode.srcIn),
      fit: fit,
    );
  }

  // ================================================================
  // AI 入口 / 助手 / 生成中
  // ================================================================
  /// 通用 AI 入口(替代 [SemanticIcons.aiEntry] 的 sparkles)。
  static Widget aiEntry({double size = IconSizeTokens.md, Color? color}) =>
      icon('llm', size: size, color: color);

  /// AI 分析中 / 思考中(替代 [SemanticIcons.aiAnalyzing] 的 loaderCircle)。
  static Widget aiAnalyzing({double size = IconSizeTokens.md, Color? color}) =>
      icon('agent-thinking', size: size, color: color);

  /// AI 生成结果(替代 [SemanticIcons.aiGenerated] 的 bot)。
  static Widget aiGenerated({double size = IconSizeTokens.md, Color? color}) =>
      icon('agent', size: size, color: color);

  /// AI 建议(替代 [SemanticIcons.aiSuggestion] 的 brain)。
  static Widget aiSuggestion({double size = IconSizeTokens.md, Color? color}) =>
      icon('brain', size: size, color: color);

  /// AI 提示 / 洞察(替代 [SemanticIcons.aiTip] 的 lightbulb)。
  static Widget aiTip({double size = IconSizeTokens.md, Color? color}) =>
      icon('idea-bulb', size: size, color: color);

  /// 助手对话 / 消息(替代 messageSquare)。
  static Widget aiMessage({double size = IconSizeTokens.md, Color? color}) =>
      icon('message-thread', size: size, color: color);

  // ================================================================
  // 能力面板 / 上下文
  // ================================================================
  /// 记忆(assistant 记忆开关)。
  static Widget aiMemory({double size = IconSizeTokens.md, Color? color}) =>
      icon('memory', size: size, color: color);

  /// 记忆读取 / 检索。
  static Widget aiMemoryRead({double size = IconSizeTokens.md, Color? color}) =>
      icon('memory-read', size: size, color: color);

  /// 记忆写入。
  static Widget aiMemoryWrite({
    double size = IconSizeTokens.md,
    Color? color,
  }) => icon('memory-write', size: size, color: color);

  /// 知识库 / RAG 向量库。
  static Widget aiKnowledge({double size = IconSizeTokens.md, Color? color}) =>
      icon('vector-database', size: size, color: color);

  /// 知识图谱。
  static Widget aiKnowledgeGraph({
    double size = IconSizeTokens.md,
    Color? color,
  }) => icon('knowledge-graph', size: size, color: color);

  /// 检索器 / 召回。
  static Widget aiRetriever({double size = IconSizeTokens.md, Color? color}) =>
      icon('retriever', size: size, color: color);

  /// 重排序。
  static Widget aiReranker({double size = IconSizeTokens.md, Color? color}) =>
      icon('reranker', size: size, color: color);

  /// 引用 / 溯源。
  static Widget aiCitation({double size = IconSizeTokens.md, Color? color}) =>
      icon('citation', size: size, color: color);

  /// 语义搜索。
  static Widget aiSemanticSearch({
    double size = IconSizeTokens.md,
    Color? color,
  }) => icon('semantic-search', size: size, color: color);

  /// RAG 管线。
  static Widget aiRagPipeline({
    double size = IconSizeTokens.md,
    Color? color,
  }) => icon('rag-pipeline', size: size, color: color);

  // ================================================================
  // 工具 / MCP / 模型
  // ================================================================
  /// 工具调用。
  static Widget aiToolCalling({
    double size = IconSizeTokens.md,
    Color? color,
  }) => icon('tool-calling', size: size, color: color);

  /// MCP 服务器。
  static Widget aiMcpServer({double size = IconSizeTokens.md, Color? color}) =>
      icon('mcp-server', size: size, color: color);

  /// MCP 工具。
  static Widget aiMcpTool({double size = IconSizeTokens.md, Color? color}) =>
      icon('mcp-tool', size: size, color: color);

  /// 上下文窗口。
  static Widget aiContextWindow({
    double size = IconSizeTokens.md,
    Color? color,
  }) => icon('context-window', size: size, color: color);

  /// 系统提示词。
  static Widget aiSystemPrompt({
    double size = IconSizeTokens.md,
    Color? color,
  }) => icon('system-prompt', size: size, color: color);

  /// Token / 计费。
  static Widget aiToken({double size = IconSizeTokens.md, Color? color}) =>
      icon('token', size: size, color: color);

  /// 流式响应。
  static Widget aiStreaming({double size = IconSizeTokens.md, Color? color}) =>
      icon('streaming-response', size: size, color: color);

  /// 停止原因 / 状态。
  static Widget aiStopReason({double size = IconSizeTokens.md, Color? color}) =>
      icon('stop-reason', size: size, color: color);

  /// 护栏 / 安全。
  static Widget aiGuardrail({double size = IconSizeTokens.md, Color? color}) =>
      icon('guardrail', size: size, color: color);

  /// 置信度。
  static Widget aiConfidence({double size = IconSizeTokens.md, Color? color}) =>
      icon('confidence', size: size, color: color);

  /// 幻觉检测。
  static Widget aiHallucination({
    double size = IconSizeTokens.md,
    Color? color,
  }) => icon('hallucination', size: size, color: color);

  /// 推理追踪。
  static Widget aiReasoningTrace({
    double size = IconSizeTokens.md,
    Color? color,
  }) => icon('reasoning-trace', size: size, color: color);

  /// 思维链。
  static Widget aiChainOfThought({
    double size = IconSizeTokens.md,
    Color? color,
  }) => icon('chain-of-thought', size: size, color: color);

  /// 评估。
  static Widget aiEvaluation({double size = IconSizeTokens.md, Color? color}) =>
      icon('evaluation', size: size, color: color);

  /// 准确率。
  static Widget aiAccuracy({double size = IconSizeTokens.md, Color? color}) =>
      icon('accuracy', size: size, color: color);

  /// 基准测试。
  static Widget aiBenchmark({double size = IconSizeTokens.md, Color? color}) =>
      icon('benchmark', size: size, color: color);

  /// 重试。
  static Widget aiRetry({double size = IconSizeTokens.md, Color? color}) =>
      icon('retry', size: size, color: color);
}
