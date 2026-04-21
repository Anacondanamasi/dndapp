import 'package:supabase_flutter/supabase_flutter.dart' as sb;

class ReviewModel {
  final String id;
  final String productId;
  final String userId;
  final String userName;
  final String? profilePicture;
  final double rating;
  final String comment;
  final DateTime createdAt;

  ReviewModel({
    required this.id,
    required this.productId,
    required this.userId,
    required this.userName,
    this.profilePicture,
    required this.rating,
    required this.comment,
    required this.createdAt,
  });

  static ReviewModel empty() => ReviewModel(id: '', productId: '', userId: '', userName: '', rating: 0.0, comment: '', createdAt: DateTime.now());


  /// Factory constructor to create ReviewModel from Supabase Map
  factory ReviewModel.fromMap(Map<String, dynamic> data) {
    return ReviewModel(
      id: data['id'] ?? '',
      productId: data['product_id'] ?? '',
      userId: data['user_id'] ?? '',
      userName: data['user_name'] ?? '', // Note: In Supabase we might join with profiles table
      profilePicture: data['profile_picture'] ?? '',
      rating: (data['rating'] ?? 0).toDouble(),
      comment: data['comment'] ?? '',
      createdAt: data['created_at'] != null ? DateTime.parse(data['created_at']) : DateTime.now(),
    );
  }

  /// Convert ReviewModel to Supabase Map
  Map<String, dynamic> toMap() {
    return {
      'product_id': productId,
      'user_id': userId,
      'user_name': userName,
      'profile_picture': profilePicture,
      'rating': rating,
      'comment': comment,
      'created_at': createdAt.toIso8601String(),
    };
  }
}
