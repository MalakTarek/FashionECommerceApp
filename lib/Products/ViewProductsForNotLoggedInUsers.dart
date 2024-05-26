
import 'package:fashion_ecommerce/Products/product_view.dart';
import 'package:fashion_ecommerce/Registration/sign_in.dart';
import 'package:fashion_ecommerce/Registration/users.dart';
import 'package:fashion_ecommerce/main.dart';
import 'package:firebase_auth/firebase_auth.dart' as users;

import 'package:flutter/material.dart';

import '../Order/cartpage.dart';
import '../Registration/sign_up.dart';

import 'product.dart';
import '../clothingCategory.dart';


class ProductListScreenDesign extends StatefulWidget {
  const ProductListScreenDesign();

  @override
  _ProductListScreenDesignState createState() => _ProductListScreenDesignState();
}

class _ProductListScreenDesignState extends State<ProductListScreenDesign> {
  late final ProductRepository _productRepository;
  late final String? pid; // Add pid field
  late Future<List<Product>> _allProductsFuture;
  final TextEditingController _searchController = TextEditingController();

  ClothingCategory _selectedCategory = ClothingCategory.shirts; // Initially selected category


  late final UserRepository  _userRepository;
  @override
  void initState() {
    super.initState();
    _productRepository = ProductRepository();
    _refreshProducts();
    _userRepository = UserRepository();
    _selectedCategory;
  }

  void _refreshProducts() {
    setState(() {
      _allProductsFuture = _productRepository.getAllProducts();
    });
  }
  void _searchProducts(String query) {
    setState(() {
      _allProductsFuture = _productRepository.searchProductsByName(query);
      print('hi');
    });
  }

  void _filterProductsByCategory(ClothingCategory category) {
    setState(() {
      _selectedCategory = category;
      _allProductsFuture = _productRepository.getProductsByCategory(category);
      print('hi');
    });
  }
  @override
  Widget build(BuildContext context) {
    //_userRepository = UserRepository();

    final userId = users.FirebaseAuth.instance.currentUser?.uid;
    return Scaffold(
      appBar: AppBar(
        title: Text('Products'),
        leading: Builder(
          builder: (BuildContext context) {
            return IconButton(
              icon: Icon(Icons.menu),
              onPressed: () {
                Scaffold.of(context).openDrawer();
              },
            );
          },
        ),
        actions: [
          IconButton(
            icon: Icon(Icons.refresh),
            onPressed: () {
              _refreshProducts();
            },
          ),
          if (userId != null)
            FutureBuilder<String?>(
              future: _userRepository.getUserRole(),
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return SizedBox.shrink();
                } else if (snapshot.hasError) {
                  return SizedBox.shrink(); // Handle error appropriately in your app
                } else if (snapshot.hasData && snapshot.data == 'Shopper') {
                  return IconButton(
                    icon: const Icon(Icons.shopping_cart),
                    onPressed: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(builder: (context) => CartPage()),
                      );
                    },
                  );
                } else {
                  return SizedBox.shrink();
                }
              },
            ),
        ],
      ),
      drawer: Drawer(
        child: ListView(
          padding: EdgeInsets.zero,
          children: [
            DrawerHeader(
              decoration: BoxDecoration(
                color: Color(0xFFE1BFAA),
              ),
              child: Text('Menu'),
            ),
            ListTile(
              leading: Icon(Icons.login),
              title: Text('Login'),
              onTap: () async {
                Navigator.pushReplacement(
                  context,
                  MaterialPageRoute(builder: (context) => SignInPage()),
                );
              },
            ),
            ListTile(
              leading: Icon(Icons.app_registration),
              title: Text('Do not have an account? sign up here'),
              onTap: () async {
                Navigator.pushReplacement(
                  context,
                  MaterialPageRoute(builder: (context) => SignUpPage()),
                );
              },
            ),
            ListTile(
              leading: Icon(Icons.directions_run),
              title: Text('Or just leave!'),
              onTap: () async {
                Navigator.pushReplacement(
                  context,
                  MaterialPageRoute(builder: (context) => HomePage()),
                );
              },
            ),
          ],
        ),
      ),

      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                IconButton(
                  icon: Icon(Icons.search),
                  onPressed: () {
                    _searchProducts(_searchController.text.trim());
                  },
                ),
                Expanded(
                  child: TextField(
                    controller: _searchController,
                    decoration: InputDecoration(
                      labelText: 'Search by name',
                      suffixIcon: IconButton(
                        icon: Icon(Icons.clear),
                        onPressed: () {
                          _searchController.clear();
                        },
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),


          DropdownButton<ClothingCategory>(
            value: _selectedCategory,
            onChanged: (newValue) {
              _filterProductsByCategory(newValue!);
            },
            items: ClothingCategory.values.map((category) {
              return DropdownMenuItem(
                value: category,
                child: Text(category.name),
              );
            }).toList(),
          ),
          Expanded(
            child: FutureBuilder<List<Product>>(
              future: _allProductsFuture,
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return Center(
                    child: CircularProgressIndicator(),
                  );
                } else if (snapshot.hasError) {
                  return Center(
                    child: Text('Error: ${snapshot.error}'),
                  );
                } else {
                  List<Product>? products = snapshot.data;
                  if (products == null || products.isEmpty) {
                    return Center(
                      child: Text('No products available.'),
                    );
                  } else {
                    return GridView.builder(
                      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                        crossAxisCount: 2,
                      ),
                      itemCount: products.length,
                      itemBuilder: (context, index) {
                        return InkWell(
                          onTap: () {
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (context) => ProductViewPage(product: products[index], pid: products[index].pid),
                              ),
                            );
                          },
                          child: Card(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: <Widget>[
                                Expanded(
                                  child: Center(
                                    child: SizedBox(
                                      width: double.infinity,
                                      height: 150,
                                      child: Image.network(
                                        products[index].imageUrl,
                                        fit: BoxFit.contain,
                                      ),
                                    ),
                                  ),
                                ),
                                Padding(
                                  padding: const EdgeInsets.all(8.0),
                                  child: Column(
                                    crossAxisAlignment: CrossAxisAlignment.start,
                                    children: [
                                      Text(products[index].name),
                                      Text('Price: ${products[index].price.toString()}'),
                                    ],
                                  ),
                                ),
                              ],
                            ),
                          ),
                        );
                      },
                    );
                  }
                }
              },
            ),
          ),
        ],
      ),

    );
  }
  ClothingCategory clothingCategoryFromString(String categoryString) {
    switch (categoryString.toLowerCase()) {
      case 'Dresses':
        return ClothingCategory.dresses;
      case 'Shirts':
        return ClothingCategory.shirts;
      case 'Pants':
        return ClothingCategory.pants;
      case 'Bags':
        return ClothingCategory.bags;
      case 'Accessories':
        return ClothingCategory.accessories;
      case 'Shoes':
        return ClothingCategory.shoes;
      default:
        return ClothingCategory.pants;
    }
  }
}

