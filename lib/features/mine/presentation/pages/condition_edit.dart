import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:luminous/core/design/app_design.dart';
import 'package:luminous/core/feedback/app_toast.dart';
import 'package:luminous/core/widgets/app_state_views.dart';
import 'package:luminous/core/widgets/page_scaffold_shell.dart';
import 'package:luminous/features/health_context/data/providers/health_context_data_providers.dart';
import 'package:luminous/features/health_context/domain/entities/health_context_write_inputs.dart';
import 'package:luminous/features/mine/presentation/providers/health_edit_forms.dart';
import 'package:luminous/features/settings/presentation/widgets/settings_components.dart';
import 'package:luminous/l10n/app_localizations.dart';

class ConditionEditPage extends ConsumerStatefulWidget {
  const ConditionEditPage({super.key, this.conditionId});

  final String? conditionId;

  @override
  ConsumerState<ConditionEditPage> createState() => _ConditionEditPageState();
}

class _ConditionEditPageState extends ConsumerState<ConditionEditPage> {
  final _labelController = TextEditingController();
  final _diagnosedAtController = TextEditingController();
  final _noteController = TextEditingController();

  HealthConditionStatus _status = HealthConditionStatus.active;

  bool _prefilled = false;
  bool _notFound = false;

  @override
  void dispose() {
    _labelController.dispose();
    _diagnosedAtController.dispose();
    _noteController.dispose();
    super.dispose();
  }

  void _tryPrefill() {
    if (_prefilled) return;
    final snapshot = ref.read(healthContextSnapshotProvider).asData?.value;
    if (snapshot == null) return;

    final id = widget.conditionId;
    if (id == null) {
      _prefilled = true;
      return;
    }

    final item = snapshot.conditions.cast<dynamic>().firstWhere(
      (c) => c.id == id,
      orElse: () => null,
    );
    if (item == null) {
      _notFound = true;
      _prefilled = true;
      return;
    }

    _prefilled = true;
    _labelController.text = item.label ?? '';
    _diagnosedAtController.text = item.diagnosedAt ?? '';
    _noteController.text = item.note ?? '';
    setState(() {
      _status = HealthConditionStatus.fromValue(item.status) ??
          HealthConditionStatus.active;
    });
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final isNew = widget.conditionId == null;
    final isEdit = !isNew;

    ref.listen<ConditionFormState>(conditionFormProvider, (_, next) {
      if (next.saved) {
        AppToast.show(context, l10n.mineEditSavedToast);
        if (context.mounted) context.pop();
      }
    });

    final snapshot = ref.watch(healthContextSnapshotProvider);
    snapshot.whenOrNull(data: (_) => _tryPrefill());

    if (_notFound) {
      return PageScaffoldShell(
        title: l10n.mineEditConditionTitle,
        centerTitle: true,
        leading: const SettingsBackButton(),
        children: [
          AppStateErrorView(
            title: l10n.mineErrorDescription,
            description: '',
            icon: Icons.error_outline_rounded,
            actionLabel: l10n.todayRetryAction,
            onAction: () => context.pop(),
          ),
        ],
      );
    }

    if (isEdit && !_prefilled && !snapshot.hasError) {
      return PageScaffoldShell(
        title: l10n.mineEditConditionTitle,
        centerTitle: true,
        leading: const SettingsBackButton(),
        children: [const Center(child: CircularProgressIndicator())],
      );
    }

    return PageScaffoldShell(
      title:
          isNew
              ? l10n.mineEditConditionNewTitle
              : l10n.mineEditConditionTitle,
      centerTitle: true,
      leading: const SettingsBackButton(),
      children: [
        Padding(
          padding: const EdgeInsets.all(AppSpacingTokens.md),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              TextField(
                key: const Key('condition-label-field'),
                controller: _labelController,
                decoration: InputDecoration(labelText: l10n.mineEditFieldLabel),
              ),
              const SizedBox(height: 12),
              _enumDropdown<HealthConditionStatus>(
                label: l10n.mineEditFieldStatus,
                value: _status,
                values: HealthConditionStatus.values,
                onChanged: (v) => setState(() => _status = v),
              ),
              const SizedBox(height: 12),
              TextField(
                controller: _diagnosedAtController,
                decoration: InputDecoration(
                  labelText: l10n.mineEditFieldDiagnosedAt,
                ),
              ),
              const SizedBox(height: 12),
              TextField(
                controller: _noteController,
                decoration: InputDecoration(labelText: l10n.mineEditFieldNote),
                maxLines: 3,
              ),
              const SizedBox(height: 24),
              ElevatedButton(
                key: const Key('condition-save-button'),
                onPressed: _onSave,
                child: Text(l10n.mineEditSaveAction),
              ),
              if (!isNew) ...[
                const SizedBox(height: 12),
                OutlinedButton(
                  key: const Key('condition-delete-button'),
                  onPressed: _onDelete,
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
    );
  }

  void _onSave() {
    if (_labelController.text.trim().isEmpty) {
      AppToast.show(context, AppLocalizations.of(context)!.authCodeRequiredToast);
      return;
    }

    if (widget.conditionId != null) {
      ref.read(conditionFormProvider.notifier).save(
        create: HealthConditionWriteInput(label: ''),
        id: widget.conditionId,
        update: HealthConditionUpdateInput(
          label: _labelController.text,
          status: _status,
          diagnosedAt:
              _diagnosedAtController.text.isEmpty
                  ? null
                  : _diagnosedAtController.text,
          note: _noteController.text.isEmpty ? null : _noteController.text,
        ),
      );
    } else {
      ref.read(conditionFormProvider.notifier).save(
        create: HealthConditionWriteInput(
          label: _labelController.text,
          status: _status,
          diagnosedAt:
              _diagnosedAtController.text.isEmpty
                  ? null
                  : _diagnosedAtController.text,
          note: _noteController.text.isEmpty ? null : _noteController.text,
        ),
      );
    }
  }

  void _onDelete() {
    if (widget.conditionId != null) {
      ref.read(conditionFormProvider.notifier).delete(widget.conditionId!);
    }
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
    items:
        values
            .map((v) => DropdownMenuItem(value: v, child: Text(v.value)))
            .toList(),
    onChanged: (v) {
      if (v != null) onChanged(v);
    },
  );
}
