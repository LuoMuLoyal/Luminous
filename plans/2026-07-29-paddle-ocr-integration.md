# 计划：集成 paddle_ocr_native 替换 google_mlkit_text_recognition

创建日期：2026-07-29
状态：待执行

## 背景

当前药品盒拍照识别的离线 OCR 路径使用 `google_mlkit_text_recognition`（ML Kit Text Recognition v2），
存在以下核心问题：

1. **中文识别质量差**：ML Kit 的中文模型是通用多语种模型，非中文专用；对药盒常见的曲面文字、
   烫金/银箔反光文字、极小字号、复杂背景等场景命中率低。
2. **后处理算法薄弱**：`text_matcher.dart` 的正则匹配零容错（OCR 常见混淆字符即失败），
   停用词表仅 20 个词，品名提取仅取前 5 个 CJK 段无空间感知，置信度评分无意义。
3. **模型旧**：ML Kit v2 模型多年未更新；PaddleOCR 已到 PP-OCRv6（2025 最新）。

`paddle_ocr_native`（pub.dev，Apache 2.0）基于 PaddleOCR PP-OCRv6 + ONNX Runtime，
是中文 OCR 的事实标准，且返回文本坐标+置信度，可大幅改善后处理算法精度。

## 方案对比

| 维度 | google_mlkit_text_recognition | paddle_ocr_native |
|------|-------------------------------|--------------------|
| 模型 | ML Kit v2（通用多语种） | PP-OCRv6 small（中文专用） |
| 中文场景质量 | 差（曲面/反光/小字场景大量失败） | 好（DB 检测算法为自然场景设计） |
| 返回数据 | 纯文本 | text + confidence + 四点坐标 + boundingBox |
| GMS 依赖 | 无 | 无 |
| 模型管理 | 随插件自动集成 | 随插件打包（~29 MB，安装时自带） |
| 推理引擎 | ML Kit 内部 | ONNX Runtime 1.21 + OpenCV |
| 平台支持 | Android / iOS / Web | Android API 26+ (arm64) / iOS 16+ (arm64 真机) |
| 协议 | Apache 2.0 | Apache 2.0 |

## 架构设计：围绕 paddle_ocr_native 最佳实践

### 旧架构（ML Kit 模式）

```
box_scan.dart
  → OcrService (无状态，每次拍照创建+销毁 TextRecognizer)
    → recognizeText(XFile) → String（纯文本）
  → MedicineTextMatcher (无状态)
    → extractCandidates(String) → List<MedicineMatchCandidate>
  → repo.search(candidate.query)
```

旧模式的特征：OCR 引擎无状态、每次拍照都 init/dispose、返回纯文本字符串、后处理靠正则从字符串中抽取信息。

### 新架构（PaddleOCR 模式）

`paddle_ocr_native` 的最佳实践与 ML Kit 根本不同：

1. **`PaddleOcr` 是进程级共享引擎**——`init()` 创建两个 ONNX Runtime session，应复用而非每次拍照重建。
2. **输入是绝对路径字符串**，不是 `XFile` 或 `InputImage`。
3. **返回结构化 `OcrRun`**——包含 `List<OcrResult>`，每个 result 有 `text`、`confidence`、`points`（四点多边形）、`boundingBox`（轴对齐 Rect），还有 `detectionTimeMs` / `recognitionTimeMs` 性能数据。
4. **有可调配置**——`PaddleOcrConfig` 可调 DB 检测阈值、unclip 比例、batch size 等，有 `handwrittenRows` 预设。

因此新架构不再沿用 "OcrService → 纯文本 → TextMatcher 从字符串抽取" 的旧模式，
而是围绕引擎生命周期管理和结构化结果处理重新设计：

