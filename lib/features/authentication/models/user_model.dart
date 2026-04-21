import 'package:supabase_flutter/supabase_flutter.dart' as sb;

class UserModel {
  final String id;
  String name;
  String email;
  String profilePicture;
  String phone;
  String pincode;
  String address;
  String city;
  String state;
  String country;
  bool isAdmin;

  UserModel({
    required this.id,
    required this.name,
    required this.email,
    this.profilePicture = "",
    this.phone = "",
    this.pincode = "",
    this.address = "",
    this.city = "",
    this.state = "",
    this.country = "",
    this.isAdmin = false,
  });

  /// ststic function to create an empty user model 
  static UserModel empty() => UserModel(id: '', name: '', email: '');


  /// Factory method to create user model from a Supabase map
  factory UserModel.fromMap(Map<String, dynamic> data) {
    return UserModel(
      id: data['id'] ?? '',
      name: data['name'] ?? '',
      email: data['email'] ?? '',
      profilePicture: data['profile_picture'] ?? '',
      phone: data['phone_number'] ?? '',
      pincode: data['pincode'] ?? '',
      address: data['address'] ?? '',
      city: data['city'] ?? '',
      state: data['state'] ?? '',
      country: data['country'] ?? '',
      isAdmin: data['is_admin'] ?? false,
    );
  }

  /// Convert model to Supabase Map
  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'name': name,
      'email': email,
      'profile_picture': profilePicture,
      'phone_number': phone,
      'pincode': pincode,
      'address': address,
      'city': city,
      'state': state,
      'country': country,
      'is_admin': isAdmin,
    };
  }
}
