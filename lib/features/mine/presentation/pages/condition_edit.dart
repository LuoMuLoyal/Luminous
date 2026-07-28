import 'dart:async';

import 'package:collection/collection.dart';
import 'package:flutter/material.dart';
import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:forui/forui.dart';
import 'package:go_router/go_router.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:luminous/core/design/design.dart';
import 'package:luminous/core/feedback/toast.dart';
import 'package:luminous/core/forms/validators.dart';
import 'package:luminous/core/widgets/common/dialog_shell.dart';
import 'package:luminous/core/widgets/common/state_views.dart';
import 'package:luminous/core/widgets/layout/page_scaffold.dart';
import 'package:luminous/core/widgets/layout/responsive_content_frame.dart';
import 'package:luminous/features/auth/presentation/providers/session.dart';
import 'package:luminous/features/auth/presentation/widgets/shared/required_dialog.dart';
import 'package:luminous/features/health_context/data/providers/health_context.dart';
import 'package:luminous/features/health_context/domain/entities/write_inputs.dart';
import 'package:luminous/features/mine/presentation/providers/health_edit_forms.dart';
import 'package:luminous/features/mine/presentation/utils/health_enum_l10n.dart';
import 'package:luminous/features/mine/presentation/widgets/shared/mine_edit_form_loading.dart';
import 'package:luminous/l10n/app_localizations.dart';

class ConditionEditPage extends HookConsumerWidget {
  const ConditionEditPage({super.key, this.conditionId});

  final String? conditionId;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = AppLocalizations.of(context)!;
    final isNew = conditionId == null;
    final isEdit = !isNew;

    final labelController = useTextEditingController();
    final noteController = useTextEditingController();
    final diagnosedAt = useState<DateTime?>(null);
    final status = useState(HealthConditionStatus.active);
    final prefilled = useState(false);
    final notFound = useState(false);

    void tryPrefill() {
      if (prefilled.value) return;
      final snapshot = ref.read(healthContextSnapshotProvider).asData?.value;
      if (snapshot == null) return;

      final id = conditionId;
      if (id == null) {
        prefilled.value = true;
        return;
      }

      final item = snapshot.conditions.firstWhereOrNull((c) => c.id == id);
      if (item == null) {
        notFound.value = true;
        prefilled.value = true;
        return;
      }

      prefilled.value = true;
      labelController.text = item.label;
      diagnosedAt.value = _tryParseDate(item.diagnosedAt);
      noteController.text = item.note ?? '';
      status.value =
          HealthConditionStatus.fromValue(item.status) ??
          HealthConditionStatus.active;
    }

    void onSave() {
      final labelError = RequiredInput.validate(
        labelController.text,
        AppLocalizations.of(context)!.mineEditFieldLabelRequired,
      );
      if (labelError != null) {
        Toast.show(context, labelError);
        return;
      }

      if (conditionId != null) {
        ref
            .read(conditionFormProvider.notifier)
            .save(
              create: const HealthConditionWriteInput(label: ''),
              id: conditionId,
              update: HealthConditionUpdateInput(
                label: labelController.text,
                status: status.value,
                diagnosedAt: diagnosedAt.value != null
                    ? _formatDate(diagnosedAt.value!)
                    : null,
                note: noteController.text.isEmpty ? null : noteController.text,
              ),
            );
      } else {
        ref
            .read(conditionFormProvider.notifier)
            .save(
              create: HealthConditionWriteInput(
                label: labelController.text,
                status: status.value,
                diagnosedAt: diagnosedAt.value != null
                    ? _formatDate(diagnosedAt.value!)
                    : null,
                note: noteController.text.isEmpty ? null : noteController.text,
              ),
            );
      }
    }

    void onDelete() {
      if (conditionId != null) {
        ref.read(conditionFormProvider.notifier).delete(conditionId!);
      }
    }

    final session = ref.watch(authSessionProvider);

