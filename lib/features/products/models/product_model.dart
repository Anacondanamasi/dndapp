class ProductModel {
  final String id;
  final String name;
  final double price;
  final double? originalPrice;
  final String description;
  final List<String> imageUrls;
  final List<String> availableSizes;
  final bool isFeatured;
  final double rating;
  final int soldCount;
  final int reviewCount;
  final String categoryName;
  final String categoryId;
  final int stockQuantity;
  final DateTime createdAt;
  final bool isActive;
  final String gender;
  final String productTag;

  ProductModel({
    required this.id,
    required this.name,
    required this.price,
    this.originalPrice,
    required this.isFeatured,
    required this.description,
    required this.imageUrls,
    required this.availableSizes,
    this.rating = 0.0,
    required this.soldCount,
    this.reviewCount = 0,
    required this.categoryName,
    required this.categoryId,
    this.stockQuantity = 0,
    required this.createdAt,
    this.isActive = true,
    this.gender = 'All',
    this.productTag = 'none',
  });

  static ProductModel empty() => ProductModel(
      id: '',
      name: '',
      price: 0,
      description: '',
      isFeatured: false,
      imageUrls: List.empty(),
      availableSizes: List.empty(),
      categoryName: '',
      createdAt: DateTime.now(),
      soldCount: 0,
      categoryId: '',
      isActive: true,
      gender: 'All',
      productTag: 'none');

  /// Factory constructor to create ProductModel from Supabase Map
  factory ProductModel.fromMap(Map<String, dynamic> data) {
    return ProductModel(
      id: data['id'] ?? '',
      name: data['name'] ?? '',
      price: (data['price'] ?? 0).toDouble(),
      originalPrice: data['original_price'] != null
          ? (data['original_price']).toDouble()
          : null,
      description: data['description'] ?? '',
      imageUrls: List<String>.from(data['image_urls'] ?? []),
      availableSizes: List<String>.from(data['available_sizes'] ?? []),
      rating: (data['rating'] ?? 0.0).toDouble(),
      isFeatured: data['is_featured'] ?? false,
      reviewCount: data['review_count'] ?? 0,
      soldCount: data['sold_count'] ?? 0,
      categoryName: data['category_name'] ?? '',
      categoryId: data['category_id'] ?? '',
      stockQuantity: data['stock_quantity'] ?? 0,
      createdAt: data['created_at'] != null
          ? DateTime.parse(data['created_at'])
          : DateTime.now(),
      isActive: data['is_active'] ?? true,
      gender: data['gender'] ?? 'All',
      productTag: data['product_tag'] ?? 'none',
    );
  }

  /// Convert ProductModel to Supabase Map
  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'name': name,
      'price': price,
      'original_price': originalPrice,
      'description': description,
      'image_urls': imageUrls,
      'available_sizes': availableSizes,
      'rating': rating,
      'review_count': reviewCount,
      'is_featured': isFeatured,
      'category_name': categoryName,
      'category_id': categoryId,
      'sold_count': soldCount,
      'stock_quantity': stockQuantity,
      'created_at': createdAt.toIso8601String(),
      'is_active': isActive,
      'gender': gender,
      'product_tag': productTag,
    };
  }

  /// Copy with method for updating product
  ProductModel copyWith({
    String? id,
    String? name,
    double? price,
    double? originalPrice,
    String? description,
    List<String>? imageUrls,
    List<String>? availableSizes,
    double? rating,
    bool? isFeatured,
    int? reviewCount,
    String? categoryName,
    String? categoryId,
    int? stockQuantity,
    DateTime? createdAt,
    int? soldCount,
    bool? isActive,
    String? gender,
    String? productTag,
  }) {
    return ProductModel(
      id: id ?? this.id,
      name: name ?? this.name,
      price: price ?? this.price,
      isFeatured: isFeatured ?? this.isFeatured,
      originalPrice: originalPrice ?? this.originalPrice,
      description: description ?? this.description,
      imageUrls: imageUrls ?? this.imageUrls,
      availableSizes: availableSizes ?? this.availableSizes,
      rating: rating ?? this.rating,
      soldCount: soldCount ?? this.soldCount,
      reviewCount: reviewCount ?? this.reviewCount,
      categoryName: categoryName ?? this.categoryName,
      categoryId: categoryId ?? this.categoryId,
      stockQuantity: stockQuantity ?? this.stockQuantity,
      createdAt: createdAt ?? this.createdAt,
      isActive: isActive ?? this.isActive,
      gender: gender ?? this.gender,
      productTag: productTag ?? this.productTag,
    );
  }
}
