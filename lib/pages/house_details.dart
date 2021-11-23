import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:flutter_carousel_slider/carousel_slider.dart';
import 'package:flutter_carousel_slider/carousel_slider_indicators.dart';
import 'package:flutter_carousel_slider/carousel_slider_transforms.dart';
import 'package:url_launcher/url_launcher.dart';

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
      required this.number})
      : super(key: key);
  final String title;
  final String price;
  final String address;
  final String bedRooms;
  final String bathRooms;
  final String landSize;
  final String sizeUnit;
  final String keywords;
  final String name;
  final String number;

  @override
  _HouseDetailsState createState() => _HouseDetailsState();
}

class _HouseDetailsState extends State<HouseDetails> {
  final List<String> imgList = [
    "https://image.freepik.com/free-photo/house-isolated-field_1303-23773.jpg",
    "https://image.freepik.com/free-photo/interior-home-design-living-room-with-open-kitchen-loft-house_41487-613.jpg",
    "https://image.freepik.com/free-photo/3d-rendering-luxury-modern-design-wood-building-near-park-nature-night-scene_105762-1045.jpg",
    "https://image.freepik.com/free-photo/charming-yellow-house-with-wooden-windows-green-grassy-garden_181624-8074.jpg"
  ];

  late CarouselSliderController _sliderController;

  @override
  void initState() {
    super.initState();
    _sliderController = CarouselSliderController();
  }

