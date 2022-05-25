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
  String bedRooms = 'Na';
  String facing = 'North';
  String bathRooms = 'Na';
  String buyOrRent = 'Any';
  double rangeLabelStart = 30.0;
  double rangeLabelEnd = 1000.0;
  double areaStart = 30.0;
  double areaEnd = 1000.0;

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
                title: 'Budget',
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
                  // keyboardtype: TextInputType.phone,
                  obscureText: false,
                  iconChoose: Icons.monetization_on_outlined,
                  onChanged: (String) {rangeLabelStart = double.parse(String);},
                ),
              ),
              SizedBox(
                  width: size.width * .42,
                child: RoundedInputField(
                  label: 'Max',
                  // keyboardtype: TextInputType.phone,
                  obscureText: false,
                  iconChoose: Icons.monetization_on_outlined,
                  onChanged: (String) {
                    rangeLabelEnd = double.parse(String);
                  },
                ),
              )
            ],
          ),
          Row(
            children: const [
              FilterTitle(
                title: 'Area Range',
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
                  iconChoose: Icons.area_chart,
                  onChanged: (String) {
                    areaStart = double.parse(String);
                  },
                ),
              ),
              SizedBox(
                width: size.width * .42,
                child: RoundedInputField(
                  label: 'Max',
                  keyboardtype: TextInputType.phone,
                  obscureText: false,
                  iconChoose: Icons.area_chart,
                  onChanged: (String) {
                    areaEnd = double.parse(String);
                  },
                ),
              )
            ],
          ),
          const FilterTitle(
            title: 'Side Facing',
          ),
          Wrap(
            children: [
              ButtonWithText(
                onTap: () {
                  setState(() {
                    facing = 'North';
                  });
                },
                title: "North",
                size: 100,
                fontColor: facing == 'North'
                    ? Colors.white
                    : kActiveColor,
                bgColor: facing == 'North'
                    ? kActiveColor
                    : kInActiveColor,
              ),
              ButtonWithText(
                onTap: () {
                  setState(() {
                    facing = 'West';
                  });
                },
                title: "West",
                size: 100,
                fontColor: facing == 'West'
                    ? Colors.white
                    : kActiveColor,
                bgColor: facing == 'West'
                    ? kActiveColor
                    : kInActiveColor,
              ),
              ButtonWithText(
                onTap: () {
                  setState(() {
                    facing = 'East';
                  });
                },size: 100,
                title: "East",
                fontColor: facing == 'East'
                    ? Colors.white
                    : kActiveColor,
                bgColor: facing == 'East'
                    ? kActiveColor
                    : kInActiveColor,
              ),
              ButtonWithText(
                onTap: () {
                  setState(() {
                    facing = 'South';
                  });
                },size: 100,
                title: "South",
                fontColor: facing == 'South'
                    ? Colors.white
                    : kActiveColor,
                bgColor: facing == 'South'
                    ? kActiveColor
                    : kInActiveColor,
              ),
            ],
          ),
          const FilterTitle(
            title: 'Rooms',
          ),
          Wrap(
            children: [
              ButtonWithText(
                onTap: () {
                  setState(() {
                    bedRooms = '1';
                  });
                },
                size: 70,
                title: "1",
                fontColor: bedRooms == '1'
                    ? Colors.white
                    : kActiveColor,
                bgColor: bedRooms == '1'
                    ? kActiveColor
                    : kInActiveColor,
              ),
              ButtonWithText(
                onTap: () {
                  setState(() {
                    bedRooms = '2';
                  });
                }, size: 70,
                title: "2",
                fontColor: bedRooms == '2'
                    ? Colors.white
                    : kActiveColor,
                bgColor: bedRooms == '2'
                    ? kActiveColor
                    : kInActiveColor,
              ),
              ButtonWithText(
                onTap: () {
                  setState(() {
                    bedRooms = '3';
                  });
                },
                title: "3",
                size: 70,
                fontColor: bedRooms == '3'
                    ? Colors.white
                    : kActiveColor,
                bgColor: bedRooms == '3'
                    ? kActiveColor
                    : kInActiveColor,
              ),
              ButtonWithText(
                onTap: () {
                  setState(() {
                    bedRooms = '4';
                  });
                },
                title: "4",
                size: 70,
                fontColor: bedRooms == '4'
                    ? Colors.white
                    : kActiveColor,
                bgColor: bedRooms == '4'
                    ? kActiveColor
                    : kInActiveColor,
              ),
              ButtonWithText(
                onTap: () {
                  setState(() {
                    bedRooms = '4+';
                  });
                },
                title: "4+",
                fontColor: bedRooms == '4+'
                    ? Colors.white
                    : kActiveColor,
                bgColor: bedRooms == '4+'
                    ? kActiveColor
                    : kInActiveColor,
                size: 70,
              ),
              ButtonWithText(
                onTap: () {
                  setState(() {
                    bedRooms = 'Na';
                  });
                },
                title: "Na",
                fontColor: bedRooms == 'Na'
                    ? Colors.white
                    : kActiveColor,
                bgColor: bedRooms == 'Na'
                    ? kActiveColor
                    : kInActiveColor,
                size: 70,
              ),
            ],
          ),
          const FilterTitle(
            title: 'Bathrooms',
          ),
          Wrap(
            children: [
              ButtonWithText(
                onTap: () {
                  setState(() {
                    bathRooms = '1';
                  });
                },
                size: 70,
                title: "1",
                fontColor: bathRooms == '1'
                    ? Colors.white
                    : kActiveColor,
                bgColor: bathRooms == '1'
                    ? kActiveColor
                    : kInActiveColor,
              ),
              ButtonWithText(
                onTap: () {
                  setState(() {
                    bathRooms = '2';
                  });
                },
                title: "2",
                size: 70,
                fontColor: bathRooms == '2'
                    ? Colors.white
                    : kActiveColor,
                bgColor: bathRooms == '2'
                    ? kActiveColor
                    : kInActiveColor,
              ),
              ButtonWithText(
                onTap: () {
                  setState(() {
                    bathRooms = '3';
                  });
                },
                title: "3",
                size: 70,
                fontColor: bathRooms == '3'
                    ? Colors.white
                    : kActiveColor,
                bgColor: bathRooms == '3'
                    ? kActiveColor
                    : kInActiveColor,
              ),
              ButtonWithText(
                onTap: () {
                  setState(() {
                    bathRooms = '4';
                  });
                },
                title: "4",
                fontColor: bathRooms == '4'
                    ? Colors.white
                    : kActiveColor,
                bgColor: bathRooms == '4'
                    ? kActiveColor
                    : kInActiveColor,
                size: 70,
              ),
              ButtonWithText(
                onTap: () {
                  setState(() {
                    bathRooms = '4+';
                  });
                },  size: 70,
                title: "4+",
                fontColor: bathRooms == '4+'
                    ? Colors.white
                    : kActiveColor,
                bgColor: bathRooms == '4+'
                    ? kActiveColor
                    : kInActiveColor,
              ),
              ButtonWithText(
                onTap: () {
                  setState(() {
                    bathRooms = 'Na';
                  });
                },
                title: "Na",
                size: 70,
                fontColor: bathRooms == 'Na'
                    ? Colors.white
                    : kActiveColor,
                bgColor: bathRooms == 'Na'
                    ? kActiveColor
                    : kInActiveColor,
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
            child: const Center(
              child: Text(
                'Search',
                style: TextStyle(color: Colors.white, fontSize: 20),
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
                    rooms: bedRooms,
                    buyOrRent: buyOrRent,
                    bathrooms: bathRooms,
                    areaStart: areaStart,
                    areaEnd: areaEnd,
                    facing: facing
                  ),
                ),
              );
            },
          )
        ],
      ),
    );
  }
}
