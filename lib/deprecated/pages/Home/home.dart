import 'package:luminous/features/home/presentation/home.dart';

export 'package:luminous/features/home/presentation/home.dart';

/// 兼容旧路径的首页入口。
@Deprecated(
  'Use HomePage from package:luminous/features/home/presentation/home.dart',
)
class HomeView extends HomePage {
  const HomeView({super.key, super.reminderGateway, super.controller});
}
