class HomeBannerModel {
  final String id;
  final String imageUrl;
  final int sortOrder;
  final bool isActive;
  final DateTime createdAt;

  HomeBannerModel({
    required this.id,
    required this.imageUrl,
    required this.sortOrder,
    required this.isActive,
    required this.createdAt,
  });

  factory HomeBannerModel.fromMap(Map<String, dynamic> map) {
    return HomeBannerModel(
      id: map['id']?.toString() ?? '',
      imageUrl: map['image_url']?.toString() ?? '',
      sortOrder: int.tryParse(map['sort_order'].toString()) ?? 0,
      isActive: map['is_active'] == true,
      createdAt: map['created_at'] != null
          ? DateTime.tryParse(map['created_at'].toString()) ?? DateTime.now()
          : DateTime.now(),
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'image_url': imageUrl,
      'sort_order': sortOrder,
      'is_active': isActive,
    };
  }

  HomeBannerModel copyWith({
    String? id,
    String? imageUrl,
    int? sortOrder,
    bool? isActive,
    DateTime? createdAt,
  }) {
    return HomeBannerModel(
      id: id ?? this.id,
      imageUrl: imageUrl ?? this.imageUrl,
      sortOrder: sortOrder ?? this.sortOrder,
      isActive: isActive ?? this.isActive,
      createdAt: createdAt ?? this.createdAt,
    );
  }
}
