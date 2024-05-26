import 'package:flutter/material.dart';
import 'dart:ui';
import 'package:google_fonts/google_fonts.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart' as mimi;
import '../Products/product.dart';
import '../Products/product_description.dart';
import '../Order/cartItems.dart';
import '../Registration/users.dart' as malak;
import '../WishList/wishlistItems.dart';
import '../main.dart';
import 'Rating.dart';

class ProductViewPage extends StatefulWidget {
  final Product product;
  final String pid;

  const ProductViewPage({Key? key, required this.product, required this.pid}) : super(key: key);

  @override
  _ProductViewPageState createState() => _ProductViewPageState();
}

class _ProductViewPageState extends State<ProductViewPage> {
  bool isFavorite = false;
  late Product productInCart;
  late WishListItem productInwishlist;
  late TextEditingController _commentController;
  late malak.UserRepository  _userRepository;
  late ProductRepository  _productRepository;
  List<String> comments = [];
  double userRating = 0.0;

  // final TextEditingController _commentController = TextEditingController();


  @override
  void initState() {
    super.initState();
    widget.product.pid = widget.pid; // Initialize the pid field of the product
    productInCart = widget.product; // Initialize the productInCart
    checkIfFavorite(); // Check if the product is already in the wishlist
    _commentController = TextEditingController();
    _userRepository = malak.UserRepository();
     fetchComments();
     double userRating = 0.0;
  }

