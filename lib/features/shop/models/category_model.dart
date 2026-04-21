class CategoryModel {
  final String id;
  final String name;
  final String image;
  final bool isFeatured;
  final String parentId;
  final bool isActive;

  CategoryModel({
    required this.id,
    required this.name,
    required this.image,
    required this.isFeatured,
    this.parentId = '',
    this.isActive = true,
  });

  static CategoryModel empty() => CategoryModel(
        id: '',
        name: '',
        image: '',
        isFeatured: false,
        isActive: true,
      );

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'image_url': image,
      'is_featured': isFeatured,
      'parent_id': parentId,
      'is_active': isActive,
    };
  }

  factory CategoryModel.fromMap(Map<String, dynamic> data) {
    return CategoryModel(
      id: data['id']?.toString() ?? '',
      name: data['name']?.toString() ?? '',
      image: (data['image'] ?? data['image_url'] ?? '').toString(),
      isFeatured: data['is_featured'] == true,
      parentId: (data['parent_id'] ?? '').toString(),
      isActive: data['is_active'] ?? true,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'name': name,
      'image_url': image,
      'is_featured': isFeatured,
      'parent_id': parentId,
      'is_active': isActive,
    };
  }

  CategoryModel copyWith({
    String? id,
    String? name,
    String? image,
    bool? isFeatured,
    String? parentId,
    bool? isActive,
  }) {
    return CategoryModel(
      id: id ?? this.id,
      name: name ?? this.name,
      image: image ?? this.image,
      isFeatured: isFeatured ?? this.isFeatured,
      parentId: parentId ?? this.parentId,
      isActive: isActive ?? this.isActive,
    );
  }
}
