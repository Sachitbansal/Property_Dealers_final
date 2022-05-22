import 'package:flutter/material.dart';
import 'package:untitled/pages/search.dart';

import '../widgets.dart';

class Filter extends StatefulWidget {
  const Filter({Key? key, required this.uid}) : super(key: key);
  final String? uid;

  @override
  _FilterState createState() => _FilterState();
}

class _FilterState extends State<Filter> {
  var selectedRange = const RangeValues(400, 1000);
  Color? kActiveColor = Colors.blue[200];
  Color? kInActiveColor = Colors.blue[200]?.withOpacity(0.05);
  String propertyType = 'Flat';
  String rooms = 'Na';
  String bathrooms = 'Na';
  String buyOrRent = 'Any';
  double rangeLabelStart = 30.0;
  double rangeLabelEnd = 1000.0;

  @override
  Widget build(BuildContext context) {
    final Size size = MediaQuery.of(context).size;
    return Container(
      padding: const EdgeInsets.only(right: 24, left: 24, top: 32, bottom: 24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const FilterTitle(
            title: 'Filter Your Search',
          ),
          SingleChildScrollView(
            physics: const BouncingScrollPhysics(),
            scrollDirection: Axis.horizontal,
            child: Padding(
              padding: const EdgeInsets.symmetric(
                      horizontal: 10),
              child: SizedBox(
                width: 350,
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    ButtonWithTextAndIcon(
                      textIconColor:
                          propertyType == 'Flat' ? Colors.white : kActiveColor,
                      title: 'Flat',
                      onTap: () {
                        setState(() {
                          propertyType = 'Flat';
                        });
                      },
                      bgColor: propertyType == 'Flat'
                          ? kActiveColor
                          : kInActiveColor,
                      icon: Icons.apartment,
                    ),
                    ButtonWithTextAndIcon(
                      textIconColor:
                          propertyType == 'House' ? Colors.white : kActiveColor,
                      title: 'House',
                      onTap: () {
                        setState(() {
                          propertyType = 'House';
                        });
                      },
                      bgColor: propertyType == 'House'
                          ? kActiveColor
                          : kInActiveColor,
                      icon: Icons.house,
                    ),
                    ButtonWithTextAndIcon(
                      textIconColor:
                          propertyType == 'Room' ? Colors.white : kActiveColor,
                      title: 'Room',
                      onTap: () {
                        setState(() {
                          propertyType = 'Room';
                        });
                      },
                      bgColor: propertyType == 'Room'
                          ? kActiveColor
                          : kInActiveColor,
                      icon: Icons.meeting_room,
                    ),
                    ButtonWithTextAndIcon(
                      textIconColor:
                          propertyType == 'Land' ? Colors.white : kActiveColor,
                      title: 'Land',
                      onTap: () {
                        setState(() {
                          propertyType = 'Land';
                        });
                      },
                      bgColor: propertyType == 'Land'
                          ? kActiveColor
                          : kInActiveColor,
                      icon: Icons.meeting_room,
                    ),
                  ],
                ),
              ),
            ),
          ),
          const FilterTitle(
            title: 'Buy Or Rent',
          ),
          Padding(
            padding:
                const EdgeInsets.symmetric(horizontal: 20),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                ButtonWithText(
                  onTap: () {
                    setState(() {
                      buyOrRent = 'Any';
                    });
                  },
                  size: size.width * .20,
                  title: 'Any',
                  bgColor: buyOrRent == 'Any' ? kActiveColor : kInActiveColor,
                  fontColor: buyOrRent == 'Any' ? Colors.white : kActiveColor,
                ),
                ButtonWithText(
                  onTap: () {
                    setState(() {
                      buyOrRent = 'Buy';
                    });
                  },
                  size: size.width * .20,
                  title: 'Buy',
                  bgColor: buyOrRent == 'Buy' ? kActiveColor : kInActiveColor,
                  fontColor: buyOrRent == 'Buy' ? Colors.white : kActiveColor,
                ),
                ButtonWithText(
                  onTap: () {
                    setState(() {
                      buyOrRent = 'Rent';
                    });
                  },
                  size: size.width * .20,
                  title: 'Rent',
                  bgColor: buyOrRent == 'Rent' ? kActiveColor : kInActiveColor,
                  fontColor: buyOrRent == 'Rent' ? Colors.white : kActiveColor,
                ),
              ],
            ),
          ),
          Row(
            children: const [
              FilterTitle(
                title: 'Price Range',
              ),
            ],
          ),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              SizedBox(
                width: size.width * .42,
                child: RoundedInputField(
                  label: 'Min',
                  keyboardtype: TextInputType.phone,
                  obscureText: false,
                  iconChoose: Icons.monetization_on_outlined,
                  onChanged: (String) {rangeLabelStart = double.parse(String);},
                ),
              ),
              SizedBox(
                  width: size.width * .42,
                child: RoundedInputField(
                  label: 'Max',
                  keyboardtype: TextInputType.phone,
                  obscureText: false,
                  iconChoose: Icons.monetization_on_outlined,
                  onChanged: (String) {rangeLabelEnd = double.parse(String);},
                ),
              )
            ],
          ),
          // RangeSlider(
          //   labels: RangeLabels('$rangeLabelStart', '$rangeLabelEnd'),
          //   values: selectedRange,
          //   onChanged: (RangeValues newRange) {
          //     setState(() {
          //       selectedRange = newRange;
          //       rangeLabelStart = newRange.start.roundToDouble();
          //       rangeLabelEnd = newRange.end.roundToDouble();
          //     });
          //   },
          //   min: 30,
          //   max: 1000,
          //   divisions: 20,
          //   activeColor: kActiveColor,
          //   inactiveColor: Colors.grey[300],
          // ),
          const FilterTitle(
            title: 'Rooms',
          ),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              buildOption(
                onTap: () {
                  setState(() {
                    rooms = '1';
                  });
                },
                text: "1",
                textColor: rooms == '1' ? Colors.white : kActiveColor,
                bgColor: rooms == '1' ? kActiveColor : kInActiveColor,
              ),
              buildOption(
                onTap: () {
                  setState(() {
                    rooms = '2';
                  });
                },
                text: "2",
                textColor: rooms == '2' ? Colors.white : kActiveColor,
                bgColor: rooms == '2' ? kActiveColor : kInActiveColor,
              ),
              buildOption(
                onTap: () {
                  setState(() {
                    rooms = '3';
                  });
                },
                text: "3",
                textColor: rooms == '3' ? Colors.white : kActiveColor,
                bgColor: rooms == '3' ? kActiveColor : kInActiveColor,
              ),
              buildOption(
                onTap: () {
                  setState(() {
                    rooms = 'Na';
                  });
                },
                text: "Na",
                textColor: rooms == 'Na' ? Colors.white : kActiveColor,
                bgColor: rooms == 'Na' ? kActiveColor : kInActiveColor,
              ),
            ],
          ),
          const FilterTitle(
            title: 'Bathrooms',
          ),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              buildOption(
                onTap: () {
                  setState(() {
                    bathrooms = '1';
                  });
                },
                text: "1",
                textColor: bathrooms == '1' ? Colors.white : kActiveColor,
                bgColor: bathrooms == '1' ? kActiveColor : kInActiveColor,
              ),
              buildOption(
                onTap: () {
                  setState(() {
                    bathrooms = '2';
                  });
                },
                text: "2",
                textColor: bathrooms == '2' ? Colors.white : kActiveColor,
                bgColor: bathrooms == '2' ? kActiveColor : kInActiveColor,
              ),
              buildOption(
                textColor: bathrooms == '3' ? Colors.white : kActiveColor,
                onTap: () {
                  setState(() {
                    bathrooms = '3';
                  });
                },
                text: "3",
                bgColor: bathrooms == '3' ? kActiveColor : kInActiveColor,
              ),
              buildOption(
                textColor: bathrooms == 'Na' ? Colors.white : kActiveColor,
                onTap: () {
                  setState(() {
                    bathrooms = 'Na';
                  });
                },
                text: "Na",
                bgColor: bathrooms == 'Na' ? kActiveColor : kInActiveColor,
              ),
            ],
          ),
          const SizedBox(
            height: 20,
          ),
          TextButton(
            style: ButtonStyle(
                backgroundColor:
                    MaterialStateProperty.all<Color>(Colors.blue[200]!),
                alignment: Alignment.center),
            child: SizedBox(
              height: 40,
              width: size.width * .8,
              child: const Center(
                child: Text(
                  'Search',
                  style: TextStyle(color: Colors.white, fontSize: 20),
                ),
              ),
            ),
            onPressed: () {

              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => Search(
                    priceEnd: rangeLabelEnd,
                    priceStart: rangeLabelStart,
                    uid: widget.uid.toString(),
                    propertyType: propertyType,
                    rooms: rooms,
                    buyOrRent: buyOrRent,
                    bathrooms: bathrooms,
                  ),
                ),
              );
            },
          )
        ],
      ),
    );
  }

  Widget buildOption(
      {required String text,
      Color? textColor,
      Color? bgColor,
      required void Function() onTap}) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        height: 45,
        width: 65,
        decoration: BoxDecoration(
          color: bgColor,
          borderRadius: const BorderRadius.all(
            Radius.circular(15),
          ),
        ),
        child: Center(
          child: Text(
            text,
            style: TextStyle(
              color: textColor,
              fontWeight: FontWeight.bold,
              fontSize: 14,
            ),
          ),
        ),
      ),
    );
  }
}
