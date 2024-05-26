import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class CartPage extends StatefulWidget {
  @override
  _CartPageState createState() => _CartPageState();
}
class _CartPageState extends State<CartPage> {
  late Stream<QuerySnapshot> _cartStream;
  double totalPrice = 0;

  @override
  void initState() {
    super.initState();
    String? uid = FirebaseAuth.instance.currentUser?.uid;
    _cartStream = FirebaseFirestore.instance
        .collection('cart')
        .where('uid', isEqualTo: uid)
        .snapshots();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Cart'),
      ),
      body: StreamBuilder<QuerySnapshot>(
        stream: _cartStream,
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
              child: Text('Your cart is empty.'),
            );
          }

          double totalPrice = calculateTotalPrice(snapshot.data!);
          double tax = 50.0;
          double shipping = 50.0;
          double grandTotal = totalPrice + tax + shipping;

          return SingleChildScrollView(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                SizedBox(
                  height: MediaQuery.of(context).size.height * 0.5,
                  child: ListView(
                    children: snapshot.data!.docs.map((document) {
                      double price = document['price'].toDouble();
                      double newPrice = document['newPrice'].toDouble();

                      return ListTile(
                        title: Text(document['name']),
                        subtitle: RichText(
                          text: TextSpan(
                            text: '\$${price.toStringAsFixed(2)}',
                            style: TextStyle(
                              color: Colors.black,
                              decoration: newPrice != 0 ? TextDecoration.lineThrough : null,
                            ),
                            children: newPrice != 0
                                ? [
                              TextSpan(
                                text: ' \$${newPrice.toStringAsFixed(2)}',
                                style: TextStyle(
                                  color: Colors.red,
                                  decoration: TextDecoration.none,
                                ),
                              ),
                            ]
                                : [],
                          ),
                        ),
                        leading: Image.network(document['imageUrl']),
                        trailing: IconButton(
                          icon: Icon(Icons.delete),
                          onPressed: () {
                            FirebaseFirestore.instance
                                .collection('cart')
                                .doc(document.id)
                                .delete()
                                .then((_) {
                              ScaffoldMessenger.of(context).showSnackBar(
                                SnackBar(content: Text('Item removed from cart')),
                              );
                            }).catchError((error) {
                              print("Failed to remove item from cart: $error");
                            });
                          },
                        ),
                      );
                    }).toList(),
                  ),
                ),
                Container(
                  padding: EdgeInsets.all(10.0),
                  decoration: BoxDecoration(
                    color: Color(0xFFDACABF),
                    borderRadius: BorderRadius.circular(15.0),
                    border: Border.all(color: Colors.black, width: 2.0),
                  ),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      const Text(
                        'Payment is done only by cash, no visa!',
                        style: TextStyle(fontWeight: FontWeight.bold, fontSize: 20),
                      ),
                      Text(
                        'Price: \$${totalPrice.toStringAsFixed(2)}',
                        style: TextStyle(fontWeight: FontWeight.bold, fontSize: 20),
                      ),
                      SizedBox(height: 20.0),
                      Text(
                        'Tax: \$${tax.toStringAsFixed(2)}',
                        style: TextStyle(fontWeight: FontWeight.bold, fontSize: 20),
                      ),
                      SizedBox(height: 20.0),
                      Text(
                        'Shipping: \$${shipping.toStringAsFixed(2)}',
                        style: TextStyle(fontWeight: FontWeight.bold, fontSize: 20),
                      ),
                      SizedBox(height: 20.0),
                      Divider(color: Colors.black),
                      SizedBox(height: 20.0),
                      Text(
                        'Total Price: \$${grandTotal.toStringAsFixed(2)}',
                        style: TextStyle(fontWeight: FontWeight.bold, fontSize: 20),
                      ),
                    ],
                  ),
                ),
                ElevatedButton(
                  onPressed: () => checkOutOrder(grandTotal),
                  child: const Text('Checkout'),
                ),
              ],
            ),
          );
        },
      ),
    );
  }


  //Functions Here!
  double calculateTotalPrice(QuerySnapshot snapshot) {
    return snapshot.docs.fold(0, (previousValue, document) {
      double price = document['price'].toDouble();
      double newPrice = document['newPrice'].toDouble();
      return previousValue + (newPrice != 0 ? newPrice : price);
    });
  }
  Future<void> checkOutOrder(double totalPrice) async {
    User? user = FirebaseAuth.instance.currentUser;
    if (user != null) {
      String uid = user.uid;

      try {
        // Get the current timestamp
        Timestamp timestamp = Timestamp.now();

        // Collect information about the products in the cart
        List<Map<String, dynamic>> products = [];
        await FirebaseFirestore.instance
            .collection('cart')
            .where('uid', isEqualTo: uid)
            .get()
            .then((querySnapshot) {
          for (var doc in querySnapshot.docs) {
            Map<String, dynamic> productData = {
              'imageUrl': doc['imageUrl'],
              'totalPrice': doc['price'],
              'name': doc['name'],
            };
            products.add(productData);
          }
        });

        // Add the order to the 'orders' collection
        await FirebaseFirestore.instance.collection('orders').add({
          'uid': uid,
          'timestamp': timestamp,
          'products': products,
          'totalPrice': totalPrice,
        });

        // Clear the cart after placing the order
        await FirebaseFirestore.instance
            .collection('cart')
            .where('uid', isEqualTo: uid)
            .get()
            .then((querySnapshot) {
          querySnapshot.docs.forEach((doc) {
            doc.reference.delete();
          });
        });

        // Show a SnackBar to indicate success
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Order Completed')),
        );
      } catch (error) {
        // Handle errors
        print("Failed to place your order: $error");
      }
    }
  }

}
