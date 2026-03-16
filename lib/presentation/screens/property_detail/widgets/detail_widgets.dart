import 'package:flutter/material.dart';
import 'package:cached_network_image/cached_network_image.dart';
import '../../../../core/constants/app_colors.dart';
import '../../../../core/utils/date_formatter.dart';
import '../../../../core/utils/currency_formatter.dart';
import '../../../../domain/models/reservation_entity.dart';
import '../../../../domain/models/monthly_statement_result.dart';
import '../../../../domain/models/property_entity.dart';
import '../../../shared/section_card.dart';
import '../../../shared/status_badge.dart';

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
                  ? Image.network(
                      property.coverImage!,
                      fit: BoxFit.cover,
                      errorBuilder: (_, __, ___) =>
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
// RESERVATION BOXES SECTION — cajitas de noches
// ─────────────────────────────────────────────────────────────────────────────

class ReservationBoxesSection extends StatelessWidget {
  final MonthlyStatementResult statement;
  const ReservationBoxesSection({super.key, required this.statement});

  @override
  Widget build(BuildContext context) {
    return SectionCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text('Reservas',
                      style: TextStyle(fontWeight: FontWeight.w600)),
                  Text(
                    statement.formattedPeriod,
                    style: const TextStyle(
                        fontSize: 12, color: AppColors.textSecondary),
                  ),
                ],
              ),
              Text(
                '${statement.reservations.length} reservas',
                style: const TextStyle(
                    fontSize: 13, color: AppColors.textSecondary),
              ),
            ],
          ),
          const SizedBox(height: 16),
          statement.reservations.isEmpty
              ? const Center(
                  child: Padding(
                    padding: EdgeInsets.all(20),
                    child: Text(
                      'No hay reservas en este periodo',
                      style: TextStyle(color: AppColors.textSecondary),
                    ),
                  ),
                )
              : Wrap(
                  spacing: 12,
                  runSpacing: 12,
                  children: statement.reservations
                      .map((r) => NightBox(nights: r.stay.nights))
                      .toList(),
                ),
        ],
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// NIGHT BOX — cajita individual de noches
// ─────────────────────────────────────────────────────────────────────────────

class NightBox extends StatelessWidget {
  final int nights;
  const NightBox({super.key, required this.nights});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 80,
      height: 80,
      decoration: BoxDecoration(
        color: AppColors.primary.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: AppColors.primary.withValues(alpha: 0.3)),
      ),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const Icon(Icons.bed, color: AppColors.primary, size: 28),
          const SizedBox(height: 6),
          Text(
            '$nights días',
            style: const TextStyle(
              color: AppColors.primary,
              fontSize: 12,
              fontWeight: FontWeight.w600,
            ),
          ),
        ],
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// RESERVATION LIST SECTION
// ─────────────────────────────────────────────────────────────────────────────

class ReservationListSection extends StatelessWidget {
  final List<ReservationEntity> reservations;
  const ReservationListSection({super.key, required this.reservations});