    ref.listen<ConditionFormState>(conditionFormProvider, (prev, next) {
      if (next.saved && prev?.saved != true) {
        unawaited(
          Toast.show(
            context,
            next.deleted ? l10n.mineEditDeletedToast : l10n.mineEditSavedToast,
          ),
        );
        if (context.mounted) context.pop();
      }
      final error = next.errorMessage;
      if (error != null && error != prev?.errorMessage) {
        unawaited(Toast.show(context, error));
      }
    });

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
                  ? const MineEditFormLoading(
                      blockHeights: [56, 56, 56, 96, 56],
                    )
                  : AuthRequiredDialogGate(
                      onLogin: () =>
                          context.push(loginRouteForCurrentLocation(context)),
                    ),
            ],
          ),
        ),
      );
    } else {
      final snapshot = ref.watch(healthContextSnapshotProvider);
      snapshot.whenOrNull(data: (_) => tryPrefill());

      if (notFound.value) {
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
                StateErrorView(
                  title: l10n.mineEditRecordNotFoundTitle,
                  description: l10n.mineEditRecordNotFoundDescription,
                  icon: SemanticIcons.statusError,
                  actionLabel: l10n.mineEditBackAction,
                  onAction: () => context.pop(),
                ),
              ],
            ),
          ),
        );
      } else if (isEdit && !prefilled.value && !snapshot.hasError) {
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
              children: [
                MineEditFormLoading(blockHeights: [56, 56, 56, 96, 56]),
              ],
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
                  padding: const EdgeInsets.all(Spacing.level4),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      FTextField(
                        key: const Key('condition-label-field'),
                        control: FTextFieldControl.managed(
                          controller: labelController,
                        ),
                        label: Text(l10n.mineEditFieldLabel),
                      ),
                      const SizedBox(height: Spacing.level3),
                      _enumDropdown<HealthConditionStatus>(
                        label: l10n.mineEditFieldStatus,
                        value: status.value,
                        values: HealthConditionStatus.values,
                        onChanged: (v) => status.value = v,
                        labelBuilder: (v) => conditionStatusLabel(l10n, v),
                        description: conditionStatusDescription(
                          l10n,
                          status.value,
                        ),
                      ),
                      const SizedBox(height: Spacing.level3),
                      FDateField.calendar(
                        key: const Key('condition-diagnosed-at-field'),
                        label: Text(l10n.mineEditFieldDiagnosedAt),
                        selectionControl: FDateSelectionControl.managedSingle(
                          initial: diagnosedAt.value,
                          toggleable: true,
                          onChange: (value) => diagnosedAt.value = value,
                        ),
                      ),
                      const SizedBox(height: Spacing.level3),
                      FTextField(
                        control: FTextFieldControl.managed(
                          controller: noteController,
                        ),
                        label: Text(l10n.mineEditFieldNote),
                        maxLines: 3,
                      ),
                      const SizedBox(height: Spacing.level5),
                      FButton(
                        key: const Key('condition-save-button'),
                        onPress: onSave,
                        child: Text(l10n.mineEditSaveAction),
                      ),
                      if (!isNew) ...[
                        const SizedBox(height: Spacing.level3),
                        FButton(
                          key: const Key('condition-delete-button'),
                          variant: FButtonVariant.destructive,
                          onPress: () async {
                            final confirmed =
                                await showDangerConfirmationDialog(
                                  context: context,
                                  title: l10n.mineEditDeleteConfirmTitle,
                                  message: l10n.mineEditDeleteConfirmMessage,
                                  confirmLabel: l10n.mineEditDeleteAction,
                                );
                            if (confirmed) onDelete();
                          },
                          child: Text(l10n.mineEditDeleteAction),
                        ),
                      ],
                    ],
                  ),
                ),
              ],
            ),
          ),
        );
      }
    }

    final title = isNew
        ? l10n.mineEditConditionNewTitle
        : l10n.mineEditConditionTitle;

    return PageScaffold(
      title: title,
      child: SingleChildScrollView(child: content),
    );
  }
}

Widget _enumDropdown<T extends HealthContextWireEnum>({
  required String label,
  required T value,
  required List<T> values,
  required ValueChanged<T> onChanged,
  required String Function(T) labelBuilder,
  String? description,
}) {
  return FSelect<T>.rich(
    label: Text(label),
    hint: label,
    format: labelBuilder,
    description: description != null ? Text(description) : null,
    control: FSelectControl.lifted(
      value: value,
      onChange: (v) {
        if (v != null) onChanged(v);
      },
    ),
    children: values
        .map((v) => FSelectItem.item(title: Text(labelBuilder(v)), value: v))
        .toList(),
  );
}

DateTime? _tryParseDate(String? value) {
  if (value == null || value.isEmpty) return null;
  return DateTime.tryParse(value);
}

String _formatDate(DateTime date) {
  final y = date.year.toString().padLeft(4, '0');
  final m = date.month.toString().padLeft(2, '0');
  final d = date.day.toString().padLeft(2, '0');
  return '$y-$m-$d';
}
