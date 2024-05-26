import 'package:flutter/material.dart';
import 'dart:ui';
import 'package:google_fonts/google_fonts.dart';
import 'package:flutter_svg/flutter_svg.dart';
class CustomDesign extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: Color(0xFFFFFFFF),
      ),
      child: Container(
        padding: EdgeInsets.fromLTRB(0, 0, 0, 0),
        child: Stack(
          clipBehavior: Clip.none,
          children: [
            Container(
              decoration: const BoxDecoration(
                color: Color(0xFFECEDEA),
                image: DecorationImage(
                  fit: BoxFit.cover,
                  image: AssetImage(
                    'assets/images/background.png',
                  ),
                ),
              ),
              child: Container(
                width: 430.7,
                height: 900.8,
              ),
            ),
            Positioned(
              left: -6,
              top: -1.1,
              child: ClipRect(
                child: BackdropFilter(
                  filter: ImageFilter.blur(
                    sigmaX: 10,
                    sigmaY: 10,
                  ),
                  child: Container(
                    decoration: const BoxDecoration(
                      gradient: LinearGradient(
                        begin: Alignment(0, -1),
                        end: Alignment(0, 1),
                        colors: <Color>[Color(0x33FFFFFF), Color(0x33FFFFFF)],
                        stops: <double>[0, 1],
                      ),
                    ),
                    child: Container(
                      width: 168,
                      height: 762.1,
                    ),
                  ),
                ),
              ),
            ),
            Positioned(
              left: 3,
              bottom: 185,
              child: Container(
                decoration: BoxDecoration(
                  color: Color(0xFFD9D9D9),
                ),
                child: Container(
                  width: 160,
                  height: 34,
                  padding: EdgeInsets.fromLTRB(7, 6, 5.3, 5),
                  child: GestureDetector(
                    onTap: () {
                      Navigator.pushNamed(context, '/viewProducts');
                    },
                    child: Text(
                      'view products',
                      style: GoogleFonts.getFont(
                        'Poppins',
                        fontWeight: FontWeight.w400,
                        fontSize: 18,
                        height: 1.3,
                        letterSpacing: 0.3,
                        color: Color(0xFF000000),
                      ),
                    ),
                  ),
                ),
              ),
            ),
            Positioned(
              left: 30,
              bottom: 226,
              child: Container(
                decoration: BoxDecoration(
                  color: Color(0xFFD9D9D9),
                ),
                child: Container(
                  width: 120,
                  height: 34,
                  padding: EdgeInsets.fromLTRB(18.8, 4, 18.8, 4),
                  child: GestureDetector(
                    onTap: () {
                      Navigator.pushNamed(context, '/signUp');
                    },
                    child: Text(
                      'sign up',
                      style: GoogleFonts.getFont(
                        'Poppins',
                        fontWeight: FontWeight.w400,
                        fontSize: 19,
                        height: 1.3,
                        letterSpacing: 0.4,
                        color: Color(0xFF000000),
                      ),
                    ),
                  ),
                ),
              ),
            ),
            Positioned(
              left: 14,
              top: 90,
              child: SizedBox(
                height: 124,
                child: Text(
                  'shop the most modern essentials',
                  style: GoogleFonts.getFont(
                    'Poppins',
                    fontWeight: FontWeight.w400,
                    fontSize: 22,
                    height: 1.3,
                    letterSpacing: 0.7,
                    color: Color(0xFF000000),
                  ),
                ),
              ),
            ),
            Positioned(
              left: 30,
              bottom: 268,
              child: Container(
                decoration: BoxDecoration(
                  color: Color(0xFFD9D9D9),
                ),
                child: Container(
                  width: 120,
                  height: 34,
                  padding: EdgeInsets.fromLTRB(10, 3, 10, 5),
                  child: GestureDetector(
                    onTap: () {
                      Navigator.pushNamed(context, '/signIn');
                    },
                    child: Text(
                      'sign in',
                      style: GoogleFonts.getFont(
                        'Poppins',
                        fontWeight: FontWeight.w400,
                        fontSize: 20,
                        height: 1.3,
                        letterSpacing: 0.4,
                        color: Color(0xFF000000),
                      ),
                    ),
                  ),
                ),
              ),
            ),
            Positioned(
              left: 0,
              right: 0,
              bottom: 0,
              child: Container(
                width: 360,
                height: 48,
                child: Container(
                  decoration: BoxDecoration(
                    color: Color(0xFFF5F5F5),
                  ),
                  child: SizedBox(
                    width: double.infinity,
                    child: Container(
                      padding: EdgeInsets.fromLTRB(0, 16, 0, 16),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Container(
                            margin: EdgeInsets.fromLTRB(0, 1, 0, 1),
                            child: Container(
                              decoration: BoxDecoration(
                                color: Color(0xFF797979),
                                borderRadius: BorderRadius.circular(2),
                              ),
                              child: Container(
                                width: 14,
                                height: 14,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

}


