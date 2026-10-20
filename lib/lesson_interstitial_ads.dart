import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:flutter/widgets.dart';
import 'package:google_mobile_ads/google_mobile_ads.dart';

import 'admob_config.dart';

/// Optional interstitial shown only when a child leaves a completed lesson
/// through one of its explicit completion actions.
class LessonInterstitialAds {
  LessonInterstitialAds._();

  static final LessonInterstitialAds instance = LessonInterstitialAds._();

  InterstitialAd? _ad;
  Future<void>? _loading;
  bool _sdkReady = false;

  String get _adUnitId => AdMobConfig.lessonInterstitialAdUnitId;

  Future<void> prepare() {
    if (kIsWeb ||
        defaultTargetPlatform != TargetPlatform.iOS ||
        _adUnitId.isEmpty ||
        _ad != null) {
      return Future<void>.value();
    }
    return _loading ??= _load().whenComplete(() => _loading = null);
  }

  Future<void> _load() async {
    try {
      if (!await ConsentInformation.instance.canRequestAds()) return;
      if (!_sdkReady) {
        await MobileAds.instance.initialize();
        _sdkReady = true;
      }

      final loaded = Completer<void>();
      await InterstitialAd.load(
        adUnitId: _adUnitId,
        request: const AdRequest(nonPersonalizedAds: true),
        adLoadCallback: InterstitialAdLoadCallback(
          onAdLoaded: (ad) {
            _ad = ad;
            loaded.complete();
          },
          onAdFailedToLoad: (_) => loaded.complete(),
        ),
      );
      await loaded.future;
    } catch (error) {
      debugPrint('Lesson interstitial skipped: $error');
    }
  }

  Future<void> showIfReady() async {
    final ad = _ad;
    if (ad == null ||
        WidgetsBinding.instance.lifecycleState != AppLifecycleState.resumed) {
      unawaited(prepare());
      return;
    }

    _ad = null;
    final finished = Completer<void>();
    void finish() {
      ad.dispose();
      if (!finished.isCompleted) finished.complete();
      unawaited(prepare());
    }

    ad.fullScreenContentCallback = FullScreenContentCallback<InterstitialAd>(
      onAdDismissedFullScreenContent: (_) => finish(),
      onAdFailedToShowFullScreenContent: (_, _) => finish(),
    );
    try {
      await ad.show();
      await finished.future;
    } catch (_) {
      finish();
    }
  }
}
