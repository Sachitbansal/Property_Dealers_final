import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:share_plus/share_plus.dart';

import '../dynamic_links.dart';
import '../widgets.dart';
import 'house_details.dart';

class SearchBarData extends StatefulWidget {
  const SearchBarData({Key? key, required this.uid}) : super(key: key);
  final String uid;

  @override
  State<SearchBarData> createState() => _SearchBarDataState();
}

class _SearchBarDataState extends State<SearchBarData> {
  final searchController = TextEditingController();

  @override
  void dispose() {
    searchController.dispose();
    super.dispose();
  }

  Set selectedList = Set();
  bool isLoading = false;

  @override
  Widget build(BuildContext context) {
    final CollectionReference noticeCollection =
        FirebaseFirestore.instance.collection(widget.uid.toString());

    final data = FirebaseFirestore.instance
        .collection(widget.uid.toString())
        .where("searchData", arrayContains: searchController.text)
        .snapshots();

    showSnackBar(String snackText, Duration d) {
      final snackBar = SnackBar(content: Text(snackText), duration: d);
      ScaffoldMessenger.of(context).showSnackBar(snackBar);
    }

    final Size size = MediaQuery.of(context).size;

    return Scaffold(
      appBar: AppBar(
        centerTitle: true,
        title: const Text('Search Data'),
        actions: [
          GestureDetector(
            onTap: () async {
              if (selectedList.length > 0) {
                setState(() => isLoading = true);
                print(selectedList);
                var linkList = '';

                for (int i = 0; i < selectedList.length; i++) {
                  String generatedDeepLink =
                      await DynamicLinkServices.createPropertyShareLink(
                          short: false,
                          collectionId: widget.uid.toString(),
                          docId: selectedList.elementAt(i)['id'],
                          imageUrl: selectedList.elementAt(i)['id'][0],
                          propertyTitle: selectedList.elementAt(i)['title']);

                  linkList = linkList + '\n $generatedDeepLink';
                }
                Share.share(linkList)
                    .whenComplete(() => setState(() => isLoading = false));

                selectedList = Set();
              } else {
                showSnackBar(
                    'Please Select Properties to Share', Duration(seconds: 2));
              }
            },
            child: Icon(Icons.share),
          ),
          SizedBox(
            width: 10,
          )
        ],
      ),
      body: Padding(
        padding: const EdgeInsets.all(10.0),
        child: isLoading
            ? Center(
                child: Column(
                  children: [
                    CircularProgressIndicator(),
                    Text('Generating Links')
                  ],
                ),
              )
            : SingleChildScrollView(
                child: Column(
                  children: [
                    const SizedBox(
                      height: 10,
                    ),
                    CustomTextField(
                      onChanged: (String query) {
                        setState(
                          () {
                            final data = noticeCollection
                                .where("searchData",
                                    arrayContains:
                                        searchController.text.toLowerCase())
                                .snapshots();
                          },
                        );
                      },
                titleController: searchController,
                labelText: 'Search',
              ),
              const SizedBox(
                height: 20,
              ),
              SizedBox(
                height: MediaQuery.of(context).size.height - 200,
                child: StreamBuilder<QuerySnapshot>(
                  stream: data,
                  builder: (BuildContext context,
                      AsyncSnapshot<QuerySnapshot> snapshot) {
                    if (snapshot.hasError) {
                      return const Text('Something went wrong');
                    }
                    if (snapshot.connectionState == ConnectionState.waiting) {
                      return Row(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: const [
                          Text(
                            'Searching',
                            style: TextStyle(
                                fontSize: 20, fontWeight: FontWeight.w500),
                          ),
                          SizedBox(
                            width: 20,
                          ),
                          SizedBox(
                            child: CircularProgressIndicator(),
                            height: 25,
                            width: 25,
                          )
                        ],
                      );
                    }

                    final List storeDocs = [];
                    snapshot.data!.docs.map((DocumentSnapshot document) {
                      Map a = document.data() as Map<String, dynamic>;
                      storeDocs.add(a);
                      a['id'] = document.id;
                      a['collection'] = document.reference;
                    }).toList();

                    return ListView(
                      physics: const BouncingScrollPhysics(),
                      children: [
                        for (var i = 0; i < storeDocs.length; i++) ...[
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
                            location: storeDocs[i]['address'],
                            bedCount: storeDocs[i]['bedRooms'],
                            bathCount: storeDocs[i]['bathRooms'],
                            bookmarkIcon: storeDocs[i]['bookmark'],
                            bookmarkFunction: () async {
                              CollectionReference students = FirebaseFirestore
                                  .instance
                                  .collection(widget.uid.toString());

                              students.doc(storeDocs[i]['id']).update({
                                'bookmark': !storeDocs[i]['bookmark'],
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
                                          collectionId: widget.uid.toString(),
                                          docId: storeDocs[i]['id'],
                                          imageUrl: storeDocs[i]['images'][0],
                                          propertyTitle: storeDocs[i]['title']);
                              Share.share(generatedDeepLink);
                            },
                            onTap: () {
                              Navigator.push(
                                context,
                                MaterialPageRoute(
                                  builder: (context) => HouseDetails(
                                    enableEdit: true,
                                    uid: widget.uid.toString(),
                                    docId: storeDocs[i]['id'],
                                  ),
                                ),
                              );
                            },
                          ),
                        ]
                      ],
                    );
                  },
                ),
              )
            ],
          ),
        ),
      ),
    );
  }
}
