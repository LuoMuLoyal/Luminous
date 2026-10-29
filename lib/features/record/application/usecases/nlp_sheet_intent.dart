import 'package:freezed_annotation/freezed_annotation.dart';

part 'nlp_sheet_intent.freezed.dart';

/// What an NLP-sheet request should do, decided without any UI.
///
/// The composer action (the header button that opens the natural-language
/// input sheet) has three possible outcomes; the presentation layer maps each
/// case onto "do nothing", "open the sheet" or "show the sign-in dialog".
@freezed
sealed class NlpSheetIntent with _$NlpSheetIntent {
  /// The session is still resolving: ignore the tap.
  const factory NlpSheetIntent.authLoading() = NlpSheetAuthLoadingIntent;

  /// The user is signed out: prompt to sign in.
  const factory NlpSheetIntent.needsSignIn() = NlpSheetNeedsSignInIntent;

  /// Open the sheet whose `occurredAt` is [occurredAt] (`yyyy-MM-dd`).
  const factory NlpSheetIntent.open({required String occurredAt}) =
      NlpSheetOpenIntent;
}

/// Resolves the NLP-sheet intent from the auth gate.
///
/// [occurredAt] is the selected day in `yyyy-MM-dd`; formatting stays at the
/// caller so the same wire formatter is used everywhere.
NlpSheetIntent resolveNlpSheetIntent({
  required bool canAccessProtectedData,
  required bool isAuthLoading,
  required String occurredAt,
}) {
  if (!canAccessProtectedData) {
    return isAuthLoading
        ? const NlpSheetIntent.authLoading()
        : const NlpSheetIntent.needsSignIn();
  }
  return NlpSheetIntent.open(occurredAt: occurredAt);
}
