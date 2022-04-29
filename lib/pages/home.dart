import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:loader_overlay/loader_overlay.dart';
import 'package:provider/provider.dart';
import 'package:untitled/addHelper.dart';
import 'package:untitled/pages/add.dart';
import 'package:untitled/pages/loginPage.dart';
import 'package:untitled/pages/searchbar.dart';
import '../widgets.dart';
import 'filter.dart';
import 'house_details.dart';

enum Page { home, public }

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

  @override
  void initState() {
    super.initState();

    AddProvider adProvider = Provider.of<AddProvider>(context, listen: false);
    adProvider.initialiseHomePageBanner();
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
            return Wrap(
              children: [
                Filter(uid: widget.uid.toString()),
              ],
            );
          });
    }

    return LoaderOverlay(
      child: Scaffold(
        body: SafeArea(
          child: Column(
            children: [
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 20),
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
                          ]),
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
                        padding: const EdgeInsets.all(8.0),
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
              if (selectedPage == Page.home)
                Expanded(
                  child: Column(
                    children: [
                      Padding(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 20,
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

                          final List storedocs = [];
                          snapshot.data!.docs.map((DocumentSnapshot document) {
                            Map a = document.data() as Map<String, dynamic>;
                            storedocs.add(a);
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
                                          i < storedocs.length;
                                          i++) ...[
                                        GestureDetector(
                                          onDoubleTap: () {
                                            _showMyDialog(storedocs[i]['id']);
                                          },
                                          child: NearbyHomes(
                                            asset: storedocs[i]['images'],
                                            name: storedocs[i]['title'],
                                            location: storedocs[i]['address'],
                                            bedCount: storedocs[i]['bedRooms'],
                                            bathCount: storedocs[i]
                                                ['bathRooms'],
                                            onTap: () {
                                              Navigator.push(
                                                context,
                                                MaterialPageRoute(
                                                  builder: (context) =>
                                                      HouseDetails(
                                                    isPublic: storedocs[i]
                                                        ['isPublic'],
                                                    enableEdit: true,
                                                    uid: widget.uid.toString(),
                                                    docId: storedocs[i]['id'],
                                                    assets: storedocs[i]
                                                        ['images'],
                                                    facilities: storedocs[i]
                                                        ['keywords'],
                                                    title: storedocs[i]
                                                        ['title'],
                                                    address: storedocs[i]
                                                        ['address'],
                                                    bedRooms: storedocs[i]
                                                        ['bedRooms'],
                                                    bathRooms: storedocs[i]
                                                        ['bathRooms'],
                                                    price: storedocs[i]['Price']
                                                        .toString(),
                                                    landSize: storedocs[i]
                                                            ['landSize']
                                                        .toString(),
                                                    keywords: storedocs[i]
                                                        ['keywords'],
                                                    name: storedocs[i]['name'],
                                                    number: storedocs[i]
                                                            ['number']
                                                        .toString(),
                                                    sizeUnit: storedocs[i]
                                                        ['sizeUnit'],
                                                          enableChange: false,
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
                        padding: const EdgeInsets.symmetric(
                          horizontal: 20,
                        ),
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

                          final List storedocs = [];
                          snapshot.data!.docs.map((DocumentSnapshot document) {
                            Map a = document.data() as Map<String, dynamic>;
                            storedocs.add(a);
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
                                          i < storedocs.length;
                                          i++) ...[
                                        NearbyHomes(
                                          asset: storedocs[i]['images'],
                                          name: storedocs[i]['title'],
                                          location: storedocs[i]['address'],
                                          bedCount: storedocs[i]['bedRooms'],
                                          bathCount: storedocs[i]['bathRooms'],
                                          onTap: () {
                                            Navigator.push(
                                              context,
                                              MaterialPageRoute(
                                                builder: (context) =>
                                                    HouseDetails(
                                                  isPublic: storedocs[i]
                                                      ['isPublic'],
                                                  uid: widget.uid.toString(),
                                                  docId: storedocs[i]['id'],
                                                  assets: storedocs[i]
                                                      ['images'],
                                                  facilities: storedocs[i]
                                                      ['keywords'],
                                                  title: storedocs[i]['title'],
                                                  address: storedocs[i]
                                                      ['address'],
                                                  bedRooms: storedocs[i]
                                                      ['bedRooms'],
                                                  bathRooms: storedocs[i]
                                                      ['bathRooms'],
                                                  price: storedocs[i]['Price']
                                                      .toString(),
                                                  landSize: storedocs[i]
                                                          ['landSize']
                                                      .toString(),
                                                  keywords: storedocs[i]
                                                      ['keywords'],
                                                  name: storedocs[i]['name'],
                                                  number: storedocs[i]['number']
                                                      .toString(),
                                                  sizeUnit: storedocs[i]
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
                )
              // SizedBox(
              //   child:
              //       Consumer<AddProvider>(builder: (context, adProvider, child) {
              //     if (adProvider.isHomePageBannerLoaded) {
              //       return SizedBox(
              //         height: adProvider.homePageBanner.size.height.toDouble(),
              //         child: AdWidget(
              //           ad: adProvider.homePageBanner,
              //         ),
              //       );
              //     } else {
              //       return Container();
              //     }
              //   }),
              // )
            ],
          ),
        ),
        floatingActionButtonLocation: FloatingActionButtonLocation.centerDocked,
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
          padding: const EdgeInsets.symmetric(
            horizontal: 30,
            vertical: 20,
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: <Widget>[
              IconButton(
                icon: Icon(
                  Icons.home,
                  size: selectedPage == Page.home ? 36 : 26,
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
                  Icons.public,
                  size: selectedPage == Page.public ? 36 : 26,
                  color: Colors.blueGrey,
                ),
                onPressed: () {
                  if (selectedPage != Page.public) {
                    setState(() => selectedPage = Page.public);
                  }
                },
              ),
              const Icon(
                Icons.bookmark_border,
                color: Colors.blueGrey,
                size: 26,
              ),
              IconButton(
                icon: const Icon(
                  Icons.person_outline,
                  size: 26,
                  color: Colors.blueGrey,
                ),
                onPressed: () {
                  FirebaseAuth.instance.signOut();
                  Navigator.pop(context);
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => const LoginScreen(),
                    ),
                  );
                },
              ),
            ],
          ),
        ),
      ),
    );
  }
}
