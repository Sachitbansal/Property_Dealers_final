import 'package:cached_network_image/cached_network_image.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import 'package:untitled/pages/update_prooperty.dart';
import 'package:url_launcher/url_launcher.dart';
import '../addHelper.dart';
import 'package:carousel_slider/carousel_slider.dart';

class HouseDetails extends StatefulWidget {
  const HouseDetails(
      {Key? key,
      required this.title,
      required this.price,
      required this.address,
      required this.bedRooms,
      required this.bathRooms,
      required this.landSize,
      required this.sizeUnit,
      required this.keywords,
      required this.name,
      required this.number,
      required this.uid,
      required this.docId,
      required this.facilities,
      required this.assets})
      : super(key: key);
  final String title,
      price,
      facilities,
      address,
      bedRooms,
      docId,
      number,
      name,
      keywords,
      uid,
      sizeUnit,
      landSize,
      bathRooms;
  final List assets;

  @override
  _HouseDetailsState createState() => _HouseDetailsState();
}

class _HouseDetailsState extends State<HouseDetails> {


  @override
  void initState() {
    super.initState();
    AddProvider adProvider = Provider.of<AddProvider>(context, listen: false);
    adProvider.initialiseDetailsPageBanner();
  }

  @override
  Widget build(BuildContext context) {

    final String facility = widget.facilities;
    final List splits = facility.split(',');

    void phoneCall() async {
      final url = 'tel:${widget.number}';
      if (await canLaunch(url)) {
        await launch(url);
      } else {
        throw 'Could not launch $url';
      }
    }

    CollectionReference collectionRef =
    FirebaseFirestore.instance.collection(widget.uid);

    Future<void> deleteUser(String id, List urls) async {
      collectionRef.doc(id).delete();

      for (var url = 0; url < urls.length; url++) {
        await FirebaseStorage.instance.refFromURL(urls[url]).delete();
      }

    }
    return Scaffold(
      body: Column(
        children: [
          Stack(
            children: [
              SizedBox(
                height: 350,
                child: CarouselSlider(
                  options: CarouselOptions(
                    initialPage: 0,
                    autoPlay: true,
                    disableCenter: true,
                  ),
                  items: widget.assets
                      .map(
                        (item) => CachedNetworkImage(
                      imageUrl: item.toString(),
                      errorWidget: (context, url, error) =>
                      const Text("error"),
                      imageBuilder: (context, imageProvider) => Container(
                        decoration: BoxDecoration(
                          image: DecorationImage(
                            fit: BoxFit.cover,
                            image: imageProvider,
                          ),
                        ),
                      ),
                      placeholder: (context, url) =>
                      const CircularProgressIndicator(
                        backgroundColor: Colors.red,
                      ),
                    ),
                  )
                      .toList(),
                ),
              ),
              Positioned(
                top: 50.0,
                left: 20.0,
                child: GestureDetector(
                  onTap: () {
                    HapticFeedback.lightImpact();
                    Navigator.pop(context);
                  },
                  child: Container(
                    decoration: BoxDecoration(
                      color: Colors.white70,
                      borderRadius: BorderRadius.circular(15.0),
                    ),
                    child: const Padding(
                      padding: EdgeInsets.all(8.0),
                      child: Icon(
                        Icons.arrow_back,
                        color: Colors.black,
                        size: 24,
                      ),
                    ),
                  ),
                ),
              ),
              Positioned(
                top: 50.0,
                right: 20.0,
                child: Row(
                  children: [
                    GestureDetector(
                      onTap: () {
                        deleteUser(widget.docId, widget.assets).whenComplete(() {
                          Navigator.pop(context);
                          ScaffoldMessenger.of(context)
                              .showSnackBar(const SnackBar(
                            content: Text("Deleted"),
                            duration:
                            Duration(milliseconds: 1000),
                          ));
                        });
                      },
                      child: Container(
                        decoration: BoxDecoration(
                          color: Colors.white70,
                          borderRadius: BorderRadius.circular(15.0),
                        ),
                        child: const Padding(
                          padding: EdgeInsets.all(8.0),
                          child: Icon(
                            Icons.delete,
                            color: Colors.black,
                            size: 24,
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(width: 20,),
                    GestureDetector(
                      onTap: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) => UpdateProperty(
                              collection: widget.uid.toString(),
                              id: widget.docId,
                            ),
                          ),
                        );
                      },
                      child: Container(
                        decoration: BoxDecoration(
                          color: Colors.white70,
                          borderRadius: BorderRadius.circular(15.0),
                        ),
                        child: const Padding(
                          padding: EdgeInsets.all(8.0),
                          child: Icon(
                            Icons.edit,
                            color: Colors.black,
                            size: 24,
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          Expanded(
            child: Padding(
              padding: const EdgeInsets.symmetric(
                horizontal: 20,
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Padding(
                    padding: const EdgeInsets.only(top: 30),
                    child: Row(
                      children: [
                        Text(
                          widget.title,
                          style: GoogleFonts.play(
                            color: Colors.black,
                            fontWeight: FontWeight.w600,
                            fontSize: 18,
                          ),
                        ),
                        const Spacer(),
                        Text(
                          '₹${widget.price}',
                          style: GoogleFonts.play(
                            color: const Color(0xfff63e3c),
                            fontWeight: FontWeight.w600,
                            fontSize: 16,
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(
                    height: 10,
                  ),
                  Text(
                    widget.address,
                    style: GoogleFonts.play(
                      color: Colors.grey,
                      fontSize: 14,
                    ),
                  ),
                  const SizedBox(
                    height: 10,
                  ),
                  Row(
                    children: [
                      Row(
                        children: [
                          const Icon(
                            Icons.king_bed,
                            color: Colors.grey,
                            size: 18,
                          ),
                          const SizedBox(
                            width: 5,
                          ),
                          Text(
                            widget.bedRooms,
                            style: GoogleFonts.play(
                              color: Colors.black,
                              fontWeight: FontWeight.w600,
                              fontSize: 14,
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(
                        width: 15,
                      ),
                      Row(
                        children: [
                          const Icon(
                            Icons.bathtub,
                            color: Colors.grey,
                            size: 16,
                          ),
                          const SizedBox(
                            width: 5,
                          ),
                          Text(
                            widget.bathRooms,
                            style: GoogleFonts.play(
                              color: Colors.black,
                              fontWeight: FontWeight.w600,
                              fontSize: 14,
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(
                        width: 15,
                      ),
                      Row(
                        children: [
                          const Icon(
                            Icons.crop_square,
                            color: Colors.grey,
                            size: 16,
                          ),
                          const SizedBox(
                            width: 5,
                          ),
                          Text(
                            "${widget.landSize} ${widget.sizeUnit}",
                            style: GoogleFonts.play(
                              color: Colors.black,
                              fontWeight: FontWeight.w600,
                              fontSize: 14,
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                  const SizedBox(
                    height: 10,
                  ),
                  Text(
                    widget.keywords,
                    style: GoogleFonts.play(
                      color: Colors.black87,
                      letterSpacing: 1.0,
                      wordSpacing: 2.0,
                      fontSize: 14,
                    ),
                  ),
                  const SizedBox(
                    height: 10,
                  ),
                  Text(
                    "Facilities",
                    style: GoogleFonts.play(
                      color: Colors.black,
                      fontWeight: FontWeight.w600,
                      fontSize: 16,
                    ),
                  ),
                  const SizedBox(
                    height: 5,
                  ),
                  SingleChildScrollView(
                    scrollDirection: Axis.horizontal,
                    child: Row(
                      children: [
                        for (var i = 0; i < splits.length; i++) ...[
                          _facilities(Icons.bubble_chart, "${splits[i]}"),
                          const SizedBox(width: 10,),
                        ]
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),
          Container(
            color: const Color(0xfff7f7f9),
            child: Padding(
              padding: const EdgeInsets.symmetric(
                horizontal: 20,
                vertical: 20,
              ),
              child: Row(
                children: [
                  ClipRRect(
                    borderRadius: BorderRadius.circular(10.0),
                    child: Image.network(
                      "https://img.freepik.com/free-photo/happy-african-american-child-boy-smiling_263368-10.jpg?size=664&ext=jpg&ga=GA1.2.740930980.1616477634",
                      height: 50,
                      width: 50,
                      fit: BoxFit.cover,
                    ),
                  ),
                  const SizedBox(
                    width: 10,
                  ),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          widget.name,
                          style: GoogleFonts.play(
                            color: Colors.black,
                            fontWeight: FontWeight.w600,
                            fontSize: 16,
                          ),
                        ),
                        const SizedBox(
                          height: 5,
                        ),
                        Text(
                          widget.number,
                          style: GoogleFonts.play(
                            color: Colors.grey,
                            fontSize: 14,
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(
                    width: 10,
                  ),
                  Container(
                    decoration: const BoxDecoration(
                        color: Colors.white, shape: BoxShape.circle),
                    child: Padding(
                      padding: const EdgeInsets.all(8.0),
                      child: IconButton(
                        icon: const Icon(
                          Icons.phone,
                          size: 22,
                        ),
                        color: Colors.green,
                        onPressed: phoneCall,
                      ),
                    ),
                  ),
                  const SizedBox(
                    width: 20,
                  ),
                  Container(
                    decoration: const BoxDecoration(
                        color: Colors.white, shape: BoxShape.circle),
                    child: Padding(
                      padding: const EdgeInsets.all(8.0),
                      child: IconButton(
                        icon: const Icon(
                          Icons.message,
                          size: 22,
                        ),
                        color: const Color(0xfff63e3c),
                        onPressed: () async {
                          await launch(
                              'https://api.whatsapp.com/send/?phone=91${widget.number}&text&app_absent=0');
                        },
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  _facilities(IconData icon, String facility) {
    return Container(
      decoration: BoxDecoration(
          color: Colors.grey[100], borderRadius: BorderRadius.circular(5.0)),
      child: Padding(
        padding: const EdgeInsets.symmetric(
          vertical: 5,
          horizontal: 10,
        ),
        child: Row(
          children: [
            const Icon(
              Icons.bubble_chart,
              color: Colors.black,
              size: 16,
            ),
            const SizedBox(
              width: 10,
            ),
            Text(
              facility,
              style: GoogleFonts.play(
                color: Colors.black,
                fontWeight: FontWeight.w600,
                fontSize: 12,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
