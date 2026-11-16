import 'package:luminous/features/shell/domain/entities/nav_config.dart';

/// 注册表里一个 tab 的定义：身份 + 路由落点。
///
/// 这是三分模型的**注册表**层：系统里有哪些 tab 由它决定，不由用户配置决定。
/// 用户能改的是「这个 tab 叫什么、用什么图标、排第几、显不显示」，
/// 不是「能不能多出一个 today 之外的 tab」。
///
/// 为什么要这一层而不是继续用 `enum ShellTab`：`enum` 把身份、顺序、分支索引
/// 三合一压在一个 `index` 上，三者一旦有任一不再是编译期常量就全塌。
/// 拆开之后，顺序和可见性来自 `NavConfig`，身份来自 [TabDefinition]，
/// 分支索引只活在渲染层的一层映射里。
///
/// **默认图标与默认文案不在这里**：它们是 presentation 的关注点（`IconData`
/// 与 ARB 都属于 UI 层），放在 `domain/` 会让 `domain_purity` 破功。
/// 那边有对应的 `ShellTabStyle` 提供默认外观，按 [id] 查表。
class TabDefinition {
  const TabDefinition({
    required this.id,
    required this.path,
    required this.branchIndex,
  });

  /// 稳定身份。
  final TabId id;

  /// 该 tab 根路由的路径，与 `Routes` 里的常量一一对应。
  ///
  /// 放在注册表里而不是让渲染层自己去查：注册表与路由表是同一件事的两面，
  /// 分开写会让「加了一个 tab 但忘了路由」变成运行期 404。
  final String path;

  /// 该 tab 对应的 `StatefulShellBranch` 下标。
  ///
  /// **这是编译期常量、不随用户配置改变**：`go_router` 的 branches 在建
  /// router 时固定，配置只改变渲染顺序，通过这层映射把「底栏第 i 格」
  /// 翻译成「branch 第 j 条」。这正是「留在 go_router 也能做配置」的关键——
  /// 顺序是数据显示层的事，不是路由结构的事。
  final int branchIndex;

  @override
  bool operator ==(Object other) =>
      identical(this, other) || other is TabDefinition && id == other.id;

  @override
  int get hashCode => id.hashCode;
}
