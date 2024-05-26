import 'dart:async';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:fashion_ecommerce/Products/products_page.dart';
import 'package:fashion_ecommerce/Registration/sign_up.dart';
import 'package:fashion_ecommerce/Registration/sign_in.dart';
import 'package:fashion_ecommerce/Products/ViewProductsForNotLoggedInUsers.dart';
import 'package:fashion_ecommerce/Design/homepageDesign.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  try {
    await Firebase.initializeApp();

    // Initialize Firebase Messaging
    FirebaseMessaging messaging = FirebaseMessaging.instance;
    String? token = await messaging.getToken();
    print("FCM Token: $token");

    // Set token expiration to 2 hours from now
    await setTokenExpiration();

    // Check token expiration and run the app accordingly
    bool isSignedIn = await checkTokenExpiration();
    runApp(MyApp(isSignedIn: isSignedIn));
  } catch (e) {
    // Handle initialization error
    print('Error initializing Firebase: $e');
    runApp(const MyApp(isSignedIn: false));
  }
}

Future<void> setTokenExpiration() async {
  final prefs = await SharedPreferences.getInstance();
  DateTime expirationTime = DateTime.now().add(Duration(hours: 2));
  await prefs.setString('expirationTime', expirationTime.toIso8601String());
}

Future<bool> checkTokenExpiration() async {
  final prefs = await SharedPreferences.getInstance();
  String? expirationTimeString = prefs.getString('expirationTime');

  if (expirationTimeString == null) {
    return false;
  }

  DateTime expirationTime = DateTime.parse(expirationTimeString);

  if (expirationTime.isAfter(DateTime.now())) {
    return true;
  } else {
    await FirebaseAuth.instance.signOut();
    return false;
  }
}

class MyApp extends StatelessWidget {
  final bool isSignedIn;

  const MyApp({Key? key, required this.isSignedIn}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      theme: ThemeData(
        primarySwatch: Colors.blue,
        visualDensity: VisualDensity.adaptivePlatformDensity,
      ),
      home: ConnectivityHandler(
        child: isSignedIn ? const ProductsPage() : const HomePage(),
      ), // Conditional initial route
      routes: {
        '/signUp': (context) => SignUpPage(),
        '/signIn': (context) => SignInPage(),
        '/viewProducts': (context) => const ProductListScreenDesign(),
      },
    );
  }
}

class ConnectivityHandler extends StatefulWidget {
  final Widget child;

  const ConnectivityHandler({Key? key, required this.child}) : super(key: key);

  @override
  _ConnectivityHandlerState createState() => _ConnectivityHandlerState();
}

class _ConnectivityHandlerState extends State<ConnectivityHandler> {
  final Connectivity _connectivity = Connectivity();
  late StreamSubscription<ConnectivityResult> _subscription;
  bool _isAlertShown = false;

  @override
  void initState() {
    super.initState();
    _subscription = _connectivity.onConnectivityChanged.listen((result) {
      if (result == ConnectivityResult.none) {
        _showConnectionAlert();
      } else {
        _dismissConnectionAlert();
      }
    });
  }

  @override
  void dispose() {
    _subscription.cancel();
    super.dispose();
  }

  void _showConnectionAlert() {
    if (!_isAlertShown) {
      _isAlertShown = true;
      showDialog(
        context: context,
        barrierDismissible: false,
        builder: (context) => AlertDialog(
          title: const Text('Connection Error'),
          content: const Text('Unable to connect to the server. Please check your internet connection.'),
          actions: [
            TextButton(
              onPressed: () => _dismissConnectionAlert(),
              child: const Text('OK'),
            ),
          ],
        ),
      );
    }
  }

  void _dismissConnectionAlert() {
    if (_isAlertShown) {
      _isAlertShown = false;
      Navigator.of(context, rootNavigator: true).pop();
    }
  }

  @override
  Widget build(BuildContext context) {
    return widget.child;
  }
}

class HomePage extends StatelessWidget {
  const HomePage({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Fashion E-Commerce'),
      ),
      body: CustomDesign(),
    );
  }
}