  @override
  Widget build(BuildContext context) {
    _productRepository = ProductRepository();

    return Scaffold(
      appBar: AppBar(
        title: Text(widget.product.name),
      ),
      body: SingleChildScrollView(
        child: Container(
          decoration: BoxDecoration(
            color: Color(0xFFFFFFFF),
          ),
          child: Column(
              mainAxisAlignment: MainAxisAlignment.start,
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
          Container(
          margin: EdgeInsets.fromLTRB(0, 0, 0, 7),
          child: ClipRect(
            child: BackdropFilter(
              filter: ImageFilter.blur(
                sigmaX: 2,
                sigmaY: 2,
              ),
              child: Container(
                decoration: BoxDecoration(
                  color: Color(0xFFFFFFFF),
                ),
                child: Stack(
                  children: [
                    Positioned(
                      left: -12,
                      right: -12,
                      top: -4,
                      bottom: -4,
                      child: ClipRect(
                        child: BackdropFilter(
                          filter: ImageFilter.blur(
                            sigmaX: 2,
                            sigmaY: 2,
                          ),
                          child: Container(
                            decoration: BoxDecoration(
                              border: Border.all(color: Color(0xFFFFFFFF)),
                              color: Color(0xFFFFFFFF),
                            ),
                            child: Container(
                              width: 360,
                              height: 24,
                            ),
                          ),
                        ),
                      ),
                    ),
                    Container(
                      padding: EdgeInsets.fromLTRB(12, 4, 12, 4),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Container(
                            margin: EdgeInsets.fromLTRB(0, 2, 0, 2),
                            child: SizedBox(
                              width: 70,
                              child: Row(
                                mainAxisAlignment: MainAxisAlignment.start,
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [],
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
        Container(
          margin: EdgeInsets.fromLTRB(11, 0, 25, 11),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Container(
                margin: EdgeInsets.fromLTRB(0, 2, 0, 0),
                child: SizedBox(
                  width: 67,
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.start,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [],
                  ),
                ),
              ),
            ],
          ),
        ),
        Container(
          margin: EdgeInsets.fromLTRB(18, 0, 21.8, 33),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(10),
            image: DecorationImage(
              fit: BoxFit.cover,
              image: NetworkImage(
                widget.product.imageUrl,
              ),
            ),
            boxShadow: [
              BoxShadow(
                color: Color(0x2B000000),
                offset: Offset(7, 4),
                blurRadius: 5,
              ),
            ],
          ),
          child: Container(
            width: 201,
            height: 304,
          ),
        ),
        Container(
          margin: EdgeInsets.fromLTRB(18, 0, 10.8, 10),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    'Price: ',
                    style: GoogleFonts.getFont(
                      'Poppins',
                      fontWeight: FontWeight.w400,
                      fontSize: 22,
                      height: 1,
                      letterSpacing: 0.5,
                      color: Color(0xFF000000),
                    ),
                  ),
                  Row(
                    children: [
                      if (widget.product.newPrice! > 0)
                        Text(
                          '\$${widget.product.newPrice}',
                          style: TextStyle(fontSize: 20, color: Colors.red),
                        ),
                      if (widget.product.newPrice! > 0)
                        SizedBox(width: 5),
                      Text(
                        '\$${widget.product.price}',
                        style: TextStyle(
                          fontSize: 20,
                          decoration: widget.product.newPrice! > 0 ? TextDecoration.lineThrough : null,
                        ),
                      ),
                    ],
                  ),
                  FutureBuilder<String?>(
                    future: _userRepository.getUserRole(),
                    builder: (context, snapshot) {
                      if (snapshot.connectionState == ConnectionState.waiting) {
                        return CircularProgressIndicator();
                      } else if (snapshot.hasError) {
                        return Text('Error: ${snapshot.error}');
                      } else if (snapshot.hasData) {
                        if (snapshot.data == 'Shopper') {
                          return IconButton(
                            icon: Icon(
                              isFavorite ? Icons.favorite : Icons.favorite_border,
                              color: isFavorite ? Colors.red : null,
                            ),
                            onPressed: () {
                              setState(() {
                                isFavorite = !isFavorite;
                                if (isFavorite) {
                                  addToWishlist();
                                } else {
                                  removeFromWishlist();
                                }
                              });
                            },
                          );
                        } else {
                          return SizedBox(); // Return an empty widget for Vendors
                        }
                      }
                      return SizedBox(); // Return an empty widget if no data
                    },
                  ),
                ],
              ),
              SizedBox(height: 10),
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Product Name: ${widget.product.name}',
                    style: GoogleFonts.poppins(fontSize: 20),
                  ),
                  Text(
                    'Available Sizes: ${widget.product.sizes}',
                    style: GoogleFonts.poppins(fontSize: 20),
                  ),
                ],
              ),

              SizedBox(height: 10),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: [
                  TextButton(
                    onPressed: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(builder: (context) => ProductDetailPage(product: widget.product)),
                      );
                    },
                    child: Text('Read Description', style: TextStyle(fontSize: 15, color: Colors.blue)),
                  ),
                  TextButton(
                    onPressed: () {
                      showCommentsDialog(context);
                    },
                    child: Text('Show Comments', style: TextStyle(fontSize: 15, color: Colors.blue)),
                  ),

                ],
              ),
                  Column(
                    children: [
                      Text('Overall Rating'),
                      Rating(widget.product), // Assuming this is another custom widget showing overall rating
                      FutureBuilder<String?>(
                        future: _userRepository.getUserRole(),
                        builder: (context, snapshot) {
                          if (snapshot.connectionState == ConnectionState.waiting) {
                            return CircularProgressIndicator();
                          } else if (snapshot.hasError) {
                            return Text('Error: ${snapshot.error}');
                          } else if (snapshot.hasData && snapshot.data == 'Shopper') {
                            return Column(
                              children: [
                                SizedBox(height: 10),
                                Text('Rate this product: '),
                                Row(
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  children: List.generate(
                                    5,
                                        (index) => IconButton(
                                      icon: Icon(
                                        index < userRating ? Icons.star : Icons.star_border,
                                        color: Colors.amber,
                                      ),
                                      onPressed: () {
                                        setState(() {
                                          userRating = index + 1;
                                        });
                                        rateProduct(widget.product.pid, userRating);
                                      },
                                    ),
                                  ),
                                ),
                              ],
                            );
                          } else {
                            return SizedBox(); // Return an empty widget for non-Shoppers
                          }
                        },
                      ),
                    ],

                  ),
                    Center(
                child: FutureBuilder<String?>(
                  future: _userRepository.getUserRole(),
                  builder: (context, snapshot) {
                    if (snapshot.connectionState == ConnectionState.waiting) {
                      return CircularProgressIndicator();
                    } else if (snapshot.hasError) {
                      return Text('Error: ${snapshot.error}');
                    } else if (snapshot.hasData && snapshot.data == 'Shopper') {
                      return ElevatedButton(
                        onPressed: addToCart,
                        child: const Text(
                          'Add to Cart',
                          style: TextStyle(fontSize: 20),
                        ),
                      );
                    } else if (snapshot.hasData && snapshot.data == 'Vendor') {
                      return SizedBox(); // Return an empty widget for Vendors
                    } else {
                      // Show an alert dialog for all other cases
                      Future.microtask(() {
                        showDialog(
                          context: context,
                          builder: (context) => AlertDialog(
                            title: Text('Alert'),
                            content: Text('You need to be signed in or signed up.'),
                            actions: [
                              TextButton(
                                onPressed: () {
                                  Navigator.of(context).pop(); // Close the dialog
                                },
                                child: Text('OK'),
                              ),
                            ],
                          ),
                        );
                      });

                      return SizedBox(); // Return an empty widget while showing the dialog
                    }
                  },
                ),

              ),
            ],
          ),
        )
          ]
        ),
        )
    )
    );

  }


  // Functions here...
  Future<void> addToCart() async {
    // Use user.uid to specify the owner of this product
    mimi.User? user = mimi.FirebaseAuth.instance.currentUser;
    if (user != null) {
      // Use user.uid to specify the owner of this product
      String uid = user.uid;
      // Create a CartItem object with product details
      CartItem cartItem = CartItem(
        imageUrl: widget.product.imageUrl,
        price: widget.product.price,
        newPrice: widget.product.newPrice,
        name: widget.product.name
      );
      try {
        // Post the product in the cart table
        await FirebaseFirestore.instance.collection('cart').add({
          'uid': uid,
          'imageUrl': cartItem.imageUrl,
          'price': cartItem.price,
          'newPrice': cartItem.newPrice,
          'name': cartItem.name,
        });
        // Show a SnackBar to indicate success
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('${cartItem.name} added to cart')),
        );
      } catch (error) {
        // Handle errors
        print("Failed to add item to cart: $error");
      }
    }
  }

  Future<void> checkIfFavorite() async {
    mimi.User? user = mimi.FirebaseAuth.instance.currentUser;
    if (user != null) {
      String uid = user.uid;
      // Query Firestore to check if the product is in the wishlist
      QuerySnapshot snapshot = await FirebaseFirestore.instance
          .collection('wishlist')
          .where('uid', isEqualTo: uid)
          .where('name', isEqualTo: widget.product.name)
          .get();
      if (snapshot.docs.isNotEmpty) {
        setState(() {
          isFavorite = true;
        });
      }
    }
  }

  Future<void> addToWishlist() async {
    mimi.User? user = mimi.FirebaseAuth.instance.currentUser;
    if (user != null) {
      String uid = user.uid;
      WishListItem wishItem = WishListItem(
        imageUrl: widget.product.imageUrl,
        price: widget.product.price,
        name: widget.product.name,
      );
      try {
        await FirebaseFirestore.instance.collection('wishlist').add({
          'uid': uid,
          'imageUrl': wishItem.imageUrl,
          'price': wishItem.price,
          'name': wishItem.name,
        });
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('${wishItem.name} added to wishlist')),
        );
      } catch (error) {
        print("Failed to add item to wishlist: $error");
      }
    }
  }

  Future<void> removeFromWishlist() async {
    mimi.User? user = mimi.FirebaseAuth.instance.currentUser;
    if (user != null) {
      String uid = user.uid;
      try {
        QuerySnapshot snapshot = await FirebaseFirestore.instance
            .collection('wishlist')
            .where('uid', isEqualTo: uid)
            .where('name', isEqualTo: widget.product.name)
            .get();

        if (snapshot.docs.isNotEmpty) {
          await FirebaseFirestore.instance
              .collection('wishlist')
              .doc(snapshot.docs[0].id)
              .delete();
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text('${widget.product.name} removed from wishlist')),
          );
        }
      } catch (error) {
        print("Failed to remove item from wishlist: $error");
      }
    }
  }


