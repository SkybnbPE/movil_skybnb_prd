import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:skybnb/core/constants/app_colors.dart';
import 'package:skybnb/domain/models/reservation_entity.dart';

class GuestAvatar extends StatelessWidget {
  final ReservationEntity reservation;
  final double size;

  const GuestAvatar({super.key, required this.reservation, this.size = 50});

  @override
  Widget build(BuildContext context) {
    final guest = reservation.primaryGuest;
    final picUrl = guest?.profilePictureUrl;
    final initials = guest?.initials ?? '?';

    return Container(
      width: size,
      height: size,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        color: AppColors.primary.withValues(alpha: 0.2),
        border: Border.all(color: AppColors.primary, width: 2),
      ),
      child: ClipOval(
        child: picUrl != null && picUrl.isNotEmpty
            ? CachedNetworkImage(
                imageUrl: picUrl,
                fit: BoxFit.cover,
                placeholder: (_, __) => Initials(initials, size),
                errorWidget: (_, __, ___) => Initials(initials, size),
              )
            : Initials(initials, size),
      ),
    );
  }
}

class GuestMiniAvatar extends StatelessWidget {
  final ReservationEntity reservation;
  const GuestMiniAvatar({super.key, required this.reservation});

  @override
  Widget build(BuildContext context) {
    final guest = reservation.primaryGuest;
    final picUrl = guest?.profilePictureUrl;
    final initials = guest?.initials ?? '?';

    return Container(
      width: 20,
      height: 20,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        color: Colors.white,
        border: Border.all(color: AppColors.primary, width: 1.5),
      ),
      child: ClipOval(
        child: picUrl != null && picUrl.isNotEmpty
            ? CachedNetworkImage(
                imageUrl: picUrl,
                fit: BoxFit.cover,
                errorWidget: (_, __, ___) => Initials(initials, 20, fontSize: 8),
              )
            : Initials(initials, 20, fontSize: 8),
      ),
    );
  }
}

class Initials extends StatelessWidget {
  final String text;
  final double size;
  final double fontSize;

  const Initials(this.text, this.size, {super.key, this.fontSize = 16});

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Text(
        text,
        style: TextStyle(
          color: AppColors.primary,
          fontWeight: FontWeight.bold,
          fontSize: fontSize,
        ),
      ),
    );
  }
}
