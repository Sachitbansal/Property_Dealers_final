import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:share_plus/share_plus.dart';

import '../dynamic_links.dart';
import '../widgets.dart';
import 'house_details.dart';

class CustomerDetails extends StatefulWidget {
  const CustomerDetails({Key? key, required this.priceLower, required this.priceUpper, required this.sizeLower, required this.sizeUpper, required this.sizeUnit, required this.type}) : super(key: key);
  final String priceLower, priceUpper, sizeLower, sizeUpper, sizeUnit, type;

  @override
  State<CustomerDetails> createState() => _CustomerDetailsState();
}

class _CustomerDetailsState extends State<CustomerDetails> {
  final String colId = FirebaseAuth.instance.currentUser!.uid;
  bool isLoading = false;
  Set selectedList = Set();

  @override
  Widget build(BuildContext context) {
    final CollectionReference homeProperties =
        FirebaseFirestore.instance.collection(colId);

    final Stream<QuerySnapshot> data = homeProperties
        .where("types", isEqualTo: widget.type)
        .where("sizeUnit", isEqualTo: widget.sizeUnit)
        .where("Price", isGreaterThanOrEqualTo: int.parse(widget.priceLower))
        .where("Price", isLessThanOrEqualTo: int.parse(widget.priceUpper))
        .snapshots();

    showSnackBar(String snackText, Duration d) {
      final snackBar = SnackBar(content: Text(snackText), duration: d);
      ScaffoldMessenger.of(context).showSnackBar(snackBar);
    }

    Size size = MediaQuery.of(context).size;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Customer Details'),
      ),
      body: SingleChildScrollView(
        child: Column(
          children: [
            StreamBuilder<QuerySnapshot>(
              stream: data,
              builder: (BuildContext context,
                  AsyncSnapshot<QuerySnapshot> snapshot) {
                if (snapshot.hasError) {
                  print(snapshot.error);
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
                  Map a =
                  document.data() as Map<String, dynamic>;
                  storeDocs.add(a);
                  a['id'] = document.id;
                  a['collection'] = document.reference;
                }).toList();

                print('storeDocs');
                print(storeDocs);
                print(storeDocs.length);
                print('storeDocs.length');

                if (isLoading) {
                  return const Center(
                    child: Text('Loading'),
                  );
                } else {
                  return SizedBox(
                    height: 800,
                    child: ListView(
                      physics: const BouncingScrollPhysics(),
                      children: [
                        for (var i = 0;
                        i < storeDocs.length;
                        i++) ...[
                          if (storeDocs[i]['landSize'] >= int.parse(widget.sizeLower) &&
                              storeDocs[i]['landSize'] <= int.parse(widget.sizeUpper))
                            NearbyHomes(
                              isSelected: (bool value) {
                                if (value) {
                                  selectedList.add(storeDocs[i]);
                                } else {
                                  selectedList.remove(storeDocs[i]);
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
                                homeProperties
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
                                    collectionId: colId
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
                                  CustomPageRoute(child:  HouseDetails(
                                    enableEdit: true,
                                    uid: colId,
                                    docId: storeDocs[i]
                                    ['id'],
                                  ),)
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
    );
  }
}
