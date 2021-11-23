import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:google_fonts/google_fonts.dart';
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
        .where("bedRooms", isGreaterThanOrEqualTo : widget.rooms)
        // .where("buyRent", arrayContainsAny: widget.buyOrRent)
        // .where("bathRooms", isEqualTo: widget.bathrooms)
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
              StreamBuilder<QuerySnapshot>(
                  stream: data,
                  builder: (BuildContext context,
                      AsyncSnapshot<QuerySnapshot> snapshot) {

                    final List storedocs = [];
                    snapshot.data!.docs.map((DocumentSnapshot document) {
                      Map a = document.data() as Map<String, dynamic>;
                      storedocs.add(a);
                      a['id'] = document.id;
                    }).toList();

                    return Column(
                      children: [
                        for (var i = 0; i < storedocs.length; i++) ...[
                          _nearbyHomes(
                            "https://image.freepik.com/free-photo/house-isolated-field_1303-23773.jpg",
                            storedocs[i]['title'],
                            storedocs[i]['address'],
                            storedocs[i]['bedRooms'],
                            storedocs[i]['bathRooms'],
                          ),
                        ]
                      ],
                    );
                  })
            ],
          ),
        ),
      ),
    );
  }

  _nearbyHomes(String asset, String name, String location, String bedCount,
      String bathCount) {
    return Padding(
      padding: EdgeInsets.symmetric(horizontal: ScreenUtil().setWidth(20.0)) +
          EdgeInsets.only(bottom: ScreenUtil().setHeight(20.0)),
      child: GestureDetector(
        onTap: () {
          HapticFeedback.lightImpact();
          Navigator.push(
            context,
            MaterialPageRoute(builder: (context) => const HouseDetails()),
          );
        },
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            ClipRRect(
                borderRadius: BorderRadius.circular(20.0),
                child: Image.network(
                  asset,
                  fit: BoxFit.cover,
                  height: ScreenUtil().setHeight(100.0),
                  width: ScreenUtil().setWidth(100.0),
                )),
            SizedBox(
              width: ScreenUtil().setWidth(10.0),
            ),
            Expanded(
                child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  name,
                  style: GoogleFonts.play(
                    color: Colors.black,
                    fontWeight: FontWeight.w600,
                    fontSize: ScreenUtil().setSp(16.0),
                  ),
                ),
                SizedBox(
                  height: ScreenUtil().setHeight(5.0),
                ),
                Text(
                  location,
                  style: GoogleFonts.play(
                    color: Colors.grey,
                    fontSize: ScreenUtil().setSp(14.0),
                  ),
                ),
                SizedBox(
                  height: ScreenUtil().setHeight(5.0),
                ),
                Row(
                  children: [
                    Row(
                      children: [
                        Icon(
                          Icons.king_bed,
                          color: Colors.grey,
                          size: ScreenUtil().setHeight(18.0),
                        ),
                        SizedBox(
                          width: ScreenUtil().setWidth(5.0),
                        ),
                        Text(
                          bedCount,
                          style: GoogleFonts.play(
                            color: Colors.black,
                            fontSize: ScreenUtil().setSp(14.0),
                          ),
                        ),
                      ],
                    ),
                    SizedBox(
                      width: ScreenUtil().setWidth(10.0),
                    ),
                    Row(
                      children: [
                        Icon(
                          Icons.bathtub,
                          color: Colors.grey,
                          size: ScreenUtil().setHeight(16.0),
                        ),
                        SizedBox(
                          width: ScreenUtil().setWidth(5.0),
                        ),
                        Text(
                          bathCount,
                          style: GoogleFonts.play(
                            color: Colors.black,
                            fontSize: ScreenUtil().setSp(14.0),
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ],
            )),
          ],
        ),
      ),
    );
  }
}
