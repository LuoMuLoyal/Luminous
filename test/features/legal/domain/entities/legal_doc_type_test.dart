import 'package:flutter_test/flutter_test.dart';
import 'package:luminous/features/legal/domain/entities/doc_type.dart';

void main() {
  group('LegalDocType', () {
    test('fromPathSegment parses known types', () {
      expect(LegalDocType.fromPathSegment('terms'), LegalDocType.terms);
      expect(LegalDocType.fromPathSegment('privacy'), LegalDocType.privacy);
      expect(
        LegalDocType.fromPathSegment('disclaimer'),
        LegalDocType.disclaimer,
      );
      expect(
        LegalDocType.fromPathSegment('minor-protection'),
        LegalDocType.minorProtection,
      );
      expect(LegalDocType.fromPathSegment('sdk-list'), LegalDocType.sdkList);
      expect(
        LegalDocType.fromPathSegment('permissions'),
        LegalDocType.permissions,
      );
      expect(
        LegalDocType.fromPathSegment('account-cancellation'),
        LegalDocType.accountCancellation,
      );
    });

    test('fromPathSegment returns null for unknown types', () {
      expect(LegalDocType.fromPathSegment('unknown'), isNull);
      expect(LegalDocType.fromPathSegment(''), isNull);
      expect(LegalDocType.fromPathSegment(null), isNull);
    });

    test('pathSegment is correct for each type', () {
      expect(LegalDocType.terms.pathSegment, 'terms');
      expect(LegalDocType.privacy.pathSegment, 'privacy');
      expect(LegalDocType.disclaimer.pathSegment, 'disclaimer');
      expect(LegalDocType.minorProtection.pathSegment, 'minor-protection');
      expect(LegalDocType.sdkList.pathSegment, 'sdk-list');
      expect(LegalDocType.permissions.pathSegment, 'permissions');
      expect(
        LegalDocType.accountCancellation.pathSegment,
        'account-cancellation',
      );
    });
  });
}
