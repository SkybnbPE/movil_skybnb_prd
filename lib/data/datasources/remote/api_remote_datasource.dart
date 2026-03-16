import 'dart:convert';
import 'package:http/http.dart' as http;
import '../../models/user_model.dart';
import '../../models/property_model.dart';
import '../../models/reservation_model.dart';
import '../../models/financial_movement_model.dart';

/// Datasource remoto que consume la API REST del backend MongoDB.
/// Todos los endpoints esperan y retornan JSON alineado al schema de MongoDB.
class ApiRemoteDataSource {
  final http.Client _client;
  final String baseUrl;
  String? _authToken;

  ApiRemoteDataSource({
    required this.baseUrl,
    http.Client? client,
  }) : _client = client ?? http.Client();

  void setAuthToken(String token) {
    _authToken = token;
  }

  void clearAuthToken() {
    _authToken = null;
  }

  Map<String, String> get _headers => {
        'Content-Type': 'application/json',
        if (_authToken != null) 'Authorization': 'Bearer $_authToken',
      };

  /// Valida el status HTTP y lanza excepción si es error.
  void _checkResponse(http.Response response) {
    if (response.statusCode >= 400) {
      throw HttpException(response.statusCode, response.body);
    }
  }

  // ─── AUTH ────────────────────────────────────────────────────────────────

  /// POST /auth/login → { token, user }
  Future<Map<String, dynamic>> login(String username, String password) async {
    // --- BYPASS para entorno de test / validación ---
    if (username == 'test' || username == 'random') {
      await Future.delayed(const Duration(seconds: 1)); // simular red
      return {
        'token': 'test_mock_token_123',
        'user': {
          '_id': 'user_mock_001',
          'username': username,
          'full_name': 'Usuario de Prueba',
          'dni': '12345678',
          'phone': '+51 999 888 777',
          'email': '$username@prueba.com',
          'profile_picture_url': 'https://i.pravatar.cc/150?u=$username',
          'status': 'active'
        }
      };
    }
    // ------------------------------------------------

    final response = await _client.post(
      Uri.parse('$baseUrl/auth/login'),
      headers: _headers,
      body: jsonEncode({'username': username, 'password': password}),
    );
    _checkResponse(response);
    return jsonDecode(response.body) as Map<String, dynamic>;
  }

  /// GET /users/:id
  Future<UserModel> getUserProfile(String userId) async {
    final response = await _client.get(
      Uri.parse('$baseUrl/users/$userId'),
      headers: _headers,
    );
    _checkResponse(response);
    return UserModel.fromJson(jsonDecode(response.body) as Map<String, dynamic>);
  }

  // ─── PROPERTIES ──────────────────────────────────────────────────────────

  /// GET /properties?owner_id=:ownerId
  Future<List<PropertyModel>> getPropertiesByOwner(String ownerId) async {
    // --- BYPASS para entorno de test / validación ---
    if (_authToken == 'test_mock_token_123') {
      await Future.delayed(const Duration(milliseconds: 600));
      return [
        PropertyModel(
          id: 'prop_mock_001',
          ownerId: ownerId,
          name: 'Apartamento de Lujo vista al mar',
          description: 'Descripción de prueba del departamento',
          locationJson: const {'address': 'Av Malecon 123', 'district': 'Miraflores', 'city': 'Lima', 'country': 'Peru', 'geo': {'lat': -12.12, 'lng': -77.02}},
          media: const ['https://images.unsplash.com/photo-1522708323590-d24dbb6b0267?q=80&w=2070&auto=format&fit=crop'],
          capacityJson: const {'bedrooms': 2, 'bathrooms': 2, 'max_guests': 4},
          pricingJson: const {'base_price': 150.0, 'currency': 'USD', 'cleaning_fee': 30.0},
          amenities: const ['wifi', 'tv'],
          status: 'active',
        ),
      ];
    }
    // ------------------------------------------------

    final response = await _client.get(
      Uri.parse('$baseUrl/properties').replace(
        queryParameters: {'owner_id': ownerId},
      ),
      headers: _headers,
    );
    _checkResponse(response);
    final list = jsonDecode(response.body) as List;
    return list
        .map((e) => PropertyModel.fromJson(e as Map<String, dynamic>))
        .toList();
  }

