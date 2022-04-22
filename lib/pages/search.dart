import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import '../widgets.dart';
import 'house_details.dart';

class Search extends StatefulWidget {
  Search({
    Key? key,
    required this.uid,
    required this.propertyType,
    required this.rooms,
    required this.buyOrRent,
    required this.bathrooms,
  }) : super(key: key);
  final String? uid;
  String propertyType = 'Flat';
  String rooms = 'Any';
  String bathrooms = 'Any';
  String buyOrRent = 'Buy';

  @override
  _SearchState createState() => _SearchState();
}

class _SearchState extends State<Search> {
  late Object? userMap;

  @override
  Widget build(BuildContext context) {
    final CollectionReference noticeCollection =
        FirebaseFirestore.instance.collection(widget.uid.toString());

    final data = noticeCollection
        .where("types", isEqualTo: widget.propertyType)
        .where("buyRent", arrayContainsAny: [widget.buyOrRent])
        .where("bedRooms", isGreaterThanOrEqualTo: widget.rooms)
        .where("bathRooms", isEqualTo: widget.bathrooms)
        .snapshots();

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
              TextFormField(),
              SizedBox(
                height: 200,
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
                        reverse: true,
                        itemCount: data.size,
                        itemBuilder: (context, index) {
                          return Column(
                            children: [
                              NearbyHomes(
                                asset: data.docs[index]['images'],
                                name: data.docs[index]['title'],
                                location: data.docs[index]['address'],
                                bedCount: data.docs[index]['bedRooms'],
                                bathCount: data.docs[index]['bathRooms'],
                                onTap: () {
                                  Navigator.push(
                                    context,
                                    MaterialPageRoute(
                                      builder: (context) => HouseDetails(
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
                    }),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
