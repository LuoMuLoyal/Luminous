import 'doc_type.dart';

/// Metadata item for a legal document in list views.
class LegalDocumentSummary {
  const LegalDocumentSummary({
    required this.docType,
    required this.title,
    required this.updatedAt,
  });

  final LegalDocType docType;
  final String title;
  final String updatedAt;
}

/// Full legal document with Markdown content.
class LegalDocument {
  const LegalDocument({
    required this.docType,
    required this.title,
    required this.content,
    required this.updatedAt,
  });

  final LegalDocType docType;
  final String title;
  final String content;
  final String updatedAt;
}
