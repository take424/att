import 'dart:io';
import 'dart:async';
import 'package:flutter/material.dart';
import 'package:google_mobile_ads/google_mobile_ads.dart';

class BannerAdWidget extends StatefulWidget {
  /*
  * size patterns
  * AdSize.banner : 320x50
  * AdSize.largetBanner : 320x100
  * AdSize.mediumRectangle : 320x250
  * AdSize.fullBanner : 468x60
  * AdSize.leaderboard : 728x90
  */
  final AdSize size = AdSize.banner;

  @override
  State<StatefulWidget> createState() => BannerAdState();
}

class BannerAdState extends State<BannerAdWidget> {
  late BannerAd _bannerAd;
  final Completer<BannerAd> bannerCompleter = Completer<BannerAd>();

  @override
  void initState() {
    debugPrint('[LifeCycle][BannerAdWidget] initState.');
    super.initState();
    _bannerAd = BannerAd(
      adUnitId: getBannerAdUnitId(),
      request: AdRequest(),
      size: widget.size,
      //listener: AdListener(
      listener: AdListener(
        onAdLoaded: (Ad ad) {
          debugPrint('$BannerAd loaded.');
          bannerCompleter.complete(ad as BannerAd);
        },
        onAdFailedToLoad: (Ad ad, LoadAdError error) {
          ad.dispose();
          debugPrint('$BannerAd failedToLoad: $error');
          bannerCompleter.completeError(error);
        },
        onAdOpened: (Ad ad) => debugPrint('$BannerAd onAdOpened.'),
        onAdClosed: (Ad ad) => debugPrint('$BannerAd onAdClosed.'),
        onApplicationExit: (Ad ad) =>
            debugPrint('$BannerAd onApplicationExit.'),
      ),
    );
    Future<void>.delayed(Duration(seconds: 1), () => _bannerAd.load());
  }

  @override
  void dispose() {
    debugPrint('[LifeCycle][BannerAdWidget] dispose.');
    super.dispose();
    _bannerAd.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<BannerAd>(
      future: bannerCompleter.future,
      builder: (BuildContext context, AsyncSnapshot<BannerAd> snapshot) {
        Widget child;

        switch (snapshot.connectionState) {
          case ConnectionState.none:
          case ConnectionState.waiting:
          case ConnectionState.active:
            child = Container();
            break;
          case ConnectionState.done:
            if (snapshot.hasData) {
              child = AdWidget(ad: _bannerAd);
            } else {
              child =
                  Text('Error loading $BannerAd.' + snapshot.error.toString());
            }
        }

        return Container(
          width: _bannerAd.size.width.toDouble(),
          height: _bannerAd.size.height.toDouble(),
          color: Colors.transparent,
          child: child,
        );
      },
    );
  }

  bool isRelease = const bool.fromEnvironment('dart.vm.product');

  String getBannerAdUnitId() {
    String bannerAdUnitId = '';
    if (Platform.isAndroid) {
      bannerAdUnitId = (isRelease
          ? 'ca-app-pub-0000000000000000/0000000000' // 本番で差し替える
          : 'ca-app-pub-3940256099942544/6300978111'); // テスト用ID
    } else if (Platform.isIOS) {
      bannerAdUnitId = (isRelease
          ? 'ca-app-pub-0000000000000000/0000000000' // 本番で差し替える
          : 'ca-app-pub-3940256099942544/2934735716'); // テスト用ID
    }

    return bannerAdUnitId;
  }
}
