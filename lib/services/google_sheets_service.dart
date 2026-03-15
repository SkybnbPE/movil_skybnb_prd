/// ===============================
/// GOOGLE SHEETS SERVICE V3
/// ===============================
/// Con soporte para perfil de propietario y fotos de huéspedes

import 'dart:convert';
import 'package:flutter/services.dart' show rootBundle;
import 'package:googleapis/sheets/v4.dart';
import 'package:googleapis_auth/auth_io.dart';
import '../models/property.dart';

class GoogleSheetsService {
  static const String _spreadsheetId = '1ZWqUfaeF_JNg86XSCyMMMa1SQ2W8i4x8fWY1njgZxxw';
  static const String _credentialsPath = 'assets/credentials.json';

  static const String _sheetUsuarios = 'USUARIOS';
  static const String _sheetPropiedades = 'PROPIEDADES';
  static const String _sheetReservas = 'RESERVAS';
  static const String _sheetGastos = 'GASTOS';

  static SheetsApi? _sheetsApi;

  /// Limpiar números
  static double _parseCleanNumber(String value) {
    if (value.isEmpty) return 0.0;
    String cleaned = value.replaceAll(RegExp(r'S/'), '');
    cleaned = cleaned.replaceAll(' ', '');
    cleaned = cleaned.replaceAll(',', '');
    return double.tryParse(cleaned) ?? 0.0;
  }

  /// Autenticación
  static Future<SheetsApi> _getAuthenticatedClient() async {
    if (_sheetsApi != null) return _sheetsApi!;

    try {
      final credentialsJson = await rootBundle.loadString(_credentialsPath);
      final credentials = ServiceAccountCredentials.fromJson(
        json.decode(credentialsJson),
      );

      final scopes = [SheetsApi.spreadsheetsReadonlyScope];
      final client = await clientViaServiceAccount(credentials, scopes);

      _sheetsApi = SheetsApi(client);
      return _sheetsApi!;
    } catch (e) {
      throw Exception('Error al autenticar con Google Sheets: $e');
    }
  }

  /// Login con DNI
  static Future<String?> login(String username, String password) async {
    try {
      final sheetsApi = await _getAuthenticatedClient();

      final response = await sheetsApi.spreadsheets.values.get(
        _spreadsheetId,
        '$_sheetUsuarios!A2:H',
      );

      final rows = response.values;
      if (rows == null || rows.isEmpty) return null;

      for (var row in rows) {
        if (row.length >= 3) {
          final user = row[0].toString().trim();
          final dni = row[1].toString().trim();
          final ownerId = row[2].toString().trim();

          if (user.toLowerCase() == username.toLowerCase() && dni == password) {
            return ownerId;
          }
        }
      }

      return null;
    } catch (e) {
      throw Exception('Error en login: $e');
    }
  }

  /// ✅ NUEVO: Obtener perfil del propietario
  /// Columnas: username | dni | owner_id | owner_name | phone | e_mail | profile_pic_url | estado
  static Future<Owner?> getOwnerProfile(String ownerId) async {
    try {
      final sheetsApi = await _getAuthenticatedClient();

      final response = await sheetsApi.spreadsheets.values.get(
        _spreadsheetId,
        '$_sheetUsuarios!A2:H',
      );

      final rows = response.values;
      if (rows == null || rows.isEmpty) return null;

      for (var row in rows) {
        if (row.length >= 7 && row[2].toString() == ownerId) {
          return Owner(
            ownerId: row[2].toString(),
            ownerName: row[3].toString(),
            phone: row.length >= 5 ? row[4].toString() : '',
            email: row.length >= 6 ? row[5].toString() : '',
            profilePicUrl: row.length >= 7 && row[6].toString().isNotEmpty 
                ? row[6].toString() 
                : null,
          );
        }
      }

      return null;
    } catch (e) {
      throw Exception('Error al obtener perfil: $e');
    }
  }

  /// Obtener propiedades por owner
  static Future<List<Property>> getPropertiesByOwner(String ownerId) async {
    try {
      final sheetsApi = await _getAuthenticatedClient();

      final response = await sheetsApi.spreadsheets.values.get(
        _spreadsheetId,
        '$_sheetPropiedades!A2:G',
      );

      final rows = response.values;
      if (rows == null || rows.isEmpty) return [];

      final properties = <Property>[];
      for (var row in rows) {
        if (row.length >= 6 && row[1].toString() == ownerId) {
          final address = row[3].toString();
          final parts = _extractCityCountry(address);
          
          final pricePerNight = row.length >= 7 
              ? _parseCleanNumber(row[6].toString())
              : 0.0;

          properties.add(Property(
            propertyId: row[0].toString(),
            ownerId: row[1].toString(),
            airbnbListingName: row[2].toString(),
            address: address,
            photoUrl: row[4].toString(),
            city: parts['city'] ?? 'Lima',
            country: parts['country'] ?? 'Perú',
            pricePerNight: pricePerNight,
          ));
        }
      }

      return properties;
    } catch (e) {
      throw Exception('Error al obtener propiedades: $e');
    }
  }