```
box_scan.dart
  → paddleOcrProvider (Riverpod, 进程级单例, lazy init)
    → ocr.recognize(absolutePath) → OcrRun (含 List<OcrResult>)
  → MedicineOcrExtractor (无状态纯逻辑)
    → extractCandidates(OcrRun) → List<MedicineMatchCandidate>
      基于坐标面积排序 + 置信度 + 停用词过滤 + 正则模糊匹配
  → repo.search(candidate.query)
```

核心区别：
- OCR 引擎从 "用完即弃" 变为 "进程级长驻"（Riverpod provider 管理生命周期）
- OCR 结果从 `String` 变为 `OcrRun`（含每个文本块的坐标和置信度）
- 候选提取从 "正则从纯文本抽取" 变为 "基于空间布局+置信度+模糊正则的综合评分"

## 影响范围

### 需修改的文件

| 文件 | 变更内容 |
|------|---------|
| `pubspec.yaml` | 移除 `google_mlkit_text_recognition: ^0.15.1`，新增 `paddle_ocr_native: ^0.1.1` |
| `lib/features/scan/domain/services/ocr.dart` | 删除旧 `OcrService`，替换为 `paddleOcrProvider` |
| `lib/features/scan/domain/services/text_matcher.dart` | 删除旧 `MedicineTextMatcher`，替换为 `MedicineOcrExtractor` |
| `lib/features/scan/domain/entities/scan_result.dart` | 新增 `OcrTextBlock` 域实体（可选：直接用插件类型则跳过） |
| `lib/features/scan/presentation/pages/box_scan.dart` | 适配新 OCR 调用方式和返回类型 |
| `android/app/build.gradle.kts` | 移除 ML Kit 手动依赖，新增 abiFilters arm64-v8a |
| `ios/Podfile` | platform 升至 16.0；改为 static linkage |
| `test/record/ocr_test.dart` | 删除旧测试，新增 `MedicineOcrExtractor` 单元测试 |
| `assets/legal/sdk-list_zh.md` | 更新 SDK 清单（移除 ML Kit，新增 PaddleOCR/ONNX Runtime） |
| `assets/legal/sdk-list_en.md` | 同上英文版 |

### 平台约束（已确认接受）

1. **iOS 最低版本提升至 16.0**：已确认。iOS 16 于 2022 年 9 月发布，覆盖率 > 95%。
2. **iOS 模拟器不可用**：`paddle_ocr_native` 的 OpenCV 4.3 依赖不含 Apple Silicon simulator slice。
   iOS OCR 测试需在真机上进行，开发期通过单元测试覆盖逻辑层。
3. **Android ABI 限制**：仅 `arm64-v8a`。Google Play 自 2019 年起要求 64 位，影响面极小。
4. **不支持 Web**：`paddle_ocr_native` 不支持 Web 平台。Web 端走 AI 路径（已实现），不提供离线 OCR。
5. **App 体积增加**：PaddleOCR 模型 ~29 MB 打包在插件内。当前 ML Kit 的中文模型约 ~20 MB，
   净增约 ~9 MB，可接受。

## 实施步骤

### Phase 1：依赖替换与平台配置

- [ ] `pubspec.yaml`：移除 `google_mlkit_text_recognition`，新增 `paddle_ocr_native: ^0.1.1`
- [ ] `flutter pub get`
- [ ] `android/app/build.gradle.kts`：
  - 移除 `dependencies` 块中 4 个 ML Kit `text-recognition-*` 手动依赖
  - `defaultConfig.ndk` 新增 `abiFilters += "arm64-v8a"`
  - `packaging.jniLibs.excludes` 排除非 arm64 ABI 目录
- [ ] `ios/Podfile`：
  - `platform :ios, '16.0'`
  - `use_frameworks! :linkage => :static`
  - `post_install` 中 `IPHONEOS_DEPLOYMENT_TARGET` 改为 `16.0`

### Phase 2：OCR 引擎 Provider

按照 `paddle_ocr_native` 的最佳实践，`PaddleOcr` 是进程级共享引擎，应初始化一次并复用。

