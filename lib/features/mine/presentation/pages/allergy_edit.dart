import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:luminous/core/feedback/app_toast.dart';
import 'package:luminous/core/widgets/page_scaffold_shell.dart';
import 'package:luminous/features/health_context/domain/entities/health_context_write_inputs.dart';
import 'package:luminous/features/mine/presentation/providers/health_edit_forms.dart';
import 'package:luminous/features/settings/presentation/widgets/settings_components.dart';
import 'package:luminous/l10n/app_localizations.dart';

class AllergyEditPage extends ConsumerStatefulWidget {
  const AllergyEditPage({super.key, this.allergyId});

  final String? allergyId;

  @override
  ConsumerState<AllergyEditPage> createState() => _AllergyEditPageState();
}

class _AllergyEditPageState extends ConsumerState<AllergyEditPage> {
  final _labelController = TextEditingController();
  final _reactionController = TextEditingController();
  final _noteController = TextEditingController();

  HealthAllergyKind _kind = HealthAllergyKind.drug;
  HealthAllergySeverity _severity = HealthAllergySeverity.unknown;

  @override
  void dispose() {
    _labelController.dispose();
    _reactionController.dispose();
    _noteController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final isNew = widget.allergyId == null;

    ref.listen<AllergyFormState>(allergyFormProvider, (_, next) {
      if (next.saved) {
        AppToast.show(
          context,
          isNew ? l10n.mineEditSavedToast : l10n.mineEditSavedToast,
        );
        if (context.mounted) context.pop();
      }
    });

    return PageScaffoldShell(
      title:
          isNew ? l10n.mineEditAllergyNewTitle : l10n.mineEditAllergyTitle,
      centerTitle: true,
      leading: const SettingsBackButton(),
      children: [
        Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              _enumDropdown<HealthAllergyKind>(
                label: l10n.mineEditFieldKind,
                value: _kind,
                values: HealthAllergyKind.values,
                onChanged: (v) => setState(() => _kind = v),
              ),
              const SizedBox(height: 12),
              TextField(
                controller: _labelController,
                decoration: InputDecoration(labelText: l10n.mineEditFieldLabel),
              ),
              const SizedBox(height: 12),
              TextField(
                controller: _reactionController,
                decoration: InputDecoration(
                  labelText: l10n.mineEditFieldReaction,
                ),
              ),
              const SizedBox(height: 12),
              DropdownButtonFormField<HealthAllergySeverity>(
                initialValue: _severity,
                decoration: InputDecoration(
                  labelText: l10n.mineEditFieldSeverity,
                ),
                items:
                    HealthAllergySeverity.values
                        .map(
                          (v) =>
                              DropdownMenuItem(value: v, child: Text(v.value)),
                        )
                        .toList(),
                onChanged: (v) {
                  if (v != null) setState(() => _severity = v);
                },
              ),
              const SizedBox(height: 12),
              TextField(
                controller: _noteController,
                decoration: InputDecoration(labelText: l10n.mineEditFieldNote),
                maxLines: 3,
              ),
              const SizedBox(height: 24),
              ElevatedButton(
                onPressed: _onSave,
                child: Text(l10n.mineEditSaveAction),
              ),
              if (!isNew) ...[
                const SizedBox(height: 12),
                OutlinedButton(
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
    if (widget.allergyId != null) {
      ref.read(allergyFormProvider.notifier).save(
        create: HealthAllergyWriteInput(kind: _kind, label: ''),
        id: widget.allergyId,
        update: HealthAllergyUpdateInput(
          kind: _kind,
          label: _labelController.text,
          reaction:
              _reactionController.text.isEmpty
                  ? null
                  : _reactionController.text,
          severity: _severity,
          note: _noteController.text.isEmpty ? null : _noteController.text,
        ),
      );
    } else {
      ref.read(allergyFormProvider.notifier).save(
        create: HealthAllergyWriteInput(
          kind: _kind,
          label: _labelController.text,
          reaction:
              _reactionController.text.isEmpty
                  ? null
                  : _reactionController.text,
          severity: _severity,
          note: _noteController.text.isEmpty ? null : _noteController.text,
        ),
      );
    }
  }

  void _onDelete() {
    if (widget.allergyId != null) {
      ref.read(allergyFormProvider.notifier).delete(widget.allergyId!);
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
