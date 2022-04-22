import 'package:flutter/material.dart';
import 'package:google_mobile_ads/google_mobile_ads.dart';

class AddHelper {
  static String banneradd() {
    return 'ca-app-pub-9719585953227487/6470523474';
  }
}

class AddProvider with ChangeNotifier {

  late BannerAd homePageBanner;
  bool isAddLoaded = false;

  void initialiseHomePageBanner() async {
    homePageBanner = BannerAd(
      adUnitId: AddHelper.banneradd(),
      size: AdSize.banner,
      request: const AdRequest(),
      listener: BannerAdListener(
        onAdLoaded: (ad) {
          print('add loaded');
          isAddLoaded = true;
        },
        onAdClosed: (ad) {
          ad.dispose();
          isAddLoaded = false;
        },
        onAdFailedToLoad: (ad, error) {
          print(error.toString());
          isAddLoaded = false;
        }
      )
    );

    await homePageBanner.load();
    notifyListeners();
}

}