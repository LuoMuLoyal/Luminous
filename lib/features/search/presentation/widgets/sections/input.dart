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
    // Guards the controller→onChanged echo while [query] is synced back into
    // the controller. External query changes (e.g. tapping a recent search
    // keyword) otherwise fire onChange during build, and the resulting
    // provider update trips Riverpod's "modify while building" assertion.
    final syncing = useRef(false);
    useEffect(() {
      if (query != controller.text) {
        syncing.value = true;
        controller.text = query;
        syncing.value = false;
      }
      return null;
    }, [query]);

    return FTextField(
      control: FTextFieldControl.managed(
        controller: controller,
        onChange: (value) {
          if (!syncing.value) {
            onChanged(value.text);
          }
        },
      ),
      hint: l10n.medicineSearchFieldHint,
      textInputAction: TextInputAction.search,
      onSubmit: onChanged,
      prefixBuilder: (context, style, variants) => FTextField.prefixIconBuilder(
        context,
        style,
        variants,
        Icon(
          SemanticIcons.actionSearch,
          color: SemanticColor.neutral.solid(context),
        ),
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
                    color: SemanticColor.neutral.solid(context),
                  ),
                ),
              ),
            ),
    );
  }
}
