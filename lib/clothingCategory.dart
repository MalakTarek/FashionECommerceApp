enum ClothingCategory {
  all, // Add 'all' as the first option
  pants,
  shirts,
  dresses,
  bags,
  accessories,
  shoes,
}

extension CategoryExtension on ClothingCategory {
  String get name {
    switch (this) {
      case ClothingCategory.all:
        return 'All'; // Provide a name for the 'all' category
      case ClothingCategory.pants:
        return 'Pants';
      case ClothingCategory.shirts:
        return 'Shirts';
      case ClothingCategory.dresses:
        return 'Dresses';
      case ClothingCategory.bags:
        return 'Bags';
      case ClothingCategory.accessories:
        return 'Accessories';
      case ClothingCategory.shoes:
        return 'Shoes';
    }
  }

  static ClothingCategory fromString(String category) {
    switch (category) {
      case 'All': // Adjust the string match for 'all'
        return ClothingCategory.all;
      case 'Pants':
        return ClothingCategory.pants;
      case 'Shirts':
        return ClothingCategory.shirts;
      case 'Dresses':
        return ClothingCategory.dresses;
      case 'Bags':
        return ClothingCategory.bags;
      case 'Accessories':
        return ClothingCategory.accessories;
      case 'Shoes':
        return ClothingCategory.shoes;
      default:
        throw Exception('Unknown category: $category');
    }
  }
}