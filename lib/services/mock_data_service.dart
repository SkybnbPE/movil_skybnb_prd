/// ===============================
/// MOCK DATA SERVICE
/// ===============================
/// Simula la conexión a Google Sheets
/// En FASE 2, este servicio será reemplazado por el servicio real de Google Sheets API

import '../models/property.dart';

class MockDataService {
  /// Simula el login del usuario
  /// En producción, esto validará contra USUARIOS sheet
  static Future<String?> login(String username, String password) async {
    await Future.delayed(const Duration(milliseconds: 500)); // Simula red

    // Mock: usuario de prueba
    if (username == 'jrodriguez' && password == '123456') {
      return 'OWN-0001'; // Retorna owner_id de Julia Rodríguez
    }

    return null; // Login fallido
  }

  /// Obtiene las propiedades de un owner
  static Future<List<Property>> getPropertiesByOwner(String ownerId) async {
    await Future.delayed(const Duration(milliseconds: 300));

    // Mock basado en hoja PROPIEDADES
    return [
      Property(
        propertyId: 'PRP-0001',
        ownerId: 'OWN-0001',
        airbnbListingName: 'Hermoso y elegante 1BR Limite con San Isidro',
        address: 'Av. Javier Prado Este 1095 dpto. 2105, La Victoria',
        photoUrl:
            'https://a0.muscache.com/im/pictures/hosting/Hosting-1582730629766453455/original/48b179e7-c3f2-46b2-b4f8-dbdc4c2831f0.jpeg?im_w=1200',
        city: 'Lima',
        country: 'Perú',
        pricePerNight: 130.0,
      ),
    ];
  }

  /// Obtiene las reservas de una propiedad en un periodo
  static Future<List<Reservation>> getReservations(
    String propertyId,
    String periodMonth,
  ) async {
    await Future.delayed(const Duration(milliseconds: 300));

    // Mock basado en hoja RESERVAS
    if (propertyId == 'PRP-0001' && periodMonth == '2026-01') {
      return [
        Reservation(
          reservationId: 'HMDHPAHCPY',
          propertyId: 'PRP-0001',
          source: 'Airbnb',
          status: 'Completada',
          guestFullName: 'Jeniffer Chipana',
          checkIn: DateTime(2026, 1, 6),
          checkOut: DateTime(2026, 1, 11),
          nights: 5,
          grossAmount: 649.6,
          currency: 'Soles',
          notes: '2/3 reservas con descuento',
          periodMonth: '2026-01',
        ),
        Reservation(
          reservationId: 'HMZSFYSAR9',
          propertyId: 'PRP-0001',
          source: 'Airbnb',
          status: 'Completada',
          guestFullName: 'Roxana Parada De Vega',
          checkIn: DateTime(2026, 1, 13),
          checkOut: DateTime(2026, 1, 18),
          nights: 5,
          grossAmount: 650.0,
          currency: 'Soles',
          notes: 'Precio normal',
          periodMonth: '2026-01',
        ),
        Reservation(
          reservationId: 'HM8KWE9JK2',
          propertyId: 'PRP-0001',
          source: 'Airbnb',
          status: 'En curso',
          guestFullName: 'Gianella Paredes',
          checkIn: DateTime(2026, 1, 18),
          checkOut: DateTime(2026, 1, 24),
          nights: 6,
          grossAmount: 756.8,
          currency: 'Soles',
          notes: '3/3 reservas con descuento',
          periodMonth: '2026-01',
        ),
      ];
    } else if (propertyId == 'PRP-0001' && periodMonth == '2025-12') {
      return [
        Reservation(
          reservationId: 'HMKZY4C9RA',
          propertyId: 'PRP-0001',
          source: 'Airbnb',
          status: 'Completada',
          guestFullName: 'Maria Elena Del Aguila',
          checkIn: DateTime(2025, 12, 31),
          checkOut: DateTime(2026, 1, 5),
          nights: 5,
          grossAmount: 681.6,
          currency: 'Soles',
          notes: '1/3 reservas con descuento',
          periodMonth: '2025-12',
        ),
      ];
    }

    return [];
  }

  /// Obtiene los gastos de una propiedad en un periodo
  static Future<List<Expense>> getExpenses(
    String propertyId,
    String periodMonth,
  ) async {
    await Future.delayed(const Duration(milliseconds: 300));

    // Mock basado en hoja GASTOS
    if (propertyId == 'PRP-0001' && periodMonth == '2026-01') {
      return [
        Expense(
          expenseId: 'EXP-0002',
          propertyId: 'PRP-0001',
          periodMonth: '2026-01',
          category: 'Tarifa de Limpieza',
          amount: 80,
          description: 'Tarifa de limpieza',
        ),
        Expense(
          expenseId: 'EXP-0003',
          propertyId: 'PRP-0001',
          periodMonth: '2026-01',
          category: 'Tarifa de Limpieza',
          amount: 80,
          description: 'Tarifa de limpieza',
        ),
        Expense(
          expenseId: 'EXP-0004',
          propertyId: 'PRP-0001',
          periodMonth: '2026-01',
          category: 'Tarifa de Limpieza',
          amount: 80,
          description: 'Tarifa de limpieza',
        ),
      ];
    } else if (propertyId == 'PRP-0001' && periodMonth == '2025-12') {
      return [
        Expense(
          expenseId: 'EXP-0001',
          propertyId: 'PRP-0001',
          periodMonth: '2025-12',
          category: 'Tarifa de Limpieza',
          amount: 80,
          description: 'Tarifa de limpieza',
        ),
      ];
    }

    return [];
  }

  /// Obtiene la liquidación mensual completa
  static Future<MonthlyStatement> getMonthlyStatement(
    String propertyId,
    String periodMonth,
  ) async {
    // Obtener reservas y gastos
    final reservations = await getReservations(propertyId, periodMonth);
    final expenses = await getExpenses(propertyId, periodMonth);

    // Calcular totales (basado en hoja LIQUIDACIONES)
    final totalGross = reservations.fold(
      0.0,
      (sum, res) => sum + res.grossAmount,
    );

    final airbnbFee3Pct = totalGross * 0.03;
    final baseAfterAirbnb = totalGross - airbnbFee3Pct;

    final totalExpenses = expenses.fold(
      0.0,
      (sum, exp) => sum + exp.amount,
    );

    final baseAfterExpenses = baseAfterAirbnb - totalExpenses;
    final skybnbFee15Pct = baseAfterExpenses * 0.15;
    final igv18PctOnSkybnb = skybnbFee15Pct * 0.18;
    final netToOwner = baseAfterExpenses - skybnbFee15Pct - igv18PctOnSkybnb;

    return MonthlyStatement(
      propertyId: propertyId,
      periodMonth: periodMonth,
      totalGross: totalGross,
      airbnbFee3Pct: airbnbFee3Pct,
      baseAfterAirbnb: baseAfterAirbnb,
      totalExpenses: totalExpenses,
      baseAfterExpenses: baseAfterExpenses,
      skybnbFee15Pct: skybnbFee15Pct,
      igv18PctOnSkybnb: igv18PctOnSkybnb,
      netToOwner: netToOwner,
      reservations: reservations,
      expenses: expenses,
    );
  }

  /// Obtiene los periodos disponibles (meses con data)
  static Future<List<String>> getAvailablePeriods(String propertyId) async {
    await Future.delayed(const Duration(milliseconds: 200));

    // Mock: periodos con data
    if (propertyId == 'PRP-0001') {
      return ['2026-01', '2025-12'];
    }

    return [];
  }
}