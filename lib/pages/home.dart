import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:google_mobile_ads/google_mobile_ads.dart';
import 'package:provider/provider.dart';
import 'package:untitled/addHelper.dart';
import 'package:untitled/pages/add.dart';
import 'package:untitled/pages/searchbar.dart';
import '../widgets.dart';
import 'filter.dart';
import 'house_details.dart';

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
  void initState() {
    super.initState();
    Provider.of<AddProvider>(context, listen: false).initialiseHomePageBanner();
  }

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


    return Scaffold(
      body: SafeArea(
        child: Column(
          children: [
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  RichText(
                    text: TextSpan(
                        text: 'Find your\n',
                        style:
                            GoogleFonts.play(color: Colors.grey, fontSize: 26),
                        children: <TextSpan>[
                          TextSpan(
                            text: 'Perfect Home',
                            style: GoogleFonts.play(
                                color: Colors.blue[300],
                                fontSize: 26,
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
                        icon: const Icon(
                          Icons.search,
                          size: 24.0,
                        ),
                        color: Colors.black,
                        onPressed: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (context) => const SearchBarData(),
                            ),
                          );
                        },
                      ),
                    ),
                  ),
                ],
              ),
            ),
            Padding(
              padding: const EdgeInsets.symmetric(
                horizontal: 20,
              ),
              child: Row(
                children: [
                  Text(
                    "Nearby Homes",
                    style: GoogleFonts.play(
                      color: const Color(0xff4d3a58),
                      fontWeight: FontWeight.w600,
                      fontSize: 18,
                    ),
                  ),
                  const Spacer(),
                  TextButton(
                    child: Text(
                      "FILTER",
                      style: GoogleFonts.play(
                        color: const Color(0xfff63e3c),
                        fontWeight: FontWeight.w600,
                        fontSize: 12,
                      ),
                    ),
                    onPressed: () {
                      print(widget.uid);
                      print('widget.uid');
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
                                NearbyHomes(
                                  asset: storedocs[i]['images'],
                                  name: storedocs[i]['title'],
                                  location: storedocs[i]['address'],
                                  bedCount: storedocs[i]['bedRooms'][0],
                                  bathCount: storedocs[i]['bathRooms'][0],
                                  onTap: () {
                                    Navigator.push(
                                      context,
                                      MaterialPageRoute(
                                        builder: (context) => HouseDetails(
                                          uid: widget.uid.toString(),
                                          docId: storedocs[i]['id'],
                                          assets: storedocs[i]['images'],
                                          facilities: storedocs[i]['keywords'],
                                          title: storedocs[i]['title'],
                                          address: storedocs[i]['address'],
                                          bedRooms: storedocs[i]['bedRooms'][0],
                                          bathRooms: storedocs[i]['bathRooms']
                                              [0],
                                          price: storedocs[i]['Price'],
                                          landSize: storedocs[i]['landSize'],
                                          keywords: storedocs[i]['keywords'],
                                          name: storedocs[i]['name'],
                                          number: storedocs[i]['number'],
                                          sizeUnit: storedocs[i]['sizeUnit'],
                                        ),
                                      ),
                                    );
                                  },
                                ),
                              ]
                            ],
                          ),
                        );
                }),
          ],
        ),
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
                builder: (context) => Add(
                  collection: widget.uid.toString(),
                ),
              ),
            );
          },
          tooltip: 'Increment',
          child: const Icon(
            Icons.add,
            size: 26,
          ),
          elevation: 2.0,
        ),
      ),


      //todo: un comment after account approoved
      // bottomNavigationBar: Consumer<AddProvider>(
      //   builder: (context, adProvider, child) {
      //
      //     if (adProvider.isAddLoaded) {
      //       return SizedBox(
      //         height: adProvider.homePageBanner.size.height.toDouble(),
      //         child: AdWidget(
      //           ad: adProvider.homePageBanner,
      //         ),
      //       );
      //     }
      //     else {
      //       return Container();
      //     }
      //
      //   }
      // ),

      //todo: normal bottom sheet
      bottomNavigationBar: BottomAppBar(
        child: Padding(
          padding: const EdgeInsets.symmetric(
            horizontal: 30,
            vertical: 20,
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: const <Widget>[
              Icon(
                Icons.home,
                color: Color(0xff442243),
                size: 26,
              ),
              Icon(
                Icons.explore_outlined,
                color: Colors.grey,
                size: 26,
              ),
              Icon(
                Icons.bookmark_border,
                color: Colors.grey,
                size: 26,
              ),
              Icon(
                Icons.person_outline,
                color: Colors.grey,
                size: 26,
              ),
            ],
          ),
        ),
        color: Colors.white,
      ),
    );
  }
}
