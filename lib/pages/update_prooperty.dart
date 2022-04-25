import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import '../widgets.dart';
import 'dart:io';

class UpdateProperty extends StatefulWidget {
  const UpdateProperty({Key? key, required this.collection, required this.id})
      : super(key: key);
  final String collection;
  final String id;

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

  List<XFile>? _image;
  final imagePicker = ImagePicker();
  List<String> downloadURL = [];
  List<String> urls = [];
  var isLoading = false;
  int uploadItem = 0;
  UploadTask? uploadTask;

  Future imagePickerMethod() async {
    final pick = await imagePicker.pickMultiImage();
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

  void uploadFunction(List<XFile> images) async {
    for (int i = 0; i < images.length; i++) {
      var imgUrl = await uploadFile(images[i]);
      urls.add(imgUrl.toString());
    }

    updateProperty().whenComplete(() {
      urls.clear();
    });
  }

  Future<void> updateProperty() async {
    CollectionReference students =
    FirebaseFirestore.instance.collection(widget.collection.toString());

    students
        .doc(widget.id)
        .update({
      'buyRent': buyRent,
      'bedRooms': bedRooms,
      'bathRooms': bathRooms,
      'sizeUnit': sizeUnit,
      'construction': construction,
      'landSize': landSize,
      'keywords': keywords,
      'address': address,
      'name': nameController.text,
      'number': number,
      'types': type,
      'Price': price,
      'title': title,
      'images': urls,
    })
        .then(
          (value) => showSnackBar(
        'Updated',
        const Duration(milliseconds: 1000),
      ),
    )
        .catchError(
          (error) => print("Failed to update user: $error"),
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

    });
    // print(await reference.getDownloadURL());
    return await reference.getDownloadURL();
  }


