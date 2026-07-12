import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:luminous/features/legal/domain/entities/legal_doc_type.dart';
import 'package:luminous/features/legal/domain/entities/legal_document.dart';
import 'package:luminous/features/legal/domain/repositories/documents.dart';
import 'package:luminous/features/legal/presentation/providers/legal.dart';

void main() {
  group('legalDocumentsProvider', () {
    test('returns summaries from repository', () async {
      final container = ProviderContainer(
        overrides: [
          legalRepositoryProvider.overrideWithValue(_MockLegalRepository()),
        ],
      );
      addTearDown(container.dispose);

      final result = await container.read(legalDocumentsProvider.future);

      expect(result, hasLength(3));
      expect(result[0].docType, LegalDocType.terms);
      expect(result[0].title, 'Terms of Service');
      expect(result[1].docType, LegalDocType.privacy);
      expect(result[1].title, 'Privacy Policy');
      expect(result[2].docType, LegalDocType.disclaimer);
      expect(result[2].title, 'Disclaimer');
    });

    test('propagates error when repository throws', () async {
      final container = ProviderContainer(
        overrides: [
          legalRepositoryProvider.overrideWithValue(_ThrowingLegalRepository()),
        ],
      );
      addTearDown(container.dispose);

      // Listen to keep the autoDispose provider alive and observe state changes.
      container.listen(
        legalDocumentsProvider,
        (_, __) {},
        fireImmediately: true,
      );

      // Pump microtasks to let the future settle.
      await Future.delayed(const Duration(milliseconds: 10));

      final state = container.read(legalDocumentsProvider);
      expect(state.hasError, isTrue);
    });
  });

  group('legalDocumentProvider', () {
    test('returns document for given docType', () async {
      final container = ProviderContainer(
        overrides: [
          legalRepositoryProvider.overrideWithValue(_MockLegalRepository()),
        ],
      );
      addTearDown(container.dispose);

      final result = await container.read(
        legalDocumentProvider(LegalDocType.terms).future,
      );

      expect(result.docType, LegalDocType.terms);
      expect(result.title, 'Terms of Service');
      expect(result.content, contains('Service'));
    });

    test('returns different document for different docType', () async {
      final container = ProviderContainer(
        overrides: [
          legalRepositoryProvider.overrideWithValue(_MockLegalRepository()),
        ],
      );
      addTearDown(container.dispose);

      final result = await container.read(
        legalDocumentProvider(LegalDocType.privacy).future,
      );

      expect(result.docType, LegalDocType.privacy);
      expect(result.title, 'Privacy Policy');
      expect(result.content, contains('Privacy'));
    });
  });
}

class _MockLegalRepository implements LegalRepository {
  @override
  Future<List<LegalDocumentSummary>> findAll() async {
    return const [
      LegalDocumentSummary(
        docType: LegalDocType.terms,
        title: 'Terms of Service',
        updatedAt: '2026-07-11T00:00:00Z',
      ),
      LegalDocumentSummary(
        docType: LegalDocType.privacy,
        title: 'Privacy Policy',
        updatedAt: '2026-07-11T00:00:00Z',
      ),
      LegalDocumentSummary(
        docType: LegalDocType.disclaimer,
        title: 'Disclaimer',
        updatedAt: '2026-07-11T00:00:00Z',
      ),
    ];
  }

  @override
  Future<LegalDocument> findOne(LegalDocType docType) async {
    return LegalDocument(
      docType: docType,
      title: switch (docType) {
        LegalDocType.terms => 'Terms of Service',
        LegalDocType.privacy => 'Privacy Policy',
        LegalDocType.disclaimer => 'Disclaimer',
        _ => 'Unknown',
      },
      content: switch (docType) {
        LegalDocType.terms => '# Terms of Service\n\nContent.',
        LegalDocType.privacy => '# Privacy Policy\n\nContent.',
        LegalDocType.disclaimer => '# Disclaimer\n\nContent.',
        _ => '# Unknown',
      },
      updatedAt: '2026-07-11T00:00:00Z',
    );
  }
}

class _ThrowingLegalRepository implements LegalRepository {
  @override
  Future<List<LegalDocumentSummary>> findAll() async {
    throw Exception('Network error');
  }

  @override
  Future<LegalDocument> findOne(LegalDocType docType) async {
    throw Exception('Network error');
  }
}
