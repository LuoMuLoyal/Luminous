import 'dart:async';

import 'package:clock/clock.dart';
import 'package:flutter/material.dart';
import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:forui/forui.dart';
import 'package:go_router/go_router.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:luminous/app/router.dart';
import 'package:luminous/core/auth/session_provider.dart';
import 'package:luminous/core/design/design.dart';
import 'package:luminous/core/feedback/toast.dart';
import 'package:luminous/core/widgets/common/back_button.dart';
import 'package:luminous/core/widgets/common/dialog_shell.dart';
import 'package:luminous/core/widgets/common/state_views.dart';
import 'package:luminous/core/widgets/layout/page_scaffold.dart';
import 'package:luminous/core/widgets/layout/responsive_content_frame.dart';
import 'package:luminous/features/auth/presentation/widgets/shared/required_dialog.dart';
import 'package:luminous/features/record/application/usecases/record_detail_actions.dart';
import 'package:luminous/features/record/domain/entities/record.dart';
import 'package:luminous/features/record/presentation/providers/record_edit_controller.dart';
import 'package:luminous/features/record/presentation/utils/date_time_formatters.dart';
import 'package:luminous/features/record/presentation/widgets/forms/edit_actions.dart';
import 'package:luminous/features/record/presentation/widgets/forms/form_fields.dart';
import 'package:luminous/features/record/presentation/widgets/forms/image_attachment_field.dart';
import 'package:luminous/features/record/presentation/widgets/forms/kind_icon_field.dart';
import 'package:luminous/features/record/presentation/widgets/forms/meal_confirm_action.dart';
import 'package:luminous/features/record/presentation/widgets/forms/occurred_at_fields.dart';
import 'package:luminous/features/record/presentation/widgets/forms/sleep_structured_fields.dart';
import 'package:luminous/features/record/presentation/widgets/meal/dish_editor.dart';
import 'package:luminous/l10n/app_localizations.dart';

class RecordEditPage extends HookConsumerWidget {
  const RecordEditPage({super.key, required this.recordId});

  final String recordId;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = AppLocalizations.of(context)!;
    final state = ref.watch(recordEditControllerProvider);
    final controller = ref.read(recordEditControllerProvider.notifier);

    final valueController = useTextEditingController();
    final unitController = useTextEditingController();
    final noteController = useTextEditingController();
    final titleController = useTextEditingController();

    // Rebuild on every text change so dirty detection stays current.
    final rebuildTick = useState(0);
    useEffect(() {
      void onEdit() => rebuildTick.value++;
      for (final controller in [
        valueController,
        unitController,
        noteController,
        titleController,
      ]) {
        controller.addListener(onEdit);
      }
      return () {
        for (final controller in [
          valueController,
          unitController,
          noteController,
          titleController,
        ]) {
          controller.removeListener(onEdit);
        }
      };
    }, [valueController, unitController, noteController, titleController]);

    final session = ref.watch(authSessionProvider);

    // Load the record once when signed in and not already loading/loaded.
    useEffect(
      () {
        if (session.canAccessProtectedData &&
            !state.loading &&
            !state.loaded &&
            !state.loadFailed) {
          WidgetsBinding.instance.addPostFrameCallback((_) {
            if (context.mounted) unawaited(controller.load(recordId));
          });
        }
        return null;
      },
      [
        session.canAccessProtectedData,
        state.loading,
        state.loaded,
        state.loadFailed,
      ],
    );

    // Sync text controllers once the record has loaded.
    useEffect(
      () {
        if (!state.loaded) return null;
        valueController.text = state.initialValue;
        unitController.text = state.initialUnit;
        titleController.text = state.initialTitle;
        noteController.text = state.initialNote;
        return null;
      },
      [
        state.loaded,
        state.initialValue,
        state.initialUnit,
        state.initialTitle,
        state.initialNote,
      ],
    );

