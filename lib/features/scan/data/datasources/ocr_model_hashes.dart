/// SHA-256 digests of the OCR model files served from the pinned GitHub
/// release. These match `pkgs/paddle_ocr_native-0.1.1/doc/model-provenance.md`
/// and pin the exact bytes loaded into the ONNX Runtime.
///
/// On-demand model downloads MUST verify these digests before use: the model
/// files are executed by the native OCR engine, so a tampered or replaced
/// file is a supply-chain risk. When the model distribution channel or the
/// upstream release changes, update these hashes AND the provenance doc
/// together.
library;

/// SHA-256 of `det_inference.onnx` (PP-OCRv6 small detection model).
const String detModelSha256 =
    'd73e0058b7a8086bbd57f3d10b8bcd4ff95363f67e06e2762b5e814fe9c9410e';

/// SHA-256 of `rec_inference.onnx` (PP-OCRv6 small recognition model).
const String recModelSha256 =
    '5435fd747c9e0efe15a96d0b378d5bd157e9492ed8fd80edf08f30d02fa24634';

/// SHA-256 of `rec_inference.yml` (recognition config + character set).
const String recConfigSha256 =
    'ab078671bb49f06228eadccd34f1bb501e157f7a047095ffb943ba81512c77d1';
