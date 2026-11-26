library;

import 'dart:convert';
import 'dart:ffi';
import 'dart:io';

import 'package:ffi/ffi.dart';

/// Raw bindings for `llama_shim.h`.
///
/// A pure mirror of the header: no logic, no error handling, no Dart objects.
/// Keeping it mechanical is what makes it reviewable against the header — every
/// mismatch between the two is a memory bug, and a memory bug in an FFI layer is
/// a segfault with no stack trace pointing at the cause.
///
/// ## Why a shim exists at all
///
/// See `src-native/llama_shim.h`: llama.cpp's C API renames functions and
/// reshapes structs between builds, and a binding generated for one build breaks
/// on the next. The shim is ~10 functions whose signatures this package owns.
/// `int32_t (*)(const char* piece, int32_t len, void* user_data)`
typedef TokenCallbackNative =
    Int32 Function(Pointer<Uint8> piece, Int32 len, Pointer<Void> userData);

typedef _BackendInitNative = Int32 Function(Pointer<Uint8>, Int32);
typedef _BackendFreeNative = Void Function();
typedef _ModelLoadNative =
    Pointer<Void> Function(Pointer<Uint8>, Int32, Int32, Pointer<Uint8>, Int32);
typedef _ModelFreeNative = Void Function(Pointer<Void>);
typedef _ModelMetaNative = Int32 Function(Pointer<Void>, Pointer<Uint8>, Int32);
typedef _ContextNewNative =
    Pointer<Void> Function(
      Pointer<Void>,
      Int32,
      Int32,
      Int32,
      Pointer<Uint8>,
      Int32,
    );
typedef _ContextFreeNative = Void Function(Pointer<Void>);
typedef _ContextResetNative = Void Function(Pointer<Void>);
typedef _TokenizeNative =
    Int32 Function(
      Pointer<Void>,
      Pointer<Uint8>,
      Int32,
      Pointer<Int32>,
      Int32,
      Int32,
    );
typedef _GenerateNative =
    Int32 Function(
      Pointer<Void>,
      Pointer<Void>,
      Pointer<Uint8>,
      Int32,
      Int32,
      Float,
      Float,
      Int32,
      Float,
      Float,
      Pointer<Uint8>,
      Pointer<Uint8>,
      Pointer<NativeFunction<TokenCallbackNative>>,
      Pointer<Void>,
      Pointer<Uint8>,
      Int32,
    );
typedef _ApplyTemplateNative =
    Int32 Function(Pointer<Void>, Pointer<Uint8>, Int32, Pointer<Uint8>, Int32);

typedef ModelLoadDart =
    Pointer<Void> Function(Pointer<Uint8>, int, int, Pointer<Uint8>, int);
typedef ContextNewDart =
    Pointer<Void> Function(Pointer<Void>, int, int, int, Pointer<Uint8>, int);
typedef TokenizeDart =
    int Function(Pointer<Void>, Pointer<Uint8>, int, Pointer<Int32>, int, int);
typedef GenerateDart =
    int Function(
      Pointer<Void>,
      Pointer<Void>,
      Pointer<Uint8>,
      int,
      int,
      double,
      double,
      int,
      double,
      double,
      Pointer<Uint8>,
      Pointer<Uint8>,
      Pointer<NativeFunction<TokenCallbackNative>>,
      Pointer<Void>,
      Pointer<Uint8>,
      int,
    );
typedef ApplyTemplateDart =
    int Function(Pointer<Void>, Pointer<Uint8>, int, Pointer<Uint8>, int);

