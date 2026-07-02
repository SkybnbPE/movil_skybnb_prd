/// Constantes de negocio y configuración de la aplicación.
class AppConstants {
  AppConstants._();

  // ─── Fees ────────────────────────────────────────────────────────────────
  static const double platformFeeRate = 0.155; // 15.5%
  static const double skybnbFeeRate = 0.15;    // 15%
  static const double igvRate = 0.18;          // 18%

  // ─── Paginación ──────────────────────────────────────────────────────────
  static const int initialPageSize = 3;
  static const int pageSizeIncrement = 3;

  // ─── Calendario ──────────────────────────────────────────────────────────
  static const int calendarFirstYear = 2025;
  static const int calendarLastYear = 2027;
}
