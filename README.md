Read [](file:///home/mako/skybnb/skybnb_movil/lib/core/service_locator.dart)

Aquí tienes un README.md completo, adaptado a tu proyecto, con la explicación detallada de la arquitectura, el flujo de ejecución y cómo se conectan las distintas capas usando `Provider` y el `ServiceLocator`. 

Puedes copiar este contenido y reemplazar o combinarlo con el README.md que viene por defecto en Flutter.

```markdown
# 🏙️ Skybnb App

Aplicación móvil desarrollada en Flutter para la gestión de propiedades, reservaciones y seguimiento financiero. Diseñada bajo los principios de **Clean Architecture** para mantener un código escalable, fácil de probar y altamente desacoplado.

---

## 🏗️ Arquitectura del Proyecto (Clean Architecture)

El proyecto separa responsabilidades en distintas capas, haciendo que la interfaz gráfica no sepa nada de cómo se obtienen los datos (API) y viceversa.  
El código vive en la carpeta `lib/` y se divide de la siguiente manera:

### 1. `domain/` (Capa de Dominio)
El corazón de la aplicación. Aquí viven las reglas del negocio, completamente aisladas de Flutter y de internet.
- **Entidades/Modelos:** Clases que representan objetos reales (ej: `Property`, `Reservation`, `User`).
- **Use Cases (Casos de uso):** Acciones concretas que puede hacer el usuario. (ej: `LoginUseCase`, `GetPropertiesUseCase`).
- **Interfaces (Contratos):** Contratos de los repositorios que definen *qué* datos se necesitan, sin especificar *cómo* se obtienen.

### 2. `data/` (Capa de Datos)
Responsable de conseguir la información que el `domain/` necesita.
- **DataSources:** Implementaciones técnicas. Comunica a la app de Flutter con nuestra API REST (usando la librería `http`). Ej: `ApiRemoteDataSource`.
- **Repositories (Implementaciones):** Cumplen los contratos del Dominio. Toman la respuesta pura (JSON) del DataSource y la convierten en modelos/entidades que el Dominio entiende.

### 3. `application/` (Capa de Aplicación / Estado)
El puente entre las reglas de negocio (Dominio) y la Interfaz Gráfica (Presentación).
- **Providers:** Clases que heredan de `ChangeNotifier`. Ejecutan los casos de uso (`Use Cases`) del dominio, guardan en variables de estado (ej: `isLoading`, `error`, `propertiesList`) y avisan a la UI mediante `notifyListeners()` cuando dichos datos cambian.
  - `AuthProvider` (Manejo de sesión).
  - `PropertyProvider` (Estados de las propiedades y reportes).
  - `CalendarProvider` (Control y cruce de datos del calendario).

### 4. `presentation/` (Capa de Presentación)
Todo lo que el usuario ve e interactúa. Es lo más "tonto" posible; solo dibuja lo que le mandan los `Providers` de la capa Application.
- **Screens:** Las pantallas principales (`LoginScreen`, `HomeScreen`).
- **Widgets / Shared:** Botones y componentes reutilizables.

### 5. `core/` (Núcleo)
Utilerías y configuración que todas las capas usan.
- **`service_locator.dart` (Inyección de Dependencias):** Es la fábrica central. Inicializa y conecta el cliente `http`, con el `DataSource`, que se pasa a los `Repository`, luego a los `UseCases` y finalmente se entrega listo para usar a los `Providers`.

---

## 🌊 Flujo de Ejecución (Paso a paso)

Para entender cómo funciona la app, esto es lo que ocurre al iniciarla:

1. **`main.dart` - El Arranque:**  
   Se ejecuta la función `main()`. Se carga el formato de fecha para español (`intl`) y arranca el widget raíz `SkybnbApp`.
   
2. **Inyección de Dependencias (Service Locator):**  
   Antes de dibujar pantallas, el `MultiProvider` en `main.dart` pide a `core/service_locator.dart` que cree y configure los 3 "cerebros" visuales de la aplicación:
   - `createAuthProvider()`
   - `createPropertyProvider()`
   - `createCalendarProvider()`
   
   *Aquí es donde los casos de uso (Lógica de negocio) y los repositorios (Conexión a la API `https://api.skybnb.app/v1`) se instancian en memoria interna y se inyectan como punteros dentro de los Providers.*

3. **La Vista Inicial:**  
   Inmediatamente, la app dibuja `LoginScreen` (definido en la propiedad `home` del `MaterialApp`).
   
4. **Ciclo de un Botón (Ej. "Iniciar Sesión"):**
   1. El usuario toca el botón de Login en la UI (`presentation`).
   2. La pantalla manda a llamar al método `login(email, password)` en el `AuthProvider` (`application`).
   3. `AuthProvider` llama a su `LoginUseCase` (`domain`).
   4. El `LoginUseCase` ejecuta la petición a nuestra API REST usando el `AuthRepositoryImpl` y `ApiRemoteDataSource` (`data`).
   5. Tras el éxito de la petición REST, se devuelve la entidad de usuario (Token, Id) y vuelve de regreso hasta el `AuthProvider`.
   6. El `AuthProvider` actualiza su estado interno y dispara el método `notifyListeners()` (**El Patrón Observer**).
   7. `LoginScreen` detecta el cambio, suelta una navegación de éxito y envía al usuario al Dashboard Principal.

---

## 🛠️ Tecnologías y Librerías Principales

- **[Flutter](https://flutter.dev):** UI Toolkit.
- **[Provider](https://pub.dev/packages/provider):** Gestor de estado basado en Inyección de Dependencias y el Patrón Observer (`ChangeNotifier`).
- **[http](https://pub.dev/packages/http):** Cliente web para peticiones `REST API`.
- **[table_calendar](https://pub.dev/packages/table_calendar):** Visualización del calendario de reservas interactivo.
- **[cached_network_image](https://pub.dev/packages/cached_network_image):** Manejo eficiente y cacheo inteligente de imágenes que provienen del servidor, previniendo descargas redundantes.
- **[intl](https://pub.dev/packages/intl):** Formateadores de fecha, moneda e internacionalización (Localización a Español).

---

## 🚀 Empezando a Desarrollar

1. Clona el repositorio.
2. Descarga los paquetes de flutter ejecutando:  
   `flutter pub get`
3. Si el servidor de la API está listo o tienes uno simulado, verifica el endpoint en `lib/core/service_locator.dart` (Actualiza `_baseUrl` en caso de requerirse).
4. Corre el proyecto:  
   `flutter run`
```