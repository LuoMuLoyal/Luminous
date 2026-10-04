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
    this.onSubmitted,
  });

  final AppLocalizations l10n;
  final String query;
  final ValueChanged<String> onChanged;

  /// Fired by an explicit submit — the keyboard's search action or the field's
  /// submit button. Search is submit-driven: [onChanged] only records the typed
  /// query and never searches.
  final ValueChanged<String>? onSubmitted;

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
      key: const ValueKey('medicine-search-input'),
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
      onSubmit: (value) => (onSubmitted ?? onChanged)(value),
      prefixBuilder: (context, style, variants) => FTextField.prefixIconBuilder(
        context,
        style,
        variants,
        Icon(
          SemanticIcons.actionSearch,
          color: SemanticColor.neutral.solid(context),
        ),
      ),
      // Both suffixes only exist once there is something to act on, so the
      // submit button is never a dead control.
      suffixBuilder: controller.text.isEmpty
          ? null
          : (context, style, variants) => Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                FTappable(
                  onPress: () {
                    controller.clear();
                    onChanged('');
                  },
                  child: Semantics(
                    button: true,
                    label: l10n.medicineSearchClearAction,
                    child: Padding(
                      padding: const EdgeInsets.all(Spacing.xs),
                      child: Icon(
                        SemanticIcons.notificationFailed,
                        color: SemanticColor.neutral.solid(context),
                      ),
                    ),
                  ),
                ),
                // Explicit submit for the submit-only contract. The keyboard's
                // search action stays wired (`textInputAction` + `onSubmit`);
                // this is the same trigger for users who never press it.
                FTappable(
                  key: const ValueKey('medicine-search-submit'),
                  onPress: () {
                    final submitted = controller.text;
                    // Mirror the keyboard action, which unfocuses the field.
                    FocusScope.of(context).unfocus();
                    (onSubmitted ?? onChanged)(submitted);
                  },
                  child: Semantics(
                    button: true,
                    label: l10n.medicineSearchPageTitle,
                    child: Padding(
                      padding: const EdgeInsets.all(Spacing.xs),
                      child: Icon(
                        SemanticIcons.actionSearch,
                        color: SemanticColor.primary.solid(context),
                      ),
                    ),
                  ),
                ),
              ],
            ),
    );
  }
}
