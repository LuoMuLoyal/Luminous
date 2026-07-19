import 'dart:async';

import 'package:collection/collection.dart';
import 'package:flutter/material.dart';
import 'package:forui/forui.dart';
import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:luminous/core/design/design.dart';
import 'package:luminous/core/feedback/toast.dart';
import 'package:luminous/core/forms/validators.dart';
import 'package:luminous/core/widgets/common/dialog_shell.dart';
import 'package:luminous/core/widgets/common/state_views.dart';
import 'package:luminous/core/widgets/layout/responsive_content_frame.dart';
import 'package:luminous/features/auth/presentation/providers/session.dart';
import 'package:luminous/features/auth/presentation/widgets/shared/required_dialog.dart';
import 'package:luminous/features/health_context/data/providers/health_context.dart';
import 'package:luminous/features/health_context/domain/entities/write_inputs.dart';
import 'package:luminous/features/mine/presentation/providers/health_edit_forms.dart';
import 'package:luminous/features/mine/presentation/utils/health_enum_l10n.dart';
import 'package:luminous/core/widgets/layout/page_scaffold.dart';
import 'package:luminous/l10n/app_localizations.dart';
import 'package:luminous/core/widgets/common/shared_widgets.dart';

class AllergyEditPage extends HookConsumerWidget {
  const AllergyEditPage({super.key, this.allergyId});

  final String? allergyId;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = AppLocalizations.of(context)!;
    final isNew = allergyId == null;
    final isEdit = !isNew;

    final labelController = useTextEditingController();
    final reactionController = useTextEditingController();
    final noteController = useTextEditingController();
    final kind = useState(HealthAllergyKind.drug);
    final severity = useState(HealthAllergySeverity.unknown);
    final prefilled = useState(false);
    final notFound = useState(false);

    void tryPrefill() {
      if (prefilled.value) return;
      final snapshot = ref.read(healthContextSnapshotProvider).asData?.value;
      if (snapshot == null) return;

      final id = allergyId;
      if (id == null) {
        prefilled.value = true;
        return;
      }

      final item = snapshot.allergies.firstWhereOrNull((a) => a.id == id);
      if (item == null) {
        notFound.value = true;
        prefilled.value = true;
        return;
      }

      prefilled.value = true;
      labelController.text = item.label;
      reactionController.text = item.reaction ?? '';
      noteController.text = item.note ?? '';
      kind.value =
          HealthAllergyKind.fromValue(item.kind) ?? HealthAllergyKind.drug;
      severity.value =
          HealthAllergySeverity.fromValue(item.severity) ??
          HealthAllergySeverity.unknown;
    }

    void onSave() {
      final labelError = RequiredInput.validate(
        labelController.text,
        AppLocalizations.of(context)!.mineEditFieldLabelRequired,
      );
      if (labelError != null) {
        AppToast.show(context, labelError);
        return;
      }

      if (allergyId != null) {
        ref
            .read(allergyFormProvider.notifier)
            .save(
              create: HealthAllergyWriteInput(kind: kind.value, label: ''),
              id: allergyId,
              update: HealthAllergyUpdateInput(
                kind: kind.value,
                label: labelController.text,
                reaction: reactionController.text.isEmpty
                    ? null
                    : reactionController.text,
                severity: severity.value,
                note: noteController.text.isEmpty ? null : noteController.text,
              ),
            );
      } else {
        ref
            .read(allergyFormProvider.notifier)
            .save(
              create: HealthAllergyWriteInput(
                kind: kind.value,
                label: labelController.text,
                reaction: reactionController.text.isEmpty
                    ? null
                    : reactionController.text,
                severity: severity.value,
                note: noteController.text.isEmpty ? null : noteController.text,
              ),
            );
      }
    }

    void onDelete() {
      if (allergyId == null) return;
      unawaited(ref.read(allergyFormProvider.notifier).delete(allergyId!));
    }

    final session = ref.watch(authSessionProvider);

    ref.listen<AllergyFormState>(allergyFormProvider, (prev, next) {
      if (next.saved && prev?.saved != true) {
        unawaited(
          AppToast.show(
            context,
            next.deleted ? l10n.mineEditDeletedToast : l10n.mineEditSavedToast,
          ),
        );
        if (context.mounted) context.pop();
      }
      final error = next.errorMessage;
      if (error != null && error != prev?.errorMessage) {
        unawaited(AppToast.show(context, error));
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
                AppStateErrorView(
                  title: l10n.mineEditRecordNotFoundTitle,
                  description: l10n.mineEditRecordNotFoundDescription,
                  icon: FLucideIcons.circleAlert,
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
                      _enumDropdown<HealthAllergyKind>(
                        label: l10n.mineEditFieldKind,
                        value: kind.value,
                        values: HealthAllergyKind.values,
                        onChanged: (v) => kind.value = v,
                        labelBuilder: (v) => allergyKindLabel(l10n, v),
                      ),
                      const SizedBox(height: Spacing.level3),
                      FTextField(
                        key: const Key('allergy-label-field'),
                        control: FTextFieldControl.managed(
                          controller: labelController,
                        ),
                        label: Text(l10n.mineEditFieldLabel),
                      ),
                      const SizedBox(height: Spacing.level3),
                      FTextField(
                        control: FTextFieldControl.managed(
                          controller: reactionController,
                        ),
                        label: Text(l10n.mineEditFieldReaction),
                      ),
                      const SizedBox(height: Spacing.level3),
                      FSelect<HealthAllergySeverity>.rich(
                        label: Text(l10n.mineEditFieldSeverity),
                        hint: l10n.mineEditFieldSeverity,
                        format: (value) => allergySeverityLabel(l10n, value),
                        description: Text(
                          allergySeverityDescription(l10n, severity.value),
                        ),
                        control: FSelectControl.lifted(
                          value: severity.value,
                          onChange: (v) {
                            if (v != null) severity.value = v;
                          },
                        ),
                        children: HealthAllergySeverity.values
                            .map(
                              (v) => FSelectItem.item(
                                title: Text(allergySeverityLabel(l10n, v)),
                                value: v,
                              ),
                            )
                            .toList(),
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
                        key: const Key('allergy-save-button'),
                        onPress: onSave,
                        child: Text(l10n.mineEditSaveAction),
                      ),
                      if (!isNew) ...[
                        const SizedBox(height: Spacing.level3),
                        FButton(
                          key: const Key('allergy-delete-button'),
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
        ? l10n.mineEditAllergyNewTitle
        : l10n.mineEditAllergyTitle;

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
}) {
  return FSelect<T>.rich(
    label: Text(label),
    hint: label,
    format: labelBuilder,
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
