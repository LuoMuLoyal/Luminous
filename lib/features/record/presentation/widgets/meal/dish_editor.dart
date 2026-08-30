import 'package:flutter/material.dart';
import 'package:forui/forui.dart';
import 'package:luminous/core/design/design.dart';
import 'package:luminous/l10n/app_localizations.dart';

class MealDishEditorSection extends StatelessWidget {
  const MealDishEditorSection({
    super.key,
    required this.dishNames,
    required this.onDishChanged,
    required this.onDishRemoved,
    required this.onDishAdded,
    required this.enabled,
  });

  final List<String> dishNames;
  final void Function(int index, String value) onDishChanged;
  final ValueChanged<int> onDishRemoved;
  final VoidCallback onDishAdded;
  final bool enabled;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Text(
          l10n.recordMealAnalysisRecognizedDishes,
          style: context.theme.typography.body.sm.copyWith(
            fontWeight: FontWeight.w700,
          ),
        ),
        const SizedBox(height: Spacing.level2),
        Text(
          l10n.recordMealDishEditorHelperText,
          style: context.theme.typography.body.xs,
        ),
        const SizedBox(height: Spacing.level3),
        for (var index = 0; index < dishNames.length; index += 1) ...[
          Row(
            children: [
              Expanded(
                child: FTextField(
                  key: Key('meal-dish-field-$index'),
                  enabled: enabled,
                  control: FTextFieldControl.managed(
                    initial: TextEditingValue(text: dishNames[index]),
                    onChange: (value) => onDishChanged(index, value.text),
                  ),
                  label: Text(l10n.recordMealDishFieldLabel(index + 1)),
                ),
              ),
              const SizedBox(width: Spacing.level3),
              Tooltip(
                message: l10n.recordMealDishRemoveAction,
                child: FButton.icon(
                  key: Key('meal-dish-remove-$index'),
                  onPress: enabled ? () => onDishRemoved(index) : null,
                  child: Icon(
                    SemanticIcons.actionDelete,
                    semanticLabel: l10n.recordMealDishRemoveAction,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: Spacing.level3),
        ],
        Align(
          alignment: Alignment.centerLeft,
          child: FButton(
            variant: FButtonVariant.outline,
            key: const Key('meal-dish-add-action'),
            onPress: enabled ? onDishAdded : null,
            prefix: const Icon(SemanticIcons.actionAdd),
            child: Text(l10n.recordMealDishAddAction),
          ),
        ),
      ],
    );
  }
}
