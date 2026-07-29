import 'dart:async';
import 'package:flutter/material.dart';
import 'package:luminous/core/feedback/toast.dart';
import 'package:luminous/l10n/app_localizations.dart';

void showMineToast(BuildContext context, String action) {
  final l10n = AppLocalizations.of(context)!;
  unawaited(Toast.show(context, l10n.mineActionToast(action)));
}
