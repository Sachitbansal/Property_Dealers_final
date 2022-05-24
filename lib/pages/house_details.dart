import 'dart:async';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_carousel_slider/carousel_slider.dart';
import 'package:flutter_carousel_slider/carousel_slider_indicators.dart';
import 'package:flutter_carousel_slider/carousel_slider_transforms.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:google_mobile_ads/google_mobile_ads.dart';
import 'package:provider/provider.dart';
import 'package:share_plus/share_plus.dart';
import 'package:untitled/pages/update_property.dart';
import 'package:url_launcher/url_launcher.dart';

import '../addHelper.dart';
import '../dynamic_links.dart';

class HouseDetails extends StatefulWidget {
  const HouseDetails({
    Key? key,
    required this.uid,
    required this.docId,
    required this.enableEdit,
  }) : super(key: key);
  final String docId, uid;
  final bool enableEdit;

  @override
  _HouseDetailsState createState() => _HouseDetailsState();
}

class _HouseDetailsState extends State<HouseDetails> {
  ConnectivityResult _connectivityResult = ConnectivityResult.none;
  bool isLoading = false;
  late CarouselSliderController _sliderController;

  final Connectivity _connectivity = Connectivity();
  late StreamSubscription<ConnectivityResult> _streamSubscription;

  Future<void> initConnectivity() async {
    ConnectivityResult result = await _connectivity.checkConnectivity();

    if (!mounted) {
      return Future.value(null);
    }

    return _updateConnectionState(result);
  }

  Future<void> _updateConnectionState(ConnectivityResult result) async {
    setState(() => _connectivityResult = result);
  }

  @override
  void initState() {
    super.initState();
    initConnectivity();
    _streamSubscription =
        _connectivity.onConnectivityChanged.listen(_updateConnectionState);
    AddProvider adProvider = Provider.of<AddProvider>(context, listen: false);
    adProvider.initialiseDetailsPageBanner();
    _sliderController = CarouselSliderController();
  }

  @override
  void dispose() {
    _streamSubscription.cancel();
    super.dispose();
  }

  bool isPublic = false;

  showSnackBar(String snackText, Duration d) {
    final snackBar = SnackBar(content: Text(snackText), duration: d);
    ScaffoldMessenger.of(context).showSnackBar(snackBar);
  }

  @override
  Widget build(BuildContext context) {
    void phoneCall(String phoneNumber) async {
      final url = 'tel:$phoneNumber';
      if (await canLaunch(url)) {
        await launch(url);
      } else {
        throw 'Could not launch $url';
      }
    }

    CollectionReference collectionRef =
    FirebaseFirestore.instance.collection(widget.uid);

    Future<void> deleteUser(String id, List urls, bool isPublic) async {
      collectionRef.doc(id).delete();

      if (isPublic) {
        FirebaseFirestore.instance
            .collection("Public")
            .doc(id + widget.uid)
            .delete();
      }

      for (var url = 0; url < urls.length; url++) {
        await FirebaseStorage.instance.refFromURL(urls[url]).delete();
      }
    }

    Future<void> myDialog({required String confirmDialog,
      void Function()? onPressed,
      required String proceedButton}) async {
      return showDialog<void>(
        context: context,
        barrierDismissible: false,
        builder: (BuildContext context) {
          return AlertDialog(
            title: Text(confirmDialog),
            actions: <Widget>[
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceAround,
                children: [
                  TextButton(
                    child: const Text('Cancel'),
                    onPressed: () {
                      Navigator.of(context).pop();
                    },
                  ),
                  TextButton(
                      child: Text(
                        proceedButton,
                        style: const TextStyle(color: Colors.red),
                      ),
                      onPressed: onPressed),
                ],
              ),
            ],
          );
        },
      );
    }

    final Size size = MediaQuery.of(context).size;

