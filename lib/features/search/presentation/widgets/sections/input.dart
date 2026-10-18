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

  /// Fired by an explicit submit — the search button beside the field or the
  /// keyboard's search action (mobile Enter / desktop Return). Search is
  /// submit-driven: [onChanged] only records the typed query, never searches.
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

    // The single non-keyboard trigger. Mirrors the keyboard action, which
    // unfocuses the field, so both paths leave the field in the same state.
    void submit() {
      final value = controller.text;
      FocusScope.of(context).unfocus();
      (onSubmitted ?? onChanged)(value);
    }

    final canSubmit = query.trim().isNotEmpty;

    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Expanded(
          child: FTextField(
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
            prefixBuilder: (context, style, variants) =>
                FTextField.prefixIconBuilder(
                  context,
                  style,
                  variants,
                  Icon(
                    SemanticIcons.actionSearch,
                    color: SemanticColor.neutral.solid(context),
                  ),
                ),
            // Clear only exists once there is something to clear.
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
                        padding: const EdgeInsets.all(Spacing.xs),
                        child: Icon(
                          SemanticIcons.notificationFailed,
                          color: SemanticColor.neutral.solid(context),
                        ),
                      ),
                    ),
                  ),
          ),
        ),
        const SizedBox(width: Spacing.md),
        // The single non-keyboard trigger, as a labelled button beside the
        // field (the keyboard's search action stays wired above). Width-bounded
        // because a Row hands non-flex children an unbounded main axis.
        ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 120),
          child: FButton(
            key: const ValueKey('medicine-search-submit'),
            onPress: canSubmit ? submit : null,
            child: Text(
              l10n.medicineSearchSubmitAction,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              textAlign: TextAlign.center,
            ),
          ),
        ),
      ],
    );
  }
}
