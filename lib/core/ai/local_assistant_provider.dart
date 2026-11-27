import 'package:dio/dio.dart';
import 'package:llama_native/llama_native.dart';
import 'package:luminous/core/ai/local_assistant.dart';
import 'package:luminous/core/ai/model_manifest_source.dart';
import 'package:luminous/core/ai/model_store.dart';
import 'package:luminous/core/network/client/client_providers.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

part 'local_assistant_provider.g.dart';

/// The release manifest source.
///
/// A provider rather than a singleton so tests can override it with a
/// [StaticModelManifestSource] and drive the model screen without a network.
@riverpod
ModelManifestSource modelManifestSource(Ref ref) {
  final dio = ref.watch(lucentDioClientProvider).dio;
  return HttpModelManifestSource(
    url: ModelRelease.manifestUrl,
    get: (url) async {
      // `ResponseType.plain` keeps the body as text: the manifest is small, and
      // letting Dio decode it would give one parse path for JSON responses and
      // another for text ones, which is where the two drift.
      final response = await dio.get<String>(
        url.toString(),
        options: Options(responseType: ResponseType.plain),
      );
      final data = response.data;
      if (data == null || data.isEmpty) {
        throw FormatException('manifest response was empty: $url');
      }
      return data;
    },
  );
}

/// The on-disk model store.
@riverpod
Future<ModelStore> modelStore(Ref ref) => ModelStore.create();

/// The assembled assistant.
///
/// `keepAlive` because the engine holds gigabytes of resident memory: recreating
/// it whenever a dependency rebuilds would reload the model each time.
@Riverpod(keepAlive: true)
LocalAssistant localAssistant(Ref ref) {
  final store = ref.watch(modelStoreProvider).requireValue;
  final manifest = ref.watch(modelManifestSourceProvider);
  return LocalAssistant(
    store: store,
    manifest: manifest,
    // Constructing the bindings does not load the native library; that happens on
    // the first call, which keeps a cold start from paying for Rust when the
    // assistant is never opened.
    bridge: RustBridgeBindings(),
  );
}
