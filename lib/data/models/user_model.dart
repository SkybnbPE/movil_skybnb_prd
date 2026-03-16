import '../../domain/models/user/user_entity.dart';

/// DTO alineado al schema MongoDB: Users Collection.
/// Maneja la serialización/deserialización JSON del API.
class UserModel {
  final String id;
  final String username;
  final String fullName;
  final String dni;
  final String phone;
  final String email;
  final String? profilePictureUrl;
  final String status;

  const UserModel({
    required this.id,
    required this.username,
    required this.fullName,
    required this.dni,
    required this.phone,
    required this.email,
    this.profilePictureUrl,
    required this.status,
  });

  factory UserModel.fromJson(Map<String, dynamic> json) {
    return UserModel(
      id: json['_id'] as String,
      username: json['username'] as String,
      fullName: json['full_name'] as String,
      dni: json['dni'] as String,
      phone: json['phone'] as String,
      email: json['email'] as String,
      profilePictureUrl: json['profile_picture_url'] as String?,
      status: json['status'] as String,
    );
  }

  Map<String, dynamic> toJson() => {
        '_id': id,
        'username': username,
        'full_name': fullName,
        'dni': dni,
        'phone': phone,
        'email': email,
        'profile_picture_url': profilePictureUrl,
        'status': status,
      };

  UserEntity toEntity() => UserEntity(
        id: id,
        username: username,
        fullName: fullName,
        dni: dni,
        phone: phone,
        email: email,
        profilePictureUrl: profilePictureUrl,
        status: status,
      );
}
