/// Legal document type identifiers.
///
/// The [pathSegment] matches the hyphenated form used in route paths
/// and the backend `docType` field.
enum LegalDocType {
  terms('terms'),
  privacy('privacy'),
  disclaimer('disclaimer'),
  minorProtection('minor-protection'),
  sdkList('sdk-list'),
  permissions('permissions'),
  accountCancellation('account-cancellation');

  final String pathSegment;
  const LegalDocType(this.pathSegment);

  /// O(1) lookup map from path segment to [LegalDocType].
  static final Map<String, LegalDocType> _byPathSegment = {
    for (final type in LegalDocType.values) type.pathSegment: type,
  };

  /// Parses a path segment into a [LegalDocType].
  ///
  /// Returns `null` for unrecognized values so the caller can redirect
  /// to the list page or show an error state.
  static LegalDocType? fromPathSegment(String? value) {
    if (value == null) return null;
    return _byPathSegment[value];
  }
}
