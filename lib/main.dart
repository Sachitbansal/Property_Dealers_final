import 'dart:async';
import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:google_mobile_ads/google_mobile_ads.dart';
import 'package:provider/provider.dart';
import 'package:untitled/addHelper.dart';
import 'package:untitled/pages/home.dart';
import 'package:untitled/pages/loginPage.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  MobileAds.instance.initialize();
  await Firebase.initializeApp();
  runApp(const MyApp());
}

class MyApp extends StatefulWidget {
  const MyApp({Key? key}) : super(key: key);

  @override
  State<MyApp> createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {
  final Future<FirebaseApp> _initialization = Firebase.initializeApp();
  late StreamSubscription<User?> user;
  ConnectivityResult _connectivityResult = ConnectivityResult.none;
  final Connectivity _connectivity = Connectivity();
  late StreamSubscription<ConnectivityResult> _streamSubscription;

  Future<void> initConnectivity() async {
    ConnectivityResult result = await _connectivity.checkConnectivity();

    if (!mounted) {
      return Future.value(null);
    }

    return _updateConnectionState(result);
  }

  Future<void> _updateConnectionState(ConnectivityResult result) async {
    setState(() => _connectivityResult = result);
  }

  @override
  void initState() {
    super.initState();
    initConnectivity();
    _streamSubscription =
        _connectivity.onConnectivityChanged.listen(_updateConnectionState);
    user = FirebaseAuth.instance.authStateChanges().listen((user) {});
  }

  @override
  void dispose() {
    user.cancel();
    _streamSubscription.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        ChangeNotifierProvider<AddProvider>(
          create: (context) => AddProvider(),
        )
      ],
      child: FutureBuilder(
        future: _initialization,
        builder: (context, snapshot) {
          // Check for Errors
          if (snapshot.hasError) {
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(
                content: Text('Something went wrong. Please try again later.'),
              ),
            );
          }
          // once Completed, show your application
          if (snapshot.connectionState == ConnectionState.done) {

            return MaterialApp(
              title: 'Flutter Firestore CRUD',
              theme: ThemeData(
                primarySwatch: Colors.blue,
              ),
              debugShowCheckedModeBanner: false,
              home: FirebaseAuth.instance.currentUser == null && _connectivityResult != ConnectivityResult.none
                  ? const LoginScreen()
                  : Home(
                      uid: FirebaseAuth.instance.currentUser?.uid,
                    ),
            );
          }
          return const CircularProgressIndicator();
        },
      ),
    );
  }
}
