import 'dart:async';

import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:untitled/pages/home.dart';

import '../widgets.dart';

class EmailVerification extends StatefulWidget {
  const EmailVerification({Key? key}) : super(key: key);

  @override
  State<EmailVerification> createState() => _EmailVerificationState();
}

class _EmailVerificationState extends State<EmailVerification> {
  bool isEmailVerified = false;
  Timer? timer;
  bool resendEmail = false;

  @override
  void initState() {
    super.initState();

    isEmailVerified = FirebaseAuth.instance.currentUser!.emailVerified;

    if (!isEmailVerified) {
      sendVerification();

      timer = Timer.periodic(
        const Duration(seconds: 3),
        (_) {
          print(_.tick.toString());
          checkEmailVerified();
        },
      );
    }
  }

  Future checkEmailVerified() async {
    await FirebaseAuth.instance.currentUser!.reload();

    setState(() {
      isEmailVerified = FirebaseAuth.instance.currentUser!.emailVerified;
    });

    if (isEmailVerified) timer?.cancel();
  }

  Future sendVerification() async {
    try {
      final user = FirebaseAuth.instance.currentUser;
      await user?.sendEmailVerification().whenComplete(() {
        const snackBar = SnackBar(
            content: Text('Email Verification Sent'),
            duration: Duration(milliseconds: 1000));
        ScaffoldMessenger.of(context).showSnackBar(snackBar);
      });

      setState(() => resendEmail = false);
      await Future.delayed(const Duration(seconds: 7));
      setState(() => resendEmail = true);
    } catch (e) {
      final snackBar = SnackBar(
          content: Text(e.toString()),
          duration: const Duration(milliseconds: 1000));
      ScaffoldMessenger.of(context).showSnackBar(snackBar);
    }
  }

  @override
  Widget build(BuildContext context) => isEmailVerified
      ? Home(
          uid: FirebaseAuth.instance.currentUser?.uid,
        )
      : Scaffold(
          backgroundColor: Colors.white,
          body: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 10),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Image.network(
                    'https://downloader.la/temp/[Downloader.la]-6284a5afc8331.jpg'),
                const Text(
                  'Please Verify Your Email Using the Link Sent To Your Email Id',
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    fontSize: 20,
                  ),
                ),
                const SizedBox(
                  height: 20,
                ),
                RoundedButton(
                  resendEmail
                      ? sendVerification
                      : () {
                          ScaffoldMessenger.of(context).showSnackBar(
                            const SnackBar(
                              content: Text('Please Wait'),
                              duration: Duration(seconds: 1),
                            ),
                          );
                        },
                  'Resend Email',
                  Colors.white,
                  Theme.of(context).primaryColor,
                ),
                const SizedBox(
                  height: 20,
                ),
                RoundedButton(
                  () {
                    FirebaseAuth.instance.signOut();
                    Navigator.pop(context);
                  },
                  'Cancel',
                  Colors.white,
                  Theme.of(context).primaryColor,
                ),
              ],
            ),
          ),
        );
}
