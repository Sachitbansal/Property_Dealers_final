import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:untitled/pages/add.dart';
import 'filter.dart';
import 'house_details.dart';
import 'loginPage.dart';

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

  @override
  Widget build(BuildContext context) {

    final Stream<QuerySnapshot> studentsStream = FirebaseFirestore.instance
        .collection(widget.uid.toString())
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

    logout() async {
      await FirebaseAuth.instance.signOut();
      Navigator.push(
        context,
        MaterialPageRoute(
          builder: (context) => const LoginScreen(),
        ),
      );
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('You are now Signed Out'),
        ),
      );
    }

    ScreenUtil.init(
        BoxConstraints(
            maxWidth: MediaQuery.of(context).size.width,
            maxHeight: MediaQuery.of(context).size.height),
        designSize: const Size(360, 690),
        orientation: Orientation.portrait);

    return Scaffold(
      body: Column(
        children: [
          Padding(
            padding:
                EdgeInsets.symmetric(horizontal: ScreenUtil().setWidth(20.0)) +
                    EdgeInsets.only(
                      top: ScreenUtil().setHeight(50.0),
                      bottom: ScreenUtil().setHeight(40.0),
                    ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                RichText(
                  text: TextSpan(
                      text: 'Find your\n',
                      style: GoogleFonts.play(
                          color: Colors.grey,
                          fontSize: ScreenUtil().setSp(26.0)),
                      children: <TextSpan>[
                        TextSpan(
                          text: 'Perfect Home',
                          style: GoogleFonts.play(
                              color: Colors.blue[300],
                              fontSize: ScreenUtil().setSp(26.0),
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
                      icon: Icon(Icons.search, size: ScreenUtil().setHeight(24.0),),
                      color: Colors.black,
                      onPressed: () {
                        logout();
                      },
                    ),
                  ),
                ),
              ],
            ),
          ),
          Padding(
            padding: EdgeInsets.symmetric(
              horizontal: ScreenUtil().setWidth(20.0),
            ),
            child: Row(
              children: [
                Text(
                  "Nearby Homes",
                  style: GoogleFonts.play(
                    color: const Color(0xff4d3a58),
                    fontWeight: FontWeight.w600,
                    fontSize: ScreenUtil().setSp(18.0),
                  ),
                ),
                const Spacer(),
                TextButton(
                  child: Text(
                    "FILTER",
                    style: GoogleFonts.play(
                      color: const Color(0xfff63e3c),
                      fontWeight: FontWeight.w600,
                      fontSize: ScreenUtil().setSp(12.0),
                    ),
                  ),
                  onPressed: (){
                    showBottomSheet();
                  },
                )
              ],
            ),
          ),
          StreamBuilder<QuerySnapshot>(
              stream: studentsStream,
              builder: (BuildContext context,
                  AsyncSnapshot<QuerySnapshot> snapshot) {
                if (snapshot.hasError) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(
                      content: Text('Something Went Wrong.'),
                    ),
                  );
                }
                if (snapshot.connectionState == ConnectionState.waiting) {
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
                        ),
                      );
              }),
        ],
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
                builder: (context) => Add(collection: widget.uid.toString(),),
              ),
            );
          },
          tooltip: 'Increment',
          child: Icon(
            Icons.add,
            size: ScreenUtil().setHeight(26.0),
          ),
          elevation: 2.0,
        ),
      ),
      bottomNavigationBar: BottomAppBar(
        child: Padding(
          padding: EdgeInsets.symmetric(
            horizontal: ScreenUtil().setWidth(30.0),
            vertical: ScreenUtil().setHeight(20.0),
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: <Widget>[
              Icon(
                Icons.home,
                color: const Color(0xff442243),
                size: ScreenUtil().setHeight(26.0),
              ),
              Icon(
                Icons.explore_outlined,
                color: Colors.grey,
                size: ScreenUtil().setHeight(26.0),
              ),
              Icon(
                Icons.bookmark_border,
                color: Colors.grey,
                size: ScreenUtil().setHeight(26.0),
              ),
              Icon(
                Icons.person_outline,
                color: Colors.grey,
                size: ScreenUtil().setHeight(26.0),
              ),
            ],
          ),
        ),
        color: Colors.white,
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
