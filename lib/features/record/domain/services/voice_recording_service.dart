import 'dart:async';

import 'package:speech_to_text/speech_to_text.dart' as stt;

/// Wraps [stt.SpeechToText] with stream-based reactive state so UI can
/// observe recognition text, listening status, and sound level changes
/// without managing the low-level callback API directly.
class VoiceRecordingService {
  VoiceRecordingService({stt.SpeechToText? speech})
    : _speech = speech ?? stt.SpeechToText();

  final stt.SpeechToText _speech;

  // ---------------------------------------------------------------------------
  // Stream controllers
  // ---------------------------------------------------------------------------

  final StreamController<String> _textController =
      StreamController<String>.broadcast();
  final StreamController<bool> _listeningController =
      StreamController<bool>.broadcast();
  final StreamController<double> _soundLevelController =
      StreamController<double>.broadcast();
  final StreamController<String> _errorController =
      StreamController<String>.broadcast();

  // ---------------------------------------------------------------------------
  // Public streams
  // ---------------------------------------------------------------------------

  /// Emits the current recognized text as it updates.
  Stream<String> get recognizedTextStream => _textController.stream;

  /// Emits `true` when listening starts, `false` when it stops.
  Stream<bool> get listeningStatusStream => _listeningController.stream;

  /// Emits sound level values (0.0 – 1.0 normalized) during listening.
  Stream<double> get soundLevelStream => _soundLevelController.stream;

  /// Emits human-readable error messages.
  Stream<String> get errorStream => _errorController.stream;

  // ---------------------------------------------------------------------------
  // Properties
  // ---------------------------------------------------------------------------

  bool get isAvailable => _speech.isAvailable;
  bool get isListening => _speech.isListening;

  /// The accumulated recognized text from the current (or last) session.
  String get lastRecognizedWords => _speech.lastRecognizedWords;

  /// Whether the user has granted microphone permission.
  /// Can be called before [initialize].
  Future<bool> get hasPermission => _speech.hasPermission;

  // ---------------------------------------------------------------------------
  // Lifecycle
  // ---------------------------------------------------------------------------

  /// Initialize speech recognition. Call once before [startListening].
  ///
  /// Returns `true` if the recognizer is ready.
  /// May prompt the user for microphone permission on first call.
  Future<bool> initialize({required String localeId}) async {
    if (_speech.isAvailable) return true;

    final ok = await _speech.initialize(
      onError: (error) {
        if (!_errorController.isClosed) {
          _errorController.add(error.errorMsg);
        }
      },
      onStatus: (status) {
        if (status == stt.SpeechToText.listeningStatus) {
          _listeningController.add(true);
        } else if (status == stt.SpeechToText.notListeningStatus ||
            status == stt.SpeechToText.doneStatus) {
          _listeningController.add(false);
        }
      },
      debugLogging: false,
    );

    if (!ok) return false;

    // Optionally check if the requested locale is available.
    final locales = await _speech.locales();
    final hasLocale = locales.any((l) => l.localeId == localeId);
    return hasLocale;
  }

  /// Start listening and transcribing speech.
  ///
  /// Recognized text is emitted via [recognizedTextStream].
  /// Sound level changes are emitted via [soundLevelStream] (0.0-1.0).
  ///
  /// Throws if [initialize] has not been called.
  Future<void> startListening({required String localeId}) async {
    if (!_speech.isAvailable) {
      throw StateError(
        'VoiceRecordingService.startListening called before initialize.',
      );
    }

    await _speech.listen(
      onResult: (result) {
        if (!_textController.isClosed) {
          _textController.add(result.recognizedWords);
        }
      },
      onSoundLevelChange: (level) {
        // Normalize to 0.0-1.0 range (typical range is -2.0 to 10.0).
        final normalized = (level.clamp(-2.0, 10.0) + 2.0) / 12.0;
        if (!_soundLevelController.isClosed) {
          _soundLevelController.add(normalized);
        }
      },
      listenOptions: stt.SpeechListenOptions(
        localeId: localeId,
        partialResults: true,
        listenMode: stt.ListenMode.dictation,
        cancelOnError: false,
      ),
    );
  }

  /// Stop listening and return the final recognized text.
  ///
  /// After calling this, the platform delivers any remaining partial
  /// results as final. The accumulated text is available via
  /// [lastRecognizedWords].
  Future<String> stopListening() async {
    if (!_speech.isAvailable) return '';
    await _speech.stop();
    return _speech.lastRecognizedWords;
  }

  /// Cancel listening without expecting a final result.
  Future<void> cancelListening() async {
    if (!_speech.isAvailable) return;
    await _speech.cancel();
  }

  /// Dispose all stream controllers. Call when the service is no longer
  /// needed.
  void dispose() {
    _textController.close();
    _listeningController.close();
    _soundLevelController.close();
    _errorController.close();
  }
}
