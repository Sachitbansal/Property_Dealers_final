import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import '../widgets.dart';

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

  late List buyRent = ['', 'Any'];
  late List bedRooms = ['','None'];
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
      }).then((value) => {
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(
                content: Text('Added Successfully'),
              ),
            ),
          });
    }

    return Scaffold(
      appBar: AppBar(
        title: const Text('Add'),
        centerTitle: true,
      ),
      body: SingleChildScrollView(
        child: Form(
          key: _formKey,
          child: Column(
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceAround,
                children: [
                  Select(
                    onPressed: () {
                      setState(() {
                        buyRent[0] = 'Buy';
                      });
                    },
                    bgColor: buyRent[0] == 'Buy'
                          ? kActiveCardColour
                          : kInactiveCardColour,
                    text: 'Buy',
                  ),
                  Select(
                    text: 'Rent',
                    onPressed: () {
                      setState(() {
                        buyRent[0] = 'Rent';
                      });
                    },
                    bgColor: buyRent[0] == 'Rent'
                        ? kActiveCardColour
                        : kInactiveCardColour,
                  ),
                ],
              ),
              const Text('Title'),
              TextFormField(
                decoration: const InputDecoration(hintText: 'Title'),
                controller: titleController,
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Please Enter a Title';
                  }
                  return null;
                },
              ),
              const Text('Property Type'),
              Row(
                children: [
                  Select(
                    text: 'House',
                    bgColor: type == 'House'
                        ? kActiveCardColour
                        : kInactiveCardColour,
                    onPressed: () {
                      setState(() {
                        type = 'House';
                      });
                    },
                  ),
                  Select(
                    text: 'Flat',
                    bgColor: type == 'Flat'
                        ? kActiveCardColour
                        : kInactiveCardColour,
                    onPressed: () {
                      setState(() {
                        type = 'Flat';
                      });
                    },
                  ),
                  Select(
                    text: 'Room',
                    bgColor: type == 'Room'
                        ? kActiveCardColour
                        : kInactiveCardColour,
                    onPressed: () {
                      setState(() {
                        type = 'Room';
                      });
                    },
                  ),
                  Select(
                    text: 'Land',
                    bgColor: type == 'Land'
                        ? kActiveCardColour
                        : kInactiveCardColour,
                    onPressed: () {
                      setState(() {
                        type = 'Land';
                      });
                    },
                  ),
                ],
              ),
              const Text('Price Range'),
              TextFormField(
                decoration: const InputDecoration(hintText: 'e.g 100000'),
                controller: priceController,
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Please Enter a desired price';
                  }
                  return null;
                },
              ),
              const Text('Bedrooms'),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceAround,
                children: [
                  Select(
                    text: '1',
                    bgColor: bedRooms[0] == '1'
                        ? kActiveCardColour
                        : kInactiveCardColour,
                    onPressed: () {
                      setState(() {
                        bedRooms[0] = '1';
                      });
                    },
                  ),
                  Select(
                    text: '2',
                    bgColor: bedRooms[0] == '2'
                        ? kActiveCardColour
                        : kInactiveCardColour,
                    onPressed: () {
                      setState(() {
                        bedRooms[0] = '2';
                      });
                    },
                  ),
                  Select(
                    text: '3',
                    bgColor: bedRooms[0] == '3'
                        ? kActiveCardColour
                        : kInactiveCardColour,
                    onPressed: () {
                      setState(() {
                        bedRooms[0] = '3';
                      });
                    },
                  ),
                  Select(
                    text: '4',
                    bgColor: bedRooms[0] == '4'
                        ? kActiveCardColour
                        : kInactiveCardColour,
                    onPressed: () {
                      setState(() {
                        bedRooms[0] = '4';
                      });
                    },
                  ),
                  Select(
                    text: '4+',
                    bgColor: bedRooms[0] == '4+'
                        ? kActiveCardColour
                        : kInactiveCardColour,
                    onPressed: () {
                      setState(() {
                        bedRooms[0] = '4+';
                      });
                    },
                  ),
                ],
              ),
              const Text('Bathrooms'),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceAround,
                children: [
                  Select(
                    text: '1',
                    bgColor: bathRooms[0] == '1'
                        ? kActiveCardColour
                        : kInactiveCardColour,
                    onPressed: () {
                      setState(() {
                        bathRooms[0] = '1';
                      });
                    },
                  ),
                  Select(
                    text: '2',
                    bgColor: bathRooms[0] == '2'
                        ? kActiveCardColour
                        : kInactiveCardColour,
                    onPressed: () {
                      setState(() {
                        bathRooms[0] = '2';
                      });
                    },
                  ),
                  Select(
                    text: '3',
                    bgColor: bathRooms[0] == '3'
                        ? kActiveCardColour
                        : kInactiveCardColour,
                    onPressed: () {
                      setState(() {
                        bathRooms[0] = '3';
                      });
                    },
                  ),
                  Select(
                    text: '4',
                    bgColor: bathRooms[0] == '4'
                        ? kActiveCardColour
                        : kInactiveCardColour,
                    onPressed: () {
                      setState(() {
                        bathRooms[0] = '4';
                      });
                    },
                  ),
                  Select(
                    text: '4+',
                    bgColor: bathRooms[0] == '4+'
                        ? kActiveCardColour
                        : kInactiveCardColour,
                    onPressed: () {
                      setState(() {
                        bathRooms[0] = '4+';
                      });
                    },
                  ),
                ],
              ),
              const Text('Minimum Land size'),
              TextFormField(
                decoration: const InputDecoration(hintText: 'e.g 500'),
                controller: landSizeController,
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Please Enter Minimum Land Size';
                  }
                  return null;
                },
              ),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceAround,
                children: [
                  Select(
                    text: 'm²',
                    bgColor: sizeUnit == 'm²'
                        ? kActiveCardColour
                        : kInactiveCardColour,
                    onPressed: () {
                      setState(() {
                        sizeUnit = 'm²';
                      });
                    },
                  ),
                  Select(
                    text: 'Acres',
                    bgColor: sizeUnit == 'Acres'
                        ? kActiveCardColour
                        : kInactiveCardColour,
                    onPressed: () {
                      setState(() {
                        sizeUnit = 'Acres';
                      });
                    },
                  ),
                  Select(
                    text: 'Hectares',
                    bgColor: sizeUnit == 'Hectares'
                        ? kActiveCardColour
                        : kInactiveCardColour,
                    onPressed: () {
                      setState(() {
                        sizeUnit = 'Hectares';
                      });
                    },
                  ),
                ],
              ),
              const Text('Construction Status'),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceAround,
                children: [
                  Select(
                    text: 'Any',
                    bgColor: construction == 'Any'
                        ? kActiveCardColour
                        : kInactiveCardColour,
                    onPressed: () {
                      setState(() {
                        construction = 'Any';
                      });
                    },
                  ),
                  Select(
                    text: 'New',
                    bgColor: construction == 'New'
                        ? kActiveCardColour
                        : kInactiveCardColour,
                    onPressed: () {
                      setState(() {
                        construction = 'New';
                      });
                    },
                  ),
                  Select(
                    text: 'Established',
                    bgColor: construction == 'Established'
                        ? kActiveCardColour
                        : kInactiveCardColour,
                    onPressed: () {
                      setState(() {
                        construction = 'Established';
                      });
                    },
                  ),
                ],
              ),
              const Text('Keywords (separated by comma)'),
              TextFormField(
                decoration:
                    const InputDecoration(hintText: 'e.g Pool, Parking'),
                controller: keywordsController,
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Please Enter Email';
                  }
                  return null;
                },
              ),
              const Text('Address Of Property'),
              TextFormField(
                decoration: const InputDecoration(hintText: 'address'),
                controller: addressController,
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Please Enter Email';
                  }
                  return null;
                },
              ),
              const Text('Contact Details'),
              const Text('Name'),
              TextFormField(
                decoration: const InputDecoration(hintText: 'Name'),
                controller: nameController,
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Please Enter Email';
                  }
                },
              ),
              const Text('Number'),
              TextFormField(
                decoration: const InputDecoration(hintText: 'Number'),
                controller: numberController,
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Please Enter Email';
                  }
                  return null;
                },
              ),
              TextButton(
                style: ButtonStyle(
                    backgroundColor:
                        MaterialStateProperty.all<Color>(Colors.blue[100]!)),
                child: const Text('Upload To Firebase'),
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
    );
  }
}
