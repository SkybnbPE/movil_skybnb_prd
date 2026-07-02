import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
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
  final FlutterSecureStorage _secureStorage;

  static const _tokenKey = 'skybnb_auth_token';

  ApiRemoteDataSource({
    required this.baseUrl,
    http.Client? client,
    FlutterSecureStorage? secureStorage,
  })  : _client = client ?? http.Client(),
        _secureStorage = secureStorage ?? const FlutterSecureStorage();

  Future<void> setAuthToken(String token) async {
    _authToken = token;
    await _secureStorage.write(key: _tokenKey, value: token);
  }

  Future<void> clearAuthToken() async {
    _authToken = null;
    await _secureStorage.delete(key: _tokenKey);
  }

  Future<void> loadSavedToken() async {
    _authToken = await _secureStorage.read(key: _tokenKey);
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

  /// POST /auth/login → retorna el json del Usuario (o {token, user})
  Future<Map<String, dynamic>> login(String username, String password) async {
    final response = await _client.post(
      Uri.parse('$baseUrl/auth/login'),
      headers: _headers,
      body: jsonEncode({
        'username': username,
        'password': password,
      }),
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
    final response = await _client.get(
      Uri.parse('$baseUrl/properties').replace(
        queryParameters: {'userId': ownerId},
      ),
      headers: _headers,
    );
    _checkResponse(response);
    final responseBody = jsonDecode(response.body) as Map<String, dynamic>;
    final list = responseBody['data'] as List? ?? [];
    
    return list.map((e) {
      return PropertyModel.fromJson(e as Map<String, dynamic>);
    }).toList();
  }

  /// GET /properties/:propertyId/periods
  Future<List<String>> getAvailablePeriods(String propertyId) async {
    final response = await _client.get(
      Uri.parse('$baseUrl/properties/$propertyId/periods'),
      headers: _headers,
    );
    _checkResponse(response);
    return List<String>.from(jsonDecode(response.body) as List? ?? []);
  }

  // ─── RESERVATIONS ────────────────────────────────────────────────────────

  /// GET /reservations?property_id=:propertyId&period_month=:period
  Future<List<ReservationModel>> getReservationsByPeriod(
    String propertyId,
    String periodMonth,
  ) async {
    final response = await _client.get(
      Uri.parse('$baseUrl/reservations').replace(
        queryParameters: {'propertyId': propertyId, 'month': periodMonth},
      ),
      headers: _headers,
    );
    _checkResponse(response);
    final responseBody = jsonDecode(response.body) as Map<String, dynamic>;
    final list = responseBody['data'] as List? ?? [];
    
    return list.map((e) => ReservationModel.fromJson(e as Map<String, dynamic>)).toList();
  }

  /// GET /reservations?propertyId=:propertyId
  Future<List<ReservationModel>> getAllReservations(String propertyId) async {
    final response = await _client.get(
      Uri.parse('$baseUrl/reservations').replace(
        queryParameters: {'propertyId': propertyId},
      ),
      headers: _headers,
    );
    _checkResponse(response);
    final responseBody = jsonDecode(response.body) as Map<String, dynamic>;
    final list = responseBody['data'] as List? ?? [];
    
    return list.map((e) => ReservationModel.fromJson(e as Map<String, dynamic>)).toList();
  }

  /// GET /reservations/:id
  Future<ReservationModel> getReservationById(String reservationId) async {
    final response = await _client.get(
      Uri.parse('$baseUrl/reservations/$reservationId'),
      headers: _headers,
    );
    _checkResponse(response);
    return ReservationModel.fromJson(jsonDecode(response.body) as Map<String, dynamic>);
  }

  // ─── FINANCIAL MOVEMENTS ─────────────────────────────────────────────────

  /// GET /financial-movements?property_id=:propertyId&period_month=:period
  Future<List<FinancialMovementModel>> getMovementsByPeriod(
    String propertyId,
    String periodMonth,
  ) async {
    final response = await _client.get(
      Uri.parse('$baseUrl/financial-movements').replace(
        queryParameters: {'propertyId': propertyId, 'month': periodMonth},
      ),
      headers: _headers,
    );
    _checkResponse(response);
    
    final list = jsonDecode(response.body) as List? ?? [];
    return list.map((e) => FinancialMovementModel.fromJson(e as Map<String, dynamic>)).toList();
  }

  /// GET /financial-movements?reservationId=:reservationId
  Future<List<FinancialMovementModel>> getMovementsByReservation(String reservationId) async {
    final response = await _client.get(
      Uri.parse('$baseUrl/financial-movements').replace(
        queryParameters: {'reservationId': reservationId},
      ),
      headers: _headers,
    );
    _checkResponse(response);
    
    final list = jsonDecode(response.body) as List? ?? [];
    return list.map((e) => FinancialMovementModel.fromJson(e as Map<String, dynamic>)).toList();
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
