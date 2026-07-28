import 'package:flutter/material.dart';
import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:forui/forui.dart';
import 'package:luminous/core/design/design.dart';
import 'package:luminous/l10n/app_localizations.dart';

class SearchInput extends HookWidget {
  const SearchInput({
    super.key,
    required this.l10n,
    required this.query,
    required this.onChanged,
  });

  final AppLocalizations l10n;
  final String query;
  final ValueChanged<String> onChanged;

  @override
  Widget build(BuildContext context) {
    final controller = useTextEditingController(text: query);
    final colors = context.theme.colors;

    useEffect(() {
      if (query != controller.text) {
        controller.text = query;
      }
      return null;
    }, [query]);

    return FTextField(
      control: FTextFieldControl.managed(
        controller: controller,
        onChange: (value) => onChanged(value.text),
      ),
      hint: l10n.medicineSearchFieldHint,
      textInputAction: TextInputAction.search,
      onSubmit: onChanged,
      prefixBuilder: (context, style, variants) => FTextField.prefixIconBuilder(
        context,
        style,
        variants,
        Icon(SemanticIcons.actionSearch, color: colors.mutedForeground),
      ),
      suffixBuilder: controller.text.isEmpty
          ? null
          : (context, style, variants) => FTappable(
              onPress: () {
                controller.clear();
                onChanged('');
              },
              child: Semantics(
                button: true,
                label: l10n.medicineSearchClearAction,
                child: Padding(
                  padding: const EdgeInsets.all(Spacing.level1),
                  child: Icon(
                    SemanticIcons.notificationFailed,
                    color: colors.mutedForeground,
                  ),
                ),
              ),
            ),
    );
  }
}
