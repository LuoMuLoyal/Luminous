import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_markdown_plus/flutter_markdown_plus.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:forui/forui.dart';
import 'package:luminous/core/config/env_keys.dart';
import 'package:luminous/core/config/env_reader.dart';
import 'package:luminous/core/design/design.dart';
import 'package:luminous/core/feedback/toast.dart';
import 'package:luminous/core/i18n/locale.dart';
import 'package:luminous/core/network/client/client_providers.dart';
import 'package:luminous/core/router/external_url_launcher.dart';
import 'package:luminous/core/widgets/common/feedback/skeleton.dart';
import 'package:luminous/core/widgets/layout/page_scaffold.dart';
import 'package:luminous/core/widgets/layout/responsive_content_frame.dart';
import 'package:luminous/features/settings/presentation/widgets/shared/section_label.dart';
import 'package:luminous/features/support/data/providers/resources.dart';
import 'package:luminous/l10n/app_localizations.dart';

class HelpSettingsPage extends ConsumerWidget {
  const HelpSettingsPage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = AppLocalizations.of(context)!;
    final locale =
        ref.watch(localeControllerProvider).asData?.value ?? AppLocale.system;

    final width = MediaQuery.sizeOf(context).width;

    final content = ResponsiveContentFrame(
      child: Padding(
        padding: EdgeInsets.symmetric(
          vertical: width < Breakpoints.mobile ? Spacing.xl2 : Spacing.xl3,
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _FaqSection(locale: locale),
            const SizedBox(height: Spacing.xl2),
            _FeedbackSection(l10n: l10n),
          ],
        ),
      ),
    );

    return PageScaffold(
      title: l10n.mineSettingHelpTitle,
      child: SingleChildScrollView(child: content),
    );
  }
}

// ---------------------------------------------------------------------------
// FAQ section — loads Markdown from assets, splits by ## headings.
// ---------------------------------------------------------------------------

class _FaqSection extends StatefulWidget {
  const _FaqSection({required this.locale});

  final AppLocale locale;

  @override
  State<_FaqSection> createState() => _FaqSectionState();
}

class _FaqSectionState extends State<_FaqSection> {
  late Future<List<_FaqItem>> _itemsFuture;

  @override
  void initState() {
    super.initState();
    _itemsFuture = _loadFaqItems();
  }

  @override
  void didUpdateWidget(covariant _FaqSection oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.locale != widget.locale) {
      _itemsFuture = _loadFaqItems();
    }
  }

  Future<List<_FaqItem>> _loadFaqItems() async {
    final suffix = widget.locale.acceptLanguage.startsWith('en')
        ? '_en'
        : '_zh';
    final content = await rootBundle.loadString('assets/faq/faq$suffix.md');
    return _parseFaqMarkdown(content);
  }

  /// Splits the FAQ Markdown by `## ` headings.
  ///
  /// The first `# ` title line is skipped. Each `## ` section becomes
  /// a [_FaqItem] where the heading text is the question and the
  /// remaining lines until the next heading are the answer.
  static List<_FaqItem> _parseFaqMarkdown(String content) {
    final lines = content.split('\n');
    final items = <_FaqItem>[];
    String? currentQuestion;
    final currentAnswer = <String>[];

    for (final line in lines) {
      if (line.startsWith('## ')) {
        if (currentQuestion != null) {
          items.add(
            _FaqItem(
              question: currentQuestion,
              answer: currentAnswer.join('\n').trim(),
            ),
          );
        }
        currentQuestion = line.substring(3).trim();
        currentAnswer.clear();
      } else if (line.startsWith('# ')) {
        // Skip the top-level title.
        continue;
      } else if (currentQuestion != null) {
        currentAnswer.add(line);
      }
    }

    if (currentQuestion != null) {
      items.add(
        _FaqItem(
          question: currentQuestion,
          answer: currentAnswer.join('\n').trim(),
        ),
      );
    }

    return items;
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        SettingsSectionLabel(label: l10n.settingsHelpFaqSectionTitle),
        SizedBox(height: context.titleContentGap),
        // 收窄问答区并让内容左缘与下方「意见反馈」卡片的内容列对齐。
        Padding(
          padding: _faqContentInset,
          child: FutureBuilder<List<_FaqItem>>(
            future: _itemsFuture,
            builder: (context, snapshot) {
              if (snapshot.connectionState != ConnectionState.done) {
                return const _FaqSkeleton();
              }
              if (snapshot.hasError || snapshot.data == null) {
                return _FaqError(
                  onRetry: () => setState(() {
                    _itemsFuture = _loadFaqItems();
                  }),
                );
              }
              final items = snapshot.data!;
              if (items.isEmpty) {
                return const SizedBox.shrink();
              }
              return _FaqAccordion(items: items);
            },
          ),
        ),
      ],
    );
  }
}

/// FAQ 内容列相对页面内容列的缩进。
///
/// 取值对齐下方 `FTileGroup` 卡片内容列所用的内边距（Forui `FTile` 的
/// `suffixedPadding`：左 15 / 右 13）：问题文字左缘对齐卡片的前缀图标，
/// chevron 右缘对齐卡片的后缀图标，使无边框的问答列表仍与卡片同处一个内容列，
/// 而不是贴到屏幕边缘。
///
/// 这是「对齐外部组件的内部几何」而非通用设计标尺，故不走 [Spacing] token
/// （该刻度没有 15/13 档）；`FTile` 内边距若调整，这里需同步。
const EdgeInsets _faqContentInset = EdgeInsets.only(left: 15, right: 13);

class _FaqItem {
  const _FaqItem({required this.question, required this.answer});

  final String question;
  final String answer;
}

