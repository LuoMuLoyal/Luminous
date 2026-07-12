import 'package:luminous/core/network/network_providers.dart';
import 'package:luminous/features/auth/data/datasources/auth.dart';
import 'package:luminous/features/auth/data/datasources/wechat/desktop_oauth_callback_listener.dart';
import 'package:luminous/features/auth/data/datasources/wechat/mobile_auth_client.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

part 'auth.g.dart';

@riverpod
AuthRemoteDataSource authRemoteDataSource(Ref ref) {
  return AuthRemoteDataSource(
    ref.watch(lucentClientProvider),
    ref.watch(lucentSessionStoreProvider),
  );
}

@riverpod
WechatDesktopOAuthCallbackListener wechatDesktopOAuthCallbackListener(Ref ref) {
  return const WechatDesktopOAuthCallbackListener();
}

@riverpod
WechatMobileAuthClient wechatMobileAuthClient(Ref ref) {
  // 有 dart.library.io 的平台（Android/iOS） → 导出 wechat_mobile_auth_client_fluwx.dart，它的构造函数不是 const（因为有可变字段 _fluwx）
  // 其他平台 → 导出 wechat_mobile_auth_client_stub.dart，它的构造函数是 const
  // ignore: prefer_const_constructors
  return DefaultWechatMobileAuthClient();
}
