import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:google_fonts/google_fonts.dart';

class Demo extends StatefulWidget {
  Demo({
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
  _DemoState createState() => _DemoState();
}

class _DemoState extends State<Demo> {
  @override
  Widget build(BuildContext context) {
    final CollectionReference noticeCollection =
        FirebaseFirestore.instance.collection(widget.uid.toString());

    final data = noticeCollection
        .where("types", isEqualTo: widget.propertyType)
        .where("buyRent", arrayContainsAny: [widget.buyOrRent])
        .where("bedRooms", isGreaterThanOrEqualTo: widget.rooms)
        .where("bathRooms", isLessThanOrEqualTo: widget.bathrooms)
        .snapshots();

    return Scaffold(
      body: SafeArea(
        child: SingleChildScrollView(
          child: SizedBox(
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
                    return Container(
                      margin: const EdgeInsets.all(20),
                      padding: const EdgeInsets.all(10),
                      color: Colors.blue[50],
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const SizedBox(
                            height: 10,
                          ),
                          ListTile(
                            title: Text('${data.docs[index]['title']}'),
                            subtitle: Row(
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
                                      '${data.docs[index]['bedRooms']}',
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
                                      '${data.docs[index]['bathRooms']}',
                                      style: GoogleFonts.play(
                                        color: Colors.black,
                                        fontSize: ScreenUtil().setSp(14.0),
                                      ),
                                    ),
                                  ],
                                ),
                              ],
                            ),
                          )
                        ],
                      ),
                    );
                  },
                );
              },
            ),
          ),
        ),
      ),
    );
  }
}
