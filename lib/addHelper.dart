import 'package:flutter/material.dart';
import 'package:google_mobile_ads/google_mobile_ads.dart';

class AddHelper {
  static String homePageBannerKey() {
    return 'ca-app-pub-1043664077333093/1036718028';
  }

  static String detailsPageBannerKey() {
    return 'ca-app-pub-1043664077333093/7218982995';
  }

  static String addPropertyInterstitialAddKey() {
    return 'ca-app-pub-1043664077333093/1228289717';
  }
}

class AddProvider with ChangeNotifier {
  late BannerAd homePageBanner;
  bool isHomePageBannerLoaded = false;

  late BannerAd detailsPageBanner;
  bool isDetailsPageBannerLoaded = false;

  late InterstitialAd fullPageAdd;
  bool isFullPageAddLoaded = false;

  void initialiseHomePageBanner() async {
    homePageBanner = BannerAd(
        adUnitId: AddHelper.homePageBannerKey(),
        size: AdSize.banner,
        request: const AdRequest(),
        listener: BannerAdListener(onAdLoaded: (ad) {

          print('Home Page add loaded');
          isHomePageBannerLoaded = true;
        }, onAdClosed: (ad) {
          ad.dispose();
          isHomePageBannerLoaded = false;
        }, onAdFailedToLoad: (ad, error) {
          print(error.toString());
          isHomePageBannerLoaded = false;
        }));

    await homePageBanner.load();
    // notifyListeners();
  }

  void initialiseDetailsPageBanner() async {
    detailsPageBanner = BannerAd(
        adUnitId: AddHelper.detailsPageBannerKey(),
        size: AdSize.banner,
        request: const AdRequest(),
        listener: BannerAdListener(onAdLoaded: (ad) {
          print('Details Page add loaded');
          isDetailsPageBannerLoaded = true;
        }, onAdClosed: (ad) {
          ad.dispose();
          isDetailsPageBannerLoaded = false;
        }, onAdFailedToLoad: (ad, error) {
          print(error.toString());
          isDetailsPageBannerLoaded = false;
        }));

    await detailsPageBanner.load();
    // notifyListeners();
  }

  void initialiseFullPageAdd() async {
    await InterstitialAd.load(
      adUnitId: AddHelper.addPropertyInterstitialAddKey(),
      request: const AdRequest(),
      adLoadCallback: InterstitialAdLoadCallback(
        onAdLoaded: (ad) {
          print('Full Page  add Loaded');
          fullPageAdd = ad;
          isFullPageAddLoaded = true;
        },
        onAdFailedToLoad: (error) {
          print('Full Page add NotLoaded');
          print(error.toString());
          isFullPageAddLoaded = false;
        },
      ),
    );

    // notifyListeners();
  }
}
