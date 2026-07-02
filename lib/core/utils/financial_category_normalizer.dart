/// Normaliza las variaciones de nombres de categorías financieras
/// a un conjunto estándar de keys.
class FinancialCategoryNormalizer {
  FinancialCategoryNormalizer._();

  static const _normalizedKeys = {
    'rent',
    'airbnb_fee',
    'cleaning',
    'management_fee',
    'igv',
  };

  /// Normaliza una categoría cruda a su key estándar.
  /// Retorna null si la categoría no es reconocida.
  static String? normalize(String rawCategory) {
    final cat = rawCategory.toLowerCase().trim();

    if (cat == 'managment_fee' ||
        cat == 'managment' ||
        cat == 'management' ||
        cat == 'commission' ||
        cat == 'management_fee') {
      return 'management_fee';
    }
    if (cat == 'airbnb' ||
        cat == 'airbnbfee' ||
        cat == 'platform_fee' ||
        cat == 'airbnb_fee') {
      return 'airbnb_fee';
    }
    if (cat == 'rent' ||
        cat == 'accommodation' ||
        cat == 'room_rate' ||
        cat == 'revenue') {
      return 'rent';
    }
    if (cat == 'cleaning') {
      return 'cleaning';
    }
    if (cat == 'igv') {
      return 'igv';
    }

    return _normalizedKeys.contains(cat) ? cat : null;
  }
}
