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
  final String uid;
  final String propertyType;
  final String rooms;
  final String bathrooms;
  final String buyOrRent;
  final double priceStart;
  final double priceEnd;

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

    print(widget.priceEnd);
    print(widget.bathrooms);
    print(widget.priceStart);
    print(widget.buyOrRent);
    print(widget.propertyType);
    print(widget.rooms);

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
                        return const Text('Something went wrong');
                      }
                      if (snapshot.connectionState == ConnectionState.waiting) {
                        return const Text('Loading');
                      }

                      final List storeDocs = [];
                      snapshot.data!.docs
                          .map((DocumentSnapshot document) {
                        Map a = document.data() as Map<String, dynamic>;
                        storeDocs.add(a);
                        a['id'] = document.id;
                        a['collection'] = document.reference;
                      }).toList();

                      return ListView.builder(
                        itemCount: storeDocs.length,
                        itemBuilder: (context, index) {

                          print(storeDocs[index]['id']);
                          print('data Id');

                          return Column(
                            children: [
                              NearbyHomes(
                                size: size,
                                asset: storeDocs[index]['images'],
                                name: storeDocs[index]['title'],
                                location: storeDocs[index]['address'],
                                bedCount: storeDocs[index]['bedRooms'],
                                bathCount: storeDocs[index]['bathRooms'],
                                bookmarkIcon: storeDocs[index]['bookmark'],
                                bookmarkFunction: () async {
                                  CollectionReference students =
                                      FirebaseFirestore.instance
                                          .collection(widget.uid.toString());

                                  students.doc(storeDocs[index]['id']).update({
                                    'bookmark': !storeDocs[index]['bookmark'],
                                  }).whenComplete(() {
                                    showSnackBar('Bookmarked',
                                        const Duration(milliseconds: 1000));
                                    setState(() {});
                                  });
                                },
                                share: () async {
                                  String generatedDeepLink =
                                      await DynamicLinkServices
                                          .createPropertyShareLink(
                                              short: false,
                                              collectionId:
                                                  widget.uid.toString(),
                                              docId: storeDocs[index]['id'],
                                              imageUrl: storeDocs[index]
                                                  ['images'][0],
                                              propertyTitle: storeDocs[index]
                                                  ['title']);
                                  Share.share(generatedDeepLink);
                                },
                                onTap: () {
                                  Navigator.push(
                                    context,
                                    MaterialPageRoute(
                                      builder: (context) => HouseDetails(
                                        enableEdit: true,
                                        docId: storeDocs[index]['id'],
                                        uid: widget.uid.toString(),
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
