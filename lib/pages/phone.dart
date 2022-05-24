import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:untitled/widgets.dart';

import 'home.dart';

class Phone extends StatefulWidget {
  const Phone({Key? key, required this.uid}) : super(key: key);
  final String uid;

  @override
  State<Phone> createState() => _PhoneState();
}

class _PhoneState extends State<Phone> {
  final phoneController = TextEditingController();
  bool isPhoneAdded = false;

  @override
  void initState() {
    super.initState();
      checkIfDocExists();
  }

  @override
  void dispose() {
    phoneController.dispose();
    super.dispose();
  }

  Future checkIfDocExists() async {
    try {
      // Get reference to Firestore collection
      var collectionRef = FirebaseFirestore.instance.collection('UserPhone');

      var doc =
          await collectionRef.doc(widget.uid).get();
      setState(() => isPhoneAdded = doc.exists);
      print(isPhoneAdded);
      print('isPhoneAdded');
    } catch (e) {
      throw e;
    }
  }

  Future<void> addPhone() async {
    if (phoneController.text.length == 10) {
      CollectionReference students =
          FirebaseFirestore.instance.collection('UserPhone');
      students
          .doc(widget.uid)
          .set({'phone': phoneController.text}).whenComplete(() {
        Navigator.push(
          context,
          CustomPageRoute(
            child: Home(
              uid: widget.uid,
            ),
          ),
        );
      });
    } else {
      ScaffoldMessenger.of(context)
          .showSnackBar(SnackBar(content: Text('Enter Valid Phone Number')));
    }
  }

  @override
  Widget build(BuildContext context) => isPhoneAdded
      ? Home(uid: widget.uid)
      : Scaffold(
          appBar: AppBar(
            title: const Text('Add Phone Number'),
            automaticallyImplyLeading: false,
            centerTitle: true,
          ),
          body: Padding(
            padding: const EdgeInsets.all(10),
            child: Column(
              children: [
                RoundedInputField(
                  controller: phoneController,
                  obscureText: false,
                  onChanged: (value) {},
                  hint: 'Phone',
                  label: 'Phone Number',
                  iconChoose: Icons.call,
                  keyboardtype: TextInputType.phone,
                ),
                SizedBox(
                  height: 10,
                ),
                RoundedButton(addPhone, 'Add', Colors.white,
                    Theme.of(context).primaryColor)
              ],
            ),
          ),
        );
}
