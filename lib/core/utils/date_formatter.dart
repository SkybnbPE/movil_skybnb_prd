import 'package:intl/intl.dart';
import '../constants/app_strings.dart';

class DateFormatter {
  DateFormatter._();

  static final DateFormat _dayMonth = DateFormat('dd MMM', 'es');
  static final DateFormat _dayMonthYear = DateFormat('dd/MM/yyyy');
  static final DateFormat _monthYear = DateFormat.yMMMM('es');

  /// "15 mar" → para cards de reserva
  static String toDayMonth(DateTime date) => _dayMonth.format(date);

  /// "15/03/2026" → para detalle de reserva
  static String toFull(DateTime date) => _dayMonthYear.format(date);

  /// "Marzo 2026" → para header de calendario
  static String toMonthYear(DateTime date) => _monthYear.format(date);

  /// "2026-03" → "Marzo 2026"
  static String periodToLabel(String period) {
    final parts = period.split('-');
    if (parts.length != 2) return period;
    final month = int.tryParse(parts[1]);
    if (month == null || month < 1 || month > 12) return period;
    return '${AppStrings.monthNames[month - 1]} ${parts[0]}';
  }
}
