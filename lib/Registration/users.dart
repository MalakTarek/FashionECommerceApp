import 'package:cloud_firestore/cloud_firestore.dart';
import '../Products/product.dart';
import '../Order/order.dart' as orders;
import 'package:firebase_auth/firebase_auth.dart';

class User {
  final String uid;
  final String email;
  final String name;
  final String role;
  final String fcmToken;

  User({
    required this.uid,
    required this.email,
    required this.name,
    required this.role,
    required this.fcmToken,
  });





  factory User.fromFirestore(DocumentSnapshot<Map<String, dynamic>> snapshot) {
    final data = snapshot.data()!;
    return User(
      uid: snapshot.id,
      email: data['email'],
      name: data['name'],
      role: data['role'],
      fcmToken: data['fcmToken'],

    );
  }

  Map<String, dynamic> toFirestore() {
    return {
      'uid': uid,
      'email': email,
      'name': name,
      'role': role,
      'fcmToken':fcmToken,
    };
  }
}

class UserRepository {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final String _collectionPath = 'users';
  final FirebaseAuth _auth = FirebaseAuth.instance;



  Future<User?> getUserProfile(String uid) async {
    try {
      final doc = await _firestore.collection(_collectionPath).doc(uid).get();
      if (doc.exists) {
        return User.fromFirestore(doc);
      } else {
        return null;
      }
    } catch (error) {
      throw Exception('Failed to get user profile: $error');
    }
  }

  Future<void> updateFCMToken(String uid, String fcmToken) async {
    try {
      await _firestore.collection(_collectionPath).doc(uid).update({
        'fcmToken': fcmToken,
      });
    } catch (error) {
      throw Exception('Failed to update FCM token: $error');
    }
  }
  /*Stream<User?> getUserStream(String userId) {
    final CollectionReference _usersCollection = FirebaseFirestore.instance.collection('users');
    return _usersCollection.doc(userId).snapshots().map((snapshot) {
      if (snapshot.exists) {
        return User.fromDocument(snapshot);
      }
      return null;
    });
  }
  */

  Future<void> updateUserProfile(String uid, Map<String, dynamic> updatedData) async {
    try {
      await _firestore.collection(_collectionPath).doc(uid).update(updatedData);
    } catch (error) {
      throw Exception('Failed to update user profile: $error');
    }
  }

  Future<void> addToWishlist(String uid, Product product) async {
    try {
      await _firestore.collection(_collectionPath).doc(uid).update({
        'wishlist': FieldValue.arrayUnion([product.toFirestore()])
      });
    } catch (error) {
      throw Exception('Failed to add to wishlist: $error');
    }
  }

  Future<void> removeFromWishlist(String uid, Product product) async {
    try {
      await _firestore.collection(_collectionPath).doc(uid).update({
        'wishlist': FieldValue.arrayRemove([product.toFirestore()])
      });
    } catch (error) {
      throw Exception('Failed to remove from wishlist: $error');
    }
  }
  Future<User?> getUser(String uid) async {
    try {
      final doc = await _firestore.collection(_collectionPath).doc(uid).get();
      if (doc.exists) {
        return User.fromFirestore(doc);
      } else {
        return null;
      }
    } catch (error) {
      // Handle errors (e.g., print error message)
      throw Exception('Failed to get user: $error');
    }
  }
  Future<void> addUserWithFCMToken(User user, String fcmToken) async {
    try {
      // Add the user to the 'users' collection with the FCM token
      await _firestore.collection(_collectionPath).doc(user.uid).set({
        'email': user.email,
        'name': user.name,
        'role': user.role,
        'fcmToken': fcmToken, // Include the FCM token in the user's profile
      });
    } catch (error) {
      throw Exception('Failed to add user with FCM token: $error');
    }
  }
  Future<List<Product>> getWishlist() async {
    try {
      final uid = _auth.currentUser?.uid;
      if (uid != null) {
        final doc = await _firestore.collection(_collectionPath).doc(uid).get();
        if (doc.exists) {
          final data = doc.data();
          return (data?['wishlist'] as List<dynamic>)
              .map((item) => Product.fromFirestore(item))
              .toList();
        }
      }
      return [];
    } catch (error) {
      throw Exception('Failed to get wishlist: $error');
    }
  }

  Future<String?> getUserRole() async {
    try {
      final uid = _auth.currentUser?.uid;
      if (uid != null) {
        final doc = await _firestore.collection(_collectionPath).doc(uid).get();
        if (doc.exists) {
          final data = doc.data();
          return data?['role'];
        }
      }
      return null;
    } catch (error) {
      throw Exception('Failed to get user role: $error');
    }
  }
}