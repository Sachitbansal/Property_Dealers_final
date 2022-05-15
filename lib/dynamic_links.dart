import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_dynamic_links/firebase_dynamic_links.dart';
import 'package:flutter/material.dart';
import 'package:untitled/pages/add.dart';
import 'package:untitled/pages/house_details.dart';

class DynamicLinkServices {
  static Future<String> createPropertyShareLink(
      {required bool short,
      required String collectionId,
      docId,
      propertyTitle,
      imageUrl}) async {
    String _linkMessage;

    final params = DynamicLinkParameters(
      link: Uri.parse(
          "https://propertystocks.page.link.com/shareproperty?colid=$collectionId&docid=$docId&type=share"),
      uriPrefix: "https://propertystocks.page.link",
      androidParameters: const AndroidParameters(
        packageName: "com.example.untitled",
        minimumVersion: 30,
      ),
      iosParameters: const IOSParameters(
        bundleId: "com.example.app.ios",
        appStoreId: "123456789",
        minimumVersion: "1.0.1",
      ),
      googleAnalyticsParameters: const GoogleAnalyticsParameters(
        source: "twitter",
        medium: "social",
        campaign: "example-promo",
      ),
      socialMetaTagParameters: SocialMetaTagParameters(
        title: propertyTitle,
        imageUrl: Uri.parse(imageUrl),
      ),
    );

    Uri url;
    if (short) {
      final ShortDynamicLink shortLink =
          await FirebaseDynamicLinks.instance.buildShortLink(params);
      url = shortLink.shortUrl;
    } else {
      final ShortDynamicLink yo =
          await FirebaseDynamicLinks.instance.buildShortLink(params);
      url = yo.shortUrl;
    }

    _linkMessage = url.toString();
    return _linkMessage;
  }

  static Future<void> initialDynamicLink(BuildContext context) async {
    // Action for Sharing Property
    FirebaseDynamicLinks.instance.onLink.listen(
      (PendingDynamicLinkData dynamicLinkData) async {
        final Uri deepLink = dynamicLinkData.link;

        if (deepLink.queryParameters['type'].toString() == 'share') {
          String collectionId = deepLink.queryParameters['colid'].toString();
          String docId = deepLink.queryParameters['docid'].toString();
          await FirebaseFirestore.instance
              .collection(collectionId)
              .doc(docId)
              .get()
              .then((snapshot) {
            return Navigator.push(context,
                MaterialPageRoute(builder: (context) {
              return HouseDetails(
                isPublic: snapshot.data()!['isPublic'],
                uid: collectionId,
                docId: docId,
                assets: snapshot.data()!['images'],
                facilities: snapshot.data()!['keywords'],
                title: snapshot.data()!['title'],
                address: snapshot.data()!['address'],
                bedRooms: snapshot.data()!['bedRooms'],
                bathRooms: snapshot.data()!['bathRooms'],
                price: snapshot.data()!['Price'].toString(),
                landSize: snapshot.data()!['landSize'].toString(),
                keywords: snapshot.data()!['keywords'],
                name: snapshot.data()!['name'],
                number: snapshot.data()!['number'].toString(),
                sizeUnit: snapshot.data()!['sizeUnit'],
                enableChange: false,
                enableEdit: false,
              );
            }));
          });
        } else {
          String collectionId = deepLink.queryParameters['colid'].toString();
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => Add(
                collection: collectionId,
              ),
            ),
          );
        }
      },
    );

    final PendingDynamicLinkData? data =
        await FirebaseDynamicLinks.instance.getInitialLink();
    final Uri deepLink = data!.link;

    if (deepLink.queryParameters['type'].toString() == 'share') {
      String collectionId = deepLink.queryParameters['colid'].toString();
      String docId = deepLink.queryParameters['docid'].toString();

      await FirebaseFirestore.instance
          .collection(collectionId)
          .doc(docId)
          .get()
          .then((snapshot) {
        return Navigator.push(context, MaterialPageRoute(builder: (context) {
          return HouseDetails(
            isPublic: snapshot.data()!['isPublic'],
            uid: collectionId,
            docId: docId,
            assets: snapshot.data()!['images'],
            facilities: snapshot.data()!['keywords'],
            title: snapshot.data()!['title'],
            address: snapshot.data()!['address'],
            bedRooms: snapshot.data()!['bedRooms'],
            bathRooms: snapshot.data()!['bathRooms'],
            price: snapshot.data()!['Price'].toString(),
            landSize: snapshot.data()!['landSize'].toString(),
            keywords: snapshot.data()!['keywords'],
            name: snapshot.data()!['name'],
            number: snapshot.data()!['number'].toString(),
            sizeUnit: snapshot.data()!['sizeUnit'],
            enableChange: false,
            enableEdit: false,
            // enableChange: true
          );
        }));
      });
    } else {
      String collectionId = deepLink.queryParameters['colid'].toString();

      Navigator.push(
        context,
        MaterialPageRoute(
          builder: (context) => Add(
            collection: collectionId,
          ),
        ),
      );
    }

  }

  static Future<String> createAddPropertyFromCustomer({
    required bool short,
    required String collectionId,
  }) async {
    String _linkMessage;

    final params = DynamicLinkParameters(
      link: Uri.parse(
          "https://propertystocks.page.link.com/addproperty?colid=$collectionId&type=add"),
      uriPrefix: "https://propertystocks.page.link",
      androidParameters: const AndroidParameters(
        packageName: "com.example.untitled",
        minimumVersion: 30,
      ),
      iosParameters: const IOSParameters(
        bundleId: "com.example.app.ios",
        appStoreId: "123456789",
        minimumVersion: "1.0.1",
      ),
      googleAnalyticsParameters: const GoogleAnalyticsParameters(
        source: "twitter",
        medium: "social",
        campaign: "example-promo",
      ),
      socialMetaTagParameters: SocialMetaTagParameters(
        title: 'Add Property',
        imageUrl: Uri.parse(
          'http://knttraining.co.uk/wp-content/uploads/2018/11/how-to-add-a-png-to-a-photo-300x300.png',
        ),
      ),
    );

    Uri url;
    if (short) {
      final ShortDynamicLink shortLink =
          await FirebaseDynamicLinks.instance.buildShortLink(params);
      url = shortLink.shortUrl;
    } else {
      final ShortDynamicLink yo =
          await FirebaseDynamicLinks.instance.buildShortLink(params);
      url = yo.shortUrl;
    }

    _linkMessage = url.toString();
    return _linkMessage;
  }
}
