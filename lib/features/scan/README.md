# lib/features/scan — 药盒扫码与拍照识别

无 tab 归属的工具型 feature:条码扫描(`/scan/barcode`)与药盒拍照识别
(本地 PaddleOCR / 云端 AI 两种方法),识别结果比对药品库与用户健康档案后加入药箱。

## 职责与边界

- 管:条码扫码页、拍照识别全流程(方法选择 → 拍照 → 候选提取/搜库/合并 → 结果弹窗)、
  PaddleOCR 引擎与 ONNX 模型下载管理、`ScanRepository`(搜库/图片上传/AI 识别)。
- 不管:药箱写入(复用 search 的 `add_to_box.dart`)、药品详情页(medicine)、
  档案数据(只读 health_context 快照做比对)。

## 对外契约

- 路由:`Routes.scanBarcode` = `/scan/barcode`(`presentation/routes.dart` 的
  `ScanBarcodeRoute`),经 `scan_routes.$appRoutes` 注册进 lib/app/router.dart。
- 导出:`presentation/pages/box_scan.dart` 的 `showMedicineBoxScanSheet(context)`——
  medicine 与 search 直接调用的入口函数。
- 被依赖:medicine(mobile_dashboard_view / mobile_quick_operations)、
  search(quick_actions)、lib/app/router.dart。

## 不变量

- 平台能力(相机/权限/相册/OCR)全部经插件 platform interface 调用;测试注入 fake
  (PermissionHandlerPlatform / MobileScannerPlatform / ImagePickerPlatform /
  PaddleOcrNativePlatform),从不启动真实相机/OCR
  (test/scan/barcode_scanner_page_test.dart、box_scan_test.dart、
  paddle_ocr_provider_test.dart)。
- `ScanRepository` 边界:空候选集是合法 Right(不是错误);可恢复失败 = Left
  (test/scan/data/repositories/scan_test.dart)。
- `confidence` 只用于候选排序,不作百分比展示;AI 路径无分数保持 null,不伪造
  (`domain/entities/scan_result.dart`;test/scan/domain/candidate_merger_test.dart)。
- 纯逻辑(`entities` / `medicine_ocr_extractor.dart` / `candidate_merger.dart`)不依赖
  平台与 IO;平台调用集中在 `domain/services/` 的 PaddleOcrEngine / OcrModelManager。

## 依赖禁区

- `data/` 只依赖 core 网络层,不依赖其他 feature。
- presentation 跨 feature 仅限:health_context(档案比对)、medicine 的 routes(跳转)、
  search 的 `add_to_box.dart`(入箱 UI);不得再扩大。

## 陷阱与决策

- OCR 路径免登录,AI 路径(压缩 → COS 预签名上传 → recognize)强制登录,auth gate
  在 `box_scan.dart`;勿把 OCR 路径也加登录墙。
- 进相机前先做 OCR 预检查(ABI/模型文件),失败引导下载 ~30MB 模型;模型不打进 APK
  是为控制包体(`OcrModelManager`,GitHub Releases 固定分发渠道)。
- `PaddleOcr` 是进程级单例,`PaddleOcrEngine` 只是懒初始化包装;测试的 fake 必须在
  创建 engine 之前安装(paddle_ocr_provider_test.dart 的顺序依赖)。
- 批准文号 OCR 纠错映射(`medicine_ocr_extractor.dart`)是单向幂等,勿反向使用。
