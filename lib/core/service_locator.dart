import 'package:http/http.dart' as http;
import '../data/datasources/remote/api_remote_datasource.dart';
import '../data/repositories/auth_repository_impl.dart';
import '../data/repositories/property_repository_impl.dart';
import '../data/repositories/reservation_repository_impl.dart';
import '../data/repositories/financial_movement_repository_impl.dart';
import '../domain/usecases/auth_usecases.dart';
import '../domain/usecases/property_usecases.dart';
import '../domain/usecases/reservation_usecases.dart';
import '../domain/usecases/get_monthly_statement_usecase.dart';
import '../application/providers/auth_provider.dart';
import '../application/providers/property_provider.dart';
import '../application/providers/calendar_provider.dart';

/// Composición de dependencias de la aplicación.
/// Registra datasources → repositorios → use cases → providers.
///
/// TODO: Reemplaza la URL base con la de tu API REST MongoDB.
class ServiceLocator {
  ServiceLocator._();

  static const String _baseUrl = 'https://api.skybnb.app/v1';

  // ─── Shared HTTP client ───────────────────────────────────────────────────
  static final http.Client _httpClient = http.Client();

  // ─── Datasources ──────────────────────────────────────────────────────────
  static final ApiRemoteDataSource _remoteDataSource = ApiRemoteDataSource(
    baseUrl: _baseUrl,
    client: _httpClient,
  );

  // ─── Repositories ─────────────────────────────────────────────────────────
  static final _authRepo = AuthRepositoryImpl(_remoteDataSource);
  static final _propertyRepo = PropertyRepositoryImpl(_remoteDataSource);
  static final _reservationRepo = ReservationRepositoryImpl(_remoteDataSource);
  static final _financialRepo =
      FinancialMovementRepositoryImpl(_remoteDataSource);

  // ─── Use Cases ────────────────────────────────────────────────────────────
  static final loginUseCase = LoginUseCase(_authRepo);
  static final getUserProfileUseCase = GetUserProfileUseCase(_authRepo);
  static final getPropertiesUseCase = GetPropertiesUseCase(_propertyRepo);
  static final getAvailablePeriodsUseCase =
      GetAvailablePeriodsUseCase(_propertyRepo);
  static final getReservationsByPeriodUseCase =
      GetReservationsByPeriodUseCase(_reservationRepo);
  static final getAllReservationsUseCase =
      GetAllReservationsUseCase(_reservationRepo);
  static final getMonthlyStatementUseCase = GetMonthlyStatementUseCase(
    _reservationRepo,
    _financialRepo,
  );

  // ─── Providers (factories — cada Provider obtiene sus use cases) ──────────
  static AuthProvider createAuthProvider() => AuthProvider(
        loginUseCase: loginUseCase,
        getUserProfileUseCase: getUserProfileUseCase,
      );

  static PropertyProvider createPropertyProvider() => PropertyProvider(
        getPropertiesUseCase: getPropertiesUseCase,
        getAvailablePeriodsUseCase: getAvailablePeriodsUseCase,
        getMonthlyStatementUseCase: getMonthlyStatementUseCase,
      );

  static CalendarProvider createCalendarProvider() => CalendarProvider(
        getPropertiesUseCase: getPropertiesUseCase,
        getAllReservationsUseCase: getAllReservationsUseCase,
      );
}
