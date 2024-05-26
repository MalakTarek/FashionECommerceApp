import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:firebase_messaging/firebase_messaging.dart'; // Add this import
import '../Products/product.dart';
import 'users.dart' as CustomUser;

class SignUpPage extends StatelessWidget {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final CollectionReference _usersCollection =
  FirebaseFirestore.instance.collection('users');

  Future<void> signUp(BuildContext context, String email, String password, String name, String role) async {
    try {
      // Create user with email and password
      final UserCredential userCredential = await _auth.createUserWithEmailAndPassword(
        email: email,
        password: password,
      );

      // Retrieve FCM token
      final String? fcmToken = await FirebaseMessaging.instance.getToken();

      // Create new user object
      final newUser = CustomUser.User(
        uid: userCredential.user!.uid,
        email: email,
        name: name,
        role: role,
        fcmToken: fcmToken ?? '',
      );

      // Store user data in Firestore
      await _usersCollection.doc(userCredential.user!.uid).set(newUser.toFirestore());

      // Request notification permissions
      await requestNotificationPermissions();

      // Show success dialog
      showDialog(
        context: context,
        builder: (BuildContext context) {
          return AlertDialog(
            title: Text('Success'),
            content: Text('User signed up successfully!'),
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
    } catch (error) {
      // Show error dialog
      showDialog(
        context: context,
        builder: (BuildContext context) {
          return AlertDialog(
            title: Text('Error'),
            content: Text('Failed to sign up user: $error'),
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

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Sign Up'),
      ),
      body: SignUpForm(signUp: signUp),
    );
  }
}

class SignUpForm extends StatefulWidget {
  final Function(BuildContext context, String email, String password, String name, String role) signUp;

  SignUpForm({required this.signUp});

  @override
  _SignUpFormState createState() => _SignUpFormState();
}

class _SignUpFormState extends State<SignUpForm> {
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();
  final TextEditingController _nameController = TextEditingController();
  String _selectedRole = 'Shopper';

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
          TextFormField(
            controller: _nameController,
            decoration: InputDecoration(labelText: 'Name'),
          ),
          SizedBox(height: 20.0),
          DropdownButtonFormField<String>(
            value: _selectedRole,
            onChanged: (String? newValue) {
              setState(() {
                _selectedRole = newValue!;
              });
            },
            items: <String>['Shopper', 'Vendor'].map<DropdownMenuItem<String>>((String value) {
              return DropdownMenuItem<String>(
                value: value,
                child: Text(value),
              );
            }).toList(),
          ),
          SizedBox(height: 20.0),
          ElevatedButton(
            onPressed: () {
              final email = _emailController.text.trim();
              final password = _passwordController.text;
              final name = _nameController.text.trim();
              widget.signUp(context, email, password, name, _selectedRole);
            },
            child: Text('Sign Up'),
          ),
        ],
      ),
    );
  }
}