import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_carousel_slider/carousel_slider.dart';
import 'package:flutter_carousel_slider/carousel_slider_indicators.dart';
import 'package:flutter_carousel_slider/carousel_slider_transforms.dart';
import 'package:google_mobile_ads/google_mobile_ads.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import 'package:share_plus/share_plus.dart';
import 'package:untitled/pages/update_property.dart';
import 'package:url_launcher/url_launcher.dart';
import '../addHelper.dart';
import '../dynamic_links.dart';

class HouseDetails extends StatefulWidget {
  HouseDetails({
    Key? key,
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
    required this.assets,
    required this.isPublic,
    required this.enableChange,
    required this.isBookmarked,
    this.enableEdit, required this.buyRent, required this.constructionStatus, required this.type,
  }) : super(key: key);
  final String title,
      price,
      facilities,
      address,
      bedRooms,
      docId,
      number,
      constructionStatus,
      type,
      name,
      keywords,
      uid,
      sizeUnit,
      landSize,
      buyRent,
      bathRooms;
  final List assets;
  bool? enableEdit = true;
  bool enableChange, isPublic, isBookmarked;

  @override
  _HouseDetailsState createState() => _HouseDetailsState();
}

class _HouseDetailsState extends State<HouseDetails> {
  late CarouselSliderController _sliderController;

  @override
  void initState() {
    super.initState();
    AddProvider adProvider = Provider.of<AddProvider>(context, listen: false);
    adProvider.initialiseDetailsPageBanner();
    _sliderController = CarouselSliderController();
  }

  bool isPublic = false;

  showSnackBar(String snackText, Duration d) {
    final snackBar = SnackBar(content: Text(snackText), duration: d);
    ScaffoldMessenger.of(context).showSnackBar(snackBar);
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

      if (widget.isPublic) {
        FirebaseFirestore.instance
            .collection("Public")
            .doc(id + widget.uid)
            .delete();
      }

      for (var url = 0; url < urls.length; url++) {
        await FirebaseStorage.instance.refFromURL(urls[url]).delete();
      }
    }

