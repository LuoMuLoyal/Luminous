import 'package:flutter/material.dart';
import 'package:forui/forui.dart';
import 'package:luminous/core/design/app_design.dart';
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
    final textTheme = Theme.of(context).textTheme;

    return Material(
      type: MaterialType.transparency,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Text(
            l10n.recordMealAnalysisRecognizedDishes,
            style: textTheme.titleSmall?.copyWith(fontWeight: FontWeight.w700),
          ),
          const SizedBox(height: AppSpacingTokens.level2),
          Text(l10n.recordMealDishEditorHelperText, style: textTheme.bodySmall),
          const SizedBox(height: AppSpacingTokens.level3),
          for (var index = 0; index < dishNames.length; index += 1) ...[
            Row(
              children: [
                Expanded(
                  child: TextFormField(
                    key: Key('meal-dish-field-$index'),
                    enabled: enabled,
                    initialValue: dishNames[index],
                    decoration: InputDecoration(
                      labelText: l10n.recordMealDishFieldLabel(index + 1),
                    ),
                    onChanged: (value) => onDishChanged(index, value),
                  ),
                ),
                const SizedBox(width: AppSpacingTokens.level3),
                FButton.icon(
                  key: Key('meal-dish-remove-$index'),
                  onPress: enabled ? () => onDishRemoved(index) : null,
                  child: const Icon(FLucideIcons.trash2),
                ),
              ],
            ),
            const SizedBox(height: AppSpacingTokens.level3),
          ],
          Align(
            alignment: Alignment.centerLeft,
            child: FButton(
              variant: FButtonVariant.outline,
              key: const Key('meal-dish-add-action'),
              onPress: enabled ? onDishAdded : null,
              prefix: const Icon(FLucideIcons.plus),
              child: Text(l10n.recordMealDishAddAction),
            ),
          ),
        ],
      ),
    );
  }
}
