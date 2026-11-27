import 'package:dio/dio.dart';
import 'package:llama_native/llama_native.dart';
import 'package:luminous/core/network/client/client_providers.dart';
import 'package:luminous/core/network/config/pref_keys.dart';
import 'package:luminous/core/storage/kv_store.dart';
import 'package:luminous/features/settings/data/local_model/assistant.dart';
import 'package:luminous/features/settings/data/local_model/device_memory_probe.dart';
import 'package:luminous/features/settings/data/local_model/resolver.dart';
import 'package:luminous/features/settings/data/local_model/store.dart';
import 'package:luminous/features/settings/domain/device_memory.dart';
import 'package:luminous/features/settings/domain/local_model/catalog.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

part 'local_model_assistant.g.dart';

/// Resolves catalogue entries to digest-bearing descriptors.
///
/// A provider rather than a singleton so tests can inject a resolver that answers
/// from a fixture, driving the picker without a network.
@riverpod
ModelSourceResolver modelSourceResolver(Ref ref) {
  final dio = ref.watch(lucentDioClientProvider).dio;
  return HuggingFaceModelResolver(
    get: (url) async {
      // `ResponseType.plain` keeps the body as text. The tree listing is small, and
      // letting Dio decode it would give one parse path for JSON and another for
      // text — which is where the two drift apart.
      final response = await dio.get<String>(
        url.toString(),
        options: Options(responseType: ResponseType.plain),
      );
      final data = response.data;
      if (data == null || data.isEmpty) {
        throw ModelManifestException('empty response from $url');
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
/// `keepAlive` because the engine holds gigabytes of resident memory: recreating it
/// whenever a dependency rebuilds would reload the model each time.
@Riverpod(keepAlive: true)
LocalAssistant localAssistant(Ref ref) {
  final store = ref.watch(modelStoreProvider).requireValue;
  final resolver = ref.watch(modelSourceResolverProvider);
  return LocalAssistant(
    store: store,
    resolver: resolver,
    // Constructing the bindings does not load the native library; that happens on
    // the first call, keeping a cold start from paying for Rust when the assistant
    // is never opened.
    bridge: RustBridgeBindings(),
  );
}

/// The model the user last chose, from `KvStore`.
///
/// Returns null when nothing was chosen: the first run should not silently commit
/// the user to a model they did not pick.
@riverpod
ModelSource? selectedModelSource(Ref ref) {
  final stored = KvStore.instance.getOrNull<String>(PrefKeys.localModelId);
  if (stored == null || stored.isEmpty) return null;
  for (final source in availableModels) {
    if (source.id == stored) return source;
  }
  // A stored id whose entry was removed (model delisted, catalogue shrunk) must not
  // leave the screen pointing at nothing; falling back to unselected asks the user
  // again rather than failing later.
  return null;
}

/// Persists the user's model choice.
///
/// Only the [ModelSource.id] is stored, not a resolved descriptor: the digest and
/// size are re-read from the host on each run, and persisting them would freeze a
/// value that is supposed to track the served bytes.
Future<void> persistSelectedModel(Ref ref, ModelSource source) async {
  await KvStore.instance.set(PrefKeys.localModelId, source.id);
  ref.invalidate(selectedModelSourceProvider);
}

/// Device memory, as an override point.
///
/// Exposed from the composition root rather than the picker so the platform probe
/// (which imports `device_info_plus`) stays out of the presentation layer.
@Riverpod(keepAlive: true)
DeviceMemoryProbe localModelMemory(Ref ref) => const PlatformMemoryProbe();

/// Remembers and clears the user's model choice.
///
/// Owns the `KvStore` write because the presentation layer may not touch storage.
/// Only the [ModelSource.id] is stored: the digest and size are re-read from the
/// host on each run, and persisting them would freeze a value that must track the
/// served bytes.
@Riverpod(keepAlive: true)
class LocalModelSelection extends _$LocalModelSelection {
  @override
  ModelSource? build() {
    final stored = KvStore.instance.getOrNull<String>(PrefKeys.localModelId);
    if (stored == null || stored.isEmpty) return null;
    for (final source in availableModels) {
      if (source.id == stored) return source;
    }
    // A stored id whose entry was removed must not leave the screen pointing at
    // nothing; falling back to unselected asks the user again rather than failing
    // later.
    return null;
  }

  Future<void> remember(ModelSource source) async {
    state = source;
    await KvStore.instance.set(PrefKeys.localModelId, source.id);
  }

  Future<void> forget() async {
    state = null;
    await KvStore.instance.set(PrefKeys.localModelId, null);
  }
}