  @override
  Widget build(BuildContext context) {

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

    final Size size = MediaQuery.of(context).size;
    return Scaffold(
      appBar: AppBar(
        title: const Text('Update Property'),
      ),
      body: SingleChildScrollView(
        child: Form(
          key: _formKey,
          child: FutureBuilder<DocumentSnapshot<Map<String, dynamic>>>(
            future: FirebaseFirestore.instance
                .collection(widget.collection.toString())
                .doc(widget.id)
                .get(),
            builder: (_, snapshot) {
              if (snapshot.hasError) {
                print('Something Went Wrong');
              }
              if (snapshot.connectionState == ConnectionState.waiting) {
                return const Center(
                  child: CircularProgressIndicator(),
                );
              }

              var data = snapshot.data!.data();
              nameController.text = data!['name'];
              landSizeController.text = data['landSize'];
              keywordsController.text = data['keywords'];
              addressController.text = data['address'];
              numberController.text = data['number'];
              titleController.text = data['title'];
              priceController.text = data['Price'];

              // buyRent = data['buyRent'];
              // bedRooms = data['bedRooms'];
              // bathRooms = data['bathRooms'];
              // sizeUnit = data['sizeUnit'];
              // type = data['types'];
              // construction = data['construction'];

              final List imageUrls = data['images'];

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
                        ButtonWithText(
                          onTap: () {
                              buyRent[0] = 'Buy';
                          },
                          size: size.width * .40,
                          title: 'Buy',
                          bgColor: buyRent[0] == 'Buy'
                              ? kActiveColor
                              : kInActiveColor,
                          fontColor:
                              buyRent[0] == 'Buy' ? Colors.white : kActiveColor,
                        ),
                        ButtonWithText(
                          onTap: () {
                              buyRent[0] = 'Rent';
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
                                type = 'Flat';
                          },
                          bgColor:
                              type == 'Flat' ? kActiveColor : kInActiveColor,
                          icon: Icons.apartment,
                        ),
                        ButtonWithTextAndIcon(
                          textIconColor:
                              type == 'House' ? Colors.white : kActiveColor,
                          title: 'House',
                          onTap: () {
                              type = 'House';
                          },
                          bgColor:
                              type == 'House' ? kActiveColor : kInActiveColor,
                          icon: Icons.house,
                        ),
                        ButtonWithTextAndIcon(
                          textIconColor:
                              type == 'Room' ? Colors.white : kActiveColor,
                          title: 'Room',
                          onTap: () {
                              type = 'Room';
                          },
                          bgColor:
                              type == 'Room' ? kActiveColor : kInActiveColor,
                          icon: Icons.meeting_room,
                        ),
                        ButtonWithTextAndIcon(
                          textIconColor:
                              type == 'Land' ? Colors.white : kActiveColor,
                          title: 'Land',
                          onTap: () {
                              type = 'Land';
                          },
                          bgColor:
                              type == 'Land' ? kActiveColor : kInActiveColor,
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
                              bedRooms[0] = '1';
                          },
                          text: "1",
                          textColor:
                              bedRooms[0] == '1' ? Colors.white : kActiveColor,
                          bgColor: bedRooms[0] == '1'
                              ? kActiveColor
                              : kInActiveColor,
                        ),
                        buildOption(
                          onTap: () {
                              bedRooms[0] = '2';
                          },
                          text: "2",
                          textColor:
                              bedRooms[0] == '2' ? Colors.white : kActiveColor,
                          bgColor: bedRooms[0] == '2'
                              ? kActiveColor
                              : kInActiveColor,
                        ),
                        buildOption(
                          onTap: () {
                              bedRooms[0] = '3';
                          },
                          text: "3",
                          textColor:
                              bedRooms[0] == '3' ? Colors.white : kActiveColor,
                          bgColor: bedRooms[0] == '3'
                              ? kActiveColor
                              : kInActiveColor,
                        ),
                        buildOption(
                          onTap: () {
                              bedRooms[0] = '4';
                          },
                          text: "4",
                          textColor:
                              bedRooms[0] == '4' ? Colors.white : kActiveColor,
                          bgColor: bedRooms[0] == '4'
                              ? kActiveColor
                              : kInActiveColor,
                        ),
                        buildOption(
                          onTap: () {
                              bedRooms[0] = '4+';
                          },
                          text: "4+",
                          textColor:
                              bedRooms[0] == '4+' ? Colors.white : kActiveColor,
                          bgColor: bedRooms[0] == '4+'
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
                              bathRooms[0] = '1';
                          },
                          text: "1",
                          textColor:
                              bathRooms[0] == '1' ? Colors.white : kActiveColor,
                          bgColor: bathRooms[0] == '1'
                              ? kActiveColor
                              : kInActiveColor,
                        ),
                        buildOption(
                          onTap: () {
                              bathRooms[0] = '2';
                          },
                          text: "2",
                          textColor:
                              bathRooms[0] == '2' ? Colors.white : kActiveColor,
                          bgColor: bathRooms[0] == '2'
                              ? kActiveColor
                              : kInActiveColor,
                        ),
                        buildOption(
                          onTap: () {
                              bathRooms[0] = '3';
                          },
                          text: "3",
                          textColor:
                              bathRooms[0] == '3' ? Colors.white : kActiveColor,
                          bgColor: bathRooms[0] == '3'
                              ? kActiveColor
                              : kInActiveColor,
                        ),
                        buildOption(
                          onTap: () {
                              bathRooms[0] = '4';
                          },
                          text: "4",
                          textColor:
                              bathRooms[0] == '4' ? Colors.white : kActiveColor,
                          bgColor: bathRooms[0] == '4'
                              ? kActiveColor
                              : kInActiveColor,
                        ),
                        buildOption(
                          onTap: () {
                              bathRooms[0] = '4+';
                          },
                          text: "4+",
                          textColor: bathRooms[0] == '4+'
                              ? Colors.white
                              : kActiveColor,
                          bgColor: bathRooms[0] == '4+'
                              ? kActiveColor
                              : kInActiveColor,
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
                              sizeUnit = 'm²';
                          },
                          size: size.width * .20,
                          title: 'm²',
                          bgColor:
                              sizeUnit == 'm²' ? kActiveColor : kInActiveColor,
                          fontColor:
                              sizeUnit == 'm²' ? Colors.white : kActiveColor,
                        ),
                        ButtonWithText(
                          onTap: () {
                              sizeUnit = 'Acres';
                          },
                          size: size.width * .25,
                          title: 'Acres',
                          bgColor: sizeUnit == 'Acres'
                              ? kActiveColor
                              : kInActiveColor,
                          fontColor:
                              sizeUnit == 'Acres' ? Colors.white : kActiveColor,
                        ),
                        ButtonWithText(
                          onTap: () {
                              sizeUnit = 'Hectares';
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
                              construction = 'Any';
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
                              construction = 'New';
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
                              construction = 'Established';
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
                            backgroundColor: MaterialStateProperty.all<Color>(
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
                      child: const SizedBox(
                        height: 40,
                        // width: size.width * .8,
                        child: Center(
                          child: Text(
                            'Add',
                            style: TextStyle(color: Colors.white, fontSize: 20),
                          ),
                        ),
                      ),
                      onPressed: () {
                        if (_formKey.currentState!.validate() && _image != null) {
                            landSize = landSizeController.text;
                            keywords = keywordsController.text;
                            address = addressController.text;
                            // name = nameController.text;
                            number = numberController.text;
                            price = priceController.text;
                            title = titleController.text;

                            for (var url = 0; url < imageUrls.length; url++) {
                              FirebaseStorage.instance.refFromURL(imageUrls[url]).delete();
                            }

                            uploadFunction(_image!);
                        } else {
                          showSnackBar('Please Update Images Also', const Duration(milliseconds: 1000));
                        }
                      },
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
    );
  }
}
