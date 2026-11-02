import 'dart:async';

import 'package:flutter/widgets.dart';
import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:forui/forui.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:luminous/core/design/design.dart';
import 'package:luminous/features/generative/domain/entities/slot_spec.dart';
import 'package:luminous/features/generative/presentation/providers/slot_spec.dart';
import 'package:luminous/l10n/app_localizations.dart';
import 'package:luminous/shared/domain/composition/surface.dart';

/// 编排页里「自定义生成式区块」的编辑面板。
///
/// ## 为什么入口在编排页，不在页面上
///
/// 生成式组件不是「页面上随手的输入框」，而是一个**用户配置过的区块**：
/// 它有自己的名字、有自己的长期意图（「把每日饮水做成三张并排的小卡」），
/// 并且和别的组件一样参与排序、显隐与持久化。把输入框放在页面里，等于让
/// 每次渲染都从零开始问一遍「这里要显示什么」——那是一次性的提问，不是
/// 一份持续的配置。
///
/// 所以：编排页负责**声明**（标题 + 让 agent 渲染什么），页面只负责**呈现**。
///
/// ## 为什么保存后还要能改、能清
///
/// 用户可能「恢复默认布局」之后仍想保留这个区块，所以声明独立于布局持久化
/// （`genui.<surface>.spec`），不跟着布局一起被重置。而「清掉」是明确放弃
/// 这份声明：清完那一行回到「未配置」，下次再配就是重新开始。
class GenerativeSlotSheet extends HookConsumerWidget {
  const GenerativeSlotSheet({super.key, required this.surface});

  final SurfaceId surface;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = AppLocalizations.of(context)!;
    final existing = ref.watch(generativeSlotSpecProvider(surface));
    final titleController = useTextEditingController(
      text: existing?.title ?? '',
    );
    final promptController = useTextEditingController(
      text: existing?.prompt ?? '',
    );
    final typography = context.theme.typography;

    bool canSave() =>
        titleController.text.trim().isNotEmpty &&
        promptController.text.trim().isNotEmpty;

    Future<void> save() async {
      if (!canSave()) return;
      await ref
          .read(generativeSlotSpecProvider(surface).notifier)
          .save(
            GenerativeSlotSpec(
              title: titleController.text.trim(),
              prompt: promptController.text.trim(),
            ),
          );
      if (context.mounted) Navigator.of(context).pop();
    }

    return Padding(
      padding: EdgeInsets.only(
        left: Spacing.xl2,
        right: Spacing.xl2,
        top: Spacing.md,
        bottom: MediaQuery.viewInsetsOf(context).bottom + Spacing.xl2,
      ),
      child: SingleChildScrollView(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            // 标题与说明：这一段是整个面板存在的原因，先说清楚它是什么。
            Text(
              l10n.generativeSlotSheetTitle,
              style: typography.body.lg.copyWith(fontWeight: FontWeight.w600),
            ),
            const SizedBox(height: Spacing.xs),
            Text(
              l10n.generativeSlotSheetDescription,
              style: typography.body.xs.copyWith(
                color: SemanticColor.neutral.solid(context),
              ),
            ),
            const SizedBox(height: Spacing.xl),
            FTextField(
              control: FTextFieldControl.managed(controller: titleController),
              label: Text(l10n.generativeSlotTitleLabel),
              hint: l10n.generativeSlotTitleHint,
            ),
            const SizedBox(height: Spacing.lg),
            FTextField(
              control: FTextFieldControl.managed(controller: promptController),
              label: Text(l10n.generativeSlotPromptLabel),
              hint: l10n.generativeSlotPromptHint,
              maxLines: 4,
            ),
            const SizedBox(height: Spacing.xl),
            // 保存按钮的可用性跟着输入走：`FTextField` 没有 onChange，
            // 用 `ListenableBuilder` 监听控制器，避免为了刷新按钮重建整页。
            ListenableBuilder(
              listenable: Listenable.merge([titleController, promptController]),
              builder: (context, _) {
                final enabled = canSave();
                return Row(
                  children: [
                    if (existing != null)
                      Expanded(
                        child: FButton(
                          variant: FButtonVariant.outline,
                          onPress: () async {
                            await ref
                                .read(
                                  generativeSlotSpecProvider(surface).notifier,
                                )
                                .clear();
                            if (context.mounted) Navigator.of(context).pop();
                          },
                          child: Text(
                            l10n.generativeSlotClearAction,
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                      ),
                    if (existing != null) const SizedBox(width: Spacing.md),
                    Expanded(
                      child: FButton(
                        onPress: enabled ? () => unawaited(save()) : null,
                        child: Text(
                          l10n.generativeSlotSaveAction,
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                    ),
                  ],
                );
              },
            ),
          ],
        ),
      ),
    );
  }
}
