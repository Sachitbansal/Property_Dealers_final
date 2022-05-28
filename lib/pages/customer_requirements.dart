import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:untitled/widgets.dart';

import 'contacts.dart';

class AddCustomerRequirements extends StatefulWidget {
  const AddCustomerRequirements({Key? key}) : super(key: key);

  @override
  State<AddCustomerRequirements> createState() =>
      _AddCustomerRequirementsState();
}

class _AddCustomerRequirementsState extends State<AddCustomerRequirements> {
  final _formKey = GlobalKey<FormState>();
  Color? kActiveColor = Colors.blue[200];
  Color? kInActiveColor = Colors.blue[200]?.withOpacity(0.05);

  late String sizeUnit = 'None';
  late String type = 'None';
  late String facing = 'North';

  final titleController = TextEditingController();
  final nameController = TextEditingController();
  final numberController = TextEditingController();
  final landSizeLowerController = TextEditingController();
  final landSizeUpperController = TextEditingController();
  final priceLowerController = TextEditingController();
  final priceUpperController = TextEditingController();

  @override
  void dispose() {
    nameController.dispose();
    landSizeLowerController.dispose();
    landSizeUpperController.dispose();
    numberController.dispose();
    titleController.dispose();
    priceLowerController.dispose();
    priceUpperController.dispose();
    super.dispose();
  }

  showSnackBar(String snackText, Duration d) {
    final snackBar = SnackBar(content: Text(snackText), duration: d);
    ScaffoldMessenger.of(context).showSnackBar(snackBar);
  }

  Future<void> addCustomer() async {
    List docIdList = [];

    final String colId = FirebaseAuth.instance.currentUser!.uid;

    CollectionReference CustomerDestination = FirebaseFirestore.instance
        .collection(colId)
        .doc('CustomerData')
        .collection('CustomerData');

    CustomerDestination.add({
      'docIdList': docIdList,
      'name': nameController.text,
      'phone': numberController.text,
      'priceLower': priceLowerController.text,
      'priceUpper': priceUpperController.text,
      'sizeLower': landSizeLowerController.text,
      'sizeUpper': landSizeUpperController.text,
      'sizeUnit': sizeUnit,
      'type': type,
    }).whenComplete(() => showSnackBar('Added', Duration(seconds: 2)));
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
        title: const Text('Customer Requirements'),
      ),
      body: Form(
        key: _formKey,
        child: SingleChildScrollView(
          child: Padding(
            padding: const EdgeInsets.all(10.0),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.start,
              children: [
                FilterTitle(
                  title: 'Name',
                ),
                RoundedInputField(
                  obscureText: false,
                  onChanged: (value) {},
                  controller: nameController,
                  label: 'Name',
                ),
                FilterTitle(
                  title: 'Contact',
                ),
                RoundedInputField(
                  obscureText: false,
                  onChanged: (value) {},
                  controller: numberController,
                  label: 'Contact',
                  keyboardtype: TextInputType.phone,
                ),
                SizedBox(height: 10,),
                RoundedButton(getContact, 'Choose Contact', Colors.white, Colors.blue[300]!),
                FilterTitle(
                  title: 'Price',
                ),
                RoundedInputField(
                  obscureText: false,
                  onChanged: (value) {},
                  controller: priceLowerController,
                  label: 'Low Limit',
                  keyboardtype: TextInputType.phone,
                ),
                RoundedInputField(
                  obscureText: false,
                  onChanged: (value) {},
                  controller: priceUpperController,
                  label: 'Upper Limit',
                  keyboardtype: TextInputType.phone,
                ),
                FilterTitle(
                  title: 'Area',
                ),
                RoundedInputField(
                  obscureText: false,
                  onChanged: (value) {},
                  controller: landSizeLowerController,
                  label: 'lower limit',
                  keyboardtype: TextInputType.phone,
                ),
                RoundedInputField(
                  obscureText: false,
                  onChanged: (value) {},
                  controller: landSizeUpperController,
                  label: 'upper limit',
                  keyboardtype: TextInputType.phone,
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
                      bgColor: sizeUnit == 'm²' ? kActiveColor : kInActiveColor,
                      fontColor: sizeUnit == 'm²' ? Colors.white : kActiveColor,
                    ),
                    ButtonWithText(
                      onTap: () {
                        setState(() {
                          sizeUnit = 'Acres';
                        });
                      },
                      size: 80,
                      title: 'Acres',
                      bgColor:
                          sizeUnit == 'Acres' ? kActiveColor : kInActiveColor,
                      fontColor:
                          sizeUnit == 'Acres' ? Colors.white : kActiveColor,
                    ),
                    ButtonWithText(
                      onTap: () {
                        setState(() {
                          sizeUnit = 'Yards²';
                        });
                      },
                      size: 100,
                      title: 'Yards²',
                      bgColor:
                          sizeUnit == 'Yards²' ? kActiveColor : kInActiveColor,
                      fontColor:
                          sizeUnit == 'Yards²' ? Colors.white : kActiveColor,
                    ),
                    ButtonWithText(
                      onTap: () {
                        setState(() {
                          sizeUnit = 'Feet²';
                        });
                      },
                      size: 90,
                      title: 'Feet²',
                      bgColor:
                          sizeUnit == 'Feet²' ? kActiveColor : kInActiveColor,
                      fontColor:
                          sizeUnit == 'Feet²' ? Colors.white : kActiveColor,
                    ),
                    ButtonWithText(
                      onTap: () {
                        setState(() {
                          sizeUnit = 'biswa';
                        });
                      },
                      size: 90,
                      title: 'biswa',
                      bgColor:
                          sizeUnit == 'biswa' ? kActiveColor : kInActiveColor,
                      fontColor:
                          sizeUnit == 'biswa' ? Colors.white : kActiveColor,
                    ),
                    ButtonWithText(
                      onTap: () {
                        setState(() {
                          sizeUnit = 'marla';
                        });
                      },
                      size: 90,
                      title: 'marla',
                      bgColor:
                          sizeUnit == 'marla' ? kActiveColor : kInActiveColor,
                      fontColor:
                          sizeUnit == 'marla' ? Colors.white : kActiveColor,
                    ),
                  ],
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
                RoundedButton(
                    addCustomer, 'Add Customer', Colors.white, kActiveColor!)
              ],
            ),
          ),
        ),
      ),
    );
  }
}
