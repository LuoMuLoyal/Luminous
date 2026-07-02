import 'package:collection/collection.dart';
import 'package:flutter/material.dart';
import 'package:forui/forui.dart';
import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:luminous/core/design/app_design.dart';
import 'package:luminous/core/feedback/app_toast.dart';
import 'package:luminous/core/widgets/common/app_state_views.dart';
import 'package:luminous/core/design/app_breakpoints.dart';
import 'package:luminous/core/widgets/layout/responsive_content_frame.dart';
import 'package:luminous/features/auth/presentation/providers/session/auth_session_provider.dart';
import 'package:luminous/features/auth/presentation/widgets/auth_required_dialog.dart';
import 'package:luminous/features/health_context/data/providers/health_context_data_providers.dart';
import 'package:luminous/features/health_context/domain/entities/health_context_write_inputs.dart';
import 'package:luminous/features/mine/presentation/providers/health_edit_forms.dart';
import 'package:luminous/core/widgets/common/app_back_button.dart';
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
      if (labelController.text.trim().isEmpty) {
        AppToast.show(
          context,
          AppLocalizations.of(context)!.authCodeRequiredToast,
        );
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

    if (!session.canAccessProtectedData) {
      final width = MediaQuery.sizeOf(context).width;
      final content = ResponsiveContentFrame(
        child: Padding(
          padding: EdgeInsets.symmetric(
            vertical: width < AppBreakpoints.mobile ? 24 : 32,
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              session.isLoading
                  ? const _MineEditFormLoading()
                  : AuthRequiredDialogGate(
                      onLogin: () =>
                          context.push(loginRouteForCurrentLocation(context)),
                    ),
            ],
          ),
        ),
      );

      return FScaffold(
        header: SafeArea(
          bottom: false,
          child: FHeader.nested(
            title: Text(
              isNew
                  ? l10n.mineEditConditionNewTitle
                  : l10n.mineEditConditionTitle,
            ),
            titleAlignment: Alignment.center,
            prefixes: [const AppBackButton()],
          ),
        ),
        child: SafeArea(
          top: false,
          child: Material(
            color: Colors.transparent,
            child: SingleChildScrollView(child: content),
          ),
        ),
      );
    }

    final snapshot = ref.watch(healthContextSnapshotProvider);
    snapshot.whenOrNull(data: (_) => tryPrefill());

    if (notFound.value) {
      final width = MediaQuery.sizeOf(context).width;
      final content = ResponsiveContentFrame(
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
                icon: Icons.error_outline_rounded,
                actionLabel: l10n.todayRetryAction,
                onAction: () => context.pop(),
              ),
            ],
          ),
        ),
      );

      return FScaffold(
        header: SafeArea(
          bottom: false,
          child: FHeader.nested(
            title: Text(l10n.mineEditConditionTitle),
            titleAlignment: Alignment.center,
            prefixes: [const AppBackButton()],
          ),
        ),
        child: SafeArea(
          top: false,
          child: Material(
            color: Colors.transparent,
            child: SingleChildScrollView(child: content),
          ),
        ),
      );
    }

    if (isEdit && !prefilled.value && !snapshot.hasError) {
      final width = MediaQuery.sizeOf(context).width;
      final content = ResponsiveContentFrame(
        child: Padding(
          padding: EdgeInsets.symmetric(
            vertical: width < AppBreakpoints.mobile ? 24 : 32,
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: const [_MineEditFormLoading()],
          ),
        ),
      );

      return FScaffold(
        header: SafeArea(
          bottom: false,
          child: FHeader.nested(
            title: Text(l10n.mineEditConditionTitle),
            titleAlignment: Alignment.center,
            prefixes: [const AppBackButton()],
          ),
        ),
        child: SafeArea(
          top: false,
          child: Material(
            color: Colors.transparent,
            child: SingleChildScrollView(child: content),
          ),
        ),
      );
    }

    final width = MediaQuery.sizeOf(context).width;
    final content = ResponsiveContentFrame(
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
                  ElevatedButton(
                    key: const Key('condition-save-button'),
                    onPressed: onSave,
                    child: Text(l10n.mineEditSaveAction),
                  ),
                  if (!isNew) ...[
                    const SizedBox(height: AppSpacingTokens.level3),
                    OutlinedButton(
                      key: const Key('condition-delete-button'),
                      onPressed: onDelete,
                      style: OutlinedButton.styleFrom(
                        foregroundColor: Theme.of(context).colorScheme.error,
                      ),
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

    return FScaffold(
      header: SafeArea(
        bottom: false,
        child: FHeader.nested(
          title: Text(
            isNew
                ? l10n.mineEditConditionNewTitle
                : l10n.mineEditConditionTitle,
          ),
          titleAlignment: Alignment.center,
          prefixes: [const AppBackButton()],
        ),
      ),
      child: SafeArea(
        top: false,
        child: Material(
          color: Colors.transparent,
          child: SingleChildScrollView(child: content),
        ),
      ),
    );
  }
}

class _MineEditFormLoading extends StatelessWidget {
  const _MineEditFormLoading();

  @override
  Widget build(BuildContext context) {
    return const AppInlineSkeletonSection(
      children: [
        AppInlineSkeletonBlock(height: 56),
        AppInlineSkeletonBlock(height: 56),
        AppInlineSkeletonBlock(height: 56),
        AppInlineSkeletonBlock(height: 96),
        AppInlineSkeletonBlock(height: 56),
      ],
    );
  }
}

Widget _enumDropdown<T extends HealthContextWireEnum>({
  required String label,
  required T value,
  required List<T> values,
  required ValueChanged<T> onChanged,
}) {
  return DropdownButtonFormField<T>(
    initialValue: value,
    decoration: InputDecoration(labelText: label),
    items: values
        .map((v) => DropdownMenuItem(value: v, child: Text(v.value)))
        .toList(),
    onChanged: (v) {
      if (v != null) onChanged(v);
    },
  );
}
