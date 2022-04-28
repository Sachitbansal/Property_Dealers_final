import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

import '../widgets.dart';
import 'filter.dart';
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

  @override
  Widget build(BuildContext context) {
    final CollectionReference noticeCollection =
        FirebaseFirestore.instance.collection(widget.uid.toString());

    final data = noticeCollection
        .where("searchData", arrayContains: searchController.text)
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
            return Wrap(
              children: [
                Filter(uid: widget.uid.toString()),
              ],
            );
          });
    }

    return Scaffold(
      appBar: AppBar(
        title: const Text('Search Data'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(10.0),
        child: SingleChildScrollView(
          child: Column(
            children: [
              const SizedBox(height: 10,),
              CustomTextField(
                icon: IconButton(
                  icon: const Icon(Icons.search),
                  onPressed: () {
                    setState(() {
                      final data = noticeCollection
                          .where("searchData",
                          arrayContains: searchController.text)
                          .snapshots();
                    });
                  },
                ),
                onChanged: (String query) {
                  setState(() {
                    final data = noticeCollection
                        .where("searchData",
                            arrayContains: searchController.text)
                        .snapshots();
                  });
                },
                titleController: searchController, labelText: 'Search',
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

                    final data = snapshot.requireData;

                    return ListView.builder(
                      itemCount: data.size,
                      itemBuilder: (context, index) {
                        return Column(
                          children: [
                            NearbyHomes(
                              asset: data.docs[index]['images'],
                              name: data.docs[index]['title'],
                              location: data.docs[index]['address'],
                              bedCount: data.docs[index]['bedRooms'][0],
                              bathCount: data.docs[index]['bathRooms'][0],
                              onTap: () {
                                Navigator.push(
                                  context,
                                  MaterialPageRoute(
                                    builder: (context) => HouseDetails(
                                      docId: data.docs[index]['id'],
                                      uid: widget.uid.toString(),
                                      title: data.docs[index]['title'],
                                      facilities: data.docs[index]['keywords'],
                                      assets: data.docs[index]['images'],
                                      address: data.docs[index]['address'],
                                      bedRooms: data.docs[index]['bedRooms'],
                                      bathRooms: data.docs[index]['bathRooms'],
                                      price: data.docs[index]['Price'],
                                      landSize: data.docs[index]['landSize'],
                                      keywords: data.docs[index]['keywords'],
                                      name: data.docs[index]['name'],
                                      number: data.docs[index]['number'],
                                      sizeUnit: data.docs[index]['sizeUnit'],
                                    ),
                                  ),
                                );
                              },
                            ),
                          ],
                        );
                      },
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
