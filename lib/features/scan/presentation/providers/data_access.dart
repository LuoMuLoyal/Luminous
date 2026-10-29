/// scan feature 展示层的数据接缝。
///
/// 展示层不应直接 import `scan/data/`。这里把它再导出一次，作为展示层唯一入口。
library;

export 'package:luminous/features/scan/data/datasources/ocr_model_manager.dart'
    show OcrModelManager, ocrModelManagerProvider;
export 'package:luminous/features/scan/data/datasources/paddle_ocr_provider.dart'
    show paddleOcrProvider;
export 'package:luminous/features/scan/data/repositories/scan.dart'
    show scanRepositoryProvider;
