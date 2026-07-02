import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';
import 'package:skybnb/application/providers/calendar_provider.dart';
import 'package:skybnb/core/constants/app_colors.dart';
import 'package:skybnb/core/constants/app_constants.dart';
import 'package:skybnb/core/constants/app_strings.dart';
import 'package:skybnb/domain/models/property_entity.dart';
import 'package:skybnb/presentation/screens/property_detail/widgets/guest_avatar.dart';
import 'package:skybnb/presentation/screens/property_detail/widgets/reservation_card.dart';
import 'package:table_calendar/table_calendar.dart';

/// StatefulWidget: gestiona el estado local del calendario (focusedDay, selectedDay).
/// El estado de datos (reservas, propiedades) lo gestiona CalendarProvider.
class CalendarScreen extends StatefulWidget {
  final String userId;
  const CalendarScreen({super.key, required this.userId});

  @override
  State<CalendarScreen> createState() => _CalendarScreenState();
}

class _CalendarScreenState extends State<CalendarScreen> {
  DateTime _focusedDay = DateTime.now();
  DateTime? _selectedDay;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<CalendarProvider>().loadProperties(widget.userId);
    });
  }

  @override
  Widget build(BuildContext context) {
    final provider = context.watch<CalendarProvider>();

    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        title: const Text(AppStrings.calendar,
            style: TextStyle(color: AppColors.textPrimary)),
        backgroundColor: Colors.white,
        elevation: 0,
        automaticallyImplyLeading: false,
      ),
      body: provider.isLoading
          ? const Center(child: CircularProgressIndicator())
          : provider.properties.isEmpty
              ? const Center(child: Text(AppStrings.noProperties2))
              : Column(
                  children: [
                    if (provider.properties.length > 1)
                      _PropertySelector(
                        properties: provider.properties,
                        selected: provider.selectedProperty,
                        onChanged: (p) {
                          if (p != null) provider.selectProperty(p);
                        },
                      ),
                    Expanded(
                      child: RefreshIndicator(
                        onRefresh: () async {
                          if (provider.selectedProperty != null) {
                            await provider.loadReservations(provider.selectedProperty!.id);
                          }
                        },
                        color: AppColors.primary,
                        child: SingleChildScrollView(
                          physics: const AlwaysScrollableScrollPhysics(),
                          child: Column(
                            children: [
                              _buildCalendar(provider),
                              const SizedBox(height: 20),
                              _buildReservationsList(provider),
                            ],
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
    );
  }

  Widget _buildCalendar(CalendarProvider provider) {
    return TableCalendar(
      firstDay: DateTime(AppConstants.calendarFirstYear, 1, 1),
      lastDay: DateTime(AppConstants.calendarLastYear, 12, 31),
      focusedDay: _focusedDay,
      selectedDayPredicate: (day) => isSameDay(_selectedDay, day),
      startingDayOfWeek: StartingDayOfWeek.monday,
      headerStyle: const HeaderStyle(
        formatButtonVisible: false,
        titleCentered: true,
        titleTextStyle: TextStyle(fontSize: 17, fontWeight: FontWeight.bold),
        leftChevronIcon: Icon(Icons.chevron_left, color: AppColors.primary),
        rightChevronIcon: Icon(Icons.chevron_right, color: AppColors.primary),
      ),
      calendarStyle: const CalendarStyle(markersMaxCount: 0),
      calendarBuilders: CalendarBuilders<Widget>(
        defaultBuilder: (_, day, __) =>
            _DayCell(day: day, provider: provider),
        selectedBuilder: (_, day, __) =>
            _DayCell(day: day, provider: provider, isSelected: true),
        todayBuilder: (_, day, __) =>
            _DayCell(day: day, provider: provider, isToday: true),
        outsideBuilder: (_, day, __) =>
            _DayCell(day: day, provider: provider, isOutside: true),
      ),
      onDaySelected: (selected, focused) {
        setState(() {
          _selectedDay = selected;
          _focusedDay = focused;
        });
      },
      onPageChanged: (focused) {
        setState(() => _focusedDay = focused);
      },
    );
  }

  Widget _buildReservationsList(CalendarProvider provider) {
    final monthRes = provider.reservations.where((r) {
      final first = DateTime(_focusedDay.year, _focusedDay.month, 1);
      final last = DateTime(_focusedDay.year, _focusedDay.month + 1, 0, 23, 59);
      return r.stay.checkIn.isBefore(last) && r.stay.checkOut.isAfter(first);
    }).toList();

    final monthLabel = DateFormat.yMMMM('es').format(_focusedDay);

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            monthRes.isEmpty
                ? 'No hay reservas en $monthLabel'
                : 'Reservas de $monthLabel',
            style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 12),
          ...monthRes.map((r) {
            return ReservationItemCard(
              reservation: r,
              netAmount: provider.getReservationNet(r.id),
            );
          }),
          const SizedBox(height: 20),
        ],
      ),
    );
  }
}

