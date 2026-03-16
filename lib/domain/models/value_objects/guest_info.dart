/// Información de un huésped dentro de una reserva.
class GuestInfo {
  final String guestId;
  final String name;
  final String? profilePictureUrl;
  final bool isPrimary;

  const GuestInfo({
    required this.guestId,
    required this.name,
    this.profilePictureUrl,
    required this.isPrimary,
  });

  /// Iniciales para mostrar cuando no hay foto de perfil.
  String get initials {
    final parts = name.trim().split(RegExp(r'\s+'));
    if (parts.isEmpty) return '?';
    if (parts.length == 1) return parts.first[0].toUpperCase();
    return '${parts.first[0]}${parts.last[0]}'.toUpperCase();
  }

  @override
  bool operator ==(Object other) =>
      other is GuestInfo && guestId == other.guestId;

  @override
  int get hashCode => guestId.hashCode;
}
