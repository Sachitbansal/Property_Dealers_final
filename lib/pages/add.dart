import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:image_picker/image_picker.dart';
import 'package:provider/provider.dart';
import '../addHelper.dart';
import '../widgets.dart';
import 'dart:io';

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

  String? downloadUrl =
      'https://miro.medium.com/max/800/1*UL9RWkTUtJlyHW7kGm20hQ.png';

  late List buyRent = ['', 'Any'];
  late String bedRooms = 'Na';
  late String bathRooms = 'Na';
  late String sizeUnit = 'None';
  late String construction = 'None';
  late String type = 'None';

  late int landSize = 0;
  late String keywords = 'None';
  late String address = 'None';
  late String title = 'None';
  late String name = 'None';
  late int number = 0;

  late int price = 0;

  final landSizeController = TextEditingController();
  final keywordsController = TextEditingController();
  final addressController = TextEditingController();
  final nameController = TextEditingController();
  final numberController = TextEditingController();
  final titleController = TextEditingController();
  final priceController = TextEditingController();

  @override
  void dispose() {
    nameController.dispose();
    landSizeController.dispose();
    keywordsController.dispose();
    addressController.dispose();
    numberController.dispose();
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

  Future imagePickerMethod() async {
    final pick = await imagePicker.pickMultiImage(imageQuality: 30);
    setState(() {
      if (pick != null) {
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

  Future<void> addUser() {
    CollectionReference students =
        FirebaseFirestore.instance.collection(widget.collection.toString());
    return students.add({
      'searchData': [
        buyRent[0].toLowerCase(),
        bedRooms[0].toLowerCase(),
        bathRooms[0].toLowerCase(),
        sizeUnit.toLowerCase(),
        construction.toLowerCase(),
        landSize,
        keywords.toLowerCase(),
        address.toLowerCase(),
        name.toLowerCase(),
        number,
        type.toLowerCase(),
        price,
        title.toLowerCase()
      ],
      'buyRent': buyRent,
      'bedRooms': bedRooms,
      'bathRooms': bathRooms,
      'sizeUnit': sizeUnit,
      'construction': construction,
      'landSize': landSize,
      'keywords': keywords,
      'address': address,
      'name': name,
      'number': number,
      'types': type,
      'Price': price,
      'title': title,
      'images': urls,
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
          title: const Text('Add'),
          centerTitle: true,
        ),
        body: isLoading
            ? Center(
                child: BuildProgress(
                  width: size.width,
                  uploadTask: uploadTask,
                ),
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
                        const FilterTitle(
                          title: 'Price',
                        ),
                        CustomTextField(
                          titleController: priceController,
                          keyboardType: TextInputType.number,
                            labelText: '100000',
                          validator: (value) {
                            if (value == null || value.isEmpty) {
                              return 'Please Enter a desired price';
                            }
                            return null;
                          },
                        ),
                        const FilterTitle(
                          title: 'Bedrooms',
                        ),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            buildOption(
                              onTap: () {
                                setState(() {
                                  bedRooms = '1';
                                });
                              },
                              text: "1",
                              textColor: bedRooms == '1'
                                  ? Colors.white
                                  : kActiveColor,
                              bgColor: bedRooms == '1'
                                  ? kActiveColor
                                  : kInActiveColor,
                            ),
                            buildOption(
                              onTap: () {
                                setState(() {
                                  bedRooms = '2';
                                });
                              },
                              text: "2",
                              textColor: bedRooms == '2'
                                  ? Colors.white
                                  : kActiveColor,
                              bgColor: bedRooms == '2'
                                  ? kActiveColor
                                  : kInActiveColor,
                            ),
                            buildOption(
                              onTap: () {
                                setState(() {
                                  bedRooms = '3';
                                });
                              },
                              text: "3",
                              textColor: bedRooms == '3'
                                  ? Colors.white
                                  : kActiveColor,
                              bgColor: bedRooms == '3'
                                  ? kActiveColor
                                  : kInActiveColor,
                            ),
                            buildOption(
                              onTap: () {
                                setState(() {
                                  bedRooms = '4';
                                });
                              },
                              text: "4",
                              textColor: bedRooms == '4'
                                  ? Colors.white
                                  : kActiveColor,
                              bgColor: bedRooms == '4'
                                  ? kActiveColor
                                  : kInActiveColor,
                            ),
                            buildOption(
                              onTap: () {
                                setState(() {
                                  bedRooms = 'Na';
                                });
                              },
                              text: "Na",
                              textColor: bedRooms == 'Na'
                                  ? Colors.white
                                  : kActiveColor,
                              bgColor: bedRooms == 'Na'
                                  ? kActiveColor
                                  : kInActiveColor,
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
                                  bathRooms = '1';
                                });
                              },
                              text: "1",
                              textColor: bathRooms == '1'
                                  ? Colors.white
                                  : kActiveColor,
                              bgColor: bathRooms == '1'
                                  ? kActiveColor
                                  : kInActiveColor,
                            ),
                            buildOption(
                              onTap: () {
                                setState(() {
                                  bathRooms = '2';
                                });
                              },
                              text: "2",
                              textColor: bathRooms == '2'
                                  ? Colors.white
                                  : kActiveColor,
                              bgColor: bathRooms == '2'
                                  ? kActiveColor
                                  : kInActiveColor,
                            ),
                            buildOption(
                              onTap: () {
                                setState(() {
                                  bathRooms = '3';
                                });
                              },
                              text: "3",
                              textColor: bathRooms == '3'
                                  ? Colors.white
                                  : kActiveColor,
                              bgColor: bathRooms == '3'
                                  ? kActiveColor
                                  : kInActiveColor,
                            ),
                            buildOption(
                              onTap: () {
                                setState(() {
                                  bathRooms = '4';
                                });
                              },
                              text: "4",
                              textColor: bathRooms == '4'
                                  ? Colors.white
                                  : kActiveColor,
                              bgColor: bathRooms == '4'
                                  ? kActiveColor
                                  : kInActiveColor,
                            ),
                            buildOption(
                              onTap: () {
                                setState(() {
                                  bathRooms = 'Na';
                                });
                              },
                              text: "Na",
                              textColor: bathRooms == 'Na'
                                  ? Colors.white
                                  : kActiveColor,
                              bgColor: bathRooms == 'Na'
                                  ? kActiveColor
                                  : kInActiveColor,
                            ),
                          ],
                        ),
                        const FilterTitle(
                          title: 'Minimum Land size',
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
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceAround,
                          children: [
                            ButtonWithText(
                              onTap: () {
                                setState(() {
                                  sizeUnit = 'm²';
                                });
                              },
                              size: size.width * .20,
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
                              size: size.width * .25,
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
                                  sizeUnit = 'Hectares';
                                });
                              },
                              size: size.width * .35,
                              title: 'Hectares',
                              bgColor: sizeUnit == 'Hectares'
                                  ? kActiveColor
                                  : kInActiveColor,
                              fontColor: sizeUnit == 'Hectares'
                                  ? Colors.white
                                  : kActiveColor,
                            ),
                          ],
                        ),
                        const FilterTitle(
                          title: 'Construction Status',
                        ),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceAround,
                          children: [
                            ButtonWithText(
                              onTap: () {
                                setState(() {
                                  construction = 'Any';
                                });
                              },
                              size: size.width * .20,
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
                              size: size.width * .20,
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
                              size: size.width * .45,
                              title: 'Established',
                              bgColor: construction == 'Established'
                                  ? kActiveColor
                                  : kInActiveColor,
                              fontColor: construction == 'Established'
                                  ? Colors.white
                                  : kActiveColor,
                            ),
                          ],
                        ),
                        const FilterTitle(
                          title: 'Keywords (separated by comma)',
                        ),
                        CustomTextField(
                          titleController: keywordsController,
                          labelText: 'Pool, Parking',
                          validator: (value) {
                            if (value == null || value.isEmpty) {
                              return 'Please Enter Some Keywords';
                            }
                            return null;
                          },
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
                            if (_formKey.currentState!.validate() &&
                                _image != null) {
                              setState(() {
                                landSize = int.parse(landSizeController.text);
                                keywords = keywordsController.text;
                                address = addressController.text;
                                name = nameController.text;
                                number = int.parse(numberController.text);
                                price = int.parse(priceController.text);
                                title = titleController.text;
                                uploadFunction(_image!);
                              });
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
