import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import '../WishList/wishlistpage.dart';
import '../Order/cartpage.dart';
import '../Order/orderpage.dart';
import 'users.dart' as users; // Update with your actual import

class ProfilePage extends StatefulWidget {
  final String userId;

  ProfilePage({required this.userId});

  @override
  _ProfilePageState createState() => _ProfilePageState();
}

class _ProfilePageState extends State<ProfilePage> {
  late Future<users.User?> userFuture;
  User? currentUser;

  @override
  void initState() {
    super.initState();
    currentUser = FirebaseAuth.instance.currentUser;
    _refreshUserData();
  }

  void _refreshUserData() {
    setState(() {
      userFuture = users.UserRepository().getUser(widget.userId);
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Profile'),
        backgroundColor: Colors.brown, // Custom color for the app bar
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: FutureBuilder<users.User?>(
          future: userFuture,
          builder: (context, snapshot) {
            if (snapshot.connectionState == ConnectionState.waiting) {
              return Center(child: CircularProgressIndicator());
            } else if (snapshot.hasError) {
              return Center(child: Text("Error: ${snapshot.error}"));
            } else if (!snapshot.hasData || snapshot.data == null) {
              return Center(child: Text("No user found"));
            } else {
              final user = snapshot.data!;
              return Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Center(
                    child: CircleAvatar(
                      radius: 50,
                      // backgroundImage: NetworkImage(),
                    ),
                  ),
                  SizedBox(height: 16),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Text(
                        user.name,
                        style: TextStyle(
                          fontSize: 20,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      IconButton(
                        icon: Icon(Icons.edit),
                        onPressed: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (context) => EditProfilePage(
                                userId: widget.userId,
                                user: user,
                              ),
                            ),
                          ).then((value) {
                            // Refresh user data after returning from EditProfilePage
                            _refreshUserData();
                          });
                        },
                      ),
                    ],
                  ),
                  SizedBox(height: 8),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Text(
                        user.email ?? 'No display name',
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.w400,
                        ),
                      ),
                      IconButton(
                        icon: Icon(Icons.edit),
                        onPressed: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (context) => EditProfilePage(
                                userId: widget.userId,
                                user: user,
                              ),
                            ),
                          ).then((value) {
                            // Refresh user data after returning from EditProfilePage
                            _refreshUserData();
                          });
                        },
                      ),
                    ],
                  ),
                  SizedBox(height: 32),
                  ListTile(
                    leading: Icon(Icons.favorite, color: Colors.red),
                    title: Text('Wishlist'),
                    onTap: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(builder: (context) => WishListPage()),
                      );
                    },
                  ),
                  ListTile(
                    leading: Icon(Icons.list_alt, color: Colors.green),
                    title: Text('My Orders'),
                    onTap: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(builder: (context) => OrderPage()),
                      );
                    },
                  ),
                  Spacer(),
                ],
              );
            }
          },
        ),
      ),
    );
  }
}

class EditProfilePage extends StatefulWidget {
  final String userId;
  final users.User user;

  EditProfilePage({required this.userId, required this.user});

  @override
  _EditProfilePageState createState() => _EditProfilePageState();
}

class _EditProfilePageState extends State<EditProfilePage> {
  TextEditingController _nameController = TextEditingController();
  TextEditingController _emailController = TextEditingController();

  @override
  void initState() {
    super.initState();
    _nameController.text = widget.user.name;
    _emailController.text = widget.user.email;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Edit Profile'),
        backgroundColor: Colors.brown,
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Name:',
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.bold,
              ),
            ),
            SizedBox(height: 8),
            TextField(
              controller: _nameController,
              decoration: InputDecoration(
                hintText: 'Enter your name',
                border: OutlineInputBorder(),
              ),
            ),
            SizedBox(height: 16),
            Text(
              'Email:',
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.bold,
              ),
            ),
            SizedBox(height: 8),
            TextField(
              controller: _emailController,
              decoration: InputDecoration(
                hintText: 'Enter your email',
                border: OutlineInputBorder(),
              ),
            ),
            SizedBox(height: 16),
            ElevatedButton(
              onPressed: () async {
                // Update profile
                Map<String, dynamic> updatedData = {
                  'name': _nameController.text,
                  'email': _emailController.text,
                };
                try {
                  await users.UserRepository()
                      .updateUserProfile(widget.userId, updatedData);
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(content: Text("Profile updated")),
                  );
                  // Navigate back to profile page
                  Navigator.pop(context, true);
                } catch (error) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                        content: Text("Failed to update profile: $error")),
                  );
                }
              },
              child: Text('Save'),
            ),
          ],
        ),
      ),
    );
  }

  @override
  void dispose() {
    _nameController.dispose();
    _emailController.dispose();
    super.dispose();
  }
}
