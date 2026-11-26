enum EnvKey {
  lucentBaseUrl('LUCENT_BASE_URL'),
  lucentProdBaseUrl('LUCENT_PROD_BASE_URL'),
  e2eLucentBaseUrl('E2E_LUCENT_BASE_URL'),
  wechatMobileAppId('WECHAT_MOBILE_APP_ID'),
  wechatIosUniversalLink('WECHAT_IOS_UNIVERSAL_LINK'),
  e2eTestEmail('E2E_TEST_EMAIL'),
  e2eTestPassword('E2E_TEST_PASSWORD'),
  e2eRecordDate('E2E_RECORD_DATE'),
  e2eTestNickname('E2E_TEST_NICKNAME'),
  luminousExperimentalRuntimeEnabled('LUMINOUS_EXPERIMENTAL_RUNTIME_ENABLED'),
  luminousRuntimeProvider('LUMINOUS_RUNTIME_PROVIDER'),
  luminousEnableGenUi('LUMINOUS_ENABLE_GEN_UI'),

  /// A2UI catalog id this build advertises.
  ///
  /// Named the same as Lucent's server-side `A2UI_CATALOG_ID` on purpose: the
  /// two must agree, or the `createSurface.catalogId` the agent writes will not
  /// match the catalog the renderer registered and every component in the batch
  /// is rejected.
  a2uiCatalogId('A2UI_CATALOG_ID'),

  sentryDsn('SENTRY_DSN'),
  supportEmail('SUPPORT_EMAIL'),
  luminousDeepLinkHost('LUMINOUS_DEEP_LINK_HOST'),
  luminousDeepLinkScheme('LUMINOUS_DEEP_LINK_SCHEME');

  const EnvKey(this.wireName);

  final String wireName;
}
