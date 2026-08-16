# Skybnb App

Aplicación en Flutter para la gestión de propiedades, reservaciones y seguimiento financiero para propietarios Skybnb. Diseñada con Clean Architecture para mantener el código escalable, testeable y desacoplado.

## Arquitectura

El código vive en `lib/` dividido por capas:

### `domain/` — Reglas de negocio (aisladas de Flutter)
- **Entidades**: `Property`, `Reservation`, `User`, `FinancialMovement` (con value objects en `value_objects/`).
- **Use cases**: acciones concretas (`LoginUseCase`, `GetPropertiesUseCase`, `GetMonthlyStatementUseCase`, ...).
- **Interfaces de repositorios**: contratos de datos.

### `data/` — Obtención de datos
- **`datasources/remote/api_remote_datasource.dart`**: cliente HTTP contra la API REST.
- **Repositories**: implementan los contratos del dominio, convierten JSON en modelos.

### `application/` — Estado (Provider)
- **Providers** (`ChangeNotifier`): ejecutan use cases y notifican a la UI. `AuthProvider`, `PropertyProvider`, `CalendarProvider`, `PropertyDetailProvider`, `ReservationFinancialProvider`.

### `presentation/` — UI
- Screens: `Login`, `Properties`, `PropertyDetail`, `Calendar`, `Profile`.
- Widgets compartidos en `shared/`.

### `core/` — Infraestructura compartida
- **`service_locator.dart`**: fábrica central que compone datasource → repositorios → use cases → providers.
- Constantes, utilidades de fechas/moneda y mapeo de errores.

## Flujo de ejecución

1. `main.dart` carga `.env` (URL base de la API), inicializa fechas en español y el servicio de sesión.
2. `SkybnbApp` monta los providers vía `MultiProvider` y arranca en `SplashScreen`.
3. `SplashScreen` intenta `tryAutoLogin()` con la sesión guardada; si no hay, va a `LoginScreen`.
4. `LoginScreen` → `AuthProvider.login()` → `LoginUseCase` → `AuthRepositoryImpl` → `ApiRemoteDataSource` → API REST.
5. Tras el login, la sesión (userId) se persiste y navega a `MainNavigation` (tabs: Perfil, Propiedades, Calendario).

## Tecnologías

- **Flutter** + **Provider** (estado)
- **http** — cliente REST
- **table_calendar** — calendario de reservas
- **cached_network_image** — imágenes con caché
- **flutter_secure_storage** — sesión persistida
- **intl** — fechas y monedas en español
- **flutter_dotenv** — configuración por entorno

## Desarrollo

```bash
flutter pub get
flutter run
```

La URL de la API se configura en `.env` (`API_BASE_URL`). El build de web se sirve con HTTPS obligatorio (el secure storage en web usa WebCrypto y solo funciona en contextos seguros).

## Tests

```bash
flutter test
```

## Deploy web

```bash
flutter build web --release
```

Subir `build/web/` a un hosting estático con HTTPS (AWS Amplify, Firebase Hosting, etc.). Requiere que la API permita CORS para el origen del sitio.
