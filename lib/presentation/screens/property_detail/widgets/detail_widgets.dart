import 'package:flutter/material.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:provider/provider.dart';
import '../../../../core/constants/app_colors.dart';
import '../../../../core/utils/date_formatter.dart';
import '../../../../core/utils/currency_formatter.dart';
import '../../../../domain/models/reservation_entity.dart';
import '../../../../domain/models/property_entity.dart';
import '../../../../application/providers/property_detail_provider.dart';
import '../../../shared/section_card.dart';
import '../../../shared/status_badge.dart';
import 'reservation_financial_bottom_sheet.dart';

// ─────────────────────────────────────────────────────────────────────────────
// PROPERTY HEADER
// ─────────────────────────────────────────────────────────────────────────────

class PropertyHeader extends StatelessWidget {
  final PropertyEntity property;
  const PropertyHeader({super.key, required this.property});

  @override
  Widget build(BuildContext context) {
    return SectionCard(
      child: Row(
        children: [
          Container(
            width: 96,
            height: 96,
            decoration: BoxDecoration(
              color: Colors.grey.shade300,
              borderRadius: BorderRadius.circular(12),
            ),
            child: ClipRRect(
              borderRadius: BorderRadius.circular(12),
              child: property.coverImage != null
                  ? CachedNetworkImage(
                      imageUrl: property.coverImage!,
                      fit: BoxFit.cover,
                      placeholder: (_, __) => const Center(
                          child: CircularProgressIndicator(strokeWidth: 2)),
                      errorWidget: (_, __, ___) =>
                          const Icon(Icons.image, size: 40, color: Colors.white),
                    )
                  : const Icon(Icons.image, size: 40, color: Colors.white),
            ),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  property.name,
                  style: const TextStyle(
                      fontSize: 16, fontWeight: FontWeight.w600),
                ),
                const SizedBox(height: 4),
                Row(
                  children: [
                    const Icon(Icons.location_on,
                        size: 15, color: AppColors.textSecondary),
                    const SizedBox(width: 4),
                    Expanded(
                      child: Text(
                        property.location.cityCountry,
                        style: const TextStyle(
                            fontSize: 13, color: AppColors.textSecondary),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// PROPERTY SUMMARY SECTION
// ─────────────────────────────────────────────────────────────────────────────

class PropertySummarySection extends StatelessWidget {
  final double totalIncome;
  final int totalReservations;

  const PropertySummarySection({
    super.key,
    required this.totalIncome,
    required this.totalReservations,
  });

  @override
  Widget build(BuildContext context) {
    return SectionCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Resumen Histórico',
            style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
          ),
          const SizedBox(height: 16),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              _SummaryBox(
                title: 'Ingreso Total',
                value: CurrencyFormatter.format(totalIncome),
                icon: Icons.attach_money,
                color: AppColors.success,
              ),
              const SizedBox(width: 12),
              _SummaryBox(
                title: 'Reservas Totales',
                value: totalReservations.toString(),
                icon: Icons.book_online,
                color: AppColors.primary,
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class _SummaryBox extends StatelessWidget {
  final String title;
  final String value;
  final IconData icon;
  final Color color;

  const _SummaryBox({
    required this.title,
    required this.value,
    required this.icon,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: Container(
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          color: color.withValues(alpha: 0.1),
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: color.withValues(alpha: 0.3)),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Icon(icon, color: color, size: 24),
            const SizedBox(height: 8),
            Text(
              value,
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: color,
              ),
            ),
            const SizedBox(height: 4),
            Text(
              title,
              style: const TextStyle(
                fontSize: 12,
                color: AppColors.textSecondary,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// PAGINATED RESERVATION LIST SECTION
// ─────────────────────────────────────────────────────────────────────────────

class ReservationPaginatedListSection extends StatelessWidget {
  final List<ReservationEntity> reservations;
  final bool canLoadMore;
  final VoidCallback onLoadMore;

  const ReservationPaginatedListSection({
    super.key,
    required this.reservations,
    required this.canLoadMore,
    required this.onLoadMore,
  });

  @override
  Widget build(BuildContext context) {
    if (reservations.isEmpty) return const SizedBox.shrink();
    
    return SectionCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text('Reservas',
              style: TextStyle(fontWeight: FontWeight.w600, fontSize: 16)),
          const SizedBox(height: 16),
          ...reservations.map((r) {
            final provider = context.read<PropertyDetailProvider>();
            return ReservationItemCard(
              reservation: r, 
              netAmount: provider.getReservationNet(r.id),
            );
          }),
          if (canLoadMore)
            Center(
              child: TextButton.icon(
                onPressed: onLoadMore,
                icon: const Icon(Icons.expand_more, color: AppColors.primary),
                label: const Text(
                  'Ver más reservas',
                  style: TextStyle(color: AppColors.primary),
                ),
              ),
            ),
        ],
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// RESERVATION ITEM CARD
// ─────────────────────────────────────────────────────────────────────────────

class ReservationItemCard extends StatelessWidget {
  final ReservationEntity reservation;
  final double netAmount;
  
  const ReservationItemCard({
    super.key, 
    required this.reservation,
    required this.netAmount,
  });

  void _showFinancialSummary(BuildContext context) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (_) => ReservationFinancialBottomSheet(reservation: reservation),
    );
  }

  @override
  Widget build(BuildContext context) {
    final guest = reservation.primaryGuest;
    final checkIn = DateFormatter.toFull(reservation.stay.checkIn);
    final checkOut = DateFormatter.toFull(reservation.stay.checkOut);

    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: InkWell(
        onTap: () => _showFinancialSummary(context),
        borderRadius: BorderRadius.circular(12),
        child: Container(
          padding: const EdgeInsets.all(12),
          decoration: BoxDecoration(
            color: Colors.grey.shade50,
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: AppColors.border),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          guest?.name ?? '—',
                          style: const TextStyle(
                              fontWeight: FontWeight.w600, fontSize: 14),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          '$checkIn - $checkOut',
                          style: const TextStyle(
                              fontSize: 12, color: AppColors.textSecondary),
                        ),
                      ],
                    ),
                  ),
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.end,
                    children: [
                      Text(
                        CurrencyFormatter.format(netAmount),
                        style: const TextStyle(
                          fontWeight: FontWeight.bold,
                          color: AppColors.primary,
                          fontSize: 16,
                        ),
                      ),
                      Text(
                        '${reservation.stay.nights} noches',
                        style: const TextStyle(
                            fontSize: 12, color: AppColors.textSecondary),
                      ),
                    ],
                  ),
                ],
              ),
              const SizedBox(height: 12),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Row(
                    children: [
                      StatusBadge(
                        text: reservation.status,
                        color: reservation.isCompleted
                            ? AppColors.success
                            : AppColors.warning,
                      ),
                      const SizedBox(width: 8),
                      StatusBadge(text: reservation.source, color: AppColors.info),
                    ],
                  ),
                  const Text(
                    'Ver finanzas',
                    style: TextStyle(
                      color: AppColors.primary,
                      fontSize: 12,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// GUEST AVATAR (full size) — usado en calendario
// ─────────────────────────────────────────────────────────────────────────────

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
                placeholder: (_, __) => _Initials(initials, size),
                errorWidget: (_, __, ___) => _Initials(initials, size),
              )
            : _Initials(initials, size),
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
                errorWidget: (_, __, ___) => _Initials(initials, 20, fontSize: 8),
              )
            : _Initials(initials, 20, fontSize: 8),
      ),
    );
  }
}

class _Initials extends StatelessWidget {
  final String text;
  final double size;
  final double fontSize;

  const _Initials(this.text, this.size, {this.fontSize = 16});

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