- [ ] 删除 `lib/features/scan/domain/services/ocr.dart` 中的旧 `OcrService` 和 `ocrScriptForLocale`
- [ ] 新建 `lib/features/scan/domain/services/paddle_ocr_provider.dart`：
  - 使用 Riverpod 创建 `paddleOcrProvider`——一个 `AsyncNotifier` 或 `Provider`
  - lazy init：首次被 `read` 时调用 `PaddleOcr().init(config: const PaddleOcrConfig())`
  - 提供 `recognize(String absolutePath)` 方法，返回插件的 `OcrRun` 类型
  - `dispose` 时调用 `ocr.dispose()`
  - 不需要 `XFile` 转换——`paddle_ocr_native` 直接接受文件路径
- [ ] 评估是否需要域层 `OcrTextBlock` 实体：
  - 如果插件 `OcrResult` 类型直接暴露了 `text`、`confidence`、`boundingBox`、`points`，
    且域层/测试层可以直接使用，则不需要额外包装
  - 如果需要在域层隔离插件类型（便于 mock 测试），则新建 `OcrTextBlock` 到 `scan_result.dart`

### Phase 3：候选提取器重写

旧 `MedicineTextMatcher` 的三策略串行架构（批准文号 → 条形码 → 品名模糊）是围绕纯文本设计的。
新方案不再从纯文本字符串中抽取，而是直接操作结构化的 `OcrResult` 列表。

- [ ] 删除 `lib/features/scan/domain/services/text_matcher.dart` 中的旧 `MedicineTextMatcher`
- [ ] 新建 `lib/features/scan/domain/services/medicine_ocr_extractor.dart`：
  - 类 `MedicineOcrExtractor`（无状态纯逻辑，可直接单元测试）
  - 输入：`OcrRun`（或 `List<OcrTextBlock>` 如果选择域隔离）
  - 输出：`List<MedicineMatchCandidate>`（保留现有 `MedicineMatchCandidate` / `MedicineMatchResult` 类型）

  - **策略 1（批准文号模糊匹配）**：
    - 遍历所有 `OcrResult`，对每个 block 的 text 做正则匹配
    - 正则容忍 OCR 常见错误：去除空格后匹配，字符混淆映射（`准→淮`、`0→O`、`8→B`、`1→l`）
    - 命中即返回，confidence 从 OCR 置信度继承

  - **策略 2（品名提取——空间布局评分）**：
    - 如果策略 1 未命中，对所有 block 按以下维度综合评分：
      - **面积分**（权重 0.5）：`boundingBox` 面积占图像总面积的比例——药盒上品名字号最大
      - **位置分**（权重 0.3）：`boundingBox.top` 越靠上得分越高——品名通常在药盒上半部分
      - **OCR 置信度**（权重 0.2）：PaddleOCR 返回的 recognition confidence
    - 停用词过滤：扩展至 100+ 词（覆盖药盒常见说明文字），命中停用词的 block 评分 ×0.1
    - 按综合评分降序排序，取 top 5

  - **移除条形码正则策略**：`mobile_scanner` 已有独立的条码扫描页面（`barcode_scanner.dart`），
    从 OCR 文本中提取条形码一直成功率极低且冗余。条码走 `mobile_scanner`，OCR 专注于文字。

- [ ] 更新 `MedicineMatchCandidate` 类型（如果需要携带额外信息）

### Phase 4：调用层适配

- [ ] `lib/features/scan/presentation/pages/box_scan.dart`：
  - `_processPhoto` 的 OCR 分支改为：
    1. 从 `paddleOcrProvider` 读取引擎（首次触发 lazy init）
    2. 调用 `ocr.recognize(photo.path)`（注意：`paddle_ocr_native` 接受绝对路径，`XFile.path` 可直接用）
    3. 用 `MedicineOcrExtractor().extractCandidates(ocrRun)` 提取候选
    4. 对每个候选调用 `repo.search(candidate.query)`
  - 移除对旧 `OcrService` 和 `MedicineTextMatcher` 的引用
  - 处理 OCR 引擎初始化失败的异常（回退到 AI 路径或提示用户）

