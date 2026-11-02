/// 开源许可清单的展示层接缝。
///
/// `lib/oss_licenses.dart` 是从 `pubspec.lock` 生成的纯数据文件，不在
/// presentation 层允许的依赖子树内。这个文件负责把它接进来，页面只依赖
/// 这里的再导出。
library;

export 'package:luminous/oss_licenses.dart'
    show Package, PackageRef, allDependencies;
