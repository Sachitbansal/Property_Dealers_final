import 'package:flutter/material.dart';
import 'package:google_mobile_ads/google_mobile_ads.dart';

class AddHelper {
  static String homePageBannerKey() {
    return 'ca-app-pub-9719585953227487/6470523474';
  }

  static String detailsPageBannerKey() {
    return 'ca-app-pub-9719585953227487/3322180600';
  }

  static String addPropertyInterstitialAddKey() {
    return 'ca-app-pub-9719585953227487/5202276476';
  }
}

class AddProvider with ChangeNotifier {
  late BannerAd homePageBanner;
  bool isHomePageBannerLoaded = false;

  late BannerAd detailsPageBanner;
  bool isdetailsPageBannerLoaded = false;

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
          isdetailsPageBannerLoaded = true;
        }, onAdClosed: (ad) {
          ad.dispose();
          isdetailsPageBannerLoaded = false;
        }, onAdFailedToLoad: (ad, error) {
          print(error.toString());
          isdetailsPageBannerLoaded = false;
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