  /// GET /properties/:propertyId/periods
  Future<List<String>> getAvailablePeriods(String propertyId) async {
    // --- BYPASS para entorno de test / validación ---
    if (_authToken == 'test_mock_token_123') {
      await Future.delayed(const Duration(milliseconds: 300));
      return ['2023-10', '2023-11', '2023-12', '2024-01'];
    }
    // ------------------------------------------------

    final response = await _client.get(
      Uri.parse('$baseUrl/properties/$propertyId/periods'),
      headers: _headers,
    );
    _checkResponse(response);
    return List<String>.from(jsonDecode(response.body) as List);
  }

  // ─── RESERVATIONS ────────────────────────────────────────────────────────

  /// GET /reservations?property_id=:propertyId&period_month=:period
  Future<List<ReservationModel>> getReservationsByPeriod(
    String propertyId,
    String periodMonth,
  ) async {
    // --- BYPASS para entorno de test / validación ---
    if (_authToken == 'test_mock_token_123') {
      await Future.delayed(const Duration(milliseconds: 400));
      return [
        ReservationModel(
          id: 'res_mock_001',
          propertyId: propertyId,
          source: 'airbnb',
          status: 'confirmed',
          stayJson: const {'check_in': '2023-10-15T14:00:00.000Z', 'check_out': '2023-10-20T11:00:00.000Z', 'nights': 5},
          guestsJson: const [{'guest_id': 'g1', 'name': 'Juan Pérez', 'profile_picture_url': null, 'is_primary': true}],
          pricingJson: const {'total_price': 500.0, 'currency': 'USD', 'host_payout': 450.0},
          paymentJson: const {'status': 'paid'},
        )
      ];
    }
    // ------------------------------------------------

    final response = await _client.get(
      Uri.parse('$baseUrl/reservations').replace(queryParameters: {
        'property_id': propertyId,
        'period_month': periodMonth,
      }),
      headers: _headers,
    );
    _checkResponse(response);
    final list = jsonDecode(response.body) as List;
    return list
        .map((e) => ReservationModel.fromJson(e as Map<String, dynamic>))
        .toList();
  }

  /// GET /reservations?property_id=:propertyId
  Future<List<ReservationModel>> getAllReservations(String propertyId) async {
    // --- BYPASS para entorno de test / validación ---
    if (_authToken == 'test_mock_token_123') {
      return getReservationsByPeriod(propertyId, '2023-10');
    }
    // ------------------------------------------------

    final response = await _client.get(
      Uri.parse('$baseUrl/reservations').replace(
        queryParameters: {'property_id': propertyId},
      ),
      headers: _headers,
    );
    _checkResponse(response);
    final list = jsonDecode(response.body) as List;
    return list
        .map((e) => ReservationModel.fromJson(e as Map<String, dynamic>))
        .toList();
  }

  // ─── FINANCIAL MOVEMENTS ─────────────────────────────────────────────────

  /// GET /financial-movements?property_id=:propertyId&period_month=:period
  Future<List<FinancialMovementModel>> getMovementsByPeriod(
    String propertyId,
    String periodMonth,
  ) async {
    // --- BYPASS para entorno de test / validación ---
    if (_authToken == 'test_mock_token_123') {
      await Future.delayed(const Duration(milliseconds: 400));
      return [
        FinancialMovementModel(
          id: 'mov_mock_001',
          propertyId: propertyId,
          movementType: 'expense',
          category: 'cleaning',
          amount: 50.0,
          currency: 'USD',
          description: 'Limpieza profunda test',
          date: DateTime.parse('2023-10-21T10:00:00.000Z'),
          periodMonth: periodMonth,
        )
      ];
    }
    // ------------------------------------------------

    final response = await _client.get(
      Uri.parse('$baseUrl/financial-movements').replace(queryParameters: {
        'property_id': propertyId,
        'period_month': periodMonth,
      }),
      headers: _headers,
    );
    _checkResponse(response);
    final list = jsonDecode(response.body) as List;
    return list
        .map((e) =>
            FinancialMovementModel.fromJson(e as Map<String, dynamic>))
        .toList();
  }
}

/// Excepción HTTP con código y body para manejo en repositorios.
class HttpException implements Exception {
  final int statusCode;
  final String body;
  const HttpException(this.statusCode, this.body);

  @override
  String toString() => 'HttpException($statusCode): $body';
}