/// FAQ 条目渲染。
///
/// 直接使用 Forui [FAccordion] 的官方默认样式，与 forui.dev 的 Accordion
/// 官方示例保持一致（`FAccordion(children: [...])`，不传 style override）：
/// - 标题走主题默认 `display.sm`（touch 下 16px / w500 / foreground），与示例
///   同字重同字号；不再提升到 `body.md` + w600，避免问题列表比页面标题、
///   比下方 FTileGroup 的条目标题更重；
/// - 展开内容沿用 accordion 自身的 `childTextStyle` + `childPadding`
///   （官方节奏：标题上下 16，答案距分隔线 16），不再额外叠加底部内边距；
/// - 每个问题一行标题 + chevron，点击整行展开/收起，条目间自动带分隔线；
/// - 默认所有条目收起，由受管 controller 独立管理展开状态（可同时展开多条）。
class _FaqAccordion extends StatelessWidget {
  const _FaqAccordion({required this.items});

  final List<_FaqItem> items;

  @override
  Widget build(BuildContext context) {
    return FAccordion(
      children: [
        for (final item in items)
          FAccordionItem(
            title: Text(item.question),
            child: MarkdownBody(
              data: item.answer,
              selectable: true,
              shrinkWrap: true,
              styleSheet: MarkdownStyle.legal(context),
            ),
          ),
      ],
    );
  }
}

class _FaqSkeleton extends StatelessWidget {
  const _FaqSkeleton();

  @override
  Widget build(BuildContext context) {
    return const InlineSkeleton(
      children: [
        InlineSkeletonBlock(height: 20, widthFactor: 0.7),
        InlineSkeletonBlock(height: 20, widthFactor: 0.6),
        InlineSkeletonBlock(height: 20, widthFactor: 0.75),
        InlineSkeletonBlock(height: 20, widthFactor: 0.5),
      ],
    );
  }
}

class _FaqError extends StatelessWidget {
  const _FaqError({required this.onRetry});

  final VoidCallback onRetry;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final colors = context.theme.colors;

    return Padding(
      padding: const EdgeInsets.symmetric(vertical: Spacing.lg),
      child: Row(
        children: [
          Icon(
            SemanticIcons.statusError,
            color: colors.error,
            size: IconSizeTokens.md,
          ),
          const SizedBox(width: Spacing.sm),
          Expanded(
            child: Text(
              l10n.settingsHelpFaqLoadError,
              style: context.theme.typography.body.sm.copyWith(
                color: SemanticColor.neutral.solid(context),
              ),
            ),
          ),
          FButton(
            variant: FButtonVariant.ghost,
            size: FButtonSizeVariant.xs,
            onPress: onRetry,
            child: Text(l10n.settingsHelpRetryAction),
          ),
        ],
      ),
    );
  }
}

// ---------------------------------------------------------------------------
// Feedback section — mailto via EnvReader.
// ---------------------------------------------------------------------------

class _FeedbackSection extends ConsumerWidget {
  const _FeedbackSection({required this.l10n});

  final AppLocalizations l10n;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final lastTraceId = ref.watch(lastTraceIdProvider);

    // Prefer backend supportEmail; fall back to compile-time env.
    final appInfo = ref.watch(appInfoProvider).asData?.value;
    final supportEmail =
        appInfo?.supportEmail ?? EnvReader.string(EnvKey.supportEmail);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Diagnostic block — shows the latest request Trace ID when present
        // so users can attach it to their feedback for backend correlation.
        if (lastTraceId != null && lastTraceId.isNotEmpty) ...[
          SettingsSectionLabel(label: l10n.settingsHelpTraceIdTitle),
          SizedBox(height: context.titleContentGap),
          FTileGroup(
            children: [
              FTile(
                prefix: Icon(
                  SemanticIcons.actionCopy,
                  color: SemanticColor.primary.solid(context),
                  size: IconSizeTokens.md,
                ),
                title: Text(
                  lastTraceId,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
                onPress: () {
                  unawaited(_copyTraceId(context, lastTraceId));
                },
              ),
            ],
          ),
          const SizedBox(height: Spacing.xl2),
        ],
        SettingsSectionLabel(label: l10n.settingsHelpFeedbackSectionTitle),
        SizedBox(height: context.titleContentGap),
        FTileGroup(
          children: [
            FTile(
              prefix: Icon(
                SemanticIcons.actionMessage,
                color: SemanticColor.primary.solid(context),
                size: IconSizeTokens.md,
              ),
              title: Text(l10n.mineHelpFeedbackTitle),
              subtitle: Text(
                l10n.mineHelpFeedbackSubtitle,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
              ),
              suffix: const Icon(SemanticIcons.actionExternalLink),
              onPress: () {
                unawaited(_openFeedback(context, supportEmail));
              },
            ),
          ],
        ),
      ],
    );
  }

  Future<void> _copyTraceId(BuildContext context, String traceId) async {
    await Clipboard.setData(ClipboardData(text: traceId));
    if (context.mounted) {
      unawaited(Toast.show(context, l10n.settingsHelpTraceIdCopy));
    }
  }

  Future<void> _openFeedback(BuildContext context, String email) async {
    if (email.isEmpty) {
      unawaited(Toast.show(context, l10n.settingsHelpFeedbackUnavailable));
      return;
    }

    final uri = Uri(
      scheme: 'mailto',
      path: email,
      query: 'subject=${Uri.encodeComponent(l10n.settingsHelpFeedbackSubject)}',
    );
    final ok = await const ExternalUrlLauncher().open(uri);
    if (!ok && context.mounted) {
      unawaited(Toast.show(context, l10n.settingsHelpFeedbackOpenFailed));
    }
  }
}
