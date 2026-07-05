import 'package:email_validator/email_validator.dart';
import 'package:formz/formz.dart';

class RequiredInput extends FormzInput<String, String> {
  const RequiredInput.pure([super.value = '']) : super.pure();
  const RequiredInput.dirty([super.value = '']) : super.dirty();

  @override
  String? validator(String value) {
    if (value.trim().isEmpty) {
      return ' ';
    }
    return null;
  }

  static String? validate(String? value, String message) {
    if ((value ?? '').trim().isEmpty) return message;
    return null;
  }
}

class EmailInput extends FormzInput<String, String> {
  const EmailInput.pure([super.value = '']) : super.pure();
  const EmailInput.dirty([super.value = '']) : super.dirty();

  @override
  String? validator(String value) {
    final trimmed = value.trim();
    if (trimmed.isEmpty) return ' ';
    if (!EmailValidator.validate(trimmed)) return ' ';
    return null;
  }

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

class CodeInput extends FormzInput<String, String> {
  const CodeInput.pure([super.value = '']) : super.pure();
  const CodeInput.dirty([super.value = '']) : super.dirty();

  @override
  String? validator(String value) {
    if (value.trim().isEmpty) return ' ';
    return null;
  }

  static String? validate(String? value, String message) {
    if ((value ?? '').trim().isEmpty) return message;
    return null;
  }
}

class PasswordInput extends FormzInput<String, String> {
  const PasswordInput.pure([super.value = '']) : super.pure();
  const PasswordInput.dirty([super.value = '']) : super.dirty();

  @override
  String? validator(String value) {
    if (value.trim().isEmpty) return ' ';
    return null;
  }

  static String? validate(String? value, String message) {
    if ((value ?? '').trim().isEmpty) return message;
    return null;
  }
}

class ConfirmPasswordInput extends FormzInput<String, String> {
  final String password;

  const ConfirmPasswordInput.pure({required this.password, String value = ''})
    : super.pure(value);
  const ConfirmPasswordInput.dirty({required this.password, String value = ''})
    : super.dirty(value);

  @override
  String? validator(String value) {
    if (value.trim().isEmpty) return ' ';
    if (value != password) return ' ';
    return null;
  }

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
