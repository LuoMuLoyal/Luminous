import 'package:luminous/core/i18n/locale.dart';
import 'package:luminous/core/network/client/client_providers.dart';
import 'package:luminous/features/legal/data/repositories/lucent.dart';
import 'package:luminous/features/legal/domain/repositories/documents.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

part 'legal.g.dart';

/// Composition-root glue for the legal feature.
///
/// `data/` may not read `core/i18n` (locale *state*); it only accepts a wire
/// language tag. The locale is resolved here and pushed into the repository
/// through its constructor.

/// The `lang` parameter the legal-documents endpoints take.
@riverpod
String legalDocumentLanguage(Ref ref) {
  final locale = ref.watch(localeControllerProvider).asData?.value;
  return (locale ?? AppLocale.system).acceptLanguage.startsWith('en')
      ? 'en'
      : 'zh';
}

@riverpod
LegalRepository legalRepository(Ref ref) {
  return LucentLegalRepository(
    api: ref.watch(lucentClientProvider).legalDocuments,
    localeResolver: () => ref.read(legalDocumentLanguageProvider),
  );
}