    Future<void> myDialog(
        {required String confirmDialog,
        void Function()? onPressed,
        required String proceedButton}) async {
      return showDialog<void>(
        context: context,
        barrierDismissible: false, // user must tap button!
        builder: (BuildContext context) {
          return AlertDialog(
            title: Text(confirmDialog),
            actions: <Widget>[
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceAround,
                children: [
                  TextButton(
                    child: const Text('Cancel'),
                    onPressed: () {
                      Navigator.of(context).pop();
                    },
                  ),
                  TextButton(
                      child: Text(
                        proceedButton,
                        style: const TextStyle(color: Colors.red),
                      ),
                      onPressed: onPressed),
                ],
              ),
            ],
          );
        },
      );
    }

    final Size size = MediaQuery.of(context).size;

    return Scaffold(
      body: Column(
        children: [
          Expanded(
            child: SingleChildScrollView(
              child: Column(
                children: [Stack(
                  children: [
                    SizedBox(
                      height: size.height * .5 - 82.5,
                      child: CarouselSlider.builder(
                        unlimitedMode: true,
                        controller: _sliderController,
                        slideBuilder: (index) {
                          return Image.network(
                            widget.assets[index],
                            fit: BoxFit.cover,
                          );
                        },
                        slideTransform: const ParallaxTransform(),
                        slideIndicator: CircularSlideIndicator(
                            padding: const EdgeInsets.only(bottom: 32),
                            indicatorBorderColor: Colors.white,
                            currentIndicatorColor: Colors.white,
                            indicatorBackgroundColor: Colors.transparent),
                        itemCount: widget.assets.length,
                        initialPage: 0,
                        enableAutoSlider: true,
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
                    if (widget.enableEdit == true)
                      Positioned(
                        top: 50.0,
                        right: 20.0,
                        child: Row(
                          children: [
                            GestureDetector(
                              onTap: () => myDialog(
                                  confirmDialog:
                                  'Are you sure want to delete the property?',
                                  onPressed: () {
                                    deleteUser(widget.docId, widget.assets)
                                        .whenComplete(() {
                                      Navigator.pop(context);
                                      ScaffoldMessenger.of(context)
                                          .showSnackBar(const SnackBar(
                                        content: Text("Deleted"),
                                        duration: Duration(milliseconds: 1000),
                                      ));
                                    });
                                  },
                                  proceedButton: 'DELETE'),
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
                            const SizedBox(
                              width: 20,
                            ),
                            GestureDetector(
                              onTap: () {
                                Navigator.push(
                                  context,
                                  MaterialPageRoute(
                                    builder: (context) => UpdateProperty(
                                      collection: widget.uid.toString(),
                                      id: widget.docId,
                                      imageUrls: widget.assets,
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
                  Padding(
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
                              Expanded(
                                child: Text(
                                  widget.title,
                                  maxLines: 2,
                                  overflow: TextOverflow.ellipsis,
                                  style: GoogleFonts.play(
                                    color: Colors.black,
                                    fontWeight: FontWeight.w600,
                                    fontSize: 18,
                                  ),
                                ),
                              ),
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
                          maxLines: 2,
                          overflow: TextOverflow.ellipsis,
                          style: GoogleFonts.play(
                            color: Colors.grey,
                            fontSize: 14,
                          ),
                        ),
                        const SizedBox(
                          height: 10,
                        ),
                        SingleChildScrollView(
                          scrollDirection: Axis.horizontal,
                          child: Row(
                            children: [
                              _facilities(Icons.king_bed, widget.bedRooms),
                              _facilities(Icons.bathtub, widget.bathRooms),
                              _facilities(Icons.crop_square, "${widget.landSize} ${widget.sizeUnit}"),
                              _facilities(Icons.monetization_on_outlined, widget.buyRent),
                              _facilities(Icons.construction, widget.constructionStatus),
                              _facilities(Icons.house_outlined, widget.type),
                            ],
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
                                _facilities(Icons.circle_outlined, "${splits[i]}"),
                                const SizedBox(
                                  width: 10,
                                ),
                              ]
                            ],
                          ),
                        ),
                        const SizedBox(
                          height: 10,
                        ),
                        Text(
                          widget.keywords,
                          maxLines: 2,
                          overflow: TextOverflow.ellipsis,
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
                          "Other Information",
                          style: GoogleFonts.play(
                            color: Colors.black,
                            fontWeight: FontWeight.w600,
                            fontSize: 16,
                          ),
                        ),
                        Text(
                          widget.keywords,
                          maxLines: 2,
                          overflow: TextOverflow.ellipsis,
                          style: GoogleFonts.play(
                            color: Colors.black87,
                            letterSpacing: 1.0,
                            wordSpacing: 2.0,
                            fontSize: 14,
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 15,),
                  SizedBox(
                    height: 60,
                    child: SingleChildScrollView(
                      physics: const ScrollPhysics(),
                      scrollDirection: Axis.horizontal,
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.end,
                        children: [
                          const SizedBox(
                            width: 20,
                          ),
                          GestureDetector(
                            onTap: () async {
                              String generatedDeepLink =
                              await DynamicLinkServices.createPropertyShareLink(
                                  short: false,
                                  collectionId: widget.uid,
                                  docId: widget.docId,
                                  imageUrl: widget.assets[0],
                                  propertyTitle: widget.title);
                              Share.share(generatedDeepLink);
                            },
                            child: Container(
                              decoration: BoxDecoration(
                                color: Colors.blue[50],
                                borderRadius: BorderRadius.circular(15.0),
                              ),
                              child: Padding(
                                padding: const EdgeInsets.all(8.0),
                                child: Icon(
                                  Icons.share,
                                  color: Colors.blue[800],
                                  size: 35,
                                ),
                              ),
                            ),
                          ),
                          const SizedBox(
                            width: 20,
                          ),
                          if (widget.enableChange == true)
                            GestureDetector(
                              onTap: () {
                                if (!widget.isPublic) {
                                  myDialog(
                                    confirmDialog:
                                    'Are you sure want to make the Property Public?',
                                    onPressed: () async {
                                      isPublic = true;
                                      DocumentReference copyTo = FirebaseFirestore
                                          .instance
                                          .collection('Public')
                                          .doc(
                                        widget.docId + widget.uid.toString(),
                                      );
                                      DocumentReference copyFrom = FirebaseFirestore
                                          .instance
                                          .collection(widget.uid.toString())
                                          .doc(widget.docId);

                                      copyFrom.get().then(
                                            (value) => {
                                          copyTo.set(value.data()),
                                        },
                                      );

                                      await collectionRef
                                          .doc(widget.docId)
                                          .update({'isPublic': true}).whenComplete(
                                            () {
                                          Navigator.pop(context);
                                          Navigator.pop(context);
                                        },
                                      );
                                    },
                                    proceedButton: 'Make Public',
                                  );
                                } else {
                                  myDialog(
                                    confirmDialog:
                                    'Are you sure want to make the Property Private?',
                                    proceedButton: 'Make Private',
                                    onPressed: () async {
                                      isPublic = false;
                                      await FirebaseFirestore.instance
                                          .collection('Public')
                                          .doc(
                                        widget.docId + widget.uid.toString(),
                                      )
                                          .delete();

                                      await collectionRef
                                          .doc(widget.docId)
                                          .update({'isPublic': false}).whenComplete(
                                            () {
                                          Navigator.pop(context);
                                          Navigator.pop(context);
                                        },
                                      );
                                    },
                                  );
                                }
                              },
                              child: Container(
                                decoration: BoxDecoration(
                                  color:
                                  widget.isPublic ? Colors.blue[50] : Colors.black26,
                                  borderRadius: BorderRadius.circular(15.0),
                                ),
                                child: Padding(
                                  padding: const EdgeInsets.all(8.0),
                                  child: Icon(
                                    Icons.public,
                                    color:
                                    widget.isPublic ? Colors.blue[800] : Colors.white,
                                    size: 35,
                                  ),
                                ),
                              ),
                            ),
                          if (widget.enableChange == true)
                            const SizedBox(
                              width: 20,
                            ),
                          widget.enableChange == true ? GestureDetector(
                            onTap: () {
                              collectionRef
                                  .doc(widget.docId)
                                  .update({
                                'bookmark': !widget.isBookmarked,
                              }).whenComplete(() {
                                if (!widget.isBookmarked) {
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
                                Navigator.pop(context);
                              });
                            },
                            child: Container(
                              decoration: BoxDecoration(
                                color: widget.isBookmarked ? Colors.blue[50] : Colors.black26,
                                borderRadius: BorderRadius.circular(15.0),
                              ),
                              child: Padding(
                                padding: const EdgeInsets.all(8.0),
                                child: Icon(
                                  widget.isBookmarked
                                      ? Icons.bookmark
                                      : Icons.bookmark_border,
                                  color:
                                  widget.isBookmarked ? Colors.blue[800] : Colors.white,
                                  size: 35,
                                ),
                              ),
                            ),
                          ) : Container(),
                          const SizedBox(
                            width: 20,
                          )
                        ],
                      ),
                    ),
                  ),
                  const SizedBox(height: 15,),],
              ),
            ),
          ),
          Container(
            height: 90,
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
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
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
                          maxLines: 1,
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
          SizedBox(
            child:
            Consumer<AddProvider>(builder: (context, adProvider, child) {
              if (adProvider.isDetailsPageBannerLoaded) {
                return SizedBox(
                  height: adProvider.detailsPageBanner.size.height.toDouble(),
                  child: AdWidget(
                    ad: adProvider.detailsPageBanner,
                  ),
                );
              } else {
                return Container();
              }
            }),
          )
        ],
      ),
    );
  }

  _facilities(IconData icon, String facility) {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 7.5),
      decoration: BoxDecoration(
          color: Colors.grey[100], borderRadius: BorderRadius.circular(5.0)),
      child: Padding(
        padding: const EdgeInsets.symmetric(
          vertical: 5,
          horizontal: 10,
        ),
        child: Row(
          children: [
             Icon(
              icon,
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
