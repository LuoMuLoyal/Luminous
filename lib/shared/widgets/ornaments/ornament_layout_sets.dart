part of 'app_ornaments.dart';

const List<AppOrnamentLayout> kBannerSessionLayouts = [
  kBannerOrbitLayout,
  kBannerCometLayout,
  kBannerPetalLayout,
  kBannerHaloLayout,
  kBannerDriftLayout,
  kBannerCanopyLayout,
  kBannerRibbonLayout,
  kBannerConstellationLayout,
  kBannerHarborLayout,
];

const List<AppOrnamentLayout> kSectionSessionLayouts = [
  kSectionOrbitLayout,
  kSectionCometLayout,
  kSectionPetalLayout,
  kSectionHaloLayout,
  kSectionDriftLayout,
  kSectionCanopyLayout,
  kSectionSplitLayout,
  kSectionRidgeLayout,
  kSectionTideLayout,
  kSectionClusterLayout,
  kSectionBeaconLayout,
];

const Map<AppOrnamentStyle, AppOrnamentLayout> kBannerFallbackLayouts = {
  AppOrnamentStyle.orbit: kBannerOrbitLayout,
  AppOrnamentStyle.comet: kBannerCometLayout,
  AppOrnamentStyle.petal: kBannerPetalLayout,
  AppOrnamentStyle.halo: kBannerHaloLayout,
};

const Map<AppOrnamentStyle, AppOrnamentLayout> kSectionFallbackLayouts = {
  AppOrnamentStyle.orbit: kSectionOrbitLayout,
  AppOrnamentStyle.comet: kSectionCometLayout,
  AppOrnamentStyle.petal: kSectionPetalLayout,
  AppOrnamentStyle.halo: kSectionHaloLayout,
};
