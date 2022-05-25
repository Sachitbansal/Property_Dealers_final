import 'dart:io';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:provider/provider.dart';
import 'package:share_plus/share_plus.dart';

import '../addHelper.dart';
import '../dynamic_links.dart';
import '../widgets.dart';

class Add extends StatefulWidget {
  const Add({Key? key, required this.collection}) : super(key: key);
  final String? collection;

  @override
  _AddState createState() => _AddState();
}

class _AddState extends State<Add> {
  @override
  void initState() {
    super.initState();
    AddProvider addProvider = Provider.of<AddProvider>(context, listen: false);
    addProvider.initialiseFullPageAdd();
  }

  MaterialStateProperty<Color> kActiveCardColour =
      MaterialStateProperty.all<Color>(Colors.blue[100]!);
  MaterialStateProperty<Color> kInactiveCardColour =
      MaterialStateProperty.all<Color>(Colors.transparent);

  final _formKey = GlobalKey<FormState>();
  Color? kActiveColor = Colors.blue[200];
  Color? kInActiveColor = Colors.blue[200]?.withOpacity(0.05);

  late List buyRent = ['', 'Any'];
  late String bedRooms = 'Na';
  late String facing = 'North';
  late String bathRooms = 'Na';
  late String sizeUnit = 'None';
  late String construction = 'None';
  late String type = 'None';
  late String priceSuffix = 'None';
  late int price = 0;

  final landSizeController = TextEditingController();
  final addressController = TextEditingController();
  final nameController = TextEditingController();
  final numberController = TextEditingController();
  final titleController = TextEditingController();
  final priceController = TextEditingController();
  final otherController = TextEditingController();

  @override
  void dispose() {
    nameController.dispose();
    landSizeController.dispose();
    addressController.dispose();
    numberController.dispose();
    otherController.dispose();
    titleController.dispose();
    priceController.dispose();
    super.dispose();
  }

  showSnackBar(String snackText, Duration d) {
    final snackBar = SnackBar(content: Text(snackText), duration: d);
    ScaffoldMessenger.of(context).showSnackBar(snackBar);
  }

  List<XFile>? _image;
  final imagePicker = ImagePicker();
  List<String> downloadURL = [];
  List<String> urls = [];
  var isLoading = false;
  int uploadItem = 0;
  UploadTask? uploadTask;
  bool isPicked = false;

  Future imagePickerMethod() async {
    final pick = await imagePicker.pickMultiImage(imageQuality: 30);
    setState(() {
      if (pick != null) {
        setState(() {
          isPicked = true;
        });
        _image = pick;
      } else {
        showSnackBar("No File selected", const Duration(milliseconds: 400));
      }
    });
  }

  void uploadFunction(List<XFile> images) async {
    setState(() {
      isLoading = true;
    });
    for (int i = 0; i < images.length; i++) {
      var imgUrl = await uploadFile(images[i]);
      urls.add(imgUrl.toString());
    }

    addUser().whenComplete(() {
      urls.clear();
    });
  }

