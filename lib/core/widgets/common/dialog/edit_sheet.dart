import 'package:flutter/material.dart';
import 'package:forui/forui.dart';
import 'package:luminous/core/design/design.dart';
import 'package:luminous/core/widgets/common/dialog/sheet_drag_handle.dart';
import 'package:luminous/l10n/app_localizations.dart';

/// Opens a bottom sheet that edits a single field and resolves what the user
/// confirmed.
///
/// The sheet owns the surface (opaque, via [SheetSurface]), the title and the
/// cancel/confirm actions; [body] renders only the field and reports its value
/// to [onChanged]. The caller decides what to write — the sheet never touches
/// account or health state itself.
///
/// [keepAlive] lets the body hold a controller: pass `true` and it stays mounted
/// for the whole route lifetime, so the controller can be disposed in the body's
/// own `State.dispose` rather than by a caller that only sees the route pop.
Future<bool> showAppEditSheet({
  required BuildContext context,
  required String title,
  required Widget Function(BuildContext context) body,
  String? confirmLabel,
  String? cancelLabel,
  bool isSaving = false,
}) async {
  final l10n = AppLocalizations.of(context)!;
  final result = await showFSheet<bool>(
    context: context,
    side: FLayout.btt,
    useSafeArea: true,
    resizeToAvoidBottomInset: true,
    builder: (sheetContext) => SheetSurface(
      child: SingleChildScrollView(
        padding: const EdgeInsets.fromLTRB(
          Spacing.xl,
          0,
          Spacing.xl,
          Spacing.xl,
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            const SheetDragHandle(),
            Text(
              title,
              textAlign: TextAlign.center,
              style: sheetContext.theme.typography.body.lg.copyWith(
                fontWeight: FontWeight.w700,
              ),
            ),
            const SizedBox(height: Spacing.xl),
            body(sheetContext),
            const SizedBox(height: Spacing.xl),
            Row(
              children: [
                Expanded(
                  child: FButton(
                    variant: FButtonVariant.outline,
                    onPress: isSaving
                        ? null
                        : () => Navigator.of(sheetContext).pop(false),
                    child: Text(cancelLabel ?? l10n.commonCancel),
                  ),
                ),
                const SizedBox(width: Spacing.lg),
                Expanded(
                  child: FButton(
                    onPress: isSaving
                        ? null
                        : () => Navigator.of(sheetContext).pop(true),
                    prefix: isSaving
                        ? const SizedBox(
                            width: 16,
                            height: 16,
                            child: FCircularProgress(),
                          )
                        : null,
                    child: Text(confirmLabel ?? l10n.mineEditSaveAction),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    ),
  );
  return result ?? false;
}

/// A mutable slot the body writes its current value into.
///
/// Nothing is disposed here, so a write that lands after the route pop (the
/// exit transition is still running) is harmless.
class SheetValueSlot<T> {
  SheetValueSlot(this.value);

  T value;
}

/// Opens a sheet for a field that reports its value through a [SheetValueSlot],
/// and resolves the [slot] value when the user confirms, `null` otherwise.
///
/// Use this for anything that is not a plain text field (date pickers, selects):
/// the body owns whatever controller it needs and writes the current value into
/// the slot on every change, so the caller never holds a disposable object.
Future<T?> showValueEditSheet<T>({
  required BuildContext context,
  required String title,
  required SheetValueSlot<T> slot,
  required Widget Function(BuildContext context, SheetValueSlot<T> slot) body,
  bool isSaving = false,
}) async {
  final confirmed = await showAppEditSheet(
    context: context,
    title: title,
    isSaving: isSaving,
    body: (sheetContext) => body(sheetContext, slot),
  );
  return confirmed ? slot.value : null;
}

/// Opens a single text field sheet and resolves the trimmed value, or `null`
/// when the user cancels or confirms an empty field.
///
/// The controller lives in this sheet's own [State] and the value is captured at
/// the moment of confirmation. That is what keeps disposal correct: the caller
/// never touches the controller, so it cannot dispose it while the route's exit
/// transition is still listening.
Future<String?> showTextEditSheet({
  required BuildContext context,
  required String title,
  String? label,
  String? hint,
  String? initialValue,
  TextInputType? keyboardType,
}) async {
  final result = _TextSheetResult();
  final confirmed = await showFSheet<bool>(
    context: context,
    side: FLayout.btt,
    useSafeArea: true,
    resizeToAvoidBottomInset: true,
    builder: (sheetContext) => _TextEditSheet(
      title: title,
      label: label ?? title,
      hint: hint,
      initialValue: initialValue,
      keyboardType: keyboardType,
      result: result,
    ),
  );
  return confirmed == true ? result.value : null;
}

/// Captures the confirmed text out of the sheet's own controller.
class _TextSheetResult {
  String? value;
}

class _TextEditSheet extends StatefulWidget {
  const _TextEditSheet({
    required this.title,
    required this.label,
    required this.result,
    this.hint,
    this.initialValue,
    this.keyboardType,
  });

  final String title;
  final String label;
  final _TextSheetResult result;
  final String? hint;
  final String? initialValue;
  final TextInputType? keyboardType;

  @override
  State<_TextEditSheet> createState() => _TextEditSheetState();
}

class _TextEditSheetState extends State<_TextEditSheet> {
  late final TextEditingController _controller = TextEditingController(
    text: widget.initialValue ?? '',
  );

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  void _confirm() {
    final value = _controller.text.trim();
    if (value.isEmpty) {
      Navigator.of(context).pop(false);
      return;
    }
    widget.result.value = value;
    Navigator.of(context).pop(true);
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    return SheetSurface(
      child: SingleChildScrollView(
        padding: const EdgeInsets.fromLTRB(
          Spacing.xl,
          0,
          Spacing.xl,
          Spacing.xl,
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            const SheetDragHandle(),
            Text(
              widget.title,
              textAlign: TextAlign.center,
              style: context.theme.typography.body.lg.copyWith(
                fontWeight: FontWeight.w700,
              ),
            ),
            const SizedBox(height: Spacing.xl),
            FTextField(
              key: const Key('edit-sheet-text-field'),
              control: FTextFieldControl.managed(controller: _controller),
              label: Text(widget.label),
              hint: widget.hint,
              keyboardType: widget.keyboardType,
              autofocus: true,
            ),
            const SizedBox(height: Spacing.xl),
            Row(
              children: [
                Expanded(
                  child: FButton(
                    variant: FButtonVariant.outline,
                    onPress: () => Navigator.of(context).pop(false),
                    child: Text(l10n.commonCancel),
                  ),
                ),
                const SizedBox(width: Spacing.lg),
                Expanded(
                  child: FButton(
                    onPress: _confirm,
                    child: Text(l10n.mineEditSaveAction),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
