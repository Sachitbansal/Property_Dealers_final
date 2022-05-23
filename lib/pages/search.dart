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
    required this.areaStart,
    required this.areaEnd,
  }) : super(key: key);
  final String uid;
  final String propertyType;
  final String rooms;
  final String bathrooms;
  final String buyOrRent;
  final double priceStart;
  final double priceEnd;
  final double areaStart;
  final double areaEnd;

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
              SizedBox(
                height: MediaQuery.of(context).size.height,
                child: StreamBuilder<QuerySnapshot>(
                  stream: data,
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

                    return Expanded(
                      child: ListView(
                        physics: const BouncingScrollPhysics(),
                        children: [
                          for (var i = 0;
                          i < storeDocs.length;
                          i++) ...[
                            if (storeDocs[i]['landSize'] >= widget.areaStart && storeDocs[i]['landSize'] <= widget.areaEnd)
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
              ),
            ],
          ),
        ),
      ),
    );
  }
}
