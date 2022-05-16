import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import '../widgets.dart';
import 'home_page.dart';

class SignUp extends StatefulWidget {
  const SignUp({Key? key}) : super(key: key);

  @override
  _SignUpState createState() => _SignUpState();
}

class _SignUpState extends State<SignUp> {
  bool passVisible = true;
  bool fPassVisible = true;
  late String email;
  late String fPassword;
  late String pass;
  final auth = FirebaseAuth.instance;
  bool isLoggedIn = false;
  final emailController = TextEditingController();
  final passwordController = TextEditingController();
  final fPasswordController = TextEditingController();
  final _formKey = GlobalKey<FormState>();

  @override
  void dispose() {
    // Clean up the controller when the widget is disposed.
    emailController.dispose();
    passwordController.dispose();
    fPasswordController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final Size size = MediaQuery.of(context).size;

    Future<void> signUp() async {
      try {
        await auth.createUserWithEmailAndPassword(
            email: email, password: fPassword);
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => HomePage(
              uid: FirebaseAuth.instance.currentUser?.uid,
            ),
          ),
        );

        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('You are now Signed in'),
          ),
        );
      } on FirebaseAuthException catch (e) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Failed with error code: ${e.code}'),
          ),
        );
      }
    }

    return Scaffold(
      body: SafeArea(
        child: Form(
          key: _formKey,
          child: SingleChildScrollView(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                Padding(
                  padding: EdgeInsets.fromLTRB(20, size.height * .05, 20, 0),
                  child: const Text(
                    'Client Data Management for Real Estate',
                    style: TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 18,
                        color: Colors.blue),
                  ),
                ),
                SizedBox(height: size.height * .01),
                Hero(
                  tag: 'BG Image',
                  child: Image.asset(
                    'assets/bg.png',
                    width: MediaQuery.of(context).size.width,
                    alignment: Alignment.center,
                  ),
                ),
                const Text(
                  'New User ',
                  style: TextStyle(
                    fontSize: 15,
                  ),
                ),
                SizedBox(
                  height: size.height * .01,
                ),
                SizedBox(
                  width: size.width * .9,
                  child: TextFormField(
                    cursorColor: Colors.blue[800],
                    decoration: InputDecoration(
                      fillColor: Colors.blue[50],
                      contentPadding:
                          const EdgeInsets.symmetric(vertical: 15.0),
                      filled: true,
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(30.0),
                        borderSide: const BorderSide(width: 0.8),
                      ),
                      enabledBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(30.0),
                        borderSide: BorderSide(
                          width: 0.8,
                          color: Theme.of(context).primaryColor,
                        ),
                      ),
                      hintText: 'ID',
                      labelText: 'Email ID',
                      prefixIcon: Icon(
                        Icons.account_circle,
                        color: Theme.of(context).primaryColor,
                        // size: 30.0,
                      ),
                    ),
                    controller: emailController,
                    keyboardType: TextInputType.emailAddress,
                    validator: (value) {
                      if (value == null || value.isEmpty) {
                        return 'Please Enter an Email';
                      }
                      if (!RegExp("^[a-zA-Z0-9+_.-]+@[a-zA-Z0-9.-]+.[a-z]")
                          .hasMatch(value)) {
                        return 'Please Enter a Valid Email';
                      }
                    },
                  ),
                ),
                SizedBox(
                  height: size.height * .02,
                ),
                SizedBox(
                  width: size.width * .9,
                  child: TextFormField(
                    onChanged: (value) {
                      setState(() {
                        pass = value.trim();
                      });
                    },
                    validator: (val) =>
                        val!.length < 6 ? 'Password too short.' : null,
                    obscureText: passVisible,
                    controller: passwordController,
                    keyboardType: TextInputType.visiblePassword,
                    cursorColor: Colors.blue[800],
                    decoration: InputDecoration(
                      fillColor: Colors.blue[50],
                      contentPadding:
                          const EdgeInsets.symmetric(vertical: 15.0),
                      filled: true,
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(30.0),
                        borderSide: const BorderSide(width: 0.8),
                      ),
                      enabledBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(30.0),
                        borderSide:
                            const BorderSide(width: 0.9, color: Colors.blue),
                      ),
                      hintText: 'Enter Password',
                      labelText: 'Password',
                      suffixIcon: IconButton(
                        icon: Icon(
                          passVisible ? Icons.visibility : Icons.visibility_off,
                        ),
                        color: Colors.blue,
                        onPressed: () {
                          setState(() {
                            passVisible = !passVisible;
                          });
                        },
                      ),
                      prefixIcon: const Icon(
                        Icons.lock,
                        color: Colors.blue,
                        // size: 30.0,
                      ),
                    ),
                  ),
                ),
                SizedBox(
                  height: MediaQuery.of(context).size.height * 0.02,
                ),
                SizedBox(
                  width: size.width * .9,
                  child: TextFormField(
                    validator: (value) {
                      if (value == null || value.isEmpty) {
                        return 'Please confirm the password';
                      }
                      if (value != pass) {
                        return 'Passwords do not match ';
                      }
                    },
                    controller: fPasswordController,
                    obscureText: fPassVisible,
                    cursorColor: Colors.blue[800],
                    decoration: InputDecoration(
                      fillColor: Colors.blue[50],
                      contentPadding:
                          const EdgeInsets.symmetric(vertical: 15.0),
                      filled: true,
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(30.0),
                        borderSide: const BorderSide(width: 0.8),
                      ),
                      enabledBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(30.0),
                        borderSide:
                            const BorderSide(width: 0.9, color: Colors.blue),
                      ),
                      hintText: 'Re-Type Password',
                      labelText: 'Confirm Password',
                      suffixIcon: IconButton(
                        icon: Icon(
                          fPassVisible
                              ? Icons.visibility
                              : Icons.visibility_off,
                        ),
                        color: Colors.blue,
                        onPressed: () {
                          setState(() {
                            fPassVisible = !fPassVisible;
                          });
                        },
                      ),
                      prefixIcon: const Icon(
                        Icons.lock,
                        color: Colors.blue,
                        // size: 30.0,
                      ),
                    ),
                  ),
                ),
                Container(
                  margin: const EdgeInsets.symmetric(vertical: 10),
                  child: RoundedButton(() {
                    if (_formKey.currentState!.validate()) {
                      setState(() {
                        email = emailController.text;
                        fPassword = fPasswordController.text;
                        signUp();
                      });
                    }
                  }, 'Sign Up', Colors.white, Theme.of(context).primaryColor),
                ),
                SizedBox(
                  height: size.width * .05,
                ),
                GestureDetector(
                  onTap: () => Navigator.pop(context),
                  child: const Text(
                    'Already have an account ? Login Now',
                    style: TextStyle(
                        fontSize: 15,
                        fontWeight: FontWeight.bold,
                        color: Colors.blue),
                  ),
                ),
                SizedBox(
                  height: size.height * .115,
                ),
                const Text(
                  'SBSSdigital Automation Solutions © 2021',
                  style: TextStyle(
                    color: Colors.grey,
                  ),
                ),
                const Text(
                  'Version 1.0',
                  style: TextStyle(
                    color: Colors.grey,
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
