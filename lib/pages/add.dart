import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:multi_image_picker2/multi_image_picker2.dart';
import '../widgets.dart';
import 'dart:io';

class Add extends StatefulWidget {
  const Add({Key? key, required this.collection}) : super(key: key);
  final String? collection;

  @override
  _AddState createState() => _AddState();
}

class _AddState extends State<Add> {
  MaterialStateProperty<Color> kActiveCardColour =
      MaterialStateProperty.all<Color>(Colors.blue[100]!);
  MaterialStateProperty<Color> kInactiveCardColour =
      MaterialStateProperty.all<Color>(Colors.transparent);

  final _formKey = GlobalKey<FormState>();
  Color? kActiveColor = Colors.blue[200];
  Color? kInActiveColor = Colors.blue[200]?.withOpacity(0.05);

  List<Asset> images = <Asset>[];

  File? _image;
  final imagePicker = ImagePicker();
  String? downloadUrl =
      'https://miro.medium.com/max/800/1*UL9RWkTUtJlyHW7kGm20hQ.png';

  Future imagePickerMethod() async {
    final pick = await imagePicker.pickImage(source: ImageSource.gallery);
    setState(
      () {
        if (pick != null) {
          _image = File(pick.path);
          uploadImage();
        } else {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('No file Selected'),
            ),
          );
        }
      },
    );
  }

  Future<void> loadAssets() async {
    List<Asset> resultList = <Asset>[];
    String error = 'No Error Detected';

    try {
      resultList = await MultiImagePicker.pickImages(
        maxImages: 300,
        enableCamera: true,
        selectedAssets: images,
        cupertinoOptions: const CupertinoOptions(
          takePhotoIcon: "chat",
          doneButtonTitle: "Fatto",
        ),
        materialOptions: const MaterialOptions(
          actionBarColor: "#abcdef",
          actionBarTitle: "Example App",
          allViewTitle: "All Photos",
          useDetailsView: false,
          selectCircleStrokeColor: "#000000",
        ),
      );
    } on Exception catch (e) {
      print(e);
    }

    // If the widget was removed from the tree while the asynchronous platform
    // message was in flight, we want to discard the reply rather than calling
    // setState to update our non-existent appearance.
    if (!mounted) return;

    setState(() {
      images = resultList;
    });
  }

  Future uploadImage() async {
    final postID = DateTime.now().microsecondsSinceEpoch.toString();
    Reference ref = FirebaseStorage.instance
        .ref()
        .child('${widget.collection}/images')
        .child('post_$postID');
    await ref.putFile(_image!);
    downloadUrl = await ref.getDownloadURL();
    print('DownloadURL');
    print(downloadUrl);
  }

  late List buyRent = ['', 'Any'];
  late List bedRooms = ['', 'None'];
  late List bathRooms = ['', 'None'];
  late String sizeUnit = 'None';
  late String construction = 'None';
  late String type = 'None';

  late String landSize = 'None';
  late String keywords = 'None';
  late String address = 'None';
  late String title = 'None';
  late String name = 'None';
  late String number = 'None';

  late String price = 'None';

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

  @override
  Widget build(BuildContext context) {
    CollectionReference students =
        FirebaseFirestore.instance.collection(widget.collection.toString());

    Future<void> addUser() {
      return students.add({
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

    final Size size = MediaQuery.of(context).size;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Add'),
        centerTitle: true,
      ),
      body: SingleChildScrollView(
        child: Form(
          key: _formKey,
          child: Padding(
            padding:
                const EdgeInsets.only(right: 24, left: 24, top: 15, bottom: 24),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // TextButton(
                //   child: const Text('Image Uthaa'),
                //   onPressed: imagePickerMethod,
                // ),
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
                      bgColor:
                          buyRent[0] == 'Buy' ? kActiveColor : kInActiveColor,
                      fontColor:
                          buyRent[0] == 'Buy' ? Colors.white : kActiveColor,
                    ),
                    ButtonWithText(
                      onTap: () {
                        setState(() {
                          buyRent[0] = 'Rent';
                        });
                      },
                      size: size.width * .40,
                      title: 'Rent',
                      bgColor:
                          buyRent[0] == 'Rent' ? kActiveColor : kInActiveColor,
                      fontColor:
                          buyRent[0] == 'Rent' ? Colors.white : kActiveColor,
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
                      bgColor: type == 'Flat' ? kActiveColor : kInActiveColor,
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
                      bgColor: type == 'House' ? kActiveColor : kInActiveColor,
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
                      bgColor: type == 'Room' ? kActiveColor : kInActiveColor,
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
                      bgColor: type == 'Land' ? kActiveColor : kInActiveColor,
                      icon: Icons.meeting_room,
                    ),
                  ],
                ),
                const FilterTitle(
                  title: 'Price',
                ),
                CustomTextField(
                  titleController: priceController,
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
                          bedRooms[0] = '1';
                        });
                      },
                      text: "1",
                      textColor:
                          bedRooms[0] == '1' ? Colors.white : kActiveColor,
                      bgColor:
                          bedRooms[0] == '1' ? kActiveColor : kInActiveColor,
                    ),
                    buildOption(
                      onTap: () {
                        setState(() {
                          bedRooms[0] = '2';
                        });
                      },
                      text: "2",
                      textColor:
                          bedRooms[0] == '2' ? Colors.white : kActiveColor,
                      bgColor:
                          bedRooms[0] == '2' ? kActiveColor : kInActiveColor,
                    ),
                    buildOption(
                      onTap: () {
                        setState(() {
                          bedRooms[0] = '3';
                        });
                      },
                      text: "3",
                      textColor:
                          bedRooms[0] == '3' ? Colors.white : kActiveColor,
                      bgColor:
                          bedRooms[0] == '3' ? kActiveColor : kInActiveColor,
                    ),
                    buildOption(
                      onTap: () {
                        setState(() {
                          bedRooms[0] = '4';
                        });
                      },
                      text: "4",
                      textColor:
                          bedRooms[0] == '4' ? Colors.white : kActiveColor,
                      bgColor:
                          bedRooms[0] == '4' ? kActiveColor : kInActiveColor,
                    ),
                    buildOption(
                      onTap: () {
                        setState(() {
                          bedRooms[0] = '4+';
                        });
                      },
                      text: "4+",
                      textColor:
                          bedRooms[0] == '4+' ? Colors.white : kActiveColor,
                      bgColor:
                          bedRooms[0] == '4+' ? kActiveColor : kInActiveColor,
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
                          bathRooms[0] = '1';
                        });
                      },
                      text: "1",
                      textColor:
                          bathRooms[0] == '1' ? Colors.white : kActiveColor,
                      bgColor:
                          bathRooms[0] == '1' ? kActiveColor : kInActiveColor,
                    ),
                    buildOption(
                      onTap: () {
                        setState(() {
                          bathRooms[0] = '2';
                        });
                      },
                      text: "2",
                      textColor:
                          bathRooms[0] == '2' ? Colors.white : kActiveColor,
                      bgColor:
                          bathRooms[0] == '2' ? kActiveColor : kInActiveColor,
                    ),
                    buildOption(
                      onTap: () {
                        setState(() {
                          bathRooms[0] = '3';
                        });
                      },
                      text: "3",
                      textColor:
                          bathRooms[0] == '3' ? Colors.white : kActiveColor,
                      bgColor:
                          bathRooms[0] == '3' ? kActiveColor : kInActiveColor,
                    ),
                    buildOption(
                      onTap: () {
                        setState(() {
                          bathRooms[0] = '4';
                        });
                      },
                      text: "4",
                      textColor:
                          bathRooms[0] == '4' ? Colors.white : kActiveColor,
                      bgColor:
                          bathRooms[0] == '4' ? kActiveColor : kInActiveColor,
                    ),
                    buildOption(
                      onTap: () {
                        setState(() {
                          bathRooms[0] = '4+';
                        });
                      },
                      text: "4+",
                      textColor:
                          bathRooms[0] == '4+' ? Colors.white : kActiveColor,
                      bgColor:
                          bathRooms[0] == '4+' ? kActiveColor : kInActiveColor,
                    ),
                  ],
                ),
                const FilterTitle(
                  title: 'Minimum Land size',
                ),
                CustomTextField(
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
                      bgColor: sizeUnit == 'm²' ? kActiveColor : kInActiveColor,
                      fontColor: sizeUnit == 'm²' ? Colors.white : kActiveColor,
                    ),
                    ButtonWithText(
                      onTap: () {
                        setState(() {
                          sizeUnit = 'Acres';
                        });
                      },
                      size: size.width * .25,
                      title: 'Acres',
                      bgColor:
                          sizeUnit == 'Acres' ? kActiveColor : kInActiveColor,
                      fontColor:
                          sizeUnit == 'Acres' ? Colors.white : kActiveColor,
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
                      fontColor:
                          sizeUnit == 'Hectares' ? Colors.white : kActiveColor,
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
                      bgColor:
                          construction == 'Any' ? kActiveColor : kInActiveColor,
                      fontColor:
                          construction == 'Any' ? Colors.white : kActiveColor,
                    ),
                    ButtonWithText(
                      onTap: () {
                        setState(() {
                          construction = 'New';
                        });
                      },
                      size: size.width * .20,
                      title: 'New',
                      bgColor:
                          construction == 'New' ? kActiveColor : kInActiveColor,
                      fontColor:
                          construction == 'New' ? Colors.white : kActiveColor,
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
                        MaterialStateProperty.all<Color>(Colors.blue[200]!),
                        alignment: Alignment.center,
                      ),
                      child: SizedBox(
                        height: 40,
                        width: size.width * .7,
                        child: const Center(
                          child: Text(
                            'Pick Images',
                            style: TextStyle(color: Colors.white, fontSize: 20),
                          ),
                        ),
                      ),
                      onPressed: loadAssets,
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
                    backgroundColor:
                        MaterialStateProperty.all<Color>(Colors.blue[200]!),
                    alignment: Alignment.center,
                  ),
                  child: SizedBox(
                    height: 40,
                    width: size.width * .8,
                    child: const Center(
                      child: Text(
                        'Upload To Firebase',
                        style: TextStyle(color: Colors.white, fontSize: 20),
                      ),
                    ),
                  ),
                  onPressed: () {
                    if (_formKey.currentState!.validate()) {
                      setState(() {
                        landSize = landSizeController.text;
                        keywords = keywordsController.text;
                        address = addressController.text;
                        name = nameController.text;
                        number = numberController.text;
                        price = priceController.text;
                        title = titleController.text;
                        addUser();
                      });
                    }
                  },
                )
              ],
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

class CustomTextField extends StatelessWidget {
  const CustomTextField({
    Key? key,
    required this.titleController,
    required this.labelText,
    this.validator,
  }) : super(key: key);

  final TextEditingController titleController;
  final String labelText;
  final String? Function(String?)? validator;

  @override
  Widget build(BuildContext context) {
    return TextFormField(
      cursorColor: Colors.blue[300],
      decoration: InputDecoration(
        isCollapsed: true,
        fillColor: Colors.blue[200]?.withOpacity(0.05),
        contentPadding:
            const EdgeInsets.symmetric(vertical: 15.0, horizontal: 10),
        filled: true,
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(5),
          borderSide: const BorderSide(width: 0.8),
        ),
        enabledBorder: OutlineInputBorder(
          borderSide: BorderSide(
            width: 0.8,
            color: Colors.blue[300]!,
          ),
        ),
        labelText: labelText,
      ),
      controller: titleController,
      validator: validator,
    );
  }
}
