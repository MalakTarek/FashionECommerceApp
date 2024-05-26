import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class OrderPage extends StatefulWidget {
  @override
  _OrderPageState createState() => _OrderPageState();
}

class _OrderPageState extends State<OrderPage> {
  late Stream<QuerySnapshot> _orderStream;

  @override
  void initState() {
    super.initState();

    // Initialize the order stream
    String? uid = FirebaseAuth.instance.currentUser?.uid;
    _orderStream = FirebaseFirestore.instance
        .collection('orders')
        .where('uid', isEqualTo: uid)
        .orderBy('timestamp', descending: true)
        .snapshots();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Orders'),
      ),
      body: StreamBuilder<QuerySnapshot>(
        stream: _orderStream,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return Center(
              child: CircularProgressIndicator(),
            );
          }
          if (snapshot.hasError) {
            return Center(
              child: Text('Error: ${snapshot.error}'),
            );
          }
          if (snapshot.data?.docs.isEmpty ?? true) {
            return Center(
              child: Text('No orders found.'),
            );
          }

          return ListView(
            children: snapshot.data!.docs.map((document) {
              // Extract order information from the document
              List<dynamic> products = document['products'];
              double totalPrice = document['totalPrice'];
              Timestamp timestamp = document['timestamp'];

              return Card(
                margin: EdgeInsets.all(10),
                child: ListTile(
                  title: Text('Order Placed: ${_formatTimestamp(timestamp)}'),
                  subtitle: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text('Total Price: \$${totalPrice.toStringAsFixed(2)}'),
                      Text('Products:'),
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: products.map((product) {
                          return Text('- ${product['name']}');
                        }).toList(),
                      ),
                    ],
                  ),
                ),
              );
            }).toList(),
          );
        },
      ),
    );
  }

  String _formatTimestamp(Timestamp timestamp) {
    DateTime dateTime = timestamp.toDate();
    return '${dateTime.day}/${dateTime.month}/${dateTime.year}';
  }
}
