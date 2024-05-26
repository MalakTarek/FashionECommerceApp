import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import '../Registration/users.dart' as users;
import '../clothingCategory.dart';

class Product {
  String pid;
  late final String vendorId;
  final String name;
  final String vendorName;
  final String imageUrl;
  final double price;
  double newPrice;
  final ClothingCategory category;
  final String description;
  final List<String> comments;
  final List<double> ratings = [];
  final double overallRating;
  late final List<String> sizes;
  late final Map<String, Map<String, int>> unitsByColorAndSize;
  bool isDiscounted;
  final List<String> nameTokens;

  Product({
      required this.pid,
    required this.vendorId,
    required this.name,
    required this.vendorName,
    required this.imageUrl,
    required this.price,
    required this.comments,
    required this.category,
    required this.description,
     this.overallRating=0.0,
    required this.sizes,
    required this.unitsByColorAndSize,
    this.newPrice = 0.0,
    this.isDiscounted = false,
    required this.nameTokens,
    required List<double> ratings,


  });

  String getImage() {
    return imageUrl;
  }
  void setAvailableOptions(List<String> sizes, Map<String, Map<String, int>> unitsByColorAndSize) {
    this.sizes = sizes;
    this.unitsByColorAndSize = unitsByColorAndSize;
  }
  List<String> getAvailableSizes() {
    return sizes;
  }
  List<String> getAvailableColorsForSize(String size) {
    return unitsByColorAndSize[size]?.keys.toList() ?? [];
  }
  int getAvailableUnitsForColorAndSize(String color, String size) {
    return unitsByColorAndSize[size]?[color] ?? 0;
  }
  List<String> getAllAvailableColors() {
    Set<String> allColors = {};
    for (var size in sizes) {
      allColors.addAll(unitsByColorAndSize[size]?.keys ?? []);
    }
    return allColors.toList();
  }

  double calculateNewPrice(double discountPercentage) {
    double discountAmount = price * (discountPercentage / 100);
    return price - discountAmount;
  }
  void addRating(double rating) {
    ratings.add(rating);
  }
  void addComment(String comment) {
    comments.add(comment);
  }
  double calculateOverallRating() {
    if (ratings.isEmpty) {
      return 0.0;
    }
    double sum = ratings.reduce((value, element) => value + element);
    return sum / ratings.length;
  }
  String getDescription() {
    return description;
  }

  factory Product.fromFirestore(DocumentSnapshot<Map<String, dynamic>> snapshot) {
    final data = snapshot.data();
    if (data == null) {
      throw Exception('DocumentSnapshot data is null');
    }

    final user = FirebaseAuth.instance.currentUser;
    return Product(
      pid: snapshot.id,
      vendorId: user?.uid ?? '',
      name: data['name'] ?? '',
      vendorName: data['vendorName'] ?? '',
      imageUrl: data['image'] ?? '',
      price: (data['price'] as num?)?.toDouble() ?? 0.0,
      category: CategoryExtension.fromString(data['category'] ?? ''),
      overallRating: (data['overallRating'] as num?)?.toDouble() ?? 0.0,
      comments: List<String>.from(data['comments'] ?? []),
      description: data['description'] ?? '',
      sizes: List<String>.from(data['sizes'] ?? []),
      unitsByColorAndSize: Map<String, Map<String, int>>.from(data['unitsByColorAndSize'] ?? {}),
      newPrice: (data['newPrice'] as num?)?.toDouble() ?? 0.0,
      isDiscounted: data['isDiscounted'] ?? false,
      nameTokens: [],
      ratings: List<double>.from(data['ratings'] ?? []),

    );
  }
/*
price: (data['price'] as num?)?.toDouble() ?? 0.0,
overallRating: (data['overallRating'] as num?)?.toDouble() ?? 0.0,
newPrice: (data['newPrice'] as num?)?.toDouble() ?? 0.0,
 */

