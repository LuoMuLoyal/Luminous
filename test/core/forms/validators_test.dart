import 'package:flutter_test/flutter_test.dart';
import 'package:luminous/core/forms/validators.dart';

void main() {
  group('RequiredInput.validate', () {
    test('returns message when value is null', () {
      expect(RequiredInput.validate(null, 'required'), 'required');
    });

    test('returns message when value is empty', () {
      expect(RequiredInput.validate('', 'required'), 'required');
    });

    test('returns message when value is whitespace-only', () {
      expect(RequiredInput.validate('   ', 'required'), 'required');
    });

    test('returns null when value is non-empty', () {
      expect(RequiredInput.validate('hello', 'required'), isNull);
    });

    test('returns null when value has leading/trailing spaces but content', () {
      expect(RequiredInput.validate('  hello  ', 'required'), isNull);
    });
  });

  group('EmailInput.validate', () {
    test('returns requiredMessage when value is null', () {
      expect(
        EmailInput.validate(
          null,
          requiredMessage: 'required',
          invalidMessage: 'invalid',
        ),
        'required',
      );
    });

    test('returns requiredMessage when value is empty', () {
      expect(
        EmailInput.validate(
          '',
          requiredMessage: 'required',
          invalidMessage: 'invalid',
        ),
        'required',
      );
    });

    test('returns requiredMessage when value is whitespace-only', () {
      expect(
        EmailInput.validate(
          '   ',
          requiredMessage: 'required',
          invalidMessage: 'invalid',
        ),
        'required',
      );
    });

    test('returns invalidMessage for malformed email', () {
      expect(
        EmailInput.validate(
          'not-an-email',
          requiredMessage: 'required',
          invalidMessage: 'invalid',
        ),
        'invalid',
      );
    });

    test('returns null for valid email', () {
      expect(
        EmailInput.validate(
          'user@example.com',
          requiredMessage: 'required',
          invalidMessage: 'invalid',
        ),
        isNull,
      );
    });

    test('trims email before validation', () {
      expect(
        EmailInput.validate(
          '  user@example.com  ',
          requiredMessage: 'required',
          invalidMessage: 'invalid',
        ),
        isNull,
      );
    });

    test('returns invalidMessage for email without domain', () {
      expect(
        EmailInput.validate(
          'user@',
          requiredMessage: 'required',
          invalidMessage: 'invalid',
        ),
        'invalid',
      );
    });
  });

  group('CodeInput.validate', () {
    test('returns message when value is null', () {
      expect(CodeInput.validate(null, 'required'), 'required');
    });

    test('returns message when value is empty', () {
      expect(CodeInput.validate('', 'required'), 'required');
    });

    test('returns message when value is whitespace-only', () {
      expect(CodeInput.validate('   ', 'required'), 'required');
    });

    test('returns null when value is non-empty', () {
      expect(CodeInput.validate('123456', 'required'), isNull);
    });
  });

  group('PasswordInput.validate', () {
    test('returns message when value is null', () {
      expect(PasswordInput.validate(null, 'required'), 'required');
    });

    test('returns message when value is empty', () {
      expect(PasswordInput.validate('', 'required'), 'required');
    });

    test('returns message when value is whitespace-only', () {
      expect(PasswordInput.validate('   ', 'required'), 'required');
    });

    test('returns null when value is non-empty', () {
      expect(PasswordInput.validate('password123', 'required'), isNull);
    });
  });

  group('ConfirmPasswordInput.validate', () {
    test('returns requiredMessage when value is null', () {
      expect(
        ConfirmPasswordInput.validate(
          null,
          'password123',
          requiredMessage: 'required',
          mismatchMessage: 'mismatch',
        ),
        'required',
      );
    });

    test('returns requiredMessage when value is empty', () {
      expect(
        ConfirmPasswordInput.validate(
          '',
          'password123',
          requiredMessage: 'required',
          mismatchMessage: 'mismatch',
        ),
        'required',
      );
    });

    test('returns requiredMessage when value is whitespace-only', () {
      expect(
        ConfirmPasswordInput.validate(
          '   ',
          'password123',
          requiredMessage: 'required',
          mismatchMessage: 'mismatch',
        ),
        'required',
      );
    });

    test('returns mismatchMessage when passwords differ', () {
      expect(
        ConfirmPasswordInput.validate(
          'different',
          'password123',
          requiredMessage: 'required',
          mismatchMessage: 'mismatch',
        ),
        'mismatch',
      );
    });

    test('returns null when passwords match', () {
      expect(
        ConfirmPasswordInput.validate(
          'password123',
          'password123',
          requiredMessage: 'required',
          mismatchMessage: 'mismatch',
        ),
        isNull,
      );
    });

    test('returns mismatchMessage for whitespace difference', () {
      expect(
        ConfirmPasswordInput.validate(
          'password123 ',
          'password123',
          requiredMessage: 'required',
          mismatchMessage: 'mismatch',
        ),
        'mismatch',
      );
    });
  });
}