  Future<void> addUser() async {
    List varList = [
      titleController.text,
      buyRent[0].toLowerCase(),
      bedRooms,
      bathRooms,
      sizeUnit,
      facing,
      construction,
      landSizeController.text.toString(),
      nameController.text,
      numberController.text.toString(),
      type.toLowerCase(),
      priceController.text.toString(),
      titleController.text
    ];
    List finalData = [];
    for (var i = 0; i < varList.length; i++) {
      setSearchParam() {
        List<String> caseSearchList = [];
        String temp = "";
        for (int index = 0; index < varList[i].length; index++) {
          temp = temp + varList[i][index];
          caseSearchList.add(temp);
        }
        return caseSearchList;
      }

      finalData.addAll(setSearchParam());
    }

    if (urls.isEmpty) {
      urls = [
        'https://cdn.iconscout.com/icon/free/png-256/house-home-building-infrastructure-real-estate-resident-emoj-symbol-1-30743.png'
      ];
    }

    if (priceSuffix == 'Crore') {
      price = int.parse(priceController.text * 10000000);
    } else if (priceSuffix == 'Lakh') {
      price = int.parse(priceController.text * 100000);
    } else {
      price = int.parse(priceController.text * 1000);
    }

    CollectionReference students =
    FirebaseFirestore.instance.collection(widget.collection.toString());
    return students.add({
      'ownerName': FirebaseAuth.instance.currentUser!.displayName,
      'colid': widget.collection.toString(),
      'searchData': finalData,
      'buyRent': buyRent,
      'bedRooms': bedRooms,
      'bathRooms': bathRooms,
      'sizeUnit': sizeUnit,
      'construction': construction,
      'landSize': landSizeController.text,
      'address': addressController.text,
      'name': nameController.text,
      'number': numberController.text,
      'types': type,
      'facing': facing,
      'Price': price,
      'priceAmount': priceController.text,
      'priceSuffix': priceSuffix,
      'title': titleController.text,
      'images': urls,
      'other': otherController.text,
      'isPublic': false,
      'bookmark': false
    }).then(
          (value) => {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Added Successfully'),
          ),
        ),
      },
    );
  }

  Future<String> uploadFile(XFile images) async {
    final imgId = DateTime.now().millisecondsSinceEpoch.toString();

    Reference reference = FirebaseStorage.instance
        .ref()
        .child(widget.collection.toString())
        .child("post_$imgId");
    uploadTask = reference.putFile(File(images.path));
    await uploadTask?.whenComplete(() {
      setState(() {
        isLoading = false;
      });
    });
    return await reference.getDownloadURL();
  }

  @override
  Widget build(BuildContext context) {
    final Size size = MediaQuery.of(context).size;
    return WillPopScope(
      onWillPop: () async {
        AddProvider addProvider =
            Provider.of<AddProvider>(context, listen: false);
        if (addProvider.isFullPageAddLoaded) {
          addProvider.fullPageAdd.show();
        }
        return true;
      },
      child: Scaffold(
        appBar: AppBar(
          title: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text('Add'),
              IconButton(
                icon: const Icon(Icons.share),
                onPressed: () async {
                  String generatedDeepLink =
                  await DynamicLinkServices.createAddPropertyFromCustomer(
                    short: false,
                    collectionId: widget.collection.toString(),
                  );
                  Share.share(generatedDeepLink);
                },
              )
            ],
          ),
          centerTitle: true,
        ),
        body: isLoading
            ? Stack(
                children: [
                  Container(
                    color: Colors.black12,
                    child: Center(
                      child: BuildProgress(
                        width: size.width,
                        uploadTask: uploadTask,
                      ),
                    ),
                  )
                ],
              )
            : SingleChildScrollView(
                child: Form(
                  key: _formKey,
                  child: Padding(
                    padding: const EdgeInsets.only(
                        right: 24, left: 24, top: 15, bottom: 24),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const FilterTitle(
                          title: 'Buy Or Rent',
                        ),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceAround,
                          children: [
                            ButtonWithText(
                              onTap: () {
                                setState(() {
                                  buyRent[0] = 'Buy';
                                });
                              },
                              size: size.width * .40,
                              title: 'Buy',
                              bgColor: buyRent[0] == 'Buy'
                                  ? kActiveColor
                                  : kInActiveColor,
                              fontColor: buyRent[0] == 'Buy'
                                  ? Colors.white
                                  : kActiveColor,
                            ),
                            ButtonWithText(
                              onTap: () {
                                setState(() {
                                  buyRent[0] = 'Rent';
                                });
                              },
                              size: size.width * .40,
                              title: 'Rent',
                              bgColor: buyRent[0] == 'Rent'
                                  ? kActiveColor
                                  : kInActiveColor,
                              fontColor: buyRent[0] == 'Rent'
                                  ? Colors.white
                                  : kActiveColor,
                            ),
                          ],
                        ),
                        const FilterTitle(
                          title: 'Title Of Property',
                        ),
                        CustomTextField(
                          titleController: titleController,
                          labelText: 'Title',
                          validator: (value) {
                            if (value == null || value.isEmpty) {
                              return 'Please Enter a Title';
                            }
                            return null;
                          },
                        ),
                        const FilterTitle(
                          title: 'Property Type',
                        ),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            ButtonWithTextAndIcon(
                              textIconColor:
                                  type == 'Flat' ? Colors.white : kActiveColor,
                              title: 'Flat',
                              onTap: () {
                                setState(
                                  () {
                                    type = 'Flat';
                                  },
                                );
                              },
                              bgColor: type == 'Flat'
                                  ? kActiveColor
                                  : kInActiveColor,
                              icon: Icons.apartment,
                            ),
                            ButtonWithTextAndIcon(
                              textIconColor:
                                  type == 'House' ? Colors.white : kActiveColor,
                              title: 'House',
                              onTap: () {
                                setState(() {
                                  type = 'House';
                                });
                              },
                              bgColor: type == 'House'
                                  ? kActiveColor
                                  : kInActiveColor,
                              icon: Icons.house,
                            ),
                            ButtonWithTextAndIcon(
                              textIconColor:
                                  type == 'Room' ? Colors.white : kActiveColor,
                              title: 'Room',
                              onTap: () {
                                setState(() {
                                  type = 'Room';
                                });
                              },
                              bgColor: type == 'Room'
                                  ? kActiveColor
                                  : kInActiveColor,
                              icon: Icons.meeting_room,
                            ),
                            ButtonWithTextAndIcon(
                              textIconColor:
                                  type == 'Land' ? Colors.white : kActiveColor,
                              title: 'Land',
                              onTap: () {
                                setState(() {
                                  type = 'Land';
                                });
                              },
                              bgColor: type == 'Land'
                                  ? kActiveColor
                                  : kInActiveColor,
                              icon: Icons.meeting_room,
                            ),
                          ],
                        ),
                        ExpansionTile(
                          expandedAlignment: Alignment.bottomLeft,
                          title: Row(
                            children: [
                              const FilterTitle(
                                title: 'Price',
                              ),
                            ],
                          ),
                          children: [
                            CustomTextField(
                              keyboardType: TextInputType.number,
                              titleController: priceController,
                              labelText: '100000',
                            ),
                            Wrap(
                              children: [
                                ButtonWithText(
                                  onTap: () {
                                    setState(() {
                                      priceSuffix = 'Crore';
                                    });
                                  },
                                  size: 80,
                                  title: "Crore",
                                  fontColor: priceSuffix == 'Crore'
                                      ? Colors.white
                                      : kActiveColor,
                                  bgColor: priceSuffix == 'Crore'
                                      ? kActiveColor
                                      : kInActiveColor,
                                ),
                                ButtonWithText(
                                  onTap: () {
                                    setState(() {
                                      priceSuffix = 'Lakh';
                                    });
                                  }, size: 80,
                                  title: "Lakh",
                                  fontColor: priceSuffix == 'Lakh'
                                      ? Colors.white
                                      : kActiveColor,
                                  bgColor: priceSuffix == 'Lakh'
                                      ? kActiveColor
                                      : kInActiveColor,
                                ),
                                ButtonWithText(
                                  onTap: () {
                                    setState(() {
                                      priceSuffix = 'Thousand';
                                    });
                                  },
                                  title: "Thousand",
                                  size: 120,
                                  fontColor: priceSuffix == 'Thousand'
                                      ? Colors.white
                                      : kActiveColor,
                                  bgColor: priceSuffix == 'Thousand'
                                      ? kActiveColor
                                      : kInActiveColor,
                                ),
                              ],
                            ),
                          ],
                        ),
                        ExpansionTile(
                          expandedAlignment: Alignment.bottomLeft,
                          title: Row(
                            children: [
                              const FilterTitle(
                                title: 'Bedrooms',
                              ),
                            ],
                          ),
                          children: [
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
                                  },
                                  size: 70,
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
                          ],
                        ),
                        ExpansionTile(
                          expandedAlignment: Alignment.bottomLeft,
                          title: Row(
                            children: [
                              const FilterTitle(
                                title: 'Bathrooms',
                              ),
                            ],
                          ),
                          children: [
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
                          ],
                        ),
                        ExpansionTile(
                          expandedAlignment: Alignment.bottomLeft,
                          title: Row(
                            children: [
                              const FilterTitle(
                                title: 'Facing Direction',
                              ),
                            ],
                          ),
                          children: [
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
                          ],
                        ),
                        ExpansionTile(
                          expandedAlignment: Alignment.bottomLeft,
                          title: Row(
                            children: [
                              const FilterTitle(
                                title: 'Land size',
                              ),
                            ],
                          ),
                          children: [
                            CustomTextField(
                              keyboardType: TextInputType.number,
                              titleController: landSizeController,
                              labelText: '500',
                              validator: (value) {
                                if (value == null || value.isEmpty) {
                                  return 'Please Enter Minimum Land Size';
                                }
                                return null;
                              },
                            ),
                            SizedBox(
                              height: 5,
                            ),
                            Wrap(
                              children: [
                                ButtonWithText(
                                  onTap: () {
                                    setState(() {
                                      sizeUnit = 'm²';
                                    });
                                  },
                                  size: 70,
                                  title: 'm²',
                                  bgColor: sizeUnit == 'm²'
                                      ? kActiveColor
                                      : kInActiveColor,
                                  fontColor: sizeUnit == 'm²'
                                      ? Colors.white
                                      : kActiveColor,
                                ),
                                ButtonWithText(
                                  onTap: () {
                                    setState(() {
                                      sizeUnit = 'Acres';
                                    });
                                  },
                                  size: 80,
                                  title: 'Acres',
                                  bgColor: sizeUnit == 'Acres'
                                      ? kActiveColor
                                      : kInActiveColor,
                                  fontColor: sizeUnit == 'Acres'
                                      ? Colors.white
                                      : kActiveColor,
                                ),
                                ButtonWithText(
                                  onTap: () {
                                    setState(() {
                                      sizeUnit = 'Yards²';
                                    });
                                  },
                                  size: 100,
                                  title: 'Yards²',
                                  bgColor: sizeUnit == 'Yards²'
                                      ? kActiveColor
                                      : kInActiveColor,
                                  fontColor: sizeUnit == 'Yards²'
                                      ? Colors.white
                                      : kActiveColor,
                                ),
                                ButtonWithText(
                                  onTap: () {
                                    setState(() {
                                      sizeUnit = 'Feet²';
                                    });
                                  },
                                  size: 90,
                                  title: 'Feet²',
                                  bgColor: sizeUnit == 'Feet²'
                                      ? kActiveColor
                                      : kInActiveColor,
                                  fontColor: sizeUnit == 'Feet²'
                                      ? Colors.white
                                      : kActiveColor,
                                ),
                                ButtonWithText(
                                  onTap: () {
                                    setState(() {
                                      sizeUnit = 'biswa';
                                    });
                                  },
                                  size: 90,
                                  title: 'biswa',
                                  bgColor: sizeUnit == 'biswa'
                                      ? kActiveColor
                                      : kInActiveColor,
                                  fontColor: sizeUnit == 'biswa'
                                      ? Colors.white
                                      : kActiveColor,
                                ),
                                ButtonWithText(
                                  onTap: () {
                                    setState(() {
                                      sizeUnit = 'marla';
                                    });
                                  },
                                  size: 90,
                                  title: 'marla',
                                  bgColor: sizeUnit == 'marla'
                                      ? kActiveColor
                                      : kInActiveColor,
                                  fontColor: sizeUnit == 'marla'
                                      ? Colors.white
                                      : kActiveColor,
                                ),
                              ],
                            ),
                          ],
                        ),
                        ExpansionTile(
                          expandedAlignment: Alignment.bottomLeft,
                          title: Row(
                            children: [
                              const FilterTitle(
                                title: 'Construction Status',
                              ),
                            ],
                          ),
                          children: [
                            Wrap(
                              children: [
                                ButtonWithText(
                                  onTap: () {
                                    setState(() {
                                      construction = 'Any';
                                    });
                                  },
                                  size: 80,
                                  title: 'Any',
                                  bgColor: construction == 'Any'
                                      ? kActiveColor
                                      : kInActiveColor,
                                  fontColor: construction == 'Any'
                                      ? Colors.white
                                      : kActiveColor,
                                ),
                                ButtonWithText(
                                  onTap: () {
                                    setState(() {
                                      construction = 'New';
                                    });
                                  },
                                  size: 80,
                                  title: 'New',
                                  bgColor: construction == 'New'
                                      ? kActiveColor
                                      : kInActiveColor,
                                  fontColor: construction == 'New'
                                      ? Colors.white
                                      : kActiveColor,
                                ),
                                ButtonWithText(
                                  onTap: () {
                                    setState(() {
                                      construction = 'Established';
                                    });
                                  },
                                  size: 150,
                                  title: 'Established',
                                  bgColor: construction == 'Established'
                                      ? kActiveColor
                                      : kInActiveColor,
                                  fontColor: construction == 'Established'
                                      ? Colors.white
                                      : kActiveColor,
                                ),
                                ButtonWithText(
                                  onTap: () {
                                    setState(() {
                                      construction = 'Under Construction';
                                    });
                                  },
                                  size: 200,
                                  title: 'Under Construction',
                                  bgColor: construction == 'Under Construction'
                                      ? kActiveColor
                                      : kInActiveColor,
                                  fontColor: construction == 'Under Construction'
                                      ? Colors.white
                                      : kActiveColor,
                                ),
                              ],
                            ),
                          ],
                        ),
                        const FilterTitle(
                          title: 'Address Of Property',
                        ),
                        CustomTextField(
                          titleController: addressController,
                          labelText: 'Address',
                          validator: (value) {
                            if (value == null || value.isEmpty) {
                              return 'Please Enter Address Of Property';
                            }
                            return null;
                          },
                        ),
                        const FilterTitle(
                          title: 'Additional Information',
                        ),
                        CustomTextField(
                            maxLines: 4,
                            titleController: otherController,
                            labelText: 'Information',
                            validator: (value) => null),
                        const FilterTitle(
                          title: 'Upload Images',
                        ),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            TextButton(
                              style: ButtonStyle(
                                backgroundColor:
                                    MaterialStateProperty.all<Color>(
                                        Colors.blue[200]!),
                                alignment: Alignment.center,
                              ),
                              child: SizedBox(
                                height: 40,
                                width: size.width * .7,
                                child: const Center(
                                  child: Text(
                                    'Pick Images',
                                    style: TextStyle(
                                        color: Colors.white, fontSize: 20),
                                  ),
                                ),
                              ),
                              onPressed: imagePickerMethod,
                            ),
                          ],
                        ),
                        const SizedBox(
                          height: 8,
                        ),
                        if (isPicked)
                          Container(
                            decoration: BoxDecoration(
                              border: Border.all(
                                color: Colors.blue,
                                width: 2,
                              ),
                            ),
                            child: SingleChildScrollView(
                              scrollDirection: Axis.horizontal,
                              child: Row(
                                children: List.generate(_image!.length, (i) {
                                  return Container(
                                    height: 200,
                                    width: 200,
                                    decoration: BoxDecoration(
                                      image: DecorationImage(
                                        fit: BoxFit.cover,
                                        image: FileImage(
                                          File(_image![i].path),
                                        ),
                                      ),
                                    ),
                                  );
                                }),
                              ),
                            ),
                          )
                        else
                          Container(),
                        const SizedBox(
                          height: 8,
                        ),
                        Divider(
                          thickness: 2,
                          color: Colors.blue[200]!.withOpacity(.5),
                        ),
                        const FilterTitle(
                          title: 'Name',
                        ),
                        CustomTextField(
                          titleController: nameController,
                          labelText: 'Name',
                          validator: (value) {
                            if (value == null || value.isEmpty) {
                              return 'Please Enter the Name';
                            }
                            return null;
                          },
                        ),
                        const FilterTitle(
                          title: 'Contact',
                        ),
                        CustomTextField(
                          keyboardType: TextInputType.number,
                          titleController: numberController,
                          labelText: 'Contact',
                          validator: (value) {
                            if (value == null || value.isEmpty) {
                              return 'Please Enter Contact Number';
                            }
                            return null;
                          },
                        ),
                        const SizedBox(
                          height: 10,
                        ),
                        TextButton(
                          style: ButtonStyle(
                            backgroundColor: MaterialStateProperty.all<Color>(
                                Colors.blue[200]!),
                            alignment: Alignment.center,
                          ),
                          child: const SizedBox(
                            height: 40,
                            // width: size.width * .8,
                            child: Center(
                              child: Text(
                                'Add',
                                style: TextStyle(
                                    color: Colors.white, fontSize: 20),
                              ),
                            ),
                          ),
                          onPressed: () {
                            // if (_formKey.currentState!.validate() &&
                            //     _image != null) {
                            //   uploadFunction(_image!);
                            // } else if (_image == null) {
                            //   showSnackBar('Please Select Images',
                            //       Duration(milliseconds: 1000));
                            // } else {
                            //   showSnackBar('Please fill all fields',
                            //       Duration(milliseconds: 1000));
                            // }
                            if (_image != null) {
                              uploadFunction(_image!);
                            } else {
                              addUser();
                            }

                          },
                        ),
                        const SizedBox(
                          height: 20,
                        ),
                      ],
                    ),
                  ),
                ),
              ),
      ),
    );
  }
}
