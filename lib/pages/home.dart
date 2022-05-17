import 'dart:async';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import 'package:share_plus/share_plus.dart';
import 'package:untitled/addHelper.dart';
import 'package:untitled/dynamic_links.dart';
import 'package:untitled/pages/add.dart';
import 'package:untitled/pages/loginPage.dart';
import 'package:untitled/pages/profile.dart';
import 'package:untitled/pages/reset_pass.dart';
import 'package:untitled/pages/searchbar.dart';
import '../widgets.dart';
import 'filter.dart';
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

  Future<void> _showMyDialog(String documentId) async {
    return showDialog<void>(
      context: context,
      barrierDismissible: false, // user must tap button!
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('Are you sure want to make the Property Public?'),
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
                  child: const Text(
                    'Make Public',
                    style: TextStyle(color: Colors.red),
                  ),
                  onPressed: () {
                    Navigator.pop(context);
                    CollectionReference copyTo =
                        FirebaseFirestore.instance.collection('Public');
                    DocumentReference copyFrom = FirebaseFirestore.instance
                        .collection(widget.uid.toString())
                        .doc(documentId);

                    copyFrom.get().then(
                          (value) => {
                            copyTo.add(value.data()),
                          },
                        );
                  },
                ),
              ],
            ),
          ],
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    final Stream<QuerySnapshot> homeProperties = FirebaseFirestore.instance
        .collection(widget.uid.toString())
        .snapshots();

    final Stream<QuerySnapshot> publicProperties =
        FirebaseFirestore.instance.collection('Public').snapshots();

    final Stream<DocumentSnapshot> userData = FirebaseFirestore.instance
        .collection('Users')
        .doc(widget.uid.toString())
        .snapshots();

    void showBottomSheet() {
      showModalBottomSheet(
        context: context,
        isScrollControlled: true,
        shape: const RoundedRectangleBorder(
          borderRadius: BorderRadius.only(
            topLeft: Radius.circular(30),
            topRight: Radius.circular(30),
          ),
        ),
        builder: (BuildContext context) {
          return SingleChildScrollView(
            child: Wrap(
              children: [
                Filter(uid: widget.uid.toString()),
              ],
            ),
          );
        },
      );
    }

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
                    child: Row(
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
                  ),
                  if (selectedPage == Page.profile)
                    StreamBuilder<DocumentSnapshot>(
                      stream: userData,
                      builder: (context, snapshot) {
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

                        final userDocument = snapshot.data;
                        return Expanded(
                          child: Column(
                            children: [
                              SingleChildScrollView(
                                padding:
                                    const EdgeInsets.symmetric(vertical: 20),
                                child: Column(
                                  children: [
                                    ProfilePic(
                                        url: userDocument!["profilePic"]),
                                    const SizedBox(
                                      height: 20,
                                    ),
                                    Text(
                                      userDocument['name'],
                                      style: const TextStyle(
                                          color: Colors.blue,
                                          fontSize: 22,
                                          fontWeight: FontWeight.bold),
                                    ),
                                    const SizedBox(height: 20),
                                    Padding(
                                      padding: const EdgeInsets.symmetric(
                                          horizontal: 20, vertical: 10),
                                      child: TextButton(
                                        style: TextButton.styleFrom(
                                          primary: Colors.blue[300],
                                          padding: const EdgeInsets.all(20),
                                          shape: RoundedRectangleBorder(
                                              borderRadius:
                                                  BorderRadius.circular(15)),
                                          backgroundColor:
                                              const Color(0xFFF5F6F9),
                                        ),
                                        onPressed: () {},
                                        child: Row(
                                          mainAxisAlignment:
                                              MainAxisAlignment.spaceBetween,
                                          children: const [
                                            Text(
                                              'Total Properties',
                                              style: TextStyle(fontSize: 17),
                                            ),
                                            Text(
                                              '20',
                                              style: TextStyle(fontSize: 17),
                                            ),
                                          ],
                                        ),
                                      ),
                                    ),
                                    ProfileMenu(
                                      text: 'Edit Account Details',
                                      icon: Icons.person,
                                      press: () async {
                                        Navigator.push(
                                          context,
                                          MaterialPageRoute(
                                            builder: (context) => ProfilePage(
                                              userdata: userDocument,
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
                                        Navigator.push(
                                          context,
                                          MaterialPageRoute(
                                            builder: (context) =>
                                                const ResetPassword(),
                                          ),
                                        );
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
                                              builder: (context) =>
                                                  const LoginScreen(),
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
                            ],
                          ),
                        );
                      },
                    ),

                  if (selectedPage == Page.home)
                    Expanded(
                      child: Column(
                        children: [
                          Padding(
                            padding: EdgeInsets.symmetric(
                              horizontal: .04 * size.width,
                            ),
                            child: Row(
                              children: [
                                Text(
                                  "Nearby Homes",
                                  style: GoogleFonts.play(
                                    color: const Color(0xff4d3a58),
                                    fontWeight: FontWeight.w600,
                                    fontSize: 18,
                                  ),
                                ),
                                const Spacer(),
                                TextButton(
                                  child: Text(
                                    "FILTER",
                                    style: GoogleFonts.play(
                                      color: const Color(0xfff63e3c),
                                      fontWeight: FontWeight.w600,
                                      fontSize: 12,
                                    ),
                                  ),
                                  onPressed: () {
                                    showBottomSheet();
                                  },
                                )
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
                                            GestureDetector(
                                              onDoubleTap: () {
                                                _showMyDialog(
                                                    storeDocs[i]['id']);
                                              },
                                              child: NearbyHomes(
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
                                                            type: storeDocs[i]
                                                            ['types'],
                                                            constructionStatus: storeDocs[i]
                                                            ['construction'],
                                                            buyRent: storeDocs[i]
                                                            ['buyRent'][0],
                                                            isBookmarked: storeDocs[i]
                                                            ['bookmark'],
                                                        isPublic: storeDocs[i]
                                                            ['isPublic'],
                                                        enableEdit: true,
                                                        uid: widget.uid
                                                            .toString(),
                                                        docId: storeDocs[i]
                                                            ['id'],
                                                        assets: storeDocs[i]
                                                            ['images'],
                                                        facilities: storeDocs[i]
                                                            ['keywords'],
                                                        title: storeDocs[i]
                                                            ['title'],
                                                        address: storeDocs[i]
                                                            ['address'],
                                                        bedRooms: storeDocs[i]
                                                            ['bedRooms'],
                                                        bathRooms: storeDocs[i]
                                                            ['bathRooms'],
                                                        price: storeDocs[i]
                                                                ['Price']
                                                            .toString(),
                                                        landSize: storeDocs[i]
                                                                ['landSize']
                                                            .toString(),
                                                        keywords: storeDocs[i]
                                                            ['keywords'],
                                                        name: storeDocs[i]
                                                            ['name'],
                                                        number: storeDocs[i]
                                                                ['number']
                                                            .toString(),
                                                        sizeUnit: storeDocs[i]
                                                            ['sizeUnit'],
                                                        enableChange: true,
                                                        // enableChange: true
                                                      ),
                                                    ),
                                                  );
                                                },
                                              ),
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
                  if (selectedPage == Page.public)
                    Expanded(
                      child: Column(
                        children: [
                          Padding(
                            padding: EdgeInsets.symmetric(
                                horizontal: .04 * size.width),
                            child: Row(
                              children: [
                                Text(
                                  "Public Properties",
                                  style: GoogleFonts.play(
                                    color: const Color(0xff4d3a58),
                                    fontWeight: FontWeight.w600,
                                    fontSize: 18,
                                  ),
                                ),
                                const Spacer(),
                                TextButton(
                                  child: Text(
                                    "FILTER",
                                    style: GoogleFonts.play(
                                      color: const Color(0xfff63e3c),
                                      fontWeight: FontWeight.w600,
                                      fontSize: 12,
                                    ),
                                  ),
                                  onPressed: () {
                                    showBottomSheet();
                                  },
                                )
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
                                                Navigator.push(
                                                  context,
                                                  MaterialPageRoute(
                                                    builder: (context) =>
                                                        HouseDetails(
                                                          type: storeDocs[i]
                                                          ['types'],
                                                          constructionStatus: storeDocs[i]
                                                          ['construction'],
                                                          buyRent: storeDocs[i]
                                                          ['buyRent'][0],
                                                          isBookmarked: storeDocs[i]
                                                          ['bookmark'],
                                                      enableEdit: false,
                                                      enableChange: false,
                                                      isPublic: storeDocs[i]
                                                          ['isPublic'],
                                                      uid:
                                                          widget.uid.toString(),
                                                      docId: storeDocs[i]['id'],
                                                      assets: storeDocs[i]
                                                          ['images'],
                                                      facilities: storeDocs[i]
                                                          ['keywords'],
                                                      title: storeDocs[i]
                                                          ['title'],
                                                      address: storeDocs[i]
                                                          ['address'],
                                                      bedRooms: storeDocs[i]
                                                          ['bedRooms'],
                                                      bathRooms: storeDocs[i]
                                                          ['bathRooms'],
                                                      price: storeDocs[i]
                                                              ['Price']
                                                          .toString(),
                                                      landSize: storeDocs[i]
                                                              ['landSize']
                                                          .toString(),
                                                      keywords: storeDocs[i]
                                                          ['keywords'],
                                                      name: storeDocs[i]
                                                          ['name'],
                                                      number: storeDocs[i]
                                                              ['number']
                                                          .toString(),
                                                      sizeUnit: storeDocs[i]
                                                          ['sizeUnit'],
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
                            child: Row(
                              children: [
                                Text(
                                  "Bookmarked Properties",
                                  style: GoogleFonts.play(
                                    color: const Color(0xff4d3a58),
                                    fontWeight: FontWeight.w600,
                                    fontSize: 18,
                                  ),
                                ),
                                const Spacer(),
                                TextButton(
                                  child: Text(
                                    "FILTER",
                                    style: GoogleFonts.play(
                                      color: const Color(0xfff63e3c),
                                      fontWeight: FontWeight.w600,
                                      fontSize: 12,
                                    ),
                                  ),
                                  onPressed: () {
                                    showBottomSheet();
                                  },
                                )
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
                                                            type: storeDocs[i]
                                                            ['types'],
                                                            constructionStatus: storeDocs[i]
                                                            ['construction'],
                                                            buyRent: storeDocs[i]
                                                            ['buyRent'][0],
                                                            isBookmarked: storeDocs[i]
                                                            ['bookmark'],
                                                        enableEdit: true,
                                                        enableChange: true,
                                                        isPublic: storeDocs[i]
                                                            ['isPublic'],
                                                        uid: widget.uid
                                                            .toString(),
                                                        docId: storeDocs[i]
                                                            ['id'],
                                                        assets: storeDocs[i]
                                                            ['images'],
                                                        facilities: storeDocs[i]
                                                            ['keywords'],
                                                        title: storeDocs[i]
                                                            ['title'],
                                                        address: storeDocs[i]
                                                            ['address'],
                                                        bedRooms: storeDocs[i]
                                                            ['bedRooms'],
                                                        bathRooms: storeDocs[i]
                                                            ['bathRooms'],
                                                        price: storeDocs[i]
                                                                ['Price']
                                                            .toString(),
                                                        landSize: storeDocs[i]
                                                                ['landSize']
                                                            .toString(),
                                                        keywords: storeDocs[i]
                                                            ['keywords'],
                                                        name: storeDocs[i]
                                                            ['name'],
                                                        number: storeDocs[i]
                                                                ['number']
                                                            .toString(),
                                                        sizeUnit: storeDocs[i]
                                                            ['sizeUnit'],
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
                  // Consumer<AddProvider>(builder: (context, adProvider, child) {
                  //   if (adProvider.isHomePageBannerLoaded) {
                  //     return SizedBox(
                  //       height: adProvider.homePageBanner.size.height.toDouble(),
                  //       child: AdWidget(
                  //         ad: adProvider.homePageBanner,
                  //       ),
                  //     );
                  //   } else {
                  //     return Container();
                  //   }
                  // }),
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
                      }
                    },
                  ),
                  IconButton(
                    icon: const Icon(
                      Icons.person_outline,
                      size: 26,
                      color: Colors.blueGrey,
                    ),
                    onPressed: () {
                      if (selectedPage != Page.profile) {
                        setState(() => selectedPage = Page.profile);
                      }
                    },
                  ),
                ],
              ),
            ),
          );
  }
}
