import 'package:flutter_test/flutter_test.dart';
import 'package:luminous/core/composition/a2ui/a2ui.dart';
import 'package:luminous/core/network/config/env_keys.dart';
import 'package:luminous/core/network/config/env_reader.dart';

/// The catalog id this build advertises.
///
/// It is configuration, not a code constant, and it must match Lucent's
/// server-side `A2UI_CATALOG_ID`: the agent writes `createSurface.catalogId`
/// from that value, the renderer registers its catalog under this one, and a
/// mismatch rejects every component in the batch with a schema error that looks
/// like the model's fault. These cases pin both halves — the default and the
/// override — because the failure mode is silent until the first generation.
void main() {
  tearDown(EnvReader.clearTestValues);

  test('defaults to a URN, not a domain-claiming URL', () {
    // A catalog id is a published identifier: it appears in every createSurface
    // the model emits. A URL default would assert a domain on the deployer's
    // behalf, so the default deliberately claims none.
    expect(GenerativeCatalog.catalogId, startsWith('urn:'));
    expect(GenerativeCatalog.catalogId, GenerativeCatalog.defaultCatalogId);
  });

  test('reads A2UI_CATALOG_ID when the build defines it', () {
    EnvReader.setTestValue(EnvKey.a2uiCatalogId, 'com.example.catalog.v1');

    expect(GenerativeCatalog.catalogId, 'com.example.catalog.v1');
  });

  test('the built catalog uses that id', () {
    EnvReader.setTestValue(EnvKey.a2uiCatalogId, 'com.example.catalog.v1');
    final catalog = GenerativeCatalog(domainComponents: const []);

    // `derive` is what stamps the id onto every component schema and onto the
    // document the server builds its prompt from; a getter that changed without
    // reaching the catalog would be configuration that does nothing.
    expect(catalog.catalog.id, 'com.example.catalog.v1');
    expect(catalog.toDocument()['catalogId'], 'com.example.catalog.v1');
  });

  test('a blank define falls back to the default', () {
    // `--dart-define=A2UI_CATALOG_ID=` (empty) happens when a workflow
    // interpolates an unset variable; that must not produce an empty id, which
    // would make the surface uncreatable.
    EnvReader.setTestValue(EnvKey.a2uiCatalogId, '   ');

    expect(GenerativeCatalog.catalogId, GenerativeCatalog.defaultCatalogId);
  });
}
