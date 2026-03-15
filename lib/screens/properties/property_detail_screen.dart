import 'package:flutter/material.dart';
import '../../models/property.dart';
import 'package:intl/intl.dart';

class PropertyDetailScreen extends StatelessWidget {
  final Property property;
  final MonthlyStatement statement;

  const PropertyDetailScreen({
    super.key,
    required this.property,
    required this.statement,
  });

  static const Color primaryPink = Color(0xFFE91E63);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF4F4F5),
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        iconTheme: const IconThemeData(color: Colors.black),
        title: const Text(
          'Detalle',
          style: TextStyle(color: Colors.black),
        ),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            _propertyHeader(),
            const SizedBox(height: 16),
            _reservationsBoxes(),
            const SizedBox(height: 16),
            _reservationsList(),
            const SizedBox(height: 16),
            _financialSummary(),
          ],
        ),
      ),
    );
  }

  /// ===============================
  /// HEADER PROPIEDAD
  /// ===============================
  Widget _propertyHeader() {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.grey.shade200),
      ),
      padding: const EdgeInsets.all(16),
      child: Row(
        children: [
          Container(
            width: 96,
            height: 96,
            decoration: BoxDecoration(
              color: Colors.grey.shade300,
              borderRadius: BorderRadius.circular(12),
            ),
            child: property.photoUrl.isEmpty
                ? const Icon(Icons.image, size: 40, color: Colors.white)
                : ClipRRect(
                    borderRadius: BorderRadius.circular(12),
                    child: Image.network(
                      property.photoUrl,
                      fit: BoxFit.cover,
                      errorBuilder: (context, error, stackTrace) {
                        return const Icon(
                          Icons.image,
                          size: 40,
                          color: Colors.white,
                        );
                      },
                    ),
                  ),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  property.airbnbListingName,
                  style: const TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                const SizedBox(height: 4),
                Row(
                  children: [
                    const Icon(
                      Icons.location_on,
                      size: 16,
                      color: Colors.grey,
                    ),
                    const SizedBox(width: 4),
                    Expanded(
                      child: Text(
                        '${property.city}, ${property.country}',
                        style: const TextStyle(fontSize: 13, color: Colors.grey),
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

  /// ===============================
  /// CAJITAS DE RESERVAS (VISTA 1)
  /// ===============================
  Widget _reservationsBoxes() {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.grey.shade200),
      ),
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    'Reservas',
                    style: TextStyle(fontWeight: FontWeight.w600),
                  ),
                  Text(
                    statement.formattedPeriod,
                    style: const TextStyle(fontSize: 12, color: Colors.grey),
                  ),
                ],
              ),
              Text(
                '${statement.reservations.length} reservas',
                style: const TextStyle(fontSize: 13, color: Colors.grey),
              ),
            ],
          ),
          const SizedBox(height: 16),
          
          // Grid de cajitas con noches
          statement.reservations.isEmpty
              ? const Center(
                  child: Padding(
                    padding: EdgeInsets.all(20),
                    child: Text(
                      'No hay reservas en este periodo',
                      style: TextStyle(color: Colors.grey),
                    ),
                  ),
                )
              : Wrap(
                  spacing: 12,
                  runSpacing: 12,
                  children: statement.reservations.map((res) {
                    return _NightBox(nights: res.nights);
                  }).toList(),
                ),
        ],
      ),
    );
  }

  /// ===============================
  /// LISTA DETALLADA DE RESERVAS (VISTA 2)
  /// ===============================
  Widget _reservationsList() {
    if (statement.reservations.isEmpty) return const SizedBox();

    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.grey.shade200),
      ),
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Detalle de Reservas',
            style: TextStyle(fontWeight: FontWeight.w600),
          ),
          const SizedBox(height: 16),
          ...statement.reservations.map((res) => _reservationItem(res)),
        ],
      ),
    );
  }

  Widget _reservationItem(Reservation reservation) {
    final dateFormat = DateFormat('dd/MM/yyyy');
    final checkInStr = dateFormat.format(reservation.checkIn);
    final checkOutStr = dateFormat.format(reservation.checkOut);

    return Padding(
      padding: const EdgeInsets.only(bottom: 16),
      child: Container(
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          color: Colors.grey.shade50,
          borderRadius: BorderRadius.circular(8),
          border: Border.all(color: Colors.grey.shade200),
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
                        reservation.guestFullName,
                        style: const TextStyle(
                          fontWeight: FontWeight.w600,
                          fontSize: 14,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        '$checkInStr - $checkOutStr',
                        style: const TextStyle(
                          fontSize: 12,
                          color: Colors.grey,
                        ),
                      ),
                    ],
                  ),
                ),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.end,
                  children: [
                    Text(
                      'S/ ${reservation.grossAmount.toStringAsFixed(2)}',
                      style: const TextStyle(
                        fontWeight: FontWeight.bold,
                        color: primaryPink,
                        fontSize: 16,
                      ),
                    ),
                    Text(
                      '${reservation.nights} noches',
                      style: const TextStyle(
                        fontSize: 12,
                        color: Colors.grey,
                      ),
                    ),
                  ],
                ),
              ],
            ),
            if (reservation.notes != null && reservation.notes!.isNotEmpty) ...[
              const SizedBox(height: 8),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                decoration: BoxDecoration(
                  color: Colors.blue.shade50,
                  borderRadius: BorderRadius.circular(4),
                ),
                child: Text(
                  reservation.notes!,
                  style: TextStyle(
                    fontSize: 11,
                    color: Colors.blue.shade700,
                  ),
                ),
              ),
            ],
            const SizedBox(height: 8),
            Row(
              children: [
                _badge(
                  reservation.status,
                  reservation.status == 'Completada' ? Colors.green : Colors.orange,
                ),
                const SizedBox(width: 8),
                _badge(reservation.source, Colors.blue),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _badge(String text, Color color) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(4),
      ),
      child: Text(
        text,
        style: TextStyle(
          fontSize: 11,
          color: color,
          fontWeight: FontWeight.w500,
        ),
      ),
    );
  }

  /// ===============================
  /// RESUMEN FINANCIERO COMPLETO
  /// ===============================
  Widget _financialSummary() {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.grey.shade200),
      ),
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Resumen Financiero',
            style: TextStyle(fontWeight: FontWeight.w600, fontSize: 16),
          ),
          const SizedBox(height: 16),

          // Total Generado
          _row(
            'Total Generado',
            '(${statement.totalNights} noches)',
            'S/ ${statement.totalGross.toStringAsFixed(2)}',
            Colors.black,
          ),

          // Comisión Airbnb
          _simpleRow(
            'Comisión Plataforma (3%)',
            '- S/ ${statement.airbnbFee3Pct.toStringAsFixed(2)}',
            Colors.red,
          ),

          // Subtotal después de Airbnb
          const Divider(height: 24),
          _simpleRow(
            'Subtotal',
            'S/ ${statement.baseAfterAirbnb.toStringAsFixed(2)}',
            Colors.grey,
          ),
          const Divider(height: 24),

          // Gastos
          _simpleRow(
            'Gastos (${statement.expenses.length} items)',
            '- S/ ${statement.totalExpenses.toStringAsFixed(2)}',
            Colors.red,
          ),

          // Subtotal después de gastos
          const Divider(height: 24),
          _simpleRow(
            'Base para comisión',
            'S/ ${statement.baseAfterExpenses.toStringAsFixed(2)}',
            Colors.grey,
          ),
          const Divider(height: 24),

          // Comisión Skybnb
          _simpleRow(
            'Comisión Skybnb (15%)',
            '- S/ ${statement.skybnbFee15Pct.toStringAsFixed(2)}',
            Colors.red,
          ),

          // IGV sobre comisión Skybnb
          _simpleRow(
            'IGV (18% sobre comisión)',
            '- S/ ${statement.igv18PctOnSkybnb.toStringAsFixed(2)}',
            Colors.red,
          ),

          const SizedBox(height: 16),
          const Divider(thickness: 2),
          const SizedBox(height: 16),

          // Ingreso Neto (DESTACADO)
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Ingreso Neto',
                    style: TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 16,
                    ),
                  ),
                  Text(
                    'Para ti',
                    style: TextStyle(fontSize: 12, color: Colors.grey),
                  ),
                ],
              ),
              Text(
                'S/ ${statement.netToOwner.toStringAsFixed(2)}',
                style: const TextStyle(
                  fontSize: 24,
                  fontWeight: FontWeight.bold,
                  color: Colors.green,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _row(String title, String subtitle, String value, Color color) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(title, style: const TextStyle(color: Colors.grey)),
              Text(
                subtitle,
                style: const TextStyle(fontSize: 11, color: Colors.grey),
              ),
            ],
          ),
          Text(
            value,
            style: TextStyle(fontWeight: FontWeight.w600, color: color),
          ),
        ],
      ),
    );
  }

  Widget _simpleRow(String title, String value, Color color) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(title, style: const TextStyle(color: Colors.grey)),
          Text(
            value,
            style: TextStyle(color: color, fontWeight: FontWeight.w500),
          ),
        ],
      ),
    );
  }
}

/// ===============================
/// CAJA DE NOCHES (COMPONENTE)
/// ===============================
class _NightBox extends StatelessWidget {
  final int nights;
  const _NightBox({required this.nights});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 80,
      height: 80,
      decoration: BoxDecoration(
        color: PropertyDetailScreen.primaryPink.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: PropertyDetailScreen.primaryPink.withValues(alpha: 0.3),
        ),
      ),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const Icon(
            Icons.bed,
            color: PropertyDetailScreen.primaryPink,
            size: 28,
          ),
          const SizedBox(height: 6),
          Text(
            '$nights días',
            style: const TextStyle(
              color: PropertyDetailScreen.primaryPink,
              fontSize: 12,
              fontWeight: FontWeight.w600,
            ),
          ),
        ],
      ),
    );
  }
}