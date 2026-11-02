import 'package:fpdart/fpdart.dart';

/// OCR 链路的失败词汇（domain 值类型，无框架依赖）。
///
/// 为什么不是 exception：扫描流程的失败是**预期分支**（模型没下好、ABI 不
/// 支持、模型文件被篡改），调用方要么降级到 AI 识别、要么弹重试框。用
/// 可穷举的 failure 表达，调用方 switch 就必须处理；exception 会被
/// `catch (e)` 一网打尽，看起来"处理了"。
///
/// 它实现 [Exception] 而不是 Error：宿主接口
/// （`PaddleOcrEngine.ensureInitialized`、`OcrModelManager.downloadModels`）
/// 在 Future 通道里没有 Either 返回值可用，而 `Future<FutureEither<...>>`
/// 会把一次性发生的下载确认变成"要不要再来一次"的语义问题。让 failure 自己
/// 沿 Future 的错误通道上浮，是这条链路上唯一不需要调用方重新解析的形态；
/// 类型仍是可穷举的 [OcrFailure]，不是任意错误。
final class OcrFailure implements Exception {
  const OcrFailure._({required this.kind, this.fileName, this.detail});

  /// 模型文件尚未下载（首次使用，需要约 30MB 下载）。
  const OcrFailure.modelsNotDownloaded()
    : this._(kind: OcrFailureKind.modelsNotDownloaded);

  /// 下载后的文件 SHA-256 与钉死的摘要不一致：已删除该文件，绝不再加载。
  const OcrFailure.integrity(String fileName, String expected, String actual)
    : this._(
        kind: OcrFailureKind.integrityMismatch,
        fileName: fileName,
        detail: 'expected sha256 $expected, got $actual',
      );

  /// 原生引擎初始化失败（例如设备缺少所需 ABI 的库）。
  const OcrFailure.engineUnavailable([String? detail])
    : this._(kind: OcrFailureKind.engineUnavailable, detail: detail);

  final OcrFailureKind kind;

  /// 出问题的模型文件名（仅 [OcrFailureKind.integrityMismatch] 时有值）。
  final String? fileName;

  /// 开发者诊断信息；用户可见文案由 presentation 的 l10n 映射，不从这里取。
  final String? detail;

  @override
  String toString() =>
      'OcrFailure($kind${fileName == null ? '' : ', $fileName'}'
      '${detail == null ? '' : ', $detail'})';
}

/// [OcrFailure] 的可穷举分类。
enum OcrFailureKind {
  modelsNotDownloaded,
  integrityMismatch,
  engineUnavailable;

  /// 用户可以通过重试或下载修复的那一类失败。
  bool get isRetryable => this != OcrFailureKind.engineUnavailable;
}

/// 把会抛 [OcrFailure] 的调用收敛成 `TaskEither`，供组合根与 use case 使用。
///
/// 非 [OcrFailure] 的异常（平台通道、磁盘 I/O）按 `unknown` 归类，`cause`
/// 保留原始错误，不吞掉。
Future<Either<OcrFailure, T>> ocrFailureEither<T>(
  Future<T> Function() body,
) async {
  try {
    return Either.right(await body());
  } on OcrFailure catch (failure) {
    return Either.left(failure);
  }
}