//try adding username later.
  void fetchComments() async {
    DocumentSnapshot snapshot = await FirebaseFirestore.instance
        .collection('products')
        .doc(widget.product.pid)
        .get();
    Map<String, dynamic> data = snapshot.data() as Map<String, dynamic>;
    List<dynamic> commentsData = data['comments'] ?? [];
    setState(() {
      comments = commentsData.cast<String>().toList();
    });
  }
  Future<void> showCommentsDialog(BuildContext context) async {
    await showDialog(
      context: context,
      builder: (BuildContext context) {
        return StatefulBuilder(
          builder: (context, setState) {
            return AlertDialog(
              title: Text('Comments'),
              content: SizedBox(
                width: double.maxFinite,
                child: ListView(
                  children: [
                    // ListView.builder inside ListView
                    ListView.builder(
                      shrinkWrap: true,
                      itemCount: comments.length,
                      itemBuilder: (BuildContext context, int index) {
                        return ListTile(
                          title: Text(comments[index]),
                        );
                      },
                    ),
                    SizedBox(height: 20),
                    // Text field for submitting new comment
                    // Show comment submission section only for Shopper
                    FutureBuilder<String?>(
                      future: _userRepository.getUserRole(),
                      builder: (context, snapshot) {
                        if (snapshot.connectionState == ConnectionState.waiting) {
                          return CircularProgressIndicator();
                        } else if (snapshot.hasError) {
                          return Text('Error: ${snapshot.error}');
                        } else if (snapshot.hasData && snapshot.data == 'Shopper') {
                          return Column(
                            children: [
                              TextField(
                                controller: _commentController,
                                decoration: InputDecoration(
                                  labelText: 'Enter your comment...',
                                  border: OutlineInputBorder(),
                                ),
                              ),
                              ElevatedButton(
                                onPressed: () {
                                  //submitComment(context);
                                  _productRepository.addCommentToProduct(widget.product.pid, _commentController.text);

                                  // Add the new comment to the comments list
                                  setState(() {
                                    comments.add(_commentController.text);
                                  });
                                },
                                child: Text('Submit Comment'),
                              ),
                            ],
                          );
                        } else {
                          return SizedBox(); // Return an empty widget for non-Shoppers
                        }
                      },
                    ),
                  ],
                ),

              ),
            );
          },
        );
      },
    );
  }

  Future<void> rateProduct(String productId, double rating) async {
    final FirebaseFirestore _firestore = FirebaseFirestore.instance;
    const String _collectionPath = 'products';
    try {
      final docRef = _firestore.collection(_collectionPath).doc(productId);
      final docSnapshot = await docRef.get();

      if (docSnapshot.exists) {
        final data = docSnapshot.data() as Map<String, dynamic>;
        List<dynamic> currentRatings = data['ratings'] ?? [];
        double currentOverallRating = data['overallRating'] ?? 0.0;

        // Add the new rating to the current ratings
        currentRatings.add(rating);
        print(data['ratings']);
        // Calculate the new overall rating
        double newOverallRating = currentOverallRating;

        // Recalculate the overall rating only if there are existing ratings
        if (currentRatings.isNotEmpty) {
          double sum = currentRatings.reduce((value, element) => value + element);
          newOverallRating = sum / currentRatings.length;
        }

        // Update the document with the new ratings and overall rating
        await docRef.update({
          'ratings': currentRatings,
          'overallRating': newOverallRating,
        });
      } else {
        throw Exception('Product not found');
      }
    } catch (error) {
      throw Exception('Failed to rate product: $error');
    }
  }






}