  Map<String, dynamic> toFirestore() {
    // Convert other properties to Firestore data
    Map<String, dynamic> data = {
      'vendorId': vendorId,
      'name': name,
      'vendorName': vendorName,
      'image': imageUrl,
      'price': price,
      'category': category.name,
      'comments': comments,
      'overallRating': overallRating,
      'description': description,
      'sizes': sizes,
      'unitsByColorAndSize': unitsByColorAndSize,
      'newPrice': newPrice,
      'isDiscounted': isDiscounted,
      'ratings': ratings,

    };
    // If pid is available, add it to Firestore data
    data['nameTokens'] = name.toLowerCase().split(' ');
    data['pid'] = pid;
      return data;
  }

}

class ProductRepository {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final FirebaseMessaging _messaging = FirebaseMessaging.instance;
  final String _collectionPath = 'products';


  Future<bool> isProductDiscounted(String productId) async {
    try {
      final doc = await _firestore.collection(_collectionPath)
          .doc(productId)
          .get();
      if (doc.exists) {
        bool isDiscounted = doc.data()?['isDiscounted'] ?? false;
        return isDiscounted;
      } else {
        throw Exception('Product not found');
      }
    } catch (error) {
      throw Exception('Failed to check if product is discounted: $error');
    }
  }

  Future<void> applyDiscountAndSetNewPrice(String productId,
      double discountPercentage) async {
    try {
      final doc = await _firestore.collection(_collectionPath)
          .doc(productId)
          .get();
      if (doc.exists) {
        Product product = Product.fromFirestore(doc);
        double newPrice = product.calculateNewPrice(discountPercentage);
        await _firestore.collection(_collectionPath).doc(productId).update({
          'newPrice': newPrice,
          'isDiscounted': true,
        });

        // Send notifications to shoppers
        final shoppersQuerySnapshot = await _firestore.collection('users')
            .where('role', isEqualTo: 'shopper')
            .get();
        List<String> fcmTokens = [];
        for (var doc in shoppersQuerySnapshot.docs) {
          String? token = doc.data()['fcmToken'];
          if (token != null) {
            fcmTokens.add(token);
          }
        }
        for (String token in fcmTokens) {
          await _sendPushNotification(
              token,
              'Discount Alert!',
              'The product "${product
                  .name}" is now available at a $discountPercentage% discount. New Price: \$${newPrice
                  .toStringAsFixed(2)}'
          );
        }
      }
    } catch (error) {
      throw Exception('Failed to apply discount and set new price: $error');
    }
  }

  Future<void> _sendNewProductNotification(Product product) async {
    try {
      final shoppersQuerySnapshot = await _firestore.collection('users').where(
          'role', isEqualTo: 'shopper').get();

      List<String> fcmTokens = [];
      for (var doc in shoppersQuerySnapshot.docs) {
        String? token = doc.data()['fcmToken'];
        if (token != null) {
          fcmTokens.add(token);
        }
      }

      for (String token in fcmTokens) {
        await _sendPushNotification(
          token,
          'New Product Alert!',
          'A new product "${product.name}" has been added by ${product
              .vendorName}. Check it out now!',
        );
      }
    } catch (error) {
      throw Exception('Failed to send new product notification: $error');
    }
  }

  Future<void> _sendPushNotification(String token, String title,
      String body) async {
    try {
      await _messaging.sendMessage(
        to: token,
        data: {
          'title': title,
          'body': body,
        },
      );
    } catch (error) {
      throw Exception('Failed to send push notification: $error');
    }
  }

  Future<List<Product>> getAllProducts() async {
    try {
      final querySnapshot = await _firestore.collection(_collectionPath).get();
      return querySnapshot.docs.map((doc) => Product.fromFirestore(doc)).toList();
    } catch (error) {
      print('Error fetching products: $error');
      throw Exception('Failed to get all products: $error');
    }
  }


  Future<Product?> getProduct(String productId) async {
    try {
      final doc = await _firestore.collection(_collectionPath)
          .doc(productId)
          .get();
      if (doc.exists) {
        return Product.fromFirestore(doc);
      } else {
        return null;
      }
    } catch (error) {
      throw Exception('Failed to get product: $error');
    }
  }

  Future<void> deleteProduct(String productId) async {
    try {
      await _firestore.collection(_collectionPath).doc(productId).delete();
    } catch (error) {
      throw Exception('Failed to delete product: $error');
    }
  }

  Future<void> editProductAttributes(String productId,
      Map<String, dynamic> updatedAttributes) async {
    try {
      await _firestore.collection(_collectionPath).doc(productId).update(
          updatedAttributes);
    } catch (error) {
      throw Exception('Failed to edit product attributes: $error');
    }
  }

  Future<void> rateProduct(String productId, double rating) async {
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
  Future<void> addCommentToProduct(String productId, String comment) async {
    try {
      final doc = await _firestore.collection(_collectionPath)
          .doc(productId)
          .get();
      if (doc.exists) {
        await _firestore.collection(_collectionPath).doc(productId).update({
          'comments': FieldValue.arrayUnion([comment])
        });
        final product = Product.fromFirestore(doc);

        // Fetch vendor's FCM token
        final vendorDoc = await _firestore.collection('users').doc(
            product.vendorName).get();
        final vendorToken = vendorDoc.data()?['fcmToken'];

        if (vendorToken != null) {
          await _sendPushNotification(
              vendorToken,
              'New Comment on Your Product',
              'A new comment has been added to your product "${product
                  .name}": $comment'
          );
        }
      }
    } catch (error) {
      throw Exception('Failed to add comment to product: $error');
    }
  }

  Future<List<Product>> getVendorProducts(String vendorName) async {
    try {
      final querySnapshot = await _firestore
          .collection(_collectionPath)
          .where('vendorName', isEqualTo: vendorName)
          .get();
      return querySnapshot.docs.map((doc) => Product.fromFirestore(doc))
          .toList();
    } catch (error) {
      throw Exception('Failed to get vendor products: $error');
    }
  }

  Future<String?> getProductDescription(String productId) async {
    try {
      final doc = await _firestore.collection(_collectionPath)
          .doc(productId)
          .get();
      if (doc.exists) {
        return Product.fromFirestore(doc).getDescription();
      } else {
        return null;
      }
    } catch (error) {
      throw Exception('Failed to get product description: $error');
    }
  }
  Future<List<Product>> getProductsByCategory(ClothingCategory category) async {
    try {
      if (category == ClothingCategory.all) {
        // If the category is "All", fetch all products without filtering by category
        final querySnapshot = await _firestore.collection(_collectionPath).get();
        return querySnapshot.docs.map((doc) => Product.fromFirestore(doc)).toList();
      } else {
        // If the category is specific, filter products by category
        final querySnapshot = await _firestore
            .collection(_collectionPath)
            .where('category', isEqualTo: category.name)
            .get();
        return querySnapshot.docs.map((doc) => Product.fromFirestore(doc)).toList();
      }
    } catch (error) {
      throw Exception('Failed to get products by category: $error');
    }
  }
  Future<List<Product>> searchProductsByName(String query) async {
    try {
      final querySnapshot = await _firestore
          .collection(_collectionPath)
          .where('nameTokens', arrayContains: query.toLowerCase()) // Search within nameTokens array
          .get();

      return querySnapshot.docs.map((doc) => Product.fromFirestore(doc)).toList();
    } catch (error) {
      throw Exception('Failed to search products by name: $error');
    }
  }

  Future<String?> getProductImage(String productId) async {
    try {
      final doc = await _firestore.collection(_collectionPath)
          .doc(productId)
          .get();
      if (doc.exists) {
        return Product.fromFirestore(doc).getImage();
      } else {
        return null;
      }
    } catch (error) {
      throw Exception('Failed to get product image: $error');
    }
  }

}
