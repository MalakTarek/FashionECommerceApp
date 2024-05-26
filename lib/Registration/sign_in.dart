import 'package:fashion_ecommerce/Products/products_page.dart';
import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class SignInPage extends StatelessWidget {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  Future<void> requestNotificationPermissions() async {
    NotificationSettings settings = await FirebaseMessaging.instance.requestPermission(
      alert: true,
      announcement: false,
      badge: true,
      carPlay: false,
      criticalAlert: false,
      provisional: false,
      sound: true,
    );

    print('User granted permission: ${settings.authorizationStatus}');
  }

  Future<void> signIn(BuildContext context, String email, String password) async {
    try {
      // Sign in user with email and password
      UserCredential userCredential = await _auth.signInWithEmailAndPassword(
        email: email,
        password: password,
      );

      // Retrieve FCM token
      String? fcmToken = await FirebaseMessaging.instance.getToken();

      // Update FCM token in Firestore
      if (userCredential.user != null && fcmToken != null) {
        await _firestore.collection('users').doc(userCredential.user!.uid).update({
          'fcmToken': fcmToken,
        });
      }

      // Request notification permissions
      await requestNotificationPermissions();

      // Show success dialog
      showDialog(
        context: context,
        builder: (BuildContext context) {
          return AlertDialog(
            title: Text('Success'),
            content: Text('Sign in successful!'),
            actions: [
              TextButton(
                onPressed: () {
                  Navigator.of(context).pop();
                  // Redirect to the products_page after closing the success dialog
                  Navigator.push(
                    context,
                    MaterialPageRoute(builder: (context) => const ProductsPage()),
                  );
                },
                child: Text('OK'),
              ),
            ],
          );
        },
      );
    } catch (error) {
      // Show error dialog
      String errorMessage = 'Failed to sign in. Please try again.';
      if (error is FirebaseAuthException) {
        if (error.code == 'user-not-found') {
          errorMessage = 'No user found with this email.';
        } else if (error.code == 'wrong-password') {
          errorMessage = 'Incorrect password.';
        }
      }
      showDialog(
        context: context,
        builder: (BuildContext context) {
          return AlertDialog(
            title: Text('Error'),
            content: Text(errorMessage),
            actions: [
              TextButton(
                onPressed: () {
                  Navigator.of(context).pop();
                },
                child: Text('OK'),
              ),
            ],
          );
        },
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Sign In'),
      ),
      body: SignInForm(signIn: signIn),
    );
  }
}

class SignInForm extends StatefulWidget {
  final Function(BuildContext context, String email, String password) signIn;

  SignInForm({required this.signIn});

  @override
  _SignInFormState createState() => _SignInFormState();
}

class _SignInFormState extends State<SignInForm> {
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.all(20.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          TextFormField(
            controller: _emailController,
            decoration: InputDecoration(labelText: 'Email'),
          ),
          TextFormField(
            controller: _passwordController,
            decoration: InputDecoration(labelText: 'Password'),
            obscureText: true,
          ),
          SizedBox(height: 20.0),
          ElevatedButton(
            onPressed: () {
              final email = _emailController.text.trim();
              final password = _passwordController.text;
              widget.signIn(context, email, password);
            },
            child: Text('Sign In'),
          ),
        ],
      ),
    );
  }
}