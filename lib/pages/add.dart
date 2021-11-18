import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import '../widgets.dart';

class Add extends StatefulWidget {
  const Add({Key? key, this.collection}) : super(key: key);
  final String? collection;

  @override
  _AddState createState() => _AddState();
}

class _AddState extends State<Add> {
  MaterialStateProperty<Color> kActiveCardColour =
      MaterialStateProperty.all<Color>(Colors.blue[100]!);
  MaterialStateProperty<Color> kInactiveCardColour =
      MaterialStateProperty.all<Color>(Colors.transparent);

  RangeValues _currentRangeValues = const RangeValues(0, 100);

  final _formKey = GlobalKey<FormState>();

  late String buyRent = 'None';
  late String bedRooms = 'None';
  late String bathRooms = 'None';
  late String sizeUnit = 'None';
  late String construction = 'None';
  late String type = 'None';

  late String landSize = 'None';
  late String keywords = 'None';
  late String address = 'None';
  late String name = 'None';
  late String number = 'None';

  final landSizeController = TextEditingController();
  final keywordsController = TextEditingController();
  final addressController = TextEditingController();
  final nameController = TextEditingController();
  final numberController = TextEditingController();

  @override
  void dispose() {
    nameController.dispose();
    landSizeController.dispose();
    keywordsController.dispose();
    addressController.dispose();
    numberController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    CollectionReference students =
        FirebaseFirestore.instance.collection(widget.collection.toString());

    Future<void> addUser() {
      return students
          .add({
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
            'types': type
          })
          .then(
            (value) => ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(
                content: Text('Added Successfully'),
              ),
            ),
          )
          .catchError(
            (error) => ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text('Failed: {$error}'),
              ),
            ),
          );
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
                        buyRent = 'Buy';
                      });
                    },
                    bgColor: buyRent == 'Buy'
                        ? kActiveCardColour
                        : kInactiveCardColour,
                    text: 'Buy',
                  ),
                  Select(
                    text: 'Rent',
                    onPressed: () {
                      setState(() {
                        buyRent = 'Rent';
                      });
                    },
                    bgColor: buyRent == 'Rent'
                        ? kActiveCardColour
                        : kInactiveCardColour,
                  ),
                ],
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
                    text: 'Apartment',
                    bgColor: type == 'Apartment'
                        ? kActiveCardColour
                        : kInactiveCardColour,
                    onPressed: () {
                      setState(() {
                        type = 'Apartment';
                      });
                    },
                  ),
                  Select(
                    text: 'Villa',
                    bgColor: type == 'Villa'
                        ? kActiveCardColour
                        : kInactiveCardColour,
                    onPressed: () {
                      setState(() {
                        type = 'Villa';
                      });
                    },
                  ),
                ],
              ),
              Row(
                children: [
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
                  Select(
                    text: 'Blocks of Units',
                    bgColor: type == 'Blocks of Units'
                        ? kActiveCardColour
                        : kInactiveCardColour,
                    onPressed: () {
                      setState(() {
                        type = 'Blocks of Units';
                      });
                    },
                  ),
                ],
              ),
              const Text('Price Range'),
              RangeSlider(
                values: _currentRangeValues,
                min: 0,
                max: 100,
                divisions: 5,
                labels: RangeLabels(
                  _currentRangeValues.start.round().toString(),
                  _currentRangeValues.end.round().toString(),
                ),
                onChanged: (RangeValues values) {
                  setState(() {
                    _currentRangeValues = values;
                  });
                },
              ),
              const Text('Bedrooms'),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceAround,
                children: [
                  Select(
                    text: '1',
                    bgColor: bedRooms == '1'
                        ? kActiveCardColour
                        : kInactiveCardColour,
                    onPressed: () {
                      setState(() {
                        bedRooms = '1';
                      });
                    },
                  ),
                  Select(
                    text: '2',
                    bgColor: bedRooms == '2'
                        ? kActiveCardColour
                        : kInactiveCardColour,
                    onPressed: () {
                      setState(() {
                        bedRooms = '2';
                      });
                    },
                  ),
                  Select(
                    text: '3',
                    bgColor: bedRooms == '3'
                        ? kActiveCardColour
                        : kInactiveCardColour,
                    onPressed: () {
                      setState(() {
                        bedRooms = '3';
                      });
                    },
                  ),
                  Select(
                    text: '4',
                    bgColor: bedRooms == '4'
                        ? kActiveCardColour
                        : kInactiveCardColour,
                    onPressed: () {
                      setState(() {
                        bedRooms = '4';
                      });
                    },
                  ),
                  Select(
                    text: '4+',
                    bgColor: bedRooms == '4+'
                        ? kActiveCardColour
                        : kInactiveCardColour,
                    onPressed: () {
                      setState(() {
                        bedRooms = '4+';
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
                    bgColor: bathRooms == '1'
                        ? kActiveCardColour
                        : kInactiveCardColour,
                    onPressed: () {
                      setState(() {
                        bathRooms = '1';
                      });
                    },
                  ),
                  Select(
                    text: '2',
                    bgColor: bathRooms == '2'
                        ? kActiveCardColour
                        : kInactiveCardColour,
                    onPressed: () {
                      setState(() {
                        bathRooms = '2';
                      });
                    },
                  ),
                  Select(
                    text: '3',
                    bgColor: bathRooms == '3'
                        ? kActiveCardColour
                        : kInactiveCardColour,
                    onPressed: () {
                      setState(() {
                        bathRooms = '3';
                      });
                    },
                  ),
                  Select(
                    text: '4',
                    bgColor: bathRooms == '4'
                        ? kActiveCardColour
                        : kInactiveCardColour,
                    onPressed: () {
                      setState(() {
                        bathRooms = '4';
                      });
                    },
                  ),
                  Select(
                    text: '4+',
                    bgColor: bathRooms == '4+'
                        ? kActiveCardColour
                        : kInactiveCardColour,
                    onPressed: () {
                      setState(() {
                        bathRooms = '4+';
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
                    return 'Please Enter Email';
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
                      name = nameController.text;
                      landSize = landSizeController.text;
                      keywords = keywordsController.text;
                      address = addressController.text;
                      name = nameController.text;
                      number = numberController.text;
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
