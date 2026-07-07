import 'package:collection/collection.dart';
import 'package:flutter/material.dart';
import 'package:forui/forui.dart';
import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:luminous/core/design/design.dart';
import 'package:luminous/core/feedback/app_toast.dart';
import 'package:luminous/core/forms/validators.dart';
import 'package:luminous/core/widgets/common/state_views.dart';
import 'package:luminous/core/widgets/layout/responsive_content_frame.dart';
import 'package:luminous/features/auth/presentation/providers/session/session_provider.dart';
import 'package:luminous/features/auth/presentation/widgets/shared/required_dialog.dart';
import 'package:luminous/features/health_context/data/providers/data_providers.dart';
import 'package:luminous/features/health_context/domain/entities/write_inputs.dart';
import 'package:luminous/features/mine/presentation/providers/health_edit_forms.dart';
import 'package:luminous/core/widgets/layout/page_scaffold.dart';
import 'package:luminous/l10n/app_localizations.dart';
import 'package:luminous/core/widgets/common/shared_widgets.dart';

class ConditionEditPage extends HookConsumerWidget {
  const ConditionEditPage({super.key, this.conditionId});

  final String? conditionId;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = AppLocalizations.of(context)!;
    final isNew = conditionId == null;
    final isEdit = !isNew;

    final labelController = useTextEditingController();
    final diagnosedAtController = useTextEditingController();
    final noteController = useTextEditingController();
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
      diagnosedAtController.text = item.diagnosedAt ?? '';
      noteController.text = item.note ?? '';
      status.value =
          HealthConditionStatus.fromValue(item.status) ??
          HealthConditionStatus.active;
    }

    void onSave() {
      final labelError = RequiredInput.validate(
        labelController.text,
        AppLocalizations.of(context)!.authCodeRequiredToast,
      );
      if (labelError != null) {
        AppToast.show(context, labelError);
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
                diagnosedAt: diagnosedAtController.text.isEmpty
                    ? null
                    : diagnosedAtController.text,
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
                diagnosedAt: diagnosedAtController.text.isEmpty
                    ? null
                    : diagnosedAtController.text,
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

    ref.listen<ConditionFormState>(conditionFormProvider, (_, next) {
      if (next.saved) {
        AppToast.show(context, l10n.mineEditSavedToast);
        if (context.mounted) context.pop();
      }
    });

    final Widget content;

    if (!session.canAccessProtectedData) {
      final width = MediaQuery.sizeOf(context).width;
      content = ResponsiveContentFrame(
        child: Padding(
          padding: EdgeInsets.symmetric(
            vertical: width < AppBreakpoints.mobile ? 24 : 32,
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
              vertical: width < AppBreakpoints.mobile ? 24 : 32,
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                AppStateErrorView(
                  title: l10n.mineErrorDescription,
                  description: '',
                  icon: FLucideIcons.circleAlert,
                  actionLabel: l10n.todayRetryAction,
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
              vertical: width < AppBreakpoints.mobile ? 24 : 32,
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
              vertical: width < AppBreakpoints.mobile ? 24 : 32,
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Padding(
                  padding: const EdgeInsets.all(AppSpacingTokens.level4),
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
                      const SizedBox(height: AppSpacingTokens.level3),
                      _enumDropdown<HealthConditionStatus>(
                        label: l10n.mineEditFieldStatus,
                        value: status.value,
                        values: HealthConditionStatus.values,
                        onChanged: (v) => status.value = v,
                      ),
                      const SizedBox(height: AppSpacingTokens.level3),
                      FTextField(
                        control: FTextFieldControl.managed(
                          controller: diagnosedAtController,
                        ),
                        label: Text(l10n.mineEditFieldDiagnosedAt),
                      ),
                      const SizedBox(height: AppSpacingTokens.level3),
                      FTextField(
                        control: FTextFieldControl.managed(
                          controller: noteController,
                        ),
                        label: Text(l10n.mineEditFieldNote),
                        maxLines: 3,
                      ),
                      const SizedBox(height: AppSpacingTokens.level5),
                      FButton(
                        key: const Key('condition-save-button'),
                        onPress: onSave,
                        child: Text(l10n.mineEditSaveAction),
                      ),
                      if (!isNew) ...[
                        const SizedBox(height: AppSpacingTokens.level3),
                        FButton(
                          key: const Key('condition-delete-button'),
                          variant: FButtonVariant.destructive,
                          onPress: onDelete,
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
}) {
  return FSelect<T>.rich(
    label: Text(label),
    hint: label,
    format: (value) => value.value,
    control: FSelectControl.lifted(
      value: value,
      onChange: (v) {
        if (v != null) onChanged(v);
      },
    ),
    children: values
        .map((v) => FSelectItem.item(title: Text(v.value), value: v))
        .toList(),
  );
}