  @override
  Widget build(BuildContext context) {
    if (reservations.isEmpty) return const SizedBox.shrink();
    return SectionCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text('Detalle de Reservas',
              style: TextStyle(fontWeight: FontWeight.w600)),
          const SizedBox(height: 16),
          ...reservations.map((r) => ReservationItemCard(reservation: r)),
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
  const ReservationItemCard({super.key, required this.reservation});

  @override
  Widget build(BuildContext context) {
    final guest = reservation.primaryGuest;
    final checkIn = DateFormatter.toFull(reservation.stay.checkIn);
    final checkOut = DateFormatter.toFull(reservation.stay.checkOut);

    return Padding(
      padding: const EdgeInsets.only(bottom: 16),
      child: Container(
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          color: Colors.grey.shade50,
          borderRadius: BorderRadius.circular(8),
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
                      CurrencyFormatter.format(
                          reservation.pricing.grossAmount),
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
            if (reservation.notes != null &&
                reservation.notes!.isNotEmpty) ...[
              const SizedBox(height: 8),
              Container(
                padding:
                    const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                decoration: BoxDecoration(
                  color: Colors.blue.shade50,
                  borderRadius: BorderRadius.circular(4),
                ),
                child: Text(
                  reservation.notes!,
                  style: TextStyle(fontSize: 11, color: Colors.blue.shade700),
                ),
              ),
            ],
            const SizedBox(height: 8),
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
          ],
        ),
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// FINANCIAL SUMMARY SECTION
// ─────────────────────────────────────────────────────────────────────────────

class FinancialSummarySection extends StatelessWidget {
  final MonthlyStatementResult statement;
  const FinancialSummarySection({super.key, required this.statement});

  @override
  Widget build(BuildContext context) {
    return SectionCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Resumen Financiero',
            style: TextStyle(fontWeight: FontWeight.w600, fontSize: 16),
          ),
          const SizedBox(height: 16),
          _FinRow(
            title: 'Total Generado',
            subtitle: '(${statement.totalNights} noches)',
            value: CurrencyFormatter.format(statement.totalGross),
            color: AppColors.textPrimary,
          ),
          _FinRow(
            title: 'Comisión Plataforma (3%)',
            value:
                '- ${CurrencyFormatter.format(statement.platformFee3Pct)}',
            color: AppColors.error,
          ),
          const Divider(height: 24),
          _FinRow(
            title: 'Subtotal',
            value: CurrencyFormatter.format(statement.baseAfterPlatform),
            color: AppColors.textSecondary,
          ),
          const Divider(height: 24),
          _FinRow(
            title: 'Gastos (${statement.expenses.length} items)',
            value:
                '- ${CurrencyFormatter.format(statement.totalExpenses)}',
            color: AppColors.error,
          ),
          const Divider(height: 24),
          _FinRow(
            title: 'Base para comisión',
            value:
                CurrencyFormatter.format(statement.baseAfterExpenses),
            color: AppColors.textSecondary,
          ),
          const Divider(height: 24),
          _FinRow(
            title: 'Comisión Skybnb (15%)',
            value:
                '- ${CurrencyFormatter.format(statement.skybnbFee15Pct)}',
            color: AppColors.error,
          ),
          _FinRow(
            title: 'IGV (18% sobre comisión)',
            value:
                '- ${CurrencyFormatter.format(statement.igv18PctOnSkybnb)}',
            color: AppColors.error,
          ),
          const SizedBox(height: 16),
          const Divider(thickness: 2),
          const SizedBox(height: 16),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text('Ingreso Neto',
                      style: TextStyle(
                          fontWeight: FontWeight.bold, fontSize: 16)),
                  Text('Para ti',
                      style: TextStyle(
                          fontSize: 12, color: AppColors.textSecondary)),
                ],
              ),
              Text(
                CurrencyFormatter.format(statement.netToOwner),
                style: const TextStyle(
                  fontSize: 24,
                  fontWeight: FontWeight.bold,
                  color: AppColors.success,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class _FinRow extends StatelessWidget {
  final String title;
  final String? subtitle;
  final String value;
  final Color color;

  const _FinRow({
    required this.title,
    this.subtitle,
    required this.value,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(title,
                  style: const TextStyle(color: AppColors.textSecondary)),
              if (subtitle != null)
                Text(subtitle!,
                    style: const TextStyle(
                        fontSize: 11, color: AppColors.textSecondary)),
            ],
          ),
          Text(value,
              style:
                  TextStyle(fontWeight: FontWeight.w500, color: color)),
        ],
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

// ─────────────────────────────────────────────────────────────────────────────
// GUEST MINI AVATAR — usado en celdas del calendario
// ─────────────────────────────────────────────────────────────────────────────

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

// ─────────────────────────────────────────────────────────────────────────────
// RESERVATION CARD — lista debajo del calendario
// ─────────────────────────────────────────────────────────────────────────────

class ReservationCard extends StatelessWidget {
  final ReservationEntity reservation;
  const ReservationCard({super.key, required this.reservation});

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: AppColors.primaryLight.withValues(alpha: 0.2),
        borderRadius: BorderRadius.circular(12),
        border:
            Border.all(color: AppColors.primary.withValues(alpha: 0.3)),
      ),
      child: Row(
        children: [
          GuestAvatar(reservation: reservation),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  reservation.primaryGuest?.name ?? '—',
                  style: const TextStyle(
                      fontWeight: FontWeight.bold, fontSize: 14),
                ),
                const SizedBox(height: 4),
                Text(
                  '${DateFormatter.toDayMonth(reservation.stay.checkIn)}'
                  ' - ${DateFormatter.toDayMonth(reservation.stay.checkOut)}',
                  style: const TextStyle(
                      fontSize: 12, color: AppColors.textSecondary),
                ),
                Text(
                  '${reservation.stay.nights} noches',
                  style: const TextStyle(
                      fontSize: 12,
                      color: AppColors.primary,
                      fontWeight: FontWeight.w500),
                ),
              ],
            ),
          ),
          Text(
            CurrencyFormatter.formatRounded(
                reservation.pricing.grossAmount),
            style: const TextStyle(
              fontWeight: FontWeight.bold,
              fontSize: 16,
              color: AppColors.primary,
            ),
          ),
        ],
      ),
    );
  }
}
