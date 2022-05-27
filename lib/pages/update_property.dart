import 'dart:io';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:untitled/pages/contacts.dart';
import '../main.dart';
import '../widgets.dart';

class UpdateProperty extends StatefulWidget {
  UpdateProperty(
      {Key? key,
      required this.collection,
      required this.id,
      required this.imageUrls,
      required this.buyRent,
      required this.bedRooms,
      required this.bathRooms,
      required this.sizeUnit,
      required this.types,
      required this.facing,
      required this.priceSuffix,
      required this.construction})
      : super(key: key);
  final String collection, id;
  final List imageUrls, buyRent;
  String bedRooms, bathRooms, sizeUnit, types, construction, facing, priceSuffix;

  @override
  State<UpdateProperty> createState() => _UpdatePropertyState();
}

class _UpdatePropertyState extends State<UpdateProperty> {
  final _formKey = GlobalKey<FormState>();

  MaterialStateProperty<Color> kActiveCardColour =
      MaterialStateProperty.all<Color>(Colors.blue[100]!);
  MaterialStateProperty<Color> kInactiveCardColour =
      MaterialStateProperty.all<Color>(Colors.transparent);

  Color? kActiveColor = Colors.blue[200];
  Color? kInActiveColor = Colors.blue[200]?.withOpacity(0.05);

  late List buyRent = ['', 'Any'];
  late String bedRooms = 'Na';
  late String bathRooms = 'Na';
  late String sizeUnit = 'None';
  late String construction = 'None';
  late String types = 'None';
  late String facing = '0';
  late String priceSuffix = 'None';
  late double price = 0;

  late List existingUrls = [];
  late bool isPublic = false;
  late bool bookmark = false;

  final landSizeController = TextEditingController();
  final keywordsController = TextEditingController();
  final addressController = TextEditingController();
  final nameController = TextEditingController();
  final numberController = TextEditingController();
  final TextEditingController titleController = TextEditingController();
  final priceController = TextEditingController();
  final otherController = TextEditingController();

  @override
  void dispose() {
    nameController.dispose();
    landSizeController.dispose();
    otherController.dispose();
    keywordsController.dispose();
    addressController.dispose();
    numberController.dispose();
    titleController.dispose();
    priceController.dispose();
    super.dispose();
  }

  bool isUpdating = false;

