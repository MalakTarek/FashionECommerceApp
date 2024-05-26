import 'package:fashion_ecommerce/Products/product.dart';
import 'package:flutter/material.dart';

 class Rating extends StatelessWidget {
  final Product product;

  Rating(this.product);

  Widget  buildStar(BuildContext context, int index) {
    IconData icon;
    Color color;

    // Calculate the filled star count and the remaining fractional part
    int filledStars = product.overallRating.floor();
    double remainingFraction = product.overallRating - filledStars;

    // Determine the icon and color based on the index and remaining fraction
    if (index < filledStars) {
      icon = Icons.star;
      color = Colors.amber; // Color for filled stars
    } else if (index == filledStars && remainingFraction >= 0.5) {
      icon = Icons.star_half;
      color = Colors.amber; // Color for half-filled stars
    } else {
      icon = Icons.star_border;
      color = Colors.grey; // Color for empty stars
    }

    return Icon(
      icon,
      color: color,
    );
  }
  @override
  Widget build(BuildContext context) {
    return Row(
      children: List.generate(5, (index) => buildStar(context, index)),
    );
  }
}