### Phase 5：测试与文档

- [ ] 删除 `test/record/ocr_test.dart`（旧 ML Kit 测试）
- [ ] 新建 `test/scan/medicine_ocr_extractor_test.dart`：
  - 构造 mock `OcrResult` 列表（含坐标和置信度），验证：
    - 批准文号模糊匹配（各种 OCR 变体）
    - 品名提取评分排序（大面积 > 小面积，上方 > 下方，高置信度 > 低置信度）
    - 停用词过滤
    - 空输入/无匹配场景
- [ ] `flutter analyze` 通过
- [ ] `flutter test` 通过
- [ ] 真机测试（Android arm64 + iOS 真机）：用药盒照片验证识别效果
- [ ] 更新 `assets/legal/sdk-list_zh.md` 和 `sdk-list_en.md`
- [ ] 追加迁移日志到 `docs/03-logs/migration-log/2026-07-29.md`

### Phase 6：清理

- [ ] 确认 `google_mlkit_text_recognition` 已从 `pubspec.yaml` 和 `pubspec.lock` 完全移除
- [ ] `grep -r "google_mlkit\|mlkit\|TextRecognitionScript\|TextRecognizer"` 确认无残留引用
- [ ] 确认旧 `ocr.dart` 和 `text_matcher.dart` 已删除或完全替换
- [ ] 运行文档检查工具确认需更新哪些文档

## 扩展停用词表

从当前 20 个扩展到覆盖药盒常见说明文字：

```dart
static final _stopWords = {
  // 原 20 个
  '药品', '用法', '用量', '注意', '事项', '禁忌', '不良反应',
  '贮藏', '规格', '厂商', '生产', '企业', '批准', '文号', '说明书',
  '包装', '本品', '一天', '每次', '每日', '一次', '两次', '三次',
  '毫克', '毫升', '克', '片', '粒',
  // 新增 — 药盒常见说明文字
  '口服', '外用', '饭前', '饭后', '睡前', '必要时',
  '儿童', '成人', '孕妇', '哺乳期', '婴幼儿', '老年人',
  '性状', '适应症', '功能主治', '药理毒理', '药代动力学',
  '有效期', '执行标准', '进口药品注册证号',
  '请仔细阅读', '请在医师指导下', '遮光', '密封', '置阴凉处',
  '常温', '冷藏', '冷冻', '避光', '干燥',
  '开封后', '本品为', '本品含', '辅料', '主要成分',
  '禁忌症', '注意事项', '药物相互作用',
  '特殊人群', '孕妇及哺乳期妇女', '儿童用药', '老年用药',
  '药物过量', '临床试验', '药理作用', '毒理研究',
  '贮藏条件', '包装材料', '铝塑包装', '纸盒',
  '批号', '生产日期', '有效期至',
  '进口', '分装', '总经销商', '代理商',
  '国药', '准字', '卫生许可证',
  '详见说明书', '请阅读',
  'mg', 'ml', 'IU', '微克', '国际单位',
};
```

## 风险与缓解

| 风险 | 缓解措施 |
|------|---------|
| iOS 模拟器不可用 | 开发期 OCR 逻辑通过单元测试覆盖；集成测试标注需真机 |
| App 体积增加 ~9 MB | 可接受；如需优化可后续研究动态下载模型方案 |
| 插件刚发布（0.1.1） | 关注上游 issue；如有问题可 fork 或切换到 `flutter_paddle_ocr` |
| Web 端不支持 | Web 端走 AI 路径（已实现），不提供离线 OCR |
| OCR 引擎 lazy init 耗时 | 首次调用会有初始化延迟；可在 App 启动后预热或显示 loading |
