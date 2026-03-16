class CurrencyFormatter {
  CurrencyFormatter._();

  /// "S/ 1,234.56"  (Soles peruanos por defecto)
  static String format(double amount, {String currency = 'S/'}) {
    return '$currency ${amount.toStringAsFixed(2)}';
  }

  /// "S/ 1,234"  (sin decimales)
  static String formatRounded(double amount, {String currency = 'S/'}) {
    return '$currency ${amount.toStringAsFixed(0)}';
  }
}
