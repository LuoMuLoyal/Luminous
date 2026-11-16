/// 健康事件对外的接缝：其它表面（today 的事件卡片）在这里打开事件的三个表单
/// 面板，不必 import `health_event` 的 `presentation/widgets/sheets/`。
///
/// 三个 sheet 都是纯展示 + 回调的表单，调用方负责文案、选项来源与提交回调；
/// 这里只固定「它们能被别的表面拿到」这件事。
library;

export 'package:luminous/features/health_event/presentation/widgets/sheets/check_in.dart'
    show CheckInSheet;
export 'package:luminous/features/health_event/presentation/widgets/sheets/end_event.dart'
    show EndEventSheet;
export 'package:luminous/features/health_event/presentation/widgets/sheets/start_event.dart'
    show HealthEventAssociationOption, StartEventSheet;
