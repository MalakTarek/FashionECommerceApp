import 'package:fashion_ecommerce/Products/product.dart';
import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class VendorProductPage extends StatefulWidget {
  @override
  _VendorProductPageState createState() => _VendorProductPageState();
}

class _VendorProductPageState extends State<VendorProductPage> {
  late Stream<QuerySnapshot> _productStream;
  late ProductRepository _productRepository;

  @override
  void initState() {
    super.initState();
    User? user = FirebaseAuth.instance.currentUser;
    if (user != null) {
      String userId = user.uid;
      _productStream = FirebaseFirestore.instance
          .collection('products')
          .where('vendorId', isEqualTo: userId)
          .snapshots();
    }
  }

  @override

  Widget build(BuildContext context) {
    _productRepository = ProductRepository();
    return Scaffold(
      appBar: AppBar(
        title: Text('Vendor Products'),
      ),
      body: StreamBuilder<QuerySnapshot>(
        stream: _productStream,
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
              child: Text('No products found.'),
            );
          }

          return ListView(
            children: snapshot.data!.docs.map((document) {
              // Extract product information from the document
              String productId = document.id;
              String productName = document['name'];
              double price = document['price'];
              double discount = document['newPrice'] ?? 0.0; // Get discount percentage or default to 0
              String imageUrl = document['image'];

              return Card(
                margin: EdgeInsets.all(10),
                child: ListTile(
                  title: Text(productName),
                  subtitle: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text('Price: \$${price.toStringAsFixed(2)}', style: TextStyle(decoration: TextDecoration.lineThrough)),
                      if (discount > 0)
                        Text('Discounted Price: \$${discount.toStringAsFixed(2)}', style: TextStyle(color: Colors.red)),
                    ],
                  ),
                  leading: Image.network(imageUrl),
                  trailing: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      IconButton(
                        icon: Icon(Icons.delete),
                        onPressed: () {
                          _deleteProduct(productId);
                        },
                      ),
                      SizedBox(width: 8), // Add some space between the buttons
                      IconButton(
                        icon: Icon(Icons.add),
                        onPressed: () {
                          _discountSheet(productId); // Pass productId directly
                        },
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

  Future<void> _deleteProduct(String productId) async {
    try {
      await FirebaseFirestore.instance
          .collection('products')
          .doc(productId)
          .delete();
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Product deleted successfully'),
        ),
      );
    } catch (error) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Failed to delete product: $error'),
        ),
      );
    }
  }

  void _discountSheet(String productId) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        TextEditingController discountController = TextEditingController();
        return AlertDialog(
          title: Text('Add Discount'),
          content: TextField(
            controller: discountController,
            keyboardType: TextInputType.number,
            decoration: InputDecoration(labelText: 'Discount Percentage'),
          ),
          actions: <Widget>[
            TextButton(
              onPressed: () {
                Navigator.pop(context);
              },
              child: Text('Cancel'),
            ),
            ElevatedButton(
              onPressed: () async {
                try {
                  double discountPercentage = double.parse(discountController.text);
                  // Call the function to apply discount
                  await _productRepository.applyDiscountAndSetNewPrice(productId, discountPercentage);
                  Navigator.pop(context);
                  setState(() {}); // Refresh UI
                } catch (error) {
                  print('Error applying discount: $error');
                }
              },
              child: Text('Add Discount'),
            ),
          ],
        );
      },
    );
  }
}
