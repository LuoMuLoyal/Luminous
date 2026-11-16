import 'package:luminous/features/shell/domain/entities/nav_config.dart';

/// 导航配置的持久化接口。
///
/// 同步读写：配置是启动路径上的必需品（首帧就要知道底栏长什么样），
/// 异步读会让冷启动先闪一帧默认底栏再跳成用户底栏。`KvStore` 本身就是
/// 内存 box，同步读取没有 I/O 代价。
abstract interface class NavConfigRepository {
  /// 读配置；无配置、坏数据或未知版本时返回默认配置。
  NavConfig read();

  /// 写配置；写默认配置等价于清除（见实现）。
  Future<void> write(NavConfig config);
}
