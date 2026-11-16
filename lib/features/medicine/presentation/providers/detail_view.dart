/// 药品详情**视图主体**的对外接缝。
///
/// 桌面外壳（`features/shell/presentation/detail_pane.dart`）要在右侧面板里
/// 渲染药品详情：它需要内容体与骨架，不需要页面壳（面板有自己的头部）。这两个
/// 部件因此经 `presentation/providers/` 接缝导出，外壳不 import 药品的
/// `presentation/pages/`。
///
/// 数据来源不变：两侧都读同一个 `medicineDetailProvider` family 与同一份缓存。
library;

export 'package:luminous/features/medicine/presentation/pages/detail.dart'
    show MedicineDetailLoading;
export 'package:luminous/features/medicine/presentation/pages/medicine_detail_content.dart'
    show MedicineDetailContent;