    return Scaffold(
      body: isLoading
          ? Stack(
              children: [
                Container(
                  color: Colors.black12,
                  child: const Center(
                    child: CircularProgressIndicator(),
                  ),
                )
              ],
            )
          : _connectivityResult == ConnectivityResult.none
              ? Scaffold(
                  backgroundColor: Colors.white,
                  body: Center(
                    child: Image.asset('assets/not_connected.jpg'),
                  ),
                )
              : StreamBuilder<DocumentSnapshot>(
                  stream: FirebaseFirestore.instance
                      .collection(widget.uid)
                      .doc(widget.docId)
                      .snapshots(),
                  builder: (context, snapshot) {
                    if (snapshot.hasError) {
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(
                          content: Text('Something Went Wrong.'),
                        ),
              );
            }
            if (snapshot.connectionState == ConnectionState.waiting) {
              return const Center(
                child: CircularProgressIndicator(),
              );
            }
            return Column(
              children: [
                Expanded(
                  child: SingleChildScrollView(
                    child: Column(
                      children: [
                        Stack(
                          children: [
                            SizedBox(
                              height: size.height * .5 - 82.5,
                              child: CarouselSlider.builder(
                                unlimitedMode: true,
                                controller: _sliderController,
                                slideBuilder: (index) {
                                  return Image.network(
                                    snapshot.data!['images'][index],
                                    fit: BoxFit.cover,
                                  );
                                },
                                slideTransform: const ParallaxTransform(),
                                slideIndicator: CircularSlideIndicator(
                                    padding:
                                    const EdgeInsets.only(bottom: 32),
                                    indicatorBorderColor: Colors.white,
                                    currentIndicatorColor: Colors.white,
                                    indicatorBackgroundColor:
                                    Colors.transparent),
                                itemCount: snapshot.data!['images'].length,
                                initialPage: 0,
                                enableAutoSlider: true,
                              ),
                            ),
                            Positioned(
                              top: 50.0,
                              left: 20.0,
                              child: GestureDetector(
                                onTap: () {
                                  HapticFeedback.lightImpact();
                                  Navigator.pop(context);
                                },
                                child: Container(
                                  decoration: BoxDecoration(
                                    color: Colors.white70,
                                    borderRadius: BorderRadius.circular(15.0),
                                  ),
                                  child: const Padding(
                                    padding: EdgeInsets.all(8.0),
                                    child: Icon(
                                      Icons.arrow_back,
                                      color: Colors.black,
                                      size: 24,
                                    ),
                                  ),
                                ),
                              ),
                            ),
                            if (widget.enableEdit == true)
                              Positioned(
                                top: 50.0,
                                right: 20.0,
                                child: Row(
                                  children: [
                                    //Make Public Button
                                    GestureDetector(
                                      onTap: () {
                                        if (!snapshot.data!['isPublic']) {
                                          myDialog(
                                            confirmDialog:
                                            'Are you sure want to make the Property Public?',
                                            onPressed: () async {
                                              Navigator.pop(context);
                                              isPublic = true;
                                              setState(
                                                      () => isLoading = true);
                                              DocumentReference copyTo =
                                              FirebaseFirestore.instance
                                                  .collection('Public')
                                                  .doc(
                                                widget.docId +
                                                    widget.uid
                                                        .toString(),
                                              );
                                              DocumentReference copyFrom =
                                              FirebaseFirestore.instance
                                                  .collection(widget.uid
                                                  .toString())
                                                  .doc(widget.docId);

                                              copyFrom.get().then(
                                                    (value) => {
                                                  copyTo.set(
                                                      value.data()),
                                                },
                                              );

                                              await collectionRef
                                                  .doc(widget.docId)
                                                  .update({
                                                'isPublic': true
                                              }).whenComplete(
                                                    () {
                                                  setState(() =>
                                                  isLoading = false);
                                                },
                                              );
                                            },
                                            proceedButton: 'Make Public',
                                          );
                                        } else {
                                          myDialog(
                                            confirmDialog:
                                            'Are you sure want to make the Property Private?',
                                            proceedButton: 'Make Private',
                                            onPressed: () async {
                                              isPublic = false;
                                              setState(() => isLoading = true);
                                              Navigator.pop(context);
                                              await FirebaseFirestore
                                                  .instance
                                                  .collection('Public')
                                                  .doc(
                                                widget.docId +
                                                    widget.uid
                                                        .toString(),
                                              )
                                                  .delete();

                                              await collectionRef
                                                  .doc(widget.docId)
                                                  .update({
                                                'isPublic': false
                                              }).whenComplete(
                                                    () {
                                                  setState(() => isLoading = false);
                                                },
                                              );
                                            },
                                          );
                                        }
                                      },
                                      child: Container(
                                        decoration: BoxDecoration(
                                          color: Colors.white70,
                                          borderRadius:
                                          BorderRadius.circular(15.0),
                                        ),
                                        child: Padding(
                                          padding: const EdgeInsets.all(8.0),
                                          child: Icon(
                                            Icons.public,
                                            color: snapshot.data!['isPublic']
                                                ? Colors.blue[800]
                                                : Colors.black,
                                            size: 24,
                                          ),
                                        ),
                                      ),
                                    ),
                                    const SizedBox(
                                      width: 20,
                                    ),
                                    //Delete Button
                                    GestureDetector(
                                      onTap: () => myDialog(
                                          confirmDialog:
                                          'Are you sure want to delete the property?',
                                          onPressed: () {
                                            deleteUser(
                                                widget.docId,
                                                snapshot
                                                    .data!['images'],
                                                snapshot
                                                    .data!['isPublic'])
                                                .whenComplete(
                                                  () {
                                                Navigator.pop(context);
                                                Navigator.pop(context);
                                                ScaffoldMessenger.of(
                                                    context)
                                                    .showSnackBar(
                                                  const SnackBar(
                                                    content:
                                                    Text("Deleted"),
                                                    duration: Duration(
                                                      milliseconds: 1000,
                                                    ),
                                                  ),
                                                );
                                              },
                                            );
                                          },
                                          proceedButton: 'DELETE'),
                                      child: Container(
                                        decoration: BoxDecoration(
                                          color: Colors.white70,
                                          borderRadius:
                                          BorderRadius.circular(15.0),
                                        ),
                                        child: const Padding(
                                          padding: EdgeInsets.all(8.0),
                                          child: Icon(
                                            Icons.delete,
                                            color: Colors.black,
                                            size: 24,
                                          ),
                                        ),
                                      ),
                                    ),
                                    const SizedBox(
                                      width: 20,
                                    ),
                                    //Bookmark Button
                                    GestureDetector(
                                      onTap: () {
                                        collectionRef.doc(widget.docId).update({
                                          'bookmark':
                                          !snapshot.data!['bookmark'],
                                        }).whenComplete(() {
                                          if (!snapshot.data!['bookmark']) {
                                            showSnackBar(
                                              'Bookmark Added',
                                              const Duration(
                                                milliseconds: 1000,
                                              ),
                                            );
                                          } else {
                                            showSnackBar(
                                              'Bookmark Removed',
                                              const Duration(
                                                milliseconds: 1000,
                                              ),
                                            );
                                          }
                                          Navigator.pop(context);
                                        });
                                      },
                                      child: Container(
                                        decoration: BoxDecoration(
                                          color: Colors.white70,
                                          borderRadius:
                                          BorderRadius.circular(15.0),
                                        ),
                                        child: Padding(
                                          padding: const EdgeInsets.all(8.0),
                                          child: Icon(
                                            snapshot.data!['bookmark']
                                                ? Icons.bookmark
                                                : Icons.bookmark_border,
                                            color: snapshot.data!['bookmark']
                                                ? Colors.blue[800]
                                                : Colors.black,
                                            size: 24,
                                          ),
                                        ),
                                      ),
                                    ),
                                    const SizedBox(
                                      width: 20,
                                    ),
                                    //Update Property
                                    GestureDetector(
                                      onTap: () {
                                        Navigator.push(
                                          context,
                                          MaterialPageRoute(
                                            builder: (context) =>
                                                UpdateProperty(
                                                  facing:
                                                  snapshot.data!['facing'],
                                                  types:
                                                  snapshot.data!['types'],
                                                  buyRent:
                                                  snapshot.data!['buyRent'],
                                                  bathRooms: snapshot
                                                      .data!['bathRooms'],
                                                  bedRooms: snapshot
                                                      .data!['bedRooms'],
                                                  sizeUnit: snapshot
                                                      .data!['sizeUnit'],
                                                  construction: snapshot
                                                      .data!['construction'],
                                                  collection:
                                                  widget.uid.toString(),
                                                  id: widget.docId,
                                                  imageUrls:
                                                  snapshot.data!['images'],
                                                ),
                                          ),
                                        );
                                      },
                                      child: Container(
                                        decoration: BoxDecoration(
                                          color: Colors.white70,
                                          borderRadius:
                                          BorderRadius.circular(15.0),
                                        ),
                                        child: const Padding(
                                          padding: EdgeInsets.all(8.0),
                                          child: Icon(
                                            Icons.edit,
                                            color: Colors.black,
                                            size: 24,
                                          ),
                                        ),
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                          ],
                        ),
                        Padding(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 20,
                          ),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Padding(
                                padding: const EdgeInsets.only(top: 30),
                                child: Row(
                                  children: [
                                    Expanded(
                                      child: Text(
                                        snapshot.data!['title'],
                                        maxLines: 2,
                                        overflow: TextOverflow.ellipsis,
                                        style: GoogleFonts.play(
                                          color: Colors.black,
                                          fontWeight: FontWeight.w600,
                                          fontSize: 18,
                                        ),
                                      ),
                                    ),
                                    Text(
                                      '₹${snapshot.data!['Price'].toString()}',
                                      style: GoogleFonts.play(
                                        color: const Color(0xfff63e3c),
                                        fontWeight: FontWeight.w600,
                                        fontSize: 16,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                              const SizedBox(
                                height: 10,
                              ),
                              Text(
                                snapshot.data!['address'],
                                maxLines: 2,
                                overflow: TextOverflow.ellipsis,
                                style: GoogleFonts.play(
                                  color: Colors.grey,
                                  fontSize: 14,
                                ),
                              ),
                              const SizedBox(
                                height: 10,
                              ),
                              SingleChildScrollView(
                                scrollDirection: Axis.horizontal,
                                child: Row(
                                  children: [
                                    _facilities(Icons.king_bed,
                                        snapshot.data!['bedRooms']),
                                    _facilities(Icons.bathtub,
                                        snapshot.data!['bathRooms']),
                                    _facilities(Icons.crop_square,
                                        "${snapshot.data!['landSize']} ${snapshot.data!['sizeUnit']}"),
                                    _facilities(Icons.monetization_on_outlined,
                                        snapshot.data!['buyRent'][0]),
                                    _facilities(Icons.construction,
                                        snapshot.data!['construction']),
                                    _facilities(Icons.house_outlined,
                                        snapshot.data!['types']),
                                  ],
                                ),
                              ),
                              const SizedBox(
                                height: 10,
                              ),
                              Text(
                                "Facilities",
                                style: GoogleFonts.play(
                                  color: Colors.black,
                                  fontWeight: FontWeight.w600,
                                  fontSize: 16,
                                ),
                              ),
                              const SizedBox(
                                height: 5,
                              ),

                              const SizedBox(
                                height: 10,
                              ),
                              Text(
                                "Other Information",
                                style: GoogleFonts.play(
                                  color: Colors.black,
                                  fontWeight: FontWeight.w600,
                                  fontSize: 16,
                                ),
                              ),
                              Text(
                                snapshot.data!['other'],
                                maxLines: 2,
                                overflow: TextOverflow.ellipsis,
                                style: GoogleFonts.play(
                                  color: Colors.black87,
                                  letterSpacing: 1.0,
                                  wordSpacing: 2.0,
                                  fontSize: 14,
                                ),
                              ),
                            ],
                          ),
                        ),
                        const SizedBox(
                          height: 15,
                        ),
                        SizedBox(
                          height: 60,
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.end,
                            children: [
                              const SizedBox(
                                width: 20,
                              ),
                              GestureDetector(
                                onTap: () async {
                                  String generatedDeepLink =
                                  await DynamicLinkServices
                                      .createPropertyShareLink(
                                      short: false,
                                      collectionId: widget.uid,
                                      docId: widget.docId,
                                      imageUrl: snapshot
                                          .data!['images'][0],
                                      propertyTitle:
                                      snapshot.data!['title']);
                                  Share.share(generatedDeepLink);
                                },
                                child: Container(
                                  decoration: BoxDecoration(
                                    color: Colors.blue[50],
                                    borderRadius: BorderRadius.circular(15.0),
                                  ),
                                  child: Padding(
                                    padding: const EdgeInsets.all(8.0),
                                    child: Icon(
                                      Icons.share,
                                      color: Colors.blue[800],
                                      size: 25,
                                    ),
                                  ),
                                ),
                              ),
                              const SizedBox(
                                width: 20,
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
                StreamBuilder<DocumentSnapshot>(
                    stream: FirebaseFirestore.instance
                        .collection('UserPhone')
                        .doc(snapshot.data!['colid'])
                        .snapshots(),
                    builder: (context, snap) {
                      return Container(
                        height: 90,
                        color: const Color(0xfff7f7f9),
                        child: Padding(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 20,
                            vertical: 20,
                          ),
                          child: Row(
                            children: [
                              ClipRRect(
                                borderRadius: BorderRadius.circular(10.0),
                                child: Image.network(
                                  "https://img.freepik.com/free-photo/happy-african-american-child-boy-smiling_263368-10.jpg?size=664&ext=jpg&ga=GA1.2.740930980.1616477634",
                                  height: 50,
                                  width: 50,
                                  fit: BoxFit.cover,
                                ),
                              ),
                              const SizedBox(
                                width: 10,
                              ),
                              Expanded(
                                child: Column(
                                  crossAxisAlignment:
                                  CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      widget.enableEdit
                                          ? snapshot.data!['name']
                                          .toString()
                                          : snapshot.data!['ownerName'],
                                      maxLines: 1,
                                      overflow: TextOverflow.ellipsis,
                                      style: GoogleFonts.play(
                                        color: Colors.black,
                                        fontWeight: FontWeight.w600,
                                        fontSize: 16,
                                      ),
                                    ),
                                    const SizedBox(
                                      height: 5,
                                    ),
                                    Text(
                                      widget.enableEdit
                                          ? snapshot.data!['number']
                                          .toString()
                                          : snap.data!['phone'].toString(),
                                      maxLines: 1,
                                      style: GoogleFonts.play(
                                        color: Colors.grey,
                                        fontSize: 14,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                              const SizedBox(
                                width: 10,
                              ),
                              Container(
                                decoration: const BoxDecoration(
                                    color: Colors.white,
                                    shape: BoxShape.circle),
                                child: Padding(
                                  padding: const EdgeInsets.all(8.0),
                                  child: IconButton(
                                    icon: const Icon(
                                      Icons.phone,
                                      size: 22,
                                    ),
                                    color: Colors.green,
                                    onPressed: () =>
                                        phoneCall(snapshot.data!['number']),
                                  ),
                                ),
                              ),
                              const SizedBox(
                                width: 20,
                              ),
                              Container(
                                decoration: const BoxDecoration(
                                    color: Colors.white,
                                    shape: BoxShape.circle),
                                child: Padding(
                                  padding: const EdgeInsets.all(8.0),
                                  child: IconButton(
                                    icon: const Icon(
                                      Icons.whatsapp,
                                      size: 22,
                                    ),
                                    color: const Color(0xfff63e3c),
                                    onPressed: () async {
                                      await launch(
                                          'https://api.whatsapp.com/send/?phone=91${snapshot.data!['number']}&text&app_absent=0');
                                    },
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),
                      );
                    }),
                SizedBox(
                  child: Consumer<AddProvider>(
                      builder: (context, adProvider, child) {
                        if (adProvider.isDetailsPageBannerLoaded) {
                          return SizedBox(
                            height: adProvider.detailsPageBanner.size.height
                                .toDouble(),
                            child: AdWidget(
                              ad: adProvider.detailsPageBanner,
                            ),
                          );
                        } else {
                          return Container();
                        }
                      }),
                )
              ],
            );
          }),
    );
  }

  _facilities(IconData icon, String facility) {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 7.5),
      decoration: BoxDecoration(
          color: Colors.grey[100], borderRadius: BorderRadius.circular(5.0)),
      child: Padding(
        padding: const EdgeInsets.symmetric(
          vertical: 5,
          horizontal: 10,
        ),
        child: Row(
          children: [
            Icon(
              icon,
              color: Colors.black,
              size: 16,
            ),
            const SizedBox(
              width: 10,
            ),
            Text(
              facility,
              style: GoogleFonts.play(
                color: Colors.black,
                fontWeight: FontWeight.w600,
                fontSize: 12,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
