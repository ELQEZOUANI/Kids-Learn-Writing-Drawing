/// Your AdMob configuration. Fill the iOS app ID in ios/Runner/Info.plist first.
abstract final class AdMobConfig {
  // Paste your iOS APP OPEN AD UNIT ID between the quotes below.
  // Ad unit IDs contain a slash (/). Leaving this empty disables ads.
  static const String iosAppOpenAdUnitId =
      'ca-app-pub-9283129936552011/1705705503';

  // Paste your production iOS INTERSTITIAL AD UNIT ID here once.
  // Leave empty to disable interstitial ads until the real ID is available.
  static const String iosInterstitialAdUnitId = 'ca-app-pub-9283129936552011/8956053295';

  static String get lessonInterstitialAdUnitId =>
      iosInterstitialAdUnitId.trim();
}
