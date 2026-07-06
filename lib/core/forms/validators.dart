import 'package:email_validator/email_validator.dart';

/// Validates that a value is not empty after trimming.
///
/// Returns [message] when the value is null or whitespace-only.
abstract final class RequiredInput {
  static String? validate(String? value, String message) {
    if ((value ?? '').trim().isEmpty) return message;
    return null;
  }
}

/// Validates an email address.
///
/// Returns [requiredMessage] when empty, [invalidMessage] when malformed.
abstract final class EmailInput {
  static String? validate(
    String? value, {
    required String requiredMessage,
    required String invalidMessage,
  }) {
    final trimmed = (value ?? '').trim();
    if (trimmed.isEmpty) return requiredMessage;
    if (!EmailValidator.validate(trimmed)) return invalidMessage;
    return null;
  }
}

/// Validates that a verification code is not empty.
///
/// Returns [message] when the value is null or whitespace-only.
abstract final class CodeInput {
  static String? validate(String? value, String message) {
    if ((value ?? '').trim().isEmpty) return message;
    return null;
  }
}

/// Validates that a password is not empty.
///
/// Returns [message] when the value is null or whitespace-only.
abstract final class PasswordInput {
  static String? validate(String? value, String message) {
    if ((value ?? '').trim().isEmpty) return message;
    return null;
  }
}

/// Validates that a confirm-password value matches the original password.
///
/// Returns [requiredMessage] when empty, [mismatchMessage] when the
/// two values differ.
abstract final class ConfirmPasswordInput {
  static String? validate(
    String? value,
    String password, {
    required String requiredMessage,
    required String mismatchMessage,
  }) {
    if ((value ?? '').trim().isEmpty) return requiredMessage;
    if (value != password) return mismatchMessage;
    return null;
  }
}
