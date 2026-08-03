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
import 'package:luminous/core/network/client_providers.dart';
import 'package:luminous/core/router/external_url_launcher.dart';
import 'package:luminous/core/widgets/common/divider.dart';
import 'package:luminous/core/widgets/common/skeleton.dart';
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
          vertical: width < Breakpoints.mobile
              ? Spacing.level6
              : Spacing.level7,
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _FaqSection(locale: locale),
            const SizedBox(height: Spacing.level6),
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
        const SizedBox(height: Spacing.level3),
        FutureBuilder<List<_FaqItem>>(
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
            return Column(
              children: [
                for (int i = 0; i < items.length; i++) ...[
                  _FaqTile(item: items[i]),
                  if (i < items.length - 1) const AppDivider(),
                ],
              ],
            );
          },
        ),
      ],
    );
  }
}

class _FaqItem {
  const _FaqItem({required this.question, required this.answer});

  final String question;
  final String answer;
}

class _FaqTile extends StatefulWidget {
  const _FaqTile({required this.item});

  final _FaqItem item;

  @override
  State<_FaqTile> createState() => _FaqTileState();
}

class _FaqTileState extends State<_FaqTile>
    with SingleTickerProviderStateMixin {
  late final AnimationController _controller;
  late final Animation<double> _animation;
  bool _expanded = false;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      duration: DurationTokens.widgetQuick,
      vsync: this,
    );
    _animation = CurvedAnimation(parent: _controller, curve: Curves.easeInOut);
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  void _toggle() {
    setState(() => _expanded = !_expanded);
    if (_expanded) {
      unawaited(_controller.forward());
    } else {
      unawaited(_controller.reverse());
    }
  }

  @override
  Widget build(BuildContext context) {
    final colors = context.theme.colors;

    return FTappable(
      onPress: _toggle,
      child: Padding(
        padding: const EdgeInsets.symmetric(
          vertical: Spacing.level4,
          horizontal: Spacing.level1,
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Expanded(
                  child: Text(
                    widget.item.question,
                    style: TypographyToken.level5
                        .body(context)
                        .copyWith(fontWeight: FontWeight.w600),
                  ),
                ),
                const SizedBox(width: Spacing.level3),
                AnimatedRotation(
                  turns: _expanded ? 0.25 : 0,
                  duration: DurationTokens.widgetQuick,
                  child: Icon(
                    SemanticIcons.actionNext,
                    size: IconSizeTokens.level3,
                    color: colors.mutedForeground,
                  ),
                ),
              ],
            ),
            AnimatedBuilder(
              animation: _animation,
              builder: (context, child) =>
                  FCollapsible(value: _animation.value, child: child!),
              child: Padding(
                padding: const EdgeInsets.only(top: Spacing.level3),
                child: MarkdownBody(
                  data: widget.item.answer,
                  selectable: true,
                  shrinkWrap: true,
                  styleSheet: MarkdownStyle.legal(context),
                ),
              ),
            ),
          ],
        ),
      ),
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
      padding: const EdgeInsets.symmetric(vertical: Spacing.level4),
      child: Row(
        children: [
          Icon(SemanticIcons.statusError, color: colors.error, size: 20),
          const SizedBox(width: Spacing.level2),
          Expanded(
            child: Text(
              l10n.settingsHelpFaqLoadError,
              style: TypographyToken.level4
                  .body(context)
                  .copyWith(color: colors.mutedForeground),
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
    final colors = context.theme.colors;
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
          const SizedBox(height: Spacing.level3),
          FTileGroup(
            children: [
              FTile(
                prefix: Icon(
                  SemanticIcons.actionCopy,
                  color: colors.primary,
                  size: Spacing.level5,
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
          const SizedBox(height: Spacing.level6),
        ],
        SettingsSectionLabel(label: l10n.settingsHelpFeedbackSectionTitle),
        const SizedBox(height: Spacing.level3),
        FTileGroup(
          children: [
            FTile(
              prefix: Icon(
                SemanticIcons.actionMessage,
                color: colors.primary,
                size: Spacing.level5,
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