    final dirty = controller.isDirty(
      value: valueController.text,
      unit: unitController.text,
      title: titleController.text,
      note: noteController.text,
    );

    void onKindChanged(DailyRecordKind newKind) {
      final wasWater = state.kind == DailyRecordKind.water;
      controller.setKind(newKind);
      if (newKind != DailyRecordKind.water &&
          wasWater &&
          unitController.text.trim() == dailyRecordWaterDefaultUnit) {
        unitController.clear();
      }
      if (newKind == DailyRecordKind.water &&
          unitController.text.trim().isEmpty) {
        unitController.text = dailyRecordWaterDefaultUnit;
      }
    }

    Future<void> onSave() async {
      final result = await controller.save(
        recordId,
        value: valueController.text,
        unit: unitController.text,
        title: titleController.text,
        note: noteController.text,
        occurredTime: state.occurredTime,
      );
      if (!context.mounted) return;
      switch (result) {
        case RecordEditSaveResult.saved:
          await Toast.show(context, l10n.mineEditSavedToast);
          if (context.mounted) _popOrGoHome(context);
        case RecordEditSaveResult.invalidSleep:
          await Toast.show(context, l10n.recordSleepInvalidValueToast);
        case RecordEditSaveResult.failed:
          await Toast.show(context, l10n.recordCreateFailedToast);
      }
    }

    Future<void> onDelete() => deleteRecord(
      ref: ref,
      context: context,
      recordId: recordId,
      popCount: 2,
    );

    Future<void> handleBack() async {
      if (!dirty) {
        _popOrGoHome(context);
        return;
      }
      final leave = await _confirmDiscard(context, l10n);
      if (leave == true && context.mounted) {
        _popOrGoHome(context);
      }
    }

    final Widget content;

