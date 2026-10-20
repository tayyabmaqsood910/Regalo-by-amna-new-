import 'dart:typed_data';

class Product {
  const Product({
    required this.id,
    required this.name,
    required this.price,
    this.imagePath,
    this.imageBytes,
    this.category,
    this.description,
  });

  final String id;
  final String name;
  final String? imagePath;
  final Uint8List? imageBytes;
  final String? category;
  final double price;
  final String? description;

  Product copyWith({
    String? id,
    String? name,
    String? imagePath,
    Uint8List? imageBytes,
    String? category,
    double? price,
    String? description,
    bool clearImage = false,
    bool clearCategory = false,
    bool clearDescription = false,
  }) {
    return Product(
      id: id ?? this.id,
      name: name ?? this.name,
      imagePath: clearImage ? null : (imagePath ?? this.imagePath),
      imageBytes: clearImage ? null : (imageBytes ?? this.imageBytes),
      category: clearCategory ? null : (category ?? this.category),
      price: price ?? this.price,
      description: clearDescription ? null : (description ?? this.description),
    );
  }
}

abstract final class ProductCategory {
  static const roses = 'Roses';
  static const bouquets = 'Bouquets';
  static const stems = 'Stems';
  static const extras = 'Extras';
}