// ─── Selector de propiedad (Stateless) ───────────────────────────────────────

class _PropertySelector extends StatelessWidget {
  final List<PropertyEntity> properties;
  final PropertyEntity? selected;
  final ValueChanged<PropertyEntity?> onChanged;

  const _PropertySelector({
    required this.properties,
    required this.selected,
    required this.onChanged,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      decoration: BoxDecoration(
        color: Colors.white,
        border: Border(bottom: BorderSide(color: Colors.grey.shade200)),
      ),
      child: Row(
        children: [
          const Icon(Icons.home, size: 20, color: AppColors.textSecondary),
          const SizedBox(width: 12),
          Expanded(
            child: DropdownButtonHideUnderline(
              child: DropdownButton<PropertyEntity>(
                value: selected,
                isExpanded: true,
                items: properties
                    .map((p) => DropdownMenuItem(
                          value: p,
                          child: Text(p.name,
                              overflow: TextOverflow.ellipsis),
                        ))
                    .toList(),
                onChanged: onChanged,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

// ─── Celda del día (Stateless) ────────────────────────────────────────────────

class _DayCell extends StatelessWidget {
  final DateTime day;
  final CalendarProvider provider;
  final bool isSelected;
  final bool isToday;
  final bool isOutside;

  const _DayCell({
    required this.day,
    required this.provider,
    this.isSelected = false,
    this.isToday = false,
    this.isOutside = false,
  });

  @override
  Widget build(BuildContext context) {
    final reservation = provider.getReservationForDay(day);
    final hasRes = reservation != null;

    final dayStart = DateTime(day.year, day.month, day.day);
    final isFirst = false;
    final isLast = false;
    if (hasRes) {
      final checkIn = DateTime(reservation.stay.checkIn.year,
          reservation.stay.checkIn.month, reservation.stay.checkIn.day);
      final lastNight = reservation.stay.checkOut
          .subtract(const Duration(days: 1));
      final lastNightDate = DateTime(lastNight.year, lastNight.month, lastNight.day);
      isFirst = dayStart == checkIn;
      isLast = dayStart == lastNightDate;
    }

    final bgColor = hasRes
        ? AppColors.calendarOccupied.withValues(alpha: 0.4)
        : AppColors.calendarFree;

    return Container(
      margin: const EdgeInsets.all(1),
      decoration: BoxDecoration(
        color: bgColor,
        borderRadius: BorderRadius.horizontal(
          left: Radius.circular(isFirst ? 50 : 0),
          right: Radius.circular(isLast ? 50 : 0),
        ),
      ),
      child: Stack(
        children: [
          Center(
            child: Text(
              '${day.day}',
              style: TextStyle(
                fontSize: 13,
                fontWeight:
                    isSelected || isToday ? FontWeight.bold : FontWeight.normal,
                color: isOutside
                    ? Colors.grey.shade400
                    : hasRes
                        ? AppColors.primary
                        : Colors.grey.shade600,
              ),
            ),
          ),
          if (hasRes && isFirst)
            Positioned(
              left: 2,
              top: 2,
              child: GuestMiniAvatar(reservation: reservation),
            ),
          if (isSelected || isToday)
            Center(
              child: Container(
                width: 32,
                height: 32,
                decoration: BoxDecoration(
                  color: isSelected
                      ? AppColors.primary
                      : AppColors.primary.withValues(alpha: 0.3),
                  shape: BoxShape.circle,
                ),
                child: Center(
                  child: Text(
                    '${day.day}',
                    style: TextStyle(
                      fontSize: 13,
                      fontWeight: FontWeight.bold,
                      color: isSelected ? Colors.white : AppColors.primary,
                    ),
                  ),
                ),
              ),
            ),
        ],
      ),
    );
  }
}
