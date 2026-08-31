import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:luminous/core/widgets/common/dialog/sensitive_action_password_dialog.dart';

/// Prompts the user to confirm their account password before a sensitive
/// action. The default implementation shows the password confirmation dialog;
/// tests can override the provider to bypass UI and return a fixed value.
///
/// When [title], [message], or [label] are omitted, the dialog supplies
/// defaults from l10n:
/// - title: `authSensitiveActionPasswordDialogTitle`
/// - message: `authSensitiveActionPasswordDialogMessage`
/// - label: `authSensitiveActionPasswordDialogLabel`
typedef SensitiveActionPasswordPrompt =
    Future<String?> Function(
      BuildContext context, {
      String? title,
      String? message,
      String? label,
    });

final sensitiveActionPasswordPromptProvider =
    Provider<SensitiveActionPasswordPrompt>(
      (_) => requestPasswordForSensitiveAction,
    );