    if (!session.canAccessProtectedData) {
      final width = MediaQuery.sizeOf(context).width;
      content = ResponsiveContentFrame(
        child: Padding(
          padding: EdgeInsets.symmetric(
            vertical: width < Breakpoints.mobile
                ? Spacing.level6
                : Spacing.level7,
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              session.isLoading
                  ? const _RecordEditLoading()
                  : AuthRequiredDialogGate(
                      onLogin: () =>
                          context.push(loginRouteForCurrentLocation(context)),
                    ),
            ],
          ),
        ),
      );
    } else if (state.loadFailed) {
      final width = MediaQuery.sizeOf(context).width;
      content = ResponsiveContentFrame(
        child: Padding(
          padding: EdgeInsets.symmetric(
            vertical: width < Breakpoints.mobile
                ? Spacing.level6
                : Spacing.level7,
          ),
          child: StateErrorView(
            title: l10n.recordDetailErrorTitle,
            description: l10n.recordErrorDescription,
            icon: SemanticIcons.tabRecord,
            actionLabel: l10n.todayRetryAction,
            onAction: () => controller.load(recordId),
            tone: StateTone.warning,
          ),
        ),
      );
    } else if (!state.loaded) {
      final width = MediaQuery.sizeOf(context).width;
      content = ResponsiveContentFrame(
        child: Padding(
          padding: EdgeInsets.symmetric(
            vertical: width < Breakpoints.mobile
                ? Spacing.level6
                : Spacing.level7,
          ),
          child: const Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [_RecordEditLoading()],
          ),
        ),
      );
    } else {
      final width = MediaQuery.sizeOf(context).width;
      content = ResponsiveContentFrame(
        child: Padding(
          padding: EdgeInsets.symmetric(
            vertical: width < Breakpoints.mobile
                ? Spacing.level6
                : Spacing.level7,
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: Spacing.level4),
                child: _EditStatusHint(dirty: dirty, l10n: l10n),
              ),
              const SizedBox(height: Spacing.level2),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: Spacing.level4),
                child: DecoratedBox(
                  decoration: BoxDecoration(
                    color: context.theme.colors.secondary,
                    borderRadius: context.theme.style.borderRadius.sm,
                  ),
                  child: Padding(
                    padding: const EdgeInsets.all(Spacing.level4),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      children: [
                        RecordOccurredAtFields(
                          date: state.occurredAt ?? clock.now(),
                          time: state.occurredTime,
                          onDateChanged: (date) => controller.setOccurredAt(
                            DateTime(
                              date.year,
                              date.month,
                              date.day,
                              state.occurredAt?.hour ?? clock.now().hour,
                              state.occurredAt?.minute ?? clock.now().minute,
                            ),
                          ),
                          onTimeChanged: (time) {
                            if (time == null) {
                              controller.setOccurredAt(
                                state.occurredAt,
                                time: null,
                              );
                              return;
                            }
                            controller.setOccurredAt(
                              DateTime(
                                state.occurredAt?.year ?? clock.now().year,
                                state.occurredAt?.month ?? clock.now().month,
                                state.occurredAt?.day ?? clock.now().day,
                                time.hour,
                                time.minute,
                              ),
                              time: formatHourMinute(time.hour, time.minute),
                            );
                          },
                        ),
                        const SizedBox(height: Spacing.level3),
                        DailyRecordFormFields(
                          kind: state.kind,
                          onKindChanged: onKindChanged,
                          showKindField: false,
                          valueController: valueController,
                          unitController: unitController,
                          titleController: titleController,
                          noteController: noteController,
                        ),
                        const SizedBox(height: Spacing.level3),
                        RecordKindIconField(kind: state.kind),
                        if (state.kind == DailyRecordKind.sleep) ...[
                          const SizedBox(height: Spacing.level3),
                          SleepStructuredFields(
                            l10n: l10n,
                            bedtime: state.bedtime,
                            wakeTime: state.wakeTime,
                            quality: state.sleepQuality,
                            deepMinutes: state.deepMinutes,
                            lightMinutes: state.lightMinutes,
                            remMinutes: state.remMinutes,
                            onBedtimeChanged: controller.setBedtime,
                            onWakeTimeChanged: controller.setWakeTime,
                            onQualityChanged: controller.setSleepQuality,
                            onDeepMinutesChanged: controller.setDeepMinutes,
                            onLightMinutesChanged: controller.setLightMinutes,
                            onRemMinutesChanged: controller.setRemMinutes,
                          ),
                        ],
                        if (state.kind == DailyRecordKind.meal) ...[
                          const SizedBox(height: Spacing.level3),
                          MealDishEditorSection(
                            dishNames: state.dishNames,
                            enabled: !state.saving && !state.deleting,
                            onDishChanged: controller.setDishName,
                            onDishRemoved: controller.removeDish,
                            onDishAdded: controller.addDish,
                          ),
                          if (state.canConfirmMealAnalysis) ...[
                            const SizedBox(height: Spacing.level3),
                            MealConfirmAction(
                              l10n: l10n,
                              confirmed: state.confirmMealAnalysis,
                              onToggle: () => controller.setConfirmMealAnalysis(
                                !state.confirmMealAnalysis,
                              ),
                            ),
                          ],
                        ],
                        const SizedBox(height: Spacing.level3),
                        DailyRecordImageAttachmentField(
                          l10n: l10n,
                          selectedBytes: state.selectedImage?.bytes,
                          selectedFileName: state.selectedImage?.fileName,
                          existingAttachment: state.attachmentsChanged
                              ? null
                              : state.existingImageAttachment,
                          onPick: () => unawaited(controller.pickImage()),
                          onRemove: controller.removeImage,
                          enabled: !state.saving && !state.deleting,
                        ),
                        RecordEditActions(
                          l10n: l10n,
                          saving: state.saving,
                          deleting: state.deleting,
                          onSave: onSave,
                          onDelete: onDelete,
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      );
    }

    return PopScope(
      canPop: !dirty || !state.loaded,
      onPopInvokedWithResult: (didPop, result) {
        if (didPop || !state.loaded) return;
        unawaited(handleBack());
      },
      child: PageScaffold(
        title: l10n.recordEditAction,
        leading: AppBackButton(onPressed: () => unawaited(handleBack())),
        child: SingleChildScrollView(child: content),
      ),
    );
  }
}

void _popOrGoHome(BuildContext context) {
  if (GoRouter.of(context).canPop()) {
    context.pop();
  } else {
    context.go(Routes.home);
  }
}

/// Shows a discard-confirmation dialog; returns `true` when the user agrees
/// to leave without saving.
Future<bool?> _confirmDiscard(BuildContext context, AppLocalizations l10n) {
  return showAppDialog<bool>(
    context: context,
    scrollable: false,
    builder: (dialogContext) => Column(
      mainAxisSize: MainAxisSize.min,
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          l10n.recordEditDiscardTitle,
          style: dialogContext.theme.dialogStyle.titleTextStyle,
        ),
        const SizedBox(height: Spacing.level2),
        Text(
          l10n.recordEditDiscardMessage,
          style: dialogContext.theme.dialogStyle.bodyTextStyle,
        ),
        const SizedBox(height: Spacing.level5),
        Row(
          mainAxisAlignment: MainAxisAlignment.end,
          children: [
            FButton(
              variant: FButtonVariant.ghost,
              onPress: () => Navigator.of(dialogContext).pop(false),
              child: Text(l10n.recordEditKeepEditingAction),
            ),
            const SizedBox(width: Spacing.level3),
            FButton(
              key: const Key('record-edit-discard-confirm'),
              variant: FButtonVariant.destructive,
              onPress: () => Navigator.of(dialogContext).pop(true),
              child: Text(l10n.recordEditDiscardAction),
            ),
          ],
        ),
      ],
    ),
  );
}