/// The shim, with every entry point resolved once at construction.
///
/// Resolving up front turns a missing symbol into an immediate failure naming
/// it, instead of an `ArgumentError` halfway through a generation.
final class LlamaShim {
  LlamaShim._(DynamicLibrary library)
    : backendInit = library
          .lookupFunction<
            _BackendInitNative,
            int Function(Pointer<Uint8>, int)
          >('llama_shim_backend_init'),
      backendFree = library.lookupFunction<_BackendFreeNative, void Function()>(
        'llama_shim_backend_free',
      ),
      modelLoad = library.lookupFunction<_ModelLoadNative, ModelLoadDart>(
        'llama_shim_model_load',
      ),
      modelFree = library
          .lookupFunction<_ModelFreeNative, void Function(Pointer<Void>)>(
            'llama_shim_model_free',
          ),
      modelMeta = library
          .lookupFunction<
            _ModelMetaNative,
            int Function(Pointer<Void>, Pointer<Uint8>, int)
          >('llama_shim_model_meta'),
      contextNew = library.lookupFunction<_ContextNewNative, ContextNewDart>(
        'llama_shim_ctx_new',
      ),
      contextFree = library
          .lookupFunction<_ContextFreeNative, void Function(Pointer<Void>)>(
            'llama_shim_ctx_free',
          ),
      contextReset = library
          .lookupFunction<_ContextResetNative, void Function(Pointer<Void>)>(
            'llama_shim_ctx_reset',
          ),
      tokenize = library.lookupFunction<_TokenizeNative, TokenizeDart>(
        'llama_shim_tokenize',
      ),
      generate = library.lookupFunction<_GenerateNative, GenerateDart>(
        'llama_shim_generate',
      ),
      applyTemplate = library
          .lookupFunction<_ApplyTemplateNative, ApplyTemplateDart>(
            'llama_shim_apply_chat_template',
          );

  /// Opens the shim. Throws [ArgumentError] when a symbol is missing.
  factory LlamaShim.open({String? libraryPath}) {
    return LlamaShim._(DynamicLibrary.open(libraryPath ?? defaultLibraryName));
  }

  /// The name the platform loader resolves.
  ///
  /// Android puts it in `jniLibs`, iOS in the framework, and desktop builds place
  /// it beside the executable — all reachable by bare name, so no path juggling
  /// in Dart.
  static String get defaultLibraryName {
    if (Platform.isWindows) return 'llama_shim.dll';
    if (Platform.isMacOS) return 'libllama_shim.dylib';
    return 'libllama_shim.so';
  }

  final int Function(Pointer<Uint8>, int) backendInit;
  final void Function() backendFree;
  final ModelLoadDart modelLoad;
  final void Function(Pointer<Void>) modelFree;
  final int Function(Pointer<Void>, Pointer<Uint8>, int) modelMeta;
  final ContextNewDart contextNew;
  final void Function(Pointer<Void>) contextFree;
  final void Function(Pointer<Void>) contextReset;
  final TokenizeDart tokenize;
  final GenerateDart generate;
  final ApplyTemplateDart applyTemplate;
}

/// Encodes [text] as NUL-terminated UTF-8; the caller frees the result.
///
/// Uses `dart:convert` rather than a hand-rolled encoder: a CJK prompt through a
/// manual byte loop is exactly how truncation bugs get introduced.
Pointer<Uint8> toNativeUtf8(String text) {
  final encoded = utf8.encode(text);
  final buffer = malloc<Uint8>(encoded.length + 1);
  final view = buffer.asTypedList(encoded.length + 1);
  view.setAll(0, encoded);
  view[encoded.length] = 0;
  return buffer;
}

/// Decodes [length] bytes of UTF-8 from [buffer].
///
/// `allowMalformed` because a token can end mid-codepoint: a replacement
/// character is the correct outcome there, and throwing inside a native callback
/// has nowhere to propagate to.
String decodeUtf8(Pointer<Uint8> buffer, int length) =>
    utf8.decode(buffer.asTypedList(length), allowMalformed: true);

/// Reads a NUL-terminated UTF-8 string from a fixed-size error buffer.
String decodeErrorBuffer(Pointer<Uint8> buffer, int capacity) {
  final bytes = buffer.asTypedList(capacity);
  var end = 0;
  while (end < bytes.length && bytes[end] != 0) {
    end++;
  }
  return utf8.decode(bytes.sublist(0, end), allowMalformed: true);
}
