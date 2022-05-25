import 'dart:async';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:google_mobile_ads/google_mobile_ads.dart';
import 'package:provider/provider.dart';
import 'package:share_plus/share_plus.dart';
import 'package:untitled/addHelper.dart';
import 'package:untitled/dynamic_links.dart';
import 'package:untitled/pages/add.dart';
import 'package:untitled/pages/loginPage.dart';
import 'package:untitled/pages/profile.dart';
import 'package:untitled/pages/searchbar.dart';

import '../widgets.dart';
import 'house_details.dart';

enum Page { home, public, bookmark, profile }

class Home extends StatefulWidget {
  const Home({Key? key, required this.uid}) : super(key: key);
  final String? uid;

  @override
  _HomeState createState() => _HomeState();
}

class _HomeState extends State<Home> {
  bool isLoading = false;
  Color? kActiveColor = Colors.blue[200];
  Color? kInActiveColor = Colors.blue[200]?.withOpacity(0.05);
  String propertyType = 'None';
  Page selectedPage = Page.home;
  ConnectivityResult _connectivityResult = ConnectivityResult.none;
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

    DynamicLinkServices.initialDynamicLink(context);
    AddProvider adProvider = Provider.of<AddProvider>(context, listen: false);
    adProvider.initialiseHomePageBanner();
  }

  @override
  void dispose() {
    _streamSubscription.cancel();
    super.dispose();
  }

  Set selectedList = Set();

  @override
  Widget build(BuildContext context) {
    final Stream<QuerySnapshot> homeProperties = FirebaseFirestore.instance
        .collection(widget.uid.toString())
        .snapshots();

    final Stream<QuerySnapshot> publicProperties =
        FirebaseFirestore.instance.collection('Public').snapshots();

    showSnackBar(String snackText, Duration d) {
      final snackBar = SnackBar(content: Text(snackText), duration: d);
      ScaffoldMessenger.of(context).showSnackBar(snackBar);
    }

    Size size = MediaQuery.of(context).size;

    return _connectivityResult == ConnectivityResult.none
        ? Scaffold(
            backgroundColor: Colors.white,
            body: Center(
              child: Image.asset('assets/not_connected.jpg'),
            ),
          )
        : Scaffold(
            body: SafeArea(
              child: Column(
                children: [
                  Padding(
                    padding: EdgeInsets.symmetric(horizontal: .04 * size.width),
                    child: Column(
                      children: [
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            RichText(
                              text: TextSpan(
                                text: 'Find your\n',
                                style: GoogleFonts.play(
                                    color: Colors.grey, fontSize: 26),
                                children: <TextSpan>[
                                  TextSpan(
                                    text: 'Perfect Home',
                                    style: GoogleFonts.play(
                                        color: Colors.blue[300],
                                        fontSize: 26,
                                        fontWeight: FontWeight.w600),
                                  )
                                ],
                              ),
                            ),
                            Container(
                              decoration: BoxDecoration(
                                color: Colors.transparent,
                                borderRadius: BorderRadius.circular(15.0),
                                border: Border.all(
                                  color: Colors.grey[300]!,
                                ),
                              ),
                              child: Padding(
                                padding: EdgeInsets.all(.02 * size.width),
                                child: IconButton(
                                  icon: const Icon(
                                    Icons.search,
                                    size: 24.0,
                                  ),
                                  color: Colors.black,
                                  onPressed: () {
                                    Navigator.push(
                                      context,
                                      MaterialPageRoute(
                                        builder: (context) => SearchBarData(
                                          uid: widget.uid.toString(),
                                        ),
                                      ),
                                    );
                                  },
                                ),
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                  if (selectedPage == Page.profile)
                    Expanded(
                      child: SingleChildScrollView(
                        child: Column(
                          children: [
                            ProfilePic(
                                url: FirebaseAuth
                                        .instance.currentUser!.photoURL ??
                                    'https://www.kindpng.com/picc/m/24-248729_stockvader-predicted-adig-user-profile-image-png-transparent.png'),
                            const SizedBox(
                              height: 20,
                            ),
                            Text(
                              FirebaseAuth.instance.currentUser!.displayName
                                  .toString(),
                              style: const TextStyle(
                                  color: Colors.blue,
                                  fontSize: 22,
                                  fontWeight: FontWeight.bold),
                            ),
                            const SizedBox(height: 20),
                            Text(
                              FirebaseAuth.instance.currentUser!.email
                                  .toString(),
                              style: const TextStyle(
                                  color: Colors.blue,
                                  fontSize: 17,
                                  fontWeight: FontWeight.w400),
                            ),
                            const SizedBox(height: 10),
                            ProfileMenu(
                              text: 'Edit Account Details',
                              icon: Icons.person,
                              press: () async {
                                Navigator.push(
                                  context,
                                  MaterialPageRoute(
                                    builder: (context) => ProfilePage(
                                      name: FirebaseAuth
                                          .instance.currentUser!.displayName
                                          .toString(),
                                      pic: FirebaseAuth
                                              .instance.currentUser!.photoURL ??
                                          'https://www.kindpng.com/picc/m/24-248729_stockvader-predicted-adig-user-profile-image-png-transparent.png',
                                      email: FirebaseAuth
                                          .instance.currentUser!.email
                                          .toString(),
                                      uid: widget.uid.toString(),
                                    ),
                                  ),
                                );
                              },
                            ),
                            ProfileMenu(
                              text: 'Reset Password',
                              icon: Icons.security,
                              press: () async {
                                FirebaseAuth.instance
                                    .sendPasswordResetEmail(
                                        email: FirebaseAuth
                                            .instance.currentUser!.email
                                            .toString())
                                    .whenComplete(() {
                                  ScaffoldMessenger.of(context).showSnackBar(
                                    const SnackBar(
                                      content: Text(
                                          'Password Reset Email Sent to Registered Email Id'),
                                    ),
                                  );
                                });
                              },
                            ),
                            ProfileMenu(
                              text: 'Signout',
                              icon: Icons.logout,
                              press: () async {
                                try {
                                  await FirebaseAuth.instance.signOut();
                                  showSnackBar(
                                    'Logged out',
                                    const Duration(milliseconds: 1000),
                                  );
                                  Navigator.push(
                                    context,
                                    MaterialPageRoute(
                                      builder: (context) => const LoginScreen(),
                                    ),
                                  );
                                } catch (e) {
                                  showSnackBar(
                                    'Could not loggout because of $e',
                                    const Duration(milliseconds: 1000),
                                  );
                                }
                              },
                            ),
                          ],
                        ),
                      ),
                    ),
                  if (selectedPage == Page.home)
                    Expanded(
                      child: Column(
                        children: [
                          Padding(
                            padding: EdgeInsets.symmetric(
                              horizontal: .04 * size.width,
                            ),
                            child: Column(
                              children: [
                                TitleFilter(
                                  title: 'Added Properties',
                                ),
                                GestureDetector(
                                  onTap: () async {
                                    if (selectedList.length > 0) {
                                      setState(()=>isLoading = true);
                                      print(selectedList);
                                      var linkList = '';

                                      for (int i = 0;
                                          i < selectedList.length;
                                          i++) {
                                        String generatedDeepLink =
                                            await DynamicLinkServices
                                                .createPropertyShareLink(
                                                    short: false,
                                                    collectionId:
                                                        widget.uid.toString(),
                                                    docId: selectedList
                                                        .elementAt(i)['id'],
                                                    imageUrl: selectedList
                                                        .elementAt(i)['id'][0],
                                                    propertyTitle: selectedList
                                                        .elementAt(i)['title']);

                                        linkList =
                                            linkList + '\n $generatedDeepLink';
                                      }
                                      Share.share(linkList).whenComplete(() =>
                                          setState(() => isLoading = false));

                                      selectedList = Set();
                                    } else {
                                      showSnackBar(
                                          'Please Select Properties to Share',
                                          Duration(seconds: 2));
                                    }
                                  },
                                  child: Padding(
                                    padding: const EdgeInsets.all(8.0),
                                    child: Container(
                                      decoration: BoxDecoration(
                                          border: Border.all(
                                              color: Colors.blue[200]!),
                                          color: Colors.white,
                                          borderRadius:
                                              BorderRadius.circular(15.0)),
                                      height: 40,
                                      width: size.width * .86,
                                      child: Icon(Icons.share),
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          ),
                          StreamBuilder<QuerySnapshot>(
                            stream: homeProperties,
                            builder: (BuildContext context,
                                AsyncSnapshot<QuerySnapshot> snapshot) {
                              if (snapshot.hasError) {
                                ScaffoldMessenger.of(context).showSnackBar(
                                  const SnackBar(
                                    content: Text('Something Went Wrong.'),
                                  ),
                                );
                              }
                              if (snapshot.connectionState ==
                                  ConnectionState.waiting) {
                                return const Center(
                                  child: CircularProgressIndicator(),
                                );
                              }

                              final List storeDocs = [];
                              snapshot.data!.docs
                                  .map((DocumentSnapshot document) {
                                Map a = document.data() as Map<String, dynamic>;
                                storeDocs.add(a);
                                a['id'] = document.id;
                                a['collection'] = document.reference;
                              }).toList();

                              if (isLoading) {
                                return const Center(
                                  child: Text('Loading'),
                                );
                              } else {
                                return Expanded(
                                  child: ListView(
                                    physics: const BouncingScrollPhysics(),
                                    children: [
                                      for (var i = 0;
                                          i < storeDocs.length;
                                          i++) ...[
                                        NearbyHomes(
                                          size: size,
                                          isSelected: (bool value) {
                                            if (value) {
                                              selectedList.add(storeDocs[i]);
                                            } else {
                                              selectedList.remove(storeDocs[i]);
                                            }
                                          },
                                          key: Key((i).toString()),
                                          asset: storeDocs[i]['images'],
                                          name: storeDocs[i]['title'],
                                          location: storeDocs[i]['address'],
                                          bedCount: storeDocs[i]['bedRooms'],
                                          bathCount: storeDocs[i]['bathRooms'],
                                          bookmarkIcon: storeDocs[i]
                                              ['bookmark'],
                                          bookmarkFunction: () async {
                                            CollectionReference students =
                                                FirebaseFirestore.instance
                                                    .collection(
                                                        widget.uid.toString());

                                            students
                                                .doc(storeDocs[i]['id'])
                                                .update({
                                              'bookmark': !storeDocs[i]
                                                  ['bookmark'],
                                            }).whenComplete(() {
                                              if (!storeDocs[i]['bookmark']) {
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
                                              setState(() {});
                                            });
                                          },
                                              share: () async {
                                                String generatedDeepLink =
                                                    await DynamicLinkServices
                                                        .createPropertyShareLink(
                                                            short: false,
                                                            collectionId: widget
                                                                .uid
                                                                .toString(),
                                                            docId: storeDocs[i]
                                                                ['id'],
                                                            imageUrl: storeDocs[
                                                                i]['images'][0],
                                                            propertyTitle:
                                                                storeDocs[i]
                                                                    ['title']);
                                                Share.share(generatedDeepLink);
                                              },
                                              onTap: () {
                                                Navigator.push(
                                                  context,
                                                  MaterialPageRoute(
                                                    builder: (context) =>
                                                        HouseDetails(
                                                      enableEdit: true,
                                                      uid:
                                                          widget.uid.toString(),
                                                      docId: storeDocs[i]['id'],
                                                    ),
                                                  ),
                                                );
                                              },
                                            ),
                                          ]
                                        ],
                                      ),
                                    );
                              }
                            },
                          ),
                        ],
                      ),
                    ),
                  if (selectedPage == Page.public)
                    Expanded(
                      child: Column(
                        children: [
                          Padding(
                            padding: EdgeInsets.symmetric(
                                horizontal: .04 * size.width),
                            child: Column(
                              children: [
                                TitleFilter(
                                  title: 'Public Properties',
                                ),
                                GestureDetector(
                                  onTap: () async {
                                    if (selectedList.length > 0) {
                                      setState(()=>isLoading = true);
                                      print(selectedList);
                                      var linkList = '';

                                      for (int i = 0;
                                          i < selectedList.length;
                                          i++) {
                                        String generatedDeepLink =
                                            await DynamicLinkServices
                                                .createPropertyShareLink(
                                                    short: false,
                                                    collectionId:
                                                        widget.uid.toString(),
                                                    docId: selectedList
                                                        .elementAt(i)['id'],
                                                    imageUrl: selectedList
                                                        .elementAt(i)['id'][0],
                                                    propertyTitle: selectedList
                                                        .elementAt(i)['title']);

                                        linkList =
                                            linkList + '\n $generatedDeepLink';
                                      }
                                      Share.share(linkList).whenComplete(() =>
                                          setState(() => isLoading = false));

                                      selectedList = Set();
                                    } else {
                                      showSnackBar(
                                          'Please Select Properties to Share',
                                          Duration(seconds: 2));
                                    }
                                  },
                                  child: Padding(
                                    padding: const EdgeInsets.all(8.0),
                                    child: Container(
                                      decoration: BoxDecoration(
                                          border: Border.all(
                                              color: Colors.blue[200]!),
                                          color: Colors.white,
                                          borderRadius:
                                              BorderRadius.circular(15.0)),
                                      height: 40,
                                      width: size.width * .86,
                                      child: Icon(Icons.share),
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          ),
                          StreamBuilder<QuerySnapshot>(
                            stream: publicProperties,
                            builder: (BuildContext context,
                                AsyncSnapshot<QuerySnapshot> snapshot) {
                              if (snapshot.hasError) {
                                ScaffoldMessenger.of(context).showSnackBar(
                                  const SnackBar(
                                    content: Text('Something Went Wrong.'),
                                  ),
                                );
                              }
                              if (snapshot.connectionState ==
                                  ConnectionState.waiting) {
                                return const Center(
                                  child: CircularProgressIndicator(),
                                );
                              }

                              final List storeDocs = [];
                              snapshot.data!.docs
                                  .map((DocumentSnapshot document) {
                                Map a = document.data() as Map<String, dynamic>;
                                storeDocs.add(a);
                                a['id'] = document.id;
                              }).toList();

                              return isLoading
                                  ? const Center(
                                      child: Text('Loading'),
                                    )
                                  : Expanded(
                                      child: ListView(
                                        physics: const BouncingScrollPhysics(),
                                        children: [
                                          for (var i = 0;
                                              i < storeDocs.length;
                                              i++) ...[
                                            NearbyHomes(
                                              isSelected: (bool value) {
                                                if (value) {
                                                  selectedList
                                                      .add(storeDocs[i]);
                                                } else {
                                                  selectedList
                                                      .remove(storeDocs[i]);
                                                }
                                              },
                                              key: Key((i).toString()),
                                              usage: 'public',
                                              size: size,
                                              asset: storeDocs[i]['images'],
                                              name: storeDocs[i]['title'],
                                              location: storeDocs[i]['address'],
                                              bedCount: storeDocs[i]
                                                  ['bedRooms'],
                                              bathCount: storeDocs[i]
                                                  ['bathRooms'],
                                              bookmarkIcon: storeDocs[i]
                                                  ['bookmark'],
                                              bookmarkFunction: () async {
                                                CollectionReference students =
                                                FirebaseFirestore.instance
                                                    .collection(widget.uid
                                                    .toString());

                                                students
                                                    .doc(storeDocs[i]['id'])
                                                    .update({
                                                  'bookmark': !storeDocs[i]
                                                  ['bookmark'],
                                                }).whenComplete(() {
                                                  if (!storeDocs[i]
                                                  ['bookmark']) {
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
                                                  setState(() {});
                                                });
                                              },
                                              share: () async {
                                                String generatedDeepLink =
                                                await DynamicLinkServices
                                                    .createPropertyShareLink(
                                                    short: false,
                                                    collectionId: widget
                                                        .uid
                                                        .toString(),
                                                    docId: storeDocs[i]
                                                    ['id'],
                                                    imageUrl: storeDocs[
                                                    i]['images'][0],
                                                    propertyTitle:
                                                    storeDocs[i]
                                                    ['title']);
                                                Share.share(generatedDeepLink);
                                              },
                                              onTap: () {
                                                print('tap');
                                                Navigator.push(
                                                  context,
                                                  MaterialPageRoute(
                                                    builder: (context) =>
                                                        HouseDetails(
                                                          uid: 'Public',
                                                          docId: storeDocs[i]['id'],
                                                          enableEdit: false,
                                                        ),
                                                  ),
                                                );
                                              },
                                            ),
                                          ]
                                        ],
                                      ),
                                    );
                            },
                          ),
                        ],
                      ),
                    ),
                  if (selectedPage == Page.bookmark)
                    Expanded(
                      child: Column(
                        children: [
                          Padding(
                            padding: EdgeInsets.symmetric(
                                horizontal: .04 * size.width),
                            child: Column(
                              children: [
                                TitleFilter(
                                  title: 'Bookmarked Properties',
                                ),
                                GestureDetector(
                                  onTap: () async {
                                    if (selectedList.length > 0) {
                                      setState(() => isLoading = true);
                                      print(selectedList);
                                      var linkList = '';

                                      for (int i = 0;
                                          i < selectedList.length;
                                          i++) {
                                        String generatedDeepLink =
                                            await DynamicLinkServices
                                                .createPropertyShareLink(
                                                    short: false,
                                                    collectionId:
                                                        widget.uid.toString(),
                                                    docId: selectedList
                                                        .elementAt(i)['id'],
                                                    imageUrl: selectedList
                                                        .elementAt(i)['id'][0],
                                                    propertyTitle: selectedList
                                                        .elementAt(i)['title']);

                                        linkList =
                                            linkList + '\n $generatedDeepLink';
                                      }
                                      Share.share(linkList).whenComplete(() =>
                                          setState(() => isLoading = false));

                                      selectedList = Set();
                                    } else {
                                      showSnackBar(
                                          'Please Select Properties to Share',
                                          Duration(seconds: 2));
                                    }
                                  },
                                  child: Padding(
                                    padding: const EdgeInsets.all(8.0),
                                    child: Container(
                                      decoration: BoxDecoration(
                                          border: Border.all(
                                              color: Colors.blue[200]!),
                                          color: Colors.white,
                                          borderRadius:
                                              BorderRadius.circular(15.0)),
                                      height: 40,
                                      width: size.width * .86,
                                      child: Icon(Icons.share),
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          ),
                          StreamBuilder<QuerySnapshot>(
                            stream: homeProperties,
                            builder: (BuildContext context,
                                AsyncSnapshot<QuerySnapshot> snapshot) {
                              if (snapshot.hasError) {
                                ScaffoldMessenger.of(context).showSnackBar(
                                  const SnackBar(
                                    content: Text('Something Went Wrong.'),
                                  ),
                                );
                              }
                              if (snapshot.connectionState ==
                                  ConnectionState.waiting) {
                                return const Center(
                                  child: CircularProgressIndicator(),
                                );
                              }

                              final List storeDocs = [];
                              snapshot.data!.docs
                                  .map((DocumentSnapshot document) {
                                Map a = document.data() as Map<String, dynamic>;
                                storeDocs.add(a);
                                a['id'] = document.id;
                              }).toList();

                              return isLoading
                                  ? const Center(
                                      child: Text('Loading'),
                                    )
                                  : Expanded(
                                      child: ListView(
                                        physics: const BouncingScrollPhysics(),
                                        children: [
                                          for (var i = 0;
                                              i < storeDocs.length;
                                              i++) ...[
                                            if (storeDocs[i]['bookmark'])
                                              NearbyHomes(
                                                isSelected: (bool value) {
                                                  if (value) {
                                                    selectedList
                                                        .add(storeDocs[i]);
                                                  } else {
                                                    selectedList
                                                        .remove(storeDocs[i]);
                                                  }
                                                },
                                                key: Key((i).toString()),
                                                size: size,
                                                asset: storeDocs[i]['images'],
                                                name: storeDocs[i]['title'],
                                                location: storeDocs[i]
                                                    ['address'],
                                                bedCount: storeDocs[i]
                                                    ['bedRooms'],
                                                bathCount: storeDocs[i]
                                                    ['bathRooms'],
                                                bookmarkIcon: storeDocs[i]
                                                    ['bookmark'],
                                                bookmarkFunction: () async {
                                                  CollectionReference students =
                                                  FirebaseFirestore.instance
                                                      .collection(widget.uid
                                                      .toString());

                                                  students
                                                      .doc(storeDocs[i]['id'])
                                                      .update({
                                                    'bookmark': !storeDocs[i]
                                                    ['bookmark'],
                                                  }).whenComplete(() {
                                                    if (!storeDocs[i]
                                                    ['bookmark']) {
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
                                                    setState(() {});
                                                  });
                                                },
                                                share: () async {
                                                  String generatedDeepLink =
                                                  await DynamicLinkServices
                                                      .createPropertyShareLink(
                                                      short: false,
                                                      collectionId: widget
                                                          .uid
                                                          .toString(),
                                                      docId:
                                                      storeDocs[i]
                                                      ['id'],
                                                      imageUrl: storeDocs[
                                                      i]
                                                      ['images'][0],
                                                      propertyTitle:
                                                      storeDocs[i][
                                                      'title']);
                                                  Share.share(
                                                      generatedDeepLink);
                                                },
                                                onTap: () {
                                                  Navigator.push(
                                                    context,
                                                    MaterialPageRoute(
                                                      builder: (context) =>
                                                          HouseDetails(
                                                            enableEdit: true,
                                                            uid: widget.uid
                                                                .toString(),
                                                            docId: storeDocs[i]
                                                            ['id'],
                                                          ),
                                                    ),
                                                  );
                                                },
                                              ),
                                          ]
                                        ],
                                      ),
                                    );
                            },
                          ),
                        ],
                      ),
                    ),
                  Consumer<AddProvider>(builder: (context, adProvider, child) {
                    if (adProvider.isHomePageBannerLoaded) {
                      return SizedBox(
                        height:
                            adProvider.homePageBanner.size.height.toDouble(),
                        child: AdWidget(
                          ad: adProvider.homePageBanner,
                        ),
                      );
                    } else {
                      return Container();
                    }
                  }),
                ],
              ),
            ),
            floatingActionButtonLocation:
                FloatingActionButtonLocation.centerDocked,
            floatingActionButton: ClipRRect(
              borderRadius: BorderRadius.circular(20.0),
              child: FloatingActionButton(
                backgroundColor: Colors.blue[300],
                shape: const RoundedRectangleBorder(),
                onPressed: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => Add(
                        collection: widget.uid.toString(),
                      ),
                    ),
                  );
                },
                tooltip: 'Increment',
                child: const Icon(
                  Icons.add,
                  size: 26,
                ),
                elevation: 2.0,
              ),
            ),

            //todo: un comment after account approved
            bottomNavigationBar: Padding(
              padding: EdgeInsets.symmetric(
                horizontal: .08 * size.width,
                vertical: 20,
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: <Widget>[
                  IconButton(
                    icon: Icon(
                      selectedPage == Page.home
                          ? Icons.home
                          : Icons.home_outlined,
                      size: 28,
                      color: Colors.blueGrey,
                    ),
                    color: const Color(0xff442243),
                    onPressed: () {
                      if (selectedPage != Page.home) {
                        setState(() => selectedPage = Page.home);
                        selectedList = Set();
                      }
                    },
                  ),
                  IconButton(
                    icon: Icon(
                      selectedPage == Page.public
                          ? Icons.person_pin_circle
                          : Icons.person_pin_circle_outlined,
                      size: 28,
                      color: Colors.blueGrey,
                    ),
                    onPressed: () {
                      if (selectedPage != Page.public) {
                        setState(() => selectedPage = Page.public);
                        selectedList = Set();
                      }
                    },
                  ),
                  IconButton(
                    icon: Icon(
                      selectedPage == Page.bookmark
                          ? Icons.bookmark
                          : Icons.bookmark_border,
                      size: 28,
                      color: Colors.blueGrey,
                    ),
                    onPressed: () {
                      if (selectedPage != Page.bookmark) {
                        setState(() => selectedPage = Page.bookmark);
                        selectedList = Set();
                      }
                    },
                  ),
                  IconButton(
                    icon: Icon(
                      selectedPage == Page.profile
                          ? Icons.person
                          : Icons.person_outline,
                      size: 26,
                      color: Colors.blueGrey,
                    ),
                    onPressed: () {
                      if (selectedPage != Page.profile) {
                        setState(() => selectedPage = Page.profile);
                        selectedList = Set();
                      }
                    },
                  ),
                ],
              ),
            ),
          );
  }
}
