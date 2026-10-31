import 'dart:async';

import 'package:flutter/widgets.dart';
import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:forui/forui.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:luminous/core/design/design.dart';
import 'package:luminous/features/generative/domain/entities/generation.dart';
import 'package:luminous/features/generative/presentation/components/catalog.dart'
    show generativeSurfaces;
import 'package:luminous/features/generative/presentation/providers/generation.dart';
import 'package:luminous/features/generative/presentation/providers/surface_state.dart';
import 'package:luminous/l10n/app_localizations.dart';
import 'package:luminous/shared/domain/composition/surface.dart';

/// 生成式 UI 的触发入口：一句指示 → 一次生成。
///
/// 它是 [GenerativeSurface] 的**前置**，与三态渲染分开：
/// - 从没生成过 → 显示入口（按钮 + 空态说明），而不是什么都不显示。A7a 的
///   「无结果就不占位」在没有触发入口时是自洽的；A7b 之后必须有东西让用户点，
///   否则这个能力用户永远够不到。
/// - 已有结果 → 入口退化成「重新编排」，落在渲染区块的上方。
///
/// 文案全部走 ARB：界面框架的语言由客户端决定，生成**内容**的语言由服务端按
/// `Accept-Language` 决定，两者互不越界。
class GenerativeComposeEntry extends HookConsumerWidget {
  const GenerativeComposeEntry({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = AppLocalizations.of(context)!;
    final surface = ref.watch(generativeSurfaceIdProvider);
    final state = ref.watch(generativeStateProvider);
    final controller = useTextEditingController();
    final typography = context.theme.typography;

    // 生成中不允许重复触发：一次生成是一次 LLM 调用，重复点会并发烧两次。
    final inFlight = state is GenerationInFlight;

    Future<void> submit() async {
      final prompt = controller.text.trim();
      if (prompt.isEmpty) return;
      controller.clear();
      await ref.read(generativeActionsProvider).generate(prompt: prompt);
    }

    final hasResult = switch (state) {
      GenerationReady() => true,
      GenerationFailed(:final document) => document != null,
      GenerationIdle() || GenerationInFlight() => false,
    };

    // `tab_chrome` 是底部栏，不是页面，服务端会以 400
    // `GENERATIVE_SURFACE_UNSUPPORTED` 拒绝。客户端在这里就不给入口，省一次
    // 往返、也不让用户看到一个点下去必然失败的按钮。
    if (!isComposableSurface(surface)) return const SizedBox.shrink();

    return Column(
      key: const Key('generative-compose-entry'),
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        if (!hasResult) ...[
          Text(
            l10n.generativeEmptyMessage,
            style: typography.body.sm.copyWith(
              color: SemanticColor.neutral.solid(context),
            ),
          ),
          const SizedBox(height: Spacing.sm),
        ],
        Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Expanded(
              child: FTextField(
                control: FTextFieldControl.managed(controller: controller),
                label: Text(l10n.generativePromptLabel),
                hint: l10n.generativePromptHint,
                enabled: !inFlight,
                // 键盘回车即提交：输入一句短指示是主要用法，多一次点击没有收益。
                onSubmit: (value) => unawaited(submit()),
              ),
            ),
          ],
        ),
        const SizedBox(height: Spacing.sm),
        Align(
          alignment: AlignmentDirectional.centerEnd,
          child: FButton(
            onPress: inFlight ? null : submit,
            child: Text(
              hasResult
                  ? l10n.generativeRegenerateAction
                  : l10n.generativeGenerateAction,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
            ),
          ),
        ),
      ],
    );
  }
}

/// surface 是否还能继续生成（`tab_chrome` 不是页面，不参与生成）。
///
/// 与服务端 `GENERATIVE_SURFACES` 对齐，判定依据是 [generativeSurfaces] 这份
/// 共享清单——不在这里重复写 `surface != SurfaceId.tabChrome`，否则注册逻辑与
/// 入口判断会各有一份「哪些 surface 可生成」的答案，迟早漂移。
bool isComposableSurface(SurfaceId surface) =>
    generativeSurfaces.contains(surface);
