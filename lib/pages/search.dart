import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:share_plus/share_plus.dart';
import '../dynamic_links.dart';
import '../widgets.dart';
import 'house_details.dart';

class Search extends StatefulWidget {
  Search({
    Key? key,
    required this.uid,
    required this.propertyType,
    required this.rooms,
    required this.buyOrRent,
    required this.priceStart,
    required this.priceEnd,
    required this.bathrooms,
  }) : super(key: key);
  final String? uid;
  String propertyType = 'Flat';
  String rooms = 'Any';
  String bathrooms = 'Any';
  String buyOrRent = 'Buy';
  double priceStart = 100;
  double priceEnd = 100;

  @override
  _SearchState createState() => _SearchState();
}

class _SearchState extends State<Search> {
  final searchController = TextEditingController();

  @override
  void dispose() {
    searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final CollectionReference noticeCollection =
        FirebaseFirestore.instance.collection(widget.uid.toString());

    final data = noticeCollection
        .where("types", isEqualTo: widget.propertyType)
        .where("buyRent", arrayContainsAny: [widget.buyOrRent])
        .where("Price", isGreaterThanOrEqualTo: widget.priceStart)
        .where("Price", isLessThanOrEqualTo: widget.priceEnd)
        .where("bathRooms", isEqualTo: widget.bathrooms)
        .where("bedRooms", isEqualTo: widget.rooms)
        .snapshots();

    showSnackBar(String snackText, Duration d) {
      final snackBar = SnackBar(content: Text(snackText), duration: d);
      ScaffoldMessenger.of(context).showSnackBar(snackBar);
    }

    final Size size = MediaQuery.of(context).size;

    return Scaffold(
      appBar: AppBar(
        centerTitle: true,
        title: const Text('Search'),
      ),
      body: SingleChildScrollView(
        child: Container(
          padding: const EdgeInsets.all(10),
          child: Column(
            children: [
              // TextFormField(
              //   controller: searchController,
              //   decoration: InputDecoration(
              //       labelText: 'Search For Properties',
              //       suffixIcon: IconButton(
              //         icon: const Icon(Icons.search),
              //         onPressed: () {
              //           setState(() {
              //             final data = noticeCollection
              //                 .where("searchData", arrayContains: searchController.text).snapshots();
              //           });
              //         },
              //       )),
              //
              // ),
              SizedBox(
                height: MediaQuery.of(context).size.height,
                child: StreamBuilder<QuerySnapshot>(
                    stream: data,
                    builder: (BuildContext context,
                        AsyncSnapshot<QuerySnapshot> snapshot) {
                      if (snapshot.hasError) {
                        return const Text('Something went wrong');
                      }
                      if (snapshot.connectionState == ConnectionState.waiting) {
                        return const Text('Loading');
                      }

                      final data = snapshot.requireData;

                      return ListView.builder(
                        itemCount: data.size,
                        itemBuilder: (context, index) {
                          return Column(
                            children: [
                              NearbyHomes(
                                size: size,
                                asset: data.docs[index]['images'],
                                name: data.docs[index]['title'],
                                location: data.docs[index]['address'],
                                bedCount: data.docs[index]['bedRooms'],
                                bathCount: data.docs[index]['bathRooms'],
                                bookmarkIcon: data.docs[index]['bookmark'],
                                bookmarkFunction: () async {
                                  CollectionReference students =
                                  FirebaseFirestore.instance.collection(widget.uid.toString());

                                  students.doc(data.docs[index]['id']).update({
                                    'bookmark': !data.docs[index]['bookmark'],
                                  }).whenComplete(() {
                                    showSnackBar('Bookmarked', const Duration(milliseconds: 1000));
                                    setState((){});
                                  });

                                },
                                share: () async {
                                  String generatedDeepLink =
                                  await DynamicLinkServices.createPropertyShareLink(
                                      short: false,
                                      collectionId: widget.uid.toString(),
                                      docId: data.docs[index]['id'],
                                      imageUrl: data.docs[index]
                                      ['images'][0],
                                      propertyTitle: data.docs[index]
                                      ['title']
                                  );
                                  Share.share(generatedDeepLink);
                                },
                                onTap: () {
                                  Navigator.push(
                                    context,
                                    MaterialPageRoute(
                                      builder: (context) => HouseDetails(
                                        isPublic: data.docs[index]['isPublic'],
                                        docId: data.docs[index]['id'],
                                        uid: widget.uid.toString(),
                                        title: data.docs[index]['title'],
                                        facilities: data.docs[index]
                                            ['keywords'],
                                        assets: data.docs[index]['images'],
                                        address: data.docs[index]['address'],
                                        bedRooms: data.docs[index]['bedRooms'],
                                        bathRooms: data.docs[index]
                                            ['bathRooms'],
                                        price: data.docs[index]['Price'],
                                        landSize: data.docs[index]['landSize'],
                                        keywords: data.docs[index]['keywords'],
                                        name: data.docs[index]['name'],
                                        number: data.docs[index]['number'],
                                        sizeUnit: data.docs[index]['sizeUnit'], enableChange: false,
                                      ),
                                    ),
                                  );
                                },
                              ),
                            ],
                          );
                        },
                      );
                    }),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
