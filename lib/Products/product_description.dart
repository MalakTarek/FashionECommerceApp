import 'package:flutter/material.dart';
import 'dart:ui';
import 'package:google_fonts/google_fonts.dart';
import '../Products/product.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class ProductDetailPage extends StatefulWidget {
  final Product product;

  const ProductDetailPage({Key? key, required this.product}) : super(key: key);

  @override
  _ProductDetailPageState createState() => _ProductDetailPageState();
}

class _ProductDetailPageState extends State<ProductDetailPage> {
  @override
  Widget build(BuildContext context) {
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
                                      children: [
                                      ],
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
                          children: [

                          ],
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              Container(
                margin: EdgeInsets.fromLTRB(0, 0, 1, 25),
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
                margin: EdgeInsets.fromLTRB(18, 0, 21.8, 33),
                child: RichText(
                  text: TextSpan(
                    text: ' ',
                    style: GoogleFonts.getFont(
                      'Poppins',
                      fontWeight: FontWeight.w400,
                      fontSize: 22,
                      height: 1,
                      letterSpacing: 0.5,
                      color: Color(0xFF000000),
                    ),
                    children: [


                      TextSpan(
                        text: 'Description',
                        style: GoogleFonts.getFont(
                          'Poppins',
                          fontWeight: FontWeight.w600,
                          fontSize: 22,
                          height: 1.3,
                          letterSpacing: 0.5,
                        ),
                      ),
                      TextSpan(
                        text: ': ${widget.product.getDescription()}\n', // Assuming fabricContent is a field in Product
                      ),

                      TextSpan(
                        text: 'OverAll Rating',
                        style: GoogleFonts.getFont(
                          'Poppins',
                          fontWeight: FontWeight.w600,
                          fontSize: 22,
                          height: 1.3,
                          letterSpacing: 0.5,
                        ),
                      ),
                      TextSpan(
                        text: ': ${widget.product.overallRating}\n', // Assuming usage is a field in Product
                      ),
                      TextSpan(
                        text: 'Vendor ',
                        style: GoogleFonts.getFont(
                          'Poppins',
                          fontWeight: FontWeight.w600,
                          fontSize: 22,
                          height: 1.3,
                          letterSpacing: 0.5,
                        ),
                      ),
                      TextSpan(
                        text: ': ${widget.product.vendorName}\n', // Assuming vendor is a field in Product
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Future<String?> getProductDescription(String productId) async {
    try {
      final doc = await FirebaseFirestore.instance.collection('products').doc(productId).get();
      if (doc.exists) {
        return Product.fromFirestore(doc).getDescription();
      } else {
        return null;
      }
    } catch (error) {
      throw Exception('Failed to get product description: $error');
    }
  }
}
