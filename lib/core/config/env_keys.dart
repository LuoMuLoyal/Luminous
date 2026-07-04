enum EnvKey {
  lucentBaseUrl('LUCENT_BASE_URL'),
  e2eLucentBaseUrl('E2E_LUCENT_BASE_URL'),
  wechatMobileAppId('WECHAT_MOBILE_APP_ID'),
  wechatIosUniversalLink('WECHAT_IOS_UNIVERSAL_LINK'),
  e2eTestEmail('E2E_TEST_EMAIL'),
  e2eTestPassword('E2E_TEST_PASSWORD'),
  e2eRecordDate('E2E_RECORD_DATE'),
  e2eTestNickname('E2E_TEST_NICKNAME'),
  luminousExperimentalAiRuntime('LUMINOUS_EXPERIMENTAL_AI_RUNTIME'),
  luminousAiRuntimeProvider('LUMINOUS_AI_RUNTIME_PROVIDER'),
  luminousEnableGenUi('LUMINOUS_ENABLE_GEN_UI');

  const EnvKey(this.wireName);

  final String wireName;
}
