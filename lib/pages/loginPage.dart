import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:untitled/pages/correct_signup.dart';
import 'package:untitled/pages/email_verificaition.dart';
import 'package:untitled/pages/reset_pass.dart';
import '../widgets.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({Key? key}) : super(key: key);

  @override
  _LoginScreenState createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  bool passVisible = true;
  late String email;
  late String pass;
  final auth = FirebaseAuth.instance;
  bool isLoggedIn = false;
  final emailController = TextEditingController();
  final passwordController = TextEditingController();
  final _formKey = GlobalKey<FormState>();

  @override
  void dispose() {
    // Clean up the controller when the widget is disposed.
    emailController.dispose();
    passwordController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final Size size = MediaQuery.of(context).size;

    Future<void> login() async {
      try {
        await auth.signInWithEmailAndPassword(email: email, password: pass);
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => const EmailVerification(),
          ),
        );
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('You are now logged in'),
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
                  'Existing User ',
                  style: TextStyle(
                    fontSize: 15,
                  ),
                ),
                SizedBox(
                  height: size.height * .01,
                ),
                SizedBox(
                  width: size.width * .9,
                  child: Column(
                    children: [
                      TextFormField(
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
                          return null;
                        },
                      ),
                      SizedBox(
                        height: size.height * .02,
                      ),
                      TextFormField(
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
                            borderSide: BorderSide(
                              width: 0.8,
                              color: Theme.of(context).primaryColor,
                            ),
                          ),
                          hintText: 'Enter Password',
                          labelText: 'Password',
                          suffixIcon: IconButton(
                            icon: Icon(
                              passVisible
                                  ? Icons.visibility
                                  : Icons.visibility_off,
                            ),
                            color: Theme.of(context).primaryColor,
                            onPressed: () {
                              setState(() {
                                passVisible = !passVisible;
                              });
                            },
                          ),
                          prefixIcon: Icon(
                            Icons.lock,
                            color: Theme.of(context).primaryColor,
                            // size: 30.0,
                          ),
                        ),
                      ),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.end,
                        children: [
                          GestureDetector(
                            onTap: () {
                              Navigator.push(
                                context,
                                MaterialPageRoute(
                                  builder: (context) => const ResetPassword(),
                                ),
                              );
                            },
                            child: const Text(
                              'Reset password ?',
                              style: TextStyle(color: Colors.blue),
                            ),
                          )
                        ],
                      ),
                    ],
                  ),
                ),
                Container(
                  margin: const EdgeInsets.symmetric(vertical: 10),
                  child: RoundedButton(() {
                    if (_formKey.currentState!.validate()) {
                      setState(() {
                        email = emailController.text;
                        pass = passwordController.text;
                        login();
                      });
                    }
                  }, 'Login', Colors.white, Theme.of(context).primaryColor),
                ),
                Column(
                  children: [
                    const OrDivider(),
                    GestureDetector(
                      onTap: () async {
                        // Trigger the authentication flow
                        final GoogleSignInAccount? googleUser =
                            await GoogleSignIn().signIn();
                        // Obtain the auth details from the request
                        final GoogleSignInAuthentication? googleAuth =
                            await googleUser?.authentication;

                        auth
                            .signInWithCredential(
                          GoogleAuthProvider.credential(
                            accessToken: googleAuth?.accessToken,
                            idToken: googleAuth?.idToken,
                          ),
                        )
                            .whenComplete(
                          () {
                            ScaffoldMessenger.of(context).showSnackBar(
                              const SnackBar(
                                content: Text('Logged in'),
                              ),
                            );
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (context) => const EmailVerification()
                              ),
                            );
                          },
                        );
                      },
                      child: Container(
                        padding: const EdgeInsets.symmetric(vertical: 10),
                        margin: const EdgeInsets.symmetric(horizontal: 25),
                        decoration: BoxDecoration(
                          borderRadius:
                              const BorderRadius.all(Radius.circular(20)),
                          border: Border.all(color: Colors.blue),
                          boxShadow: const [
                            BoxShadow(
                              color: Colors.white,
                              offset: Offset(0.0, 1.0), //(x,y),
                            ),
                          ],
                        ),
                        child: Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 20),
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Image.network(
                                'https://i.ibb.co/NK8qZhq/google.png',
                                height: 32,
                              ),
                              Expanded(
                                child: Row(
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  children: const [
                                    Text(
                                      'Login with Google',
                                      maxLines: 1,
                                      overflow: TextOverflow.ellipsis,
                                      style: TextStyle(
                                          fontSize: 20,
                                          fontWeight: FontWeight.w500),
                                    ),
                                  ],
                                ),
                              ),
                              const Opacity(
                                opacity: 0,
                                child: Icon(
                                  FontAwesomeIcons.google,
                                  size: 35,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
                SizedBox(
                  height: size.width * .05,
                ),
                GestureDetector(
                  onTap: () => Navigator.push(
                    context,
                    CustomPageRoute(
                      child: const SignUp(),
                    ),
                  ),
                  child: const Text(
                    'Don\'t have an account ? Sign Up Now',
                    style: TextStyle(
                        fontSize: 15,
                        fontWeight: FontWeight.bold,
                        color: Colors.blue),
                  ),
                ),
                SizedBox(
                  height: size.height * .05,
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
