import 'package:flutter/material.dart';
import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:forui/forui.dart';
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
        Icon(FLucideIcons.search, color: colors.mutedForeground),
      ),
      suffixBuilder: controller.text.isEmpty
          ? null
          : (context, style, variants) => GestureDetector(
                onTap: () {
                  controller.clear();
                  onChanged('');
                },
                child: Icon(FLucideIcons.circleX, color: colors.mutedForeground),
              ),
    );
  }
}