  @override
  Widget build(BuildContext context) {

    void phoneCall() async {
      final url = 'tel:${widget.number}';
      if (await canLaunch(url)) {
        await launch(url);
      } else {
        throw 'Could not launch $url';
      }
    }

    return Scaffold(
      body: Column(
        children: [
          slider(),
          Expanded(
            child: Padding(
              padding: EdgeInsets.symmetric(
                horizontal: ScreenUtil().setWidth(20.0),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Padding(
                    padding: EdgeInsets.only(top: ScreenUtil().setHeight(30.0)),
                    child: Row(
                      children: [
                        Text(
                          widget.title,
                          style: GoogleFonts.play(
                            color: Colors.black,
                            fontWeight: FontWeight.w600,
                            fontSize: ScreenUtil().setSp(18.0),
                          ),
                        ),
                        const Spacer(),
                        Text(
                          '₹${widget.price}',
                          style: GoogleFonts.play(
                            color: const Color(0xfff63e3c),
                            fontWeight: FontWeight.w600,
                            fontSize: ScreenUtil().setSp(16.0),
                          ),
                        ),
                      ],
                    ),
                  ),
                  SizedBox(
                    height: ScreenUtil().setHeight(10.0),
                  ),
                  Text(
                    widget.address,
                    style: GoogleFonts.play(
                      color: Colors.grey,
                      fontSize: ScreenUtil().setSp(14.0),
                    ),
                  ),
                  SizedBox(
                    height: ScreenUtil().setHeight(10.0),
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
                            widget.bedRooms,
                            style: GoogleFonts.play(
                              color: Colors.black,
                              fontWeight: FontWeight.w600,
                              fontSize: ScreenUtil().setSp(14.0),
                            ),
                          ),
                        ],
                      ),
                      SizedBox(
                        width: ScreenUtil().setWidth(15.0),
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
                            widget.bathRooms,
                            style: GoogleFonts.play(
                              color: Colors.black,
                              fontWeight: FontWeight.w600,
                              fontSize: ScreenUtil().setSp(14.0),
                            ),
                          ),
                        ],
                      ),
                      SizedBox(
                        width: ScreenUtil().setWidth(15.0),
                      ),
                      Row(
                        children: [
                          Icon(
                            Icons.crop_square,
                            color: Colors.grey,
                            size: ScreenUtil().setHeight(16.0),
                          ),
                          SizedBox(
                            width: ScreenUtil().setWidth(5.0),
                          ),
                          Text(
                            "${widget.landSize} ${widget.sizeUnit}",
                            style: GoogleFonts.play(
                              color: Colors.black,
                              fontWeight: FontWeight.w600,
                              fontSize: ScreenUtil().setSp(14.0),
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                  SizedBox(
                    height: ScreenUtil().setHeight(10.0),
                  ),
                  Text(
                    widget.keywords,
                    style: GoogleFonts.play(
                      color: Colors.black87,
                      letterSpacing: 1.0,
                      wordSpacing: 2.0,
                      fontSize: ScreenUtil().setSp(14.0),
                    ),
                  ),
                  SizedBox(
                    height: ScreenUtil().setHeight(10.0),
                  ),
                  Text(
                    "Facilities",
                    style: GoogleFonts.play(
                      color: Colors.black,
                      fontWeight: FontWeight.w600,
                      fontSize: ScreenUtil().setSp(16.0),
                    ),
                  ),
                  SizedBox(
                    height: ScreenUtil().setHeight(5.0),
                  ),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      _facilities(Icons.campaign, "CCTV"),
                      _facilities(Icons.wifi, "WIFI"),
                      _facilities(Icons.pool, "SWIMMING POOL"),
                    ],
                  ),
                ],
              ),
            ),
          ),
          Container(
            color: const Color(0xfff7f7f9),
            child: Padding(
              padding: EdgeInsets.symmetric(
                horizontal: ScreenUtil().setWidth(20.0),
                vertical: ScreenUtil().setHeight(20.0),
              ),
              child: Row(
                children: [
                  ClipRRect(
                    borderRadius: BorderRadius.circular(10.0),
                    child: Image.network(
                      "https://img.freepik.com/free-photo/happy-african-american-child-boy-smiling_263368-10.jpg?size=664&ext=jpg&ga=GA1.2.740930980.1616477634",
                      height: ScreenUtil().setHeight(50.0),
                      width: ScreenUtil().setWidth(50.0),
                      fit: BoxFit.cover,
                    ),
                  ),
                  SizedBox(
                    width: ScreenUtil().setWidth(10.0),
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
                            fontSize: ScreenUtil().setSp(16.0),
                          ),
                        ),
                        SizedBox(
                          height: ScreenUtil().setHeight(5.0),
                        ),
                        Text(
                          widget.number,
                          style: GoogleFonts.play(
                            color: Colors.grey,
                            fontSize: ScreenUtil().setSp(14.0),
                          ),
                        ),
                      ],
                    ),
                  ),
                  SizedBox(
                    width: ScreenUtil().setWidth(10.0),
                  ),
                  Container(
                    decoration: const BoxDecoration(
                        color: Colors.white, shape: BoxShape.circle),
                    child: Padding(
                      padding: const EdgeInsets.all(8.0),
                      child: IconButton(
                        icon: Icon(Icons.phone, size: ScreenUtil().setHeight(22.0),),
                        color: Colors.green,
                        onPressed: phoneCall,
                      ),
                    ),
                  ),
                  SizedBox(
                    width: ScreenUtil().setWidth(20.0),
                  ),
                  Container(
                    decoration: const BoxDecoration(
                        color: Colors.white, shape: BoxShape.circle),
                    child: Padding(
                      padding: const EdgeInsets.all(8.0),
                      child: IconButton(
                        icon: Icon(Icons.message, size: ScreenUtil().setHeight(22.0),),
                        color: const Color(0xfff63e3c),
                        onPressed: () async {
                          await launch('https://api.whatsapp.com/send/?phone=91${widget.number}&text&app_absent=0');
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

  Widget slider() {
    return Stack(
      children: [
        SizedBox(
          height: ScreenUtil().setHeight(350.0),
          child: CarouselSlider.builder(
            unlimitedMode: true,
            controller: _sliderController,
            slideBuilder: (index) {
              return Image.network(
                imgList[index],
                fit: BoxFit.cover,
              );
            },
            slideTransform: const ParallaxTransform(),
            slideIndicator: CircularSlideIndicator(
                padding: const EdgeInsets.only(bottom: 32),
                indicatorBorderColor: Colors.white,
                currentIndicatorColor: Colors.white,
                indicatorBackgroundColor: Colors.transparent),
            itemCount: imgList.length,
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
              child: Padding(
                padding: const EdgeInsets.all(8.0),
                child: Icon(
                  Icons.arrow_back,
                  color: Colors.black,
                  size: ScreenUtil().setHeight(24.0),
                ),
              ),
            ),
          ),
        ),
      ],
    );
  }

  _facilities(IconData icon, String facility) {
    return Container(
      decoration: BoxDecoration(
          color: Colors.grey[100], borderRadius: BorderRadius.circular(5.0)),
      child: Padding(
        padding: EdgeInsets.symmetric(
          vertical: ScreenUtil().setHeight(5.0),
          horizontal: ScreenUtil().setWidth(10.0),
        ),
        child: Row(
          children: [
            Icon(
              icon,
              color: Colors.black,
              size: ScreenUtil().setHeight(16.0),
            ),
            SizedBox(
              width: ScreenUtil().setWidth(10.0),
            ),
            Text(
              facility,
              style: GoogleFonts.play(
                color: Colors.black,
                fontWeight: FontWeight.w600,
                fontSize: ScreenUtil().setSp(12.0),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
