/// 兼容入口：药品工作区与提醒仓储的装配已合并到
/// `app/composition/tokens/medicine_workspace.dart`（两个文件互相 export 会成环）。
library;

export 'package:luminous/app/composition/tokens/medicine_workspace.dart'
    show
        medicineReminderRemoteDataSourceProvider,
        medicineWorkspaceRepositoryProvider,
        reminderRepositoryProvider;