  Future<void> _showMyDialog() async {
    return showDialog<void>(
      context: context,
      barrierDismissible: false, // user must tap button!
      builder: (BuildContext context) {
        return AlertDialog(
          title:
              const Text('Are you sure want to make changes to the property?'),
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
                  child: const Text(
                    'UPDATE',
                    style: TextStyle(color: Colors.red),
                  ),
                  onPressed: () {
                    if (_image != null) {
                      for (var url = 0; url < widget.imageUrls.length; url++) {
                        FirebaseStorage.instance
                            .refFromURL(widget.imageUrls[url])
                            .delete();
                      }
                    }
                    uploadFunction(_image);
                    setState(() {
                      isUpdating = true;
                    });
                    Navigator.of(context).pop();
                  },
                ),
              ],
            ),
          ],
        );
      },
    );
  }

  List<XFile>? _image;
  final imagePicker = ImagePicker();
  List<String> downloadURL = [];
  List urls = [];
  int uploadItem = 0;
  UploadTask? uploadTask;
  bool isPicked = false;

  Future imagePickerMethod() async {
    final pick = await imagePicker.pickMultiImage(imageQuality: 30);
    if (pick != null) {
      _image = pick;
    } else {
      showSnackBar("No File selected", const Duration(milliseconds: 400));
    }
  }

  showSnackBar(String snackText, Duration d) {
    final snackBar = SnackBar(content: Text(snackText), duration: d);
    ScaffoldMessenger.of(context).showSnackBar(snackBar);
  }

  void uploadFunction(List<XFile>? images) async {
    if (images != null) {
      for (int i = 0; i < images.length; i++) {
        var imgUrl = await uploadFile(images[i]);
        urls.add(imgUrl.toString());
      }
    } else {
      urls = existingUrls;
    }

    updateProperty().whenComplete(() {
      setState(() {
        isUpdating = false;
      });
      urls.clear();
    });
  }

  Future<void> updateProperty() async {
    List varList = [
      titleController.text.toLowerCase(),
      buyRent[0].toLowerCase(),
      bedRooms.toLowerCase(),
      bathRooms.toLowerCase(),
      sizeUnit.toLowerCase(),
      facing.toLowerCase(),
      construction.toLowerCase(),
      landSizeController.text.toString().toLowerCase(),
      nameController.text.toLowerCase(),
      numberController.text.toString(),
      types.toLowerCase(),
      priceController.text.toString().toLowerCase(),
      priceSuffix.toLowerCase(),
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

    if (priceSuffix == 'Crore') {
      price = double.parse(priceController.text)  * 10000000;
    } else if (priceSuffix == 'Lakh') {
      price = double.parse(priceController.text)  * 100000;
    } else {
      price = double.parse(priceController.text)  * 1000;
    }

    CollectionReference students =
    FirebaseFirestore.instance.collection(widget.collection.toString());
    students.doc(widget.id).update({
      'searchData': finalData,
      'buyRent': buyRent,
      'bedRooms': bedRooms,
      'bathRooms': bathRooms,
      'other': otherController.text,
      'sizeUnit': sizeUnit,
      'construction': construction,
      'landSize': int.parse(landSizeController.text),
      'keywords': keywordsController.text,
      'address': addressController.text,
      'name': nameController.text,
      'number': numberController.text,
      'types': types,
      'facing': facing,
      'Price': price,
      'priceAmount': priceController.text,
      'priceSuffix': priceSuffix,
      'title': titleController.text,
      'images': urls,
    }).then((value) {
      showSnackBar(
        'Updated Private Data',
        const Duration(milliseconds: 1000),
      );
      if (isPublic) {
        CollectionReference public =
            FirebaseFirestore.instance.collection('Public');
        public
            .doc(widget.id + widget.collection.toString())
            .delete()
            .whenComplete(() {
          DocumentReference copyTo = FirebaseFirestore.instance
              .collection('Public')
              .doc(widget.id + widget.collection.toString());
          DocumentReference copyFrom = FirebaseFirestore.instance
              .collection(widget.collection.toString())
              .doc(widget.id);

          copyFrom
              .get()
              .then(
                (value) => {
                  copyTo.set(value.data()),
                },
              )
              .whenComplete(() {
            showSnackBar(
              'Updates Public Property',
              const Duration(milliseconds: 1000),
            );
            Navigator.pop(context);
            Navigator.pop(context);
          });
        });
      } else {
        Navigator.pop(context);
        Navigator.pop(context);
      }
    }).catchError(
          (error) => showSnackBar(
          'Failed to Update: $error', const Duration(milliseconds: 1000)),
    );
  }

  Future<String> uploadFile(XFile images) async {
    final imgId = DateTime.now().millisecondsSinceEpoch.toString();
    Reference reference = FirebaseStorage.instance
        .ref()
        .child(widget.collection.toString())
        .child("post_$imgId");
    uploadTask = reference.putFile(File(images.path));
    await uploadTask?.whenComplete(() {});
    // print(await reference.getDownloadURL());
    return await reference.getDownloadURL();
  }

  Future<void> getContact() async {
    numberController.text = await Navigator.push(
      context,
      CustomPageRoute(child: Contacts()),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        centerTitle: true,
        title: const Text('Update Property'),
      ),
      body: isUpdating
          ? Stack(
              children: [
                Container(
                  color: Colors.black12,
                  child: const Center(
                    child: CircularProgressIndicator(),
                  ),
                )
              ],
            )
          : Column(
            children: [
              Expanded(
                child: SingleChildScrollView(
                    child: Form(
                      key: _formKey,
                      child: FutureBuilder<DocumentSnapshot<Map<String, dynamic>>>(
                        future: FirebaseFirestore.instance
                            .collection(widget.collection.toString())
                            .doc(widget.id)
                            .get(),
                        builder: (_, snapshot) {
                          if (snapshot.hasError) {
                            showSnackBar('Something Went Wrong',
                                const Duration(milliseconds: 1000));
                          }
                          if (snapshot.connectionState == ConnectionState.waiting) {
                            return const Center(
                              child: CircularProgressIndicator(),
                            );
                          }

                          var data = snapshot.data!.data();
                          nameController.text = data!['name'];
                          landSizeController.text = data['landSize'].toString();
                          addressController.text = data['address'];
                          titleController.text = data['title'];
                          numberController.text = data['number'].toString();
                          priceController.text = data['priceAmount'].toString();
                          otherController.text = data['other'].toString();

                          buyRent = widget.buyRent;
                          priceSuffix = widget.priceSuffix;
                          bedRooms = widget.bedRooms;
                          bathRooms = widget.bathRooms;
                          sizeUnit = widget.sizeUnit;
                          types = widget.types;
                          construction = widget.construction;
                          facing = widget.facing;

                          existingUrls = data['images'];
                          isPublic = data['isPublic'];
                          bookmark = data['bookmark'];

                          return Padding(
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
                                    Expanded(
                                      child: ButtonWithText(
                                        onTap: () {
                                          setState(() => buyRent[0] = 'Buy');
                                        },
                                        title: 'Buy',
                                        bgColor: buyRent[0] == 'Buy'
                                            ? kActiveColor
                                            : kInActiveColor,
                                        fontColor: buyRent[0] == 'Buy'
                                            ? Colors.white
                                            : kActiveColor,
                                      ),
                                    ),
                                    const SizedBox(
                                      width: 10,
                                    ),
                                    Expanded(
                                      child: ButtonWithText(
                                        onTap: () {
                                          setState(() => buyRent[0] = 'Rent');
                                        },
                                        title: 'Rent',
                                        bgColor: buyRent[0] == 'Rent'
                                            ? kActiveColor
                                            : kInActiveColor,
                                        fontColor: buyRent[0] == 'Rent'
                                            ? Colors.white
                                            : kActiveColor,
                                      ),
                                    ),
                                  ],
                                ),
                                const FilterTitle(
                                  title: 'Property Type',
                                ),
                                SingleChildScrollView(
                                  scrollDirection: Axis.horizontal,
                                  child: Row(
                                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                    children: [
                                      const SizedBox(
                                        width: 10,
                                      ),
                                      ButtonWithTextAndIcon(
                                        textIconColor: types == 'Flat'
                                            ? Colors.white
                                            : kActiveColor,
                                        title: 'Flat',
                                        onTap: () {
                                          setState(() => widget.types = 'Flat');
                                        },
                                        bgColor: types == 'Flat'
                                            ? kActiveColor
                                            : kInActiveColor,
                                        icon: Icons.apartment,
                                      ),
                                      const SizedBox(
                                        width: 10,
                                      ),
                                      ButtonWithTextAndIcon(
                                        textIconColor: types == 'House'
                                            ? Colors.white
                                            : kActiveColor,
                                        title: 'House',
                                        onTap: () {
                                          setState(() => widget.types = 'House');
                                        },
                                        bgColor: types == 'House'
                                            ? kActiveColor
                                            : kInActiveColor,
                                        icon: Icons.house,
                                      ),
                                      const SizedBox(
                                        width: 10,
                                      ),
                                      ButtonWithTextAndIcon(
                                        textIconColor: types == 'Room'
                                            ? Colors.white
                                            : kActiveColor,
                                        title: 'Room',
                                        onTap: () {
                                          setState(() => widget.types = 'Room');
                                        },
                                        bgColor: types == 'Room'
                                            ? kActiveColor
                                            : kInActiveColor,
                                        icon: Icons.meeting_room,
                                      ),
                                      const SizedBox(
                                        width: 10,
                                      ),
                                      ButtonWithTextAndIcon(
                                        textIconColor: types == 'Land'
                                            ? Colors.white
                                            : kActiveColor,
                                        title: 'Land',
                                        onTap: () {
                                          setState(() => widget.types = 'Land');
                                        },
                                        bgColor: types == 'Land'
                                            ? kActiveColor
                                            : kInActiveColor,
                                        icon: Icons.meeting_room,
                                      ),
                                    ],
                                  ),
                                ),
                                ExpansionTile(
                                  expandedAlignment: Alignment.bottomLeft,
                                  title: Row(
                                    children: [
                                      FilterTitle(
                                        title: 'Bedrooms',
                                      ),
                                    ],
                                  ),
                                  children: [
                                    Wrap(
                                      children: [
                                        ButtonWithText(
                                          size: 50,
                                          onTap: () {
                                            setState(() => widget.bedRooms = '1');
                                          },
                                          title: "1",
                                          fontColor: bedRooms == '1'
                                              ? Colors.white
                                              : kActiveColor,
                                          bgColor: bedRooms == '1'
                                              ? kActiveColor
                                              : kInActiveColor,
                                        ),
                                        ButtonWithText(
                                          size: 50,
                                          onTap: () {
                                            setState(() => widget.bedRooms = '2');
                                          },
                                          title: "2",
                                          fontColor: bedRooms == '2'
                                              ? Colors.white
                                              : kActiveColor,
                                          bgColor: bedRooms == '2'
                                              ? kActiveColor
                                              : kInActiveColor,
                                        ),
                                        ButtonWithText(
                                          size: 50,
                                          onTap: () {
                                            setState(() => widget.bedRooms = '3');
                                          },
                                          title: "3",
                                          fontColor: bedRooms == '3'
                                              ? Colors.white
                                              : kActiveColor,
                                          bgColor: bedRooms == '3'
                                              ? kActiveColor
                                              : kInActiveColor,
                                        ),
                                        ButtonWithText(
                                          size: 50,
                                          onTap: () {
                                            setState(() => widget.bedRooms = '4');
                                          },
                                          title: "4",
                                          fontColor: bedRooms == '4'
                                              ? Colors.white
                                              : kActiveColor,
                                          bgColor: bedRooms == '4'
                                              ? kActiveColor
                                              : kInActiveColor,
                                        ),ButtonWithText(
                                          size: 55,
                                          onTap: () {
                                            setState(() => widget.bedRooms = '4+');
                                          },
                                          title: "4+",
                                          fontColor: bedRooms == '4+'
                                              ? Colors.white
                                              : kActiveColor,
                                          bgColor: bedRooms == '4+'
                                              ? kActiveColor
                                              : kInActiveColor,
                                        ),
                                        ButtonWithText(
                                          size: 60,
                                          onTap: () {
                                            setState(() => widget.bedRooms = 'Na');
                                          },
                                          title: "Na",
                                          fontColor: bedRooms == 'Na'
                                              ? Colors.white
                                              : kActiveColor,
                                          bgColor: bedRooms == 'Na'
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
                                      FilterTitle(
                                        title: 'Bathrooms',
                                      ),
                                    ],
                                  ),
                                  children: [
                                    Wrap(
                                      children: [
                                        ButtonWithText(
                                          onTap: () {
                                            setState(() => widget.bathRooms = '1');
                                          },
                                          size: 50,
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
                                            setState(() => widget.bathRooms = '2');
                                          },
                                          size: 50,
                                          title: "2",
                                          fontColor: bathRooms == '2'
                                              ? Colors.white
                                              : kActiveColor,
                                          bgColor: bathRooms == '2'
                                              ? kActiveColor
                                              : kInActiveColor,
                                        ),
                                        ButtonWithText(
                                          size: 50,
                                          onTap: () {
                                            setState(() => widget.bathRooms = '3');
                                          },
                                          title: "3",
                                          fontColor: bathRooms == '3'
                                              ? Colors.white
                                              : kActiveColor,
                                          bgColor: bathRooms == '3'
                                              ? kActiveColor
                                              : kInActiveColor,
                                        ),
                                        ButtonWithText(
                                          onTap: () {
                                            setState(() => widget.bathRooms = '4');
                                          }, size: 50,
                                          title: "4",
                                          fontColor: bathRooms == '4'
                                              ? Colors.white
                                              : kActiveColor,
                                          bgColor: bathRooms == '4'
                                              ? kActiveColor
                                              : kInActiveColor,
                                        ),ButtonWithText(
                                          onTap: () {
                                            setState(() => widget.bathRooms = '4+');
                                          }, size: 60,
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
                                            setState(() => widget.bathRooms = 'Na');
                                          }, size: 60,
                                          title: "Na",
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
                                      FilterTitle(
                                        title: 'Construction Status',
                                      ),
                                    ],
                                  ),
                                  children: [
                                    Wrap(
                                      children: [
                                        ButtonWithText(
                                          onTap: () {
                                            setState(() => widget.construction = 'Any');
                                          }, size: 80,
                                          title: 'Any',
                                          bgColor: construction == 'Any'
                                              ? kActiveColor
                                              : kInActiveColor,
                                          fontColor: construction == 'Any'
                                              ? Colors.white
                                              : kActiveColor,
                                        ),
                                        ButtonWithText(
                                          size: 80,
                                          onTap: () {
                                            setState(() => widget.construction = 'New');
                                          },
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
                                            setState(() =>
                                            widget.construction = 'Established');
                                          },
                                          title: 'Established',
                                          bgColor: construction == 'Established'
                                              ? kActiveColor
                                              : kInActiveColor,
                                          fontColor: construction == 'Established'
                                              ? Colors.white
                                              : kActiveColor,
                                        ),ButtonWithText(
                                          onTap: () {
                                            setState(() =>
                                            widget.construction = 'Under Construction');
                                          },
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
                                            setState(() =>
                                            widget.facing = 'North');
                                          },
                                          title: 'North',
                                          bgColor: facing == 'North'
                                              ? kActiveColor
                                              : kInActiveColor,
                                          fontColor: facing == 'North'
                                              ? Colors.white
                                              : kActiveColor,
                                        ),
                                        ButtonWithText(
                                          onTap: () {
                                            setState(() =>
                                            widget.facing = 'East');
                                          },
                                          title: 'East',
                                          bgColor: facing == 'East'
                                              ? kActiveColor
                                              : kInActiveColor,
                                          fontColor: facing == 'East'
                                              ? Colors.white
                                              : kActiveColor,
                                        ),ButtonWithText(
                                          onTap: () {
                                            setState(() =>
                                            widget.facing = 'West');
                                          },
                                          title: 'West',
                                          bgColor: facing == 'West'
                                              ? kActiveColor
                                              : kInActiveColor,
                                          fontColor: facing == 'West'
                                              ? Colors.white
                                              : kActiveColor,
                                        ),
                                        ButtonWithText(
                                          onTap: () {
                                            setState(() =>
                                            widget.facing = 'South');
                                          },
                                          title: 'South',
                                          bgColor: facing == 'South'
                                              ? kActiveColor
                                              : kInActiveColor,
                                          fontColor: facing == 'South'
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
                                      FilterTitle(
                                        title: 'Unit of Area',
                                      ),
                                    ],
                                  ),
                                  children: [
                                    Wrap(
                                      children: [
                                        ButtonWithText(
                                          onTap: () {
                                            setState(() {
                                              widget.sizeUnit = 'm²';
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
                                              widget.sizeUnit = 'Acres';
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
                                              widget.sizeUnit = 'Yards²';
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
                                              widget.sizeUnit = 'Feet²';
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
                                              widget.sizeUnit = 'biswa';
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
                                              widget.sizeUnit = 'marla';
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
                                          }, size: 80, title: "Lakh",
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
                                  title: 'Land size',
                                ),
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
                                const SizedBox(
                                  height: 5,
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
                                TextButton(
                                  style: ButtonStyle(
                                    backgroundColor: MaterialStateProperty.all<Color>(
                                        Colors.blue[200]!),
                                    alignment: Alignment.center,
                                  ),
                                  child: const SizedBox(
                                    height: 40,
                                    child: Center(
                                      child: Text(
                                        'Pick Images',
                                        style: TextStyle(
                                            color: Colors.white, fontSize: 20),
                                      ),
                                    ),
                                  ),
                                  onPressed: imagePickerMethod,
                                ),
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
                                Row(
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  children: [
                                    Column(
                                      children: [
                                        RoundedButton(getContact, 'Choose Contact', Colors.white,
                                            Colors.blue[200]!),
                                        const SizedBox(
                                          height: 10,
                                        ), RoundedButton( () {
                                          if (_formKey.currentState!.validate()) {
                                            _showMyDialog();
                                          }
                                        }, 'Update Property', Colors.white,
                                            Colors.blue[200]!),
                                      ],
                                    ),
                                  ],
                                ),
                                const SizedBox(
                                  height: 20,
                                ),
                              ],
                            ),
                          );
                        },
                      ),
                    ),
                  ),
              ),
              Container(
                decoration: BoxDecoration(
                  color: Colors.blue[50],
                  borderRadius: const BorderRadius.only(topLeft: Radius.circular(25), topRight: Radius.circular(25))
                ),
                child: Padding(
                  padding: const EdgeInsets.all(10.0),
                  child: Column(
                    children: const [
                      Text(
                        'IMPORTANT',
                        style: TextStyle(
                          color: Colors.redAccent,
                          fontSize: 18,
                          fontWeight: FontWeight.bold
                        ),
                      ),
                      Text(
                        'Make Sure to Change TextFields only after changing the option fields else the TextFields wont be changed',
                        textAlign: TextAlign.center,
                        style: TextStyle(
                          fontSize: 15,
                          fontWeight: FontWeight.w500
                        ),
                      ),
                    ],
                  ),
                ),
              )
            ],
          ),
    );
  }
}
