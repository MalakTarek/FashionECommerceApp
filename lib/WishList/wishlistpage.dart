import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class WishListPage extends StatefulWidget {
  @override
  _WishListPageState createState() => _WishListPageState();
}

class _WishListPageState extends State<WishListPage> {
  late Stream<QuerySnapshot> _wishlistStream;

  @override
  void initState() {
    super.initState();

    String? uid = FirebaseAuth.instance.currentUser?.uid;
    _wishlistStream = FirebaseFirestore.instance
        .collection('wishlist')
        .where('uid', isEqualTo: uid)
        .snapshots();
  }



  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('WishList'),
      ),
      body: StreamBuilder<QuerySnapshot>(
        stream: _wishlistStream,
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
              child: Text('Your wishlist is empty.'),
            );
          }
          return Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Expanded(
                child: ListView(
                  children: snapshot.data!.docs.map((document) {
                    return ListTile(
                      title: Text(document['name']),
                      subtitle: Text('\$${document['price']}'),
                      leading: Image.network(document['imageUrl']),
                      trailing: IconButton(
                        icon: Icon(Icons.delete),
                        onPressed: () {
                          // Remove item from cart
                          FirebaseFirestore.instance
                              .collection('wishlist')
                              .doc(document.id)
                              .delete()
                              .then((_) {
                            ScaffoldMessenger.of(context).showSnackBar(
                              SnackBar(content: Text('Item removed from wishlist')),
                            );
                          }).catchError((error) {
                            print("Failed to remove item from wishlist: $error");
                          });
                        },
                      ),
                    );
                  }).toList(),
                ),
              ),

            ],
          );
        },
      ),
    );
  }
}
