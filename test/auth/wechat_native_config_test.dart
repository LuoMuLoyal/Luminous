import 'dart:io';

import 'package:flutter_test/flutter_test.dart';

void main() {
  test(
    'iOS WeChat SDK native config is injectable and SceneDelegate-aware',
    () {
      final pubspec = File('pubspec.yaml').readAsStringSync();
      expect(pubspec, contains('fluwx:'));
      expect(pubspec, contains('scene_delegate: true'));

      final infoPlist = File('ios/Runner/Info.plist').readAsStringSync();
      expect(infoPlist, contains('<string>\$(WECHAT_MOBILE_APP_ID)</string>'));
      for (final scheme in ['weixin', 'weixinULAPI', 'weixinURLParamsAPI']) {
        expect(infoPlist, contains('<string>$scheme</string>'));
      }

      for (final name in ['Debug', 'Release']) {
        final xcconfig = File('ios/Flutter/$name.xcconfig').readAsStringSync();
        expect(xcconfig, contains('#include? "Wechat.xcconfig"'));
      }

      final example = File(
        'ios/Flutter/Wechat.example.xcconfig',
      ).readAsStringSync();
      expect(example, contains('WECHAT_MOBILE_APP_ID = wx_app_id_here'));
    },
  );
}