  /// Obtener reservas (con guest_pic)
  static Future<List<Reservation>> getReservations(
    String propertyId,
    String periodMonth,
  ) async {
    try {
      final sheetsApi = await _getAuthenticatedClient();

      final response = await sheetsApi.spreadsheets.values.get(
        _spreadsheetId,
        '$_sheetReservas!A2:N', // ✅ Ahora hasta columna N (guest_pic)
      );

      final rows = response.values;
      if (rows == null || rows.isEmpty) return [];

      final reservations = <Reservation>[];
      for (var row in rows) {
        if (row.length >= 13 &&
            row[1].toString() == propertyId &&
            row[12].toString() == periodMonth) {
          
          if (row[0].toString().isEmpty) continue;

          final grossAmountStr = row[8].toString();
          final grossAmount = _parseCleanNumber(grossAmountStr);

          reservations.add(Reservation(
            reservationId: row[0].toString(),
            propertyId: row[1].toString(),
            source: row[2].toString(),
            status: row[3].toString(),
            guestFullName: row[4].toString(),
            checkIn: DateTime.parse(row[5].toString()),
            checkOut: DateTime.parse(row[6].toString()),
            nights: int.tryParse(row[7].toString()) ?? 0,
            grossAmount: grossAmount,
            currency: row[9].toString(),
            notes: row[11].toString().isEmpty ? null : row[11].toString(),
            periodMonth: row[12].toString(),
            guestPic: row.length >= 14 && row[13].toString().isNotEmpty
                ? row[13].toString()
                : null, // ✅ Columna N (guest_pic)
          ));
        }
      }

      return reservations;
    } catch (e) {
      throw Exception('Error al obtener reservas: $e');
    }
  }

  /// ✅ NUEVO: Obtener todas las reservas de una propiedad (para calendario)
  static Future<List<Reservation>> getAllReservations(String propertyId) async {
    try {
      final sheetsApi = await _getAuthenticatedClient();

      final response = await sheetsApi.spreadsheets.values.get(
        _spreadsheetId,
        '$_sheetReservas!A2:N',
      );

      final rows = response.values;
      if (rows == null || rows.isEmpty) return [];

      final reservations = <Reservation>[];
      for (var row in rows) {
        if (row.length >= 13 && row[1].toString() == propertyId) {
          if (row[0].toString().isEmpty) continue;

          final grossAmountStr = row[8].toString();
          final grossAmount = _parseCleanNumber(grossAmountStr);

          reservations.add(Reservation(
            reservationId: row[0].toString(),
            propertyId: row[1].toString(),
            source: row[2].toString(),
            status: row[3].toString(),
            guestFullName: row[4].toString(),
            checkIn: DateTime.parse(row[5].toString()),
            checkOut: DateTime.parse(row[6].toString()),
            nights: int.tryParse(row[7].toString()) ?? 0,
            grossAmount: grossAmount,
            currency: row[9].toString(),
            notes: row[11].toString().isEmpty ? null : row[11].toString(),
            periodMonth: row[12].toString(),
            guestPic: row.length >= 14 && row[13].toString().isNotEmpty
                ? row[13].toString()
                : null,
          ));
        }
      }

      return reservations;
    } catch (e) {
      throw Exception('Error al obtener todas las reservas: $e');
    }
  }

  /// Obtener gastos
  static Future<List<Expense>> getExpenses(
    String propertyId,
    String periodMonth,
  ) async {
    try {
      final sheetsApi = await _getAuthenticatedClient();

      final response = await sheetsApi.spreadsheets.values.get(
        _spreadsheetId,
        '$_sheetGastos!A2:G',
      );

      final rows = response.values;
      if (rows == null || rows.isEmpty) return [];

      final expenses = <Expense>[];
      for (var row in rows) {
        if (row.length >= 6 &&
            row[1].toString() == propertyId &&
            row[2].toString() == periodMonth) {
          
          final amountStr = row[4].toString();
          final amount = _parseCleanNumber(amountStr);

          expenses.add(Expense(
            expenseId: row[0].toString(),
            propertyId: row[1].toString(),
            periodMonth: row[2].toString(),
            category: row[3].toString(),
            amount: amount,
            description: row[5].toString(),
          ));
        }
      }

      return expenses;
    } catch (e) {
      throw Exception('Error al obtener gastos: $e');
    }
  }

  /// Obtener statement mensual
  static Future<MonthlyStatement> getMonthlyStatement(
    String propertyId,
    String periodMonth,
  ) async {
    final reservations = await getReservations(propertyId, periodMonth);
    final expenses = await getExpenses(propertyId, periodMonth);

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

  /// Obtener periodos disponibles
  static Future<List<String>> getAvailablePeriods(String propertyId) async {
    try {
      final sheetsApi = await _getAuthenticatedClient();

      final response = await sheetsApi.spreadsheets.values.get(
        _spreadsheetId,
        '$_sheetReservas!B2:M',
      );

      final rows = response.values;
      if (rows == null || rows.isEmpty) return [];

      final periods = <String>{};
      for (var row in rows) {
        if (row.length >= 12 && row[0].toString() == propertyId) {
          final period = row[11].toString();
          if (period.isNotEmpty) {
            periods.add(period);
          }
        }
      }

      final sortedPeriods = periods.toList()..sort((a, b) => b.compareTo(a));
      return sortedPeriods;
    } catch (e) {
      throw Exception('Error al obtener periodos: $e');
    }
  }

  /// Helper: Extraer ciudad y país
  static Map<String, String> _extractCityCountry(String address) {
    final result = <String, String>{};

    if (address.contains('La Victoria')) {
      result['city'] = 'La Victoria';
      result['country'] = 'Perú';
    } else if (address.contains('Lima')) {
      result['city'] = 'Lima';
      result['country'] = 'Perú';
    } else {
      result['city'] = 'Lima';
      result['country'] = 'Perú';
    }

    return result;
  }

  static void dispose() {
    _sheetsApi = null;
  }
}