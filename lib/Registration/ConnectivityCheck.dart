import 'package:flutter/material.dart';
import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:flutter/services.dart';
import 'package:internet_connection_checker/internet_connection_checker.dart';

 class ConnectivityProvider with ChangeNotifier {
         bool _isConnected = true;

          bool get isConnected => _isConnected;

ConnectivityProvider(BuildContext context) {
_checkInitialConnection(context);
_monitorConnection(context);
}

Future<void> _checkInitialConnection(BuildContext context) async {
_isConnected = await _hasInternetConnection();
if (!_isConnected) {
showNoInternetAlert(context);
}
notifyListeners();
}

void _monitorConnection(BuildContext context) {
Connectivity()
    .onConnectivityChanged
    .listen((ConnectivityResult result) async {
_isConnected = await _hasInternetConnection();
if (!_isConnected) {
showNoInternetAlert(context);
}
notifyListeners();
});
}

Future<bool> _hasInternetConnection() async {
var connectivityResult = await (Connectivity().checkConnectivity());
if (connectivityResult == ConnectivityResult.none) {
return false;
} else {
return await InternetConnectionChecker().hasConnection;
}
}

void showNoInternetAlert(BuildContext context) {
showDialog(
context: context,
barrierDismissible: false,
builder: (BuildContext context) {
return AlertDialog(
title: Text('No Internet Connection'),
content: Text('Please check your internet connection and try again.'),
actions: <Widget>[
TextButton(
child: Text('Exit'),
onPressed: () {
// Exit the application
Navigator.of(context).pop();
Future.delayed(Duration(milliseconds: 100), () {
SystemNavigator.pop();
});
},
),
],
);
},
);
}
}