import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:luminous/core/network/lucent_api.dart';
import 'package:luminous/features/auth/data/datasources/auth_remote_data_source.dart';
import 'package:luminous/features/auth/data/datasources/wechat/wechat_desktop_oauth_callback_listener.dart';
import 'package:luminous/features/auth/data/datasources/wechat/wechat_mobile_auth_client.dart';

final authRemoteDataSourceProvider = Provider<AuthRemoteDataSource>((ref) {
  return AuthRemoteDataSource(ref.watch(lucentDioClientProvider));
});

final wechatDesktopOAuthCallbackListenerProvider =
    Provider<WechatDesktopOAuthCallbackListener>((ref) {
      return const WechatDesktopOAuthCallbackListener();
    });

final wechatMobileAuthClientProvider = Provider<WechatMobileAuthClient>((ref) {
  return DefaultWechatMobileAuthClient();
});