class _RecordEditLoading extends StatelessWidget {
  const _RecordEditLoading();

  @override
  Widget build(BuildContext context) {
    return const InlineSkeletonSection(
      children: [
        InlineSkeletonBlock(height: 56),
        InlineSkeletonBlock(height: 56),
        InlineSkeletonBlock(height: 56),
        InlineSkeletonBlock(height: 96),
        InlineSkeletonBlock(height: 56),
        InlineSkeletonBlock(height: 44),
      ],
    );
  }
}

/// Status hint above the edit form.
///
/// Shows a subtle "changes take effect after saving" hint by default, and
/// switches to a warning pill while the form is dirty, echoing the
/// discard-confirmation dialog shown on back navigation.
class _EditStatusHint extends StatelessWidget {
  const _EditStatusHint({required this.dirty, required this.l10n});

  final bool dirty;
  final AppLocalizations l10n;

  @override
  Widget build(BuildContext context) {
    final colors = context.theme.colors;
    const warning = SemanticColor.warning;
    final background = dirty ? warning.subtle(context) : colors.muted;
    final foreground = dirty
        ? warning.solid(context)
        : SemanticColor.neutral.solid(context);

    return DecoratedBox(
      decoration: BoxDecoration(
        color: background,
        borderRadius: context.theme.style.borderRadius.xs,
      ),
      child: Padding(
        padding: const EdgeInsets.symmetric(
          horizontal: Spacing.level3,
          vertical: Spacing.level2,
        ),
        child: Row(
          key: Key(
            dirty ? 'record-edit-unsaved-hint' : 'record-edit-save-hint',
          ),
          children: [
            Icon(
              dirty ? SemanticIcons.statusWarning : SemanticIcons.statusInfo,
              color: foreground,
              size: IconSizeTokens.level2,
            ),
            const SizedBox(width: Spacing.level2),
            Expanded(
              child: Text(
                dirty
                    ? l10n.recordEditUnsavedWarning
                    : l10n.recordEditUnsavedHint,
                style: context.theme.typography.body.xs.copyWith(
                  color: foreground,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
