import 'package:flutter/foundation.dart';

/// Entidad de dominio: Usuario (propietario autenticado).
/// Alineado al schema MongoDB: Users Collection.
/// No incluye password_hash (nunca expuesto al cliente).
/// No incluye timestamps de auditoría (sin valor de negocio en la UI).
@immutable
class UserEntity {
  final String id;           // _id
  final String username;
  final String fullName;
  final String dni;
  final String phone;
  final String email;
  final String? profilePictureUrl;
  final String status;       // active | inactive

  const UserEntity({
    required this.id,
    required this.username,
    required this.fullName,
    required this.dni,
    required this.phone,
    required this.email,
    required this.status,
    this.profilePictureUrl,
  });

  bool get isActive => status == 'active';

  /// Iniciales para avatar cuando no hay foto.
  String get initials {
    final parts = fullName.trim().split(RegExp(r'\s+'));
    if (parts.isEmpty) return '?';
    if (parts.length == 1) return parts.first[0].toUpperCase();
    return '${parts.first[0]}${parts.last[0]}'.toUpperCase();
  }

  @override
  bool operator ==(Object other) => other is UserEntity && id == other.id;

  @override
  int get hashCode => id.hashCode;
}
