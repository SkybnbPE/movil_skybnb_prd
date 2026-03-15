import 'package:flutter/material.dart';
import 'package:table_calendar/table_calendar.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:intl/intl.dart';
import '../../models/property.dart';
import '../../services/google_sheets_service.dart';

class CalendarScreen extends StatefulWidget {
  final String ownerId;

  const CalendarScreen({super.key, required this.ownerId});

  @override
  State<CalendarScreen> createState() => _CalendarScreenState();
}

class _CalendarScreenState extends State<CalendarScreen> {
  static const Color skybnbPink = Color(0xFFE91E63);
  static const Color skybnbPinkLight = Color(0xFFF8BBD0);
  static const Color grayLight = Color(0xFFF5F5F5);
  
  DateTime _focusedDay = DateTime.now();
  DateTime? _selectedDay;
  
  List<Property> properties = [];
  Property? selectedProperty;
  List<Reservation> reservations = [];
  bool isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadData();
  }

  Future<void> _loadData() async {
    try {
      final props = await GoogleSheetsService.getPropertiesByOwner(widget.ownerId);
      
      setState(() {
        properties = props;
        selectedProperty = props.isNotEmpty ? props.first : null;
        isLoading = false;
      });

      if (selectedProperty != null) {
        await _loadReservations();
      }
    } catch (e) {
      setState(() => isLoading = false);
    }
  }

  Future<void> _loadReservations() async {
    if (selectedProperty == null) return;

    try {
      final res = await GoogleSheetsService.getAllReservations(selectedProperty!.propertyId);
      setState(() {
        reservations = res;
      });
    } catch (e) {
      debugPrint('Error al cargar reservas: $e');
    }
  }

  Reservation? _getReservationForDay(DateTime day) {
    try {
      return reservations.firstWhere((res) {
        final dayStart = DateTime(day.year, day.month, day.day);
        final dayEnd = DateTime(day.year, day.month, day.day, 23, 59, 59);
        
        return (res.checkIn.isBefore(dayEnd) || res.checkIn.isAtSameMomentAs(dayEnd)) &&
               (res.checkOut.isAfter(dayStart) || res.checkOut.isAtSameMomentAs(dayStart));
      });
    } catch (e) {
      return null;
    }
  }

  bool _isFirstDayOfReservation(DateTime day, Reservation res) {
    return isSameDay(day, res.checkIn);
  }

  bool _isLastDayOfReservation(DateTime day, Reservation res) {
    // El último día es checkout - 1 día
    final lastNight = res.checkOut.subtract(const Duration(days: 1));
    return isSameDay(day, lastNight);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        title: const Text('Calendario', style: TextStyle(color: Colors.black)),
        backgroundColor: Colors.white,
        elevation: 0,
        automaticallyImplyLeading: false,
      ),
      body: isLoading
          ? const Center(child: CircularProgressIndicator())
          : properties.isEmpty
              ? const Center(child: Text('No tienes propiedades'))
              : Column(
                  children: [
                    if (properties.length > 1) _buildPropertySelector(),
                    Expanded(
                      child: SingleChildScrollView(
                        child: Column(
                          children: [
                            _buildCalendar(),
                            const SizedBox(height: 20),
                            _buildReservationsList(),
                          ],
                        ),
                      ),
                    ),
                  ],
                ),
    );
  }

  Widget _buildPropertySelector() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      decoration: BoxDecoration(
        color: Colors.white,
        border: Border(bottom: BorderSide(color: Colors.grey.shade200)),
      ),
      child: Row(
        children: [
          const Icon(Icons.home, size: 20, color: Colors.grey),
          const SizedBox(width: 12),
          Expanded(
            child: DropdownButtonHideUnderline(
              child: DropdownButton<Property>(
                value: selectedProperty,
                isExpanded: true,
                items: properties.map((prop) {
                  return DropdownMenuItem(
                    value: prop,
                    child: Text(
                      prop.airbnbListingName,
                      overflow: TextOverflow.ellipsis,
                    ),
                  );
                }).toList(),
                onChanged: (prop) {
                  setState(() {
                    selectedProperty = prop;
                  });
                  _loadReservations();
                },
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildCalendar() {
    return TableCalendar(
      firstDay: DateTime(2025, 1, 1),
      lastDay: DateTime(2027, 12, 31),
      focusedDay: _focusedDay,
      selectedDayPredicate: (day) => isSameDay(_selectedDay, day),
      calendarFormat: CalendarFormat.month,
      startingDayOfWeek: StartingDayOfWeek.monday,
      headerStyle: HeaderStyle(
        formatButtonVisible: false,
        titleCentered: true,
        titleTextStyle: const TextStyle(
          fontSize: 17,
          fontWeight: FontWeight.bold,
        ),
        leftChevronIcon: const Icon(Icons.chevron_left, color: skybnbPink),
        rightChevronIcon: const Icon(Icons.chevron_right, color: skybnbPink),
      ),
      calendarStyle: const CalendarStyle(
        markersMaxCount: 0,
      ),
      calendarBuilders: CalendarBuilders(
        defaultBuilder: (context, day, focusedDay) {
          return _buildDayCell(day);
        },
        selectedBuilder: (context, day, focusedDay) {
          return _buildDayCell(day, isSelected: true);
        },
        todayBuilder: (context, day, focusedDay) {
          return _buildDayCell(day, isToday: true);
        },
        outsideBuilder: (context, day, focusedDay) {
          return _buildDayCell(day, isOutside: true);
        },
      ),
      onDaySelected: (selectedDay, focusedDay) {
        setState(() {
          _selectedDay = selectedDay;
          _focusedDay = focusedDay;
        });
      },
      onPageChanged: (focusedDay) {
        setState(() {
          _focusedDay = focusedDay;
        });
      },
    );
  }

  Widget _buildDayCell(DateTime day, {bool isSelected = false, bool isToday = false, bool isOutside = false}) {
    final reservation = _getReservationForDay(day);
    final hasReservation = reservation != null;
    final isFirstDay = hasReservation && _isFirstDayOfReservation(day, reservation);
    final isLastDay = hasReservation && _isLastDayOfReservation(day, reservation);
    
    // ✅ Días libres = GRIS, Días ocupados = ROSA
    final backgroundColor = hasReservation 
      ? skybnbPinkLight.withValues(alpha: 0.4)
        : grayLight;
    
    return Container(
      margin: const EdgeInsets.all(1),
      decoration: BoxDecoration(
        color: backgroundColor,
        // ✅ SEMICÍRCULOS en los extremos
        borderRadius: BorderRadius.horizontal(
          left: Radius.circular(isFirstDay ? 50 : 0),  // ← Semicírculo inicio
          right: Radius.circular(isLastDay ? 50 : 0),  // ← Semicírculo fin
        ),
      ),
      child: Stack(
        children: [
          // Número del día
          Center(
            child: Text(
              '${day.day}',
              style: TextStyle(
                fontSize: 13,
                fontWeight: isSelected || isToday ? FontWeight.bold : FontWeight.normal,
                color: isOutside 
                    ? Colors.grey.shade400
                    : hasReservation 
                        ? skybnbPink  // Número rosa cuando está ocupado
                        : Colors.grey.shade600,  // Número gris cuando está libre
              ),
            ),
          ),
          
          // ✅ Avatar del huésped en el primer día
          if (hasReservation && isFirstDay)
            Positioned(
              left: 2,
              top: 2,
              child: _buildMiniAvatar(reservation!),
            ),
          
          // Círculo de selección/hoy
          if (isSelected || isToday)
            Center(
              child: Container(
                width: 32,
                height: 32,
                decoration: BoxDecoration(
                  color: isSelected
                      ? skybnbPink
                      : skybnbPink.withValues(alpha: 0.3),
                  shape: BoxShape.circle,
                ),
                child: Center(
                  child: Text(
                    '${day.day}',
                    style: TextStyle(
                      fontSize: 13,
                      fontWeight: FontWeight.bold,
                      color: isSelected ? Colors.white : skybnbPink,
                    ),
                  ),
                ),
              ),
            ),
        ],
      ),
    );
  }

  Widget _buildMiniAvatar(Reservation res) {
    return Container(
      width: 20,
      height: 20,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        color: Colors.white,
        border: Border.all(color: skybnbPink, width: 1.5),
      ),
      child: ClipOval(
        child: res.guestPic != null && res.guestPic!.isNotEmpty
            ? CachedNetworkImage(
                imageUrl: res.guestPic!,
                fit: BoxFit.cover,
                errorWidget: (context, url, error) => Center(
                  child: Text(
                    res.guestInitials,
                    style: const TextStyle(
                      color: skybnbPink,
                      fontWeight: FontWeight.bold,
                      fontSize: 8,
                    ),
                  ),
                ),
              )
            : Center(
                child: Text(
                  res.guestInitials,
                  style: const TextStyle(
                    color: skybnbPink,
                    fontWeight: FontWeight.bold,
                    fontSize: 8,
                  ),
                ),
              ),
      ),
    );
  }

  Widget _buildReservationsList() {
    final monthReservations = reservations.where((res) {
      final firstDay = DateTime(_focusedDay.year, _focusedDay.month, 1);
      final lastDay = DateTime(_focusedDay.year, _focusedDay.month + 1, 0, 23, 59, 59);
      
      return (res.checkIn.isBefore(lastDay) || res.checkIn.isAtSameMomentAs(lastDay)) &&
             (res.checkOut.isAfter(firstDay) || res.checkOut.isAtSameMomentAs(firstDay));
    }).toList();

    if (monthReservations.isEmpty) {
      return Padding(
        padding: const EdgeInsets.all(20),
        child: Text(
          'No hay reservas en ${DateFormat.yMMMM('es').format(_focusedDay)}',
          style: const TextStyle(color: Colors.grey),
        ),
      );
    }

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Reservas de ${DateFormat.yMMMM('es').format(_focusedDay)}',
            style: const TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 12),
          ...monthReservations.map((res) => _buildReservationCard(res)),
          const SizedBox(height: 20),
        ],
      ),
    );
  }

  Widget _buildReservationCard(Reservation res) {
    final dateFormat = DateFormat('dd MMM', 'es');
    
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: skybnbPinkLight.withValues(alpha: 0.2),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: skybnbPink.withValues(alpha: 0.3)),
      ),
      child: Row(
        children: [
          _buildGuestAvatar(res),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  res.guestFullName,
                  style: const TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 14,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  '${dateFormat.format(res.checkIn)} - ${dateFormat.format(res.checkOut)}',
                  style: const TextStyle(
                    fontSize: 12,
                    color: Colors.grey,
                  ),
                ),
                Text(
                  '${res.nights} noches',
                  style: const TextStyle(
                    fontSize: 12,
                    color: skybnbPink,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ],
            ),
          ),
          Text(
            'S/ ${res.grossAmount.toStringAsFixed(0)}',
            style: const TextStyle(
              fontWeight: FontWeight.bold,
              fontSize: 16,
              color: skybnbPink,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildGuestAvatar(Reservation res) {
    return Container(
      width: 50,
      height: 50,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        color: skybnbPink.withValues(alpha: 0.2),
        border: Border.all(color: skybnbPink, width: 2),
      ),
      child: ClipOval(
        child: res.guestPic != null && res.guestPic!.isNotEmpty
            ? CachedNetworkImage(
                imageUrl: res.guestPic!,
                fit: BoxFit.cover,
                placeholder: (context, url) => Center(
                  child: Text(
                    res.guestInitials,
                    style: const TextStyle(
                      color: skybnbPink,
                      fontWeight: FontWeight.bold,
                      fontSize: 16,
                    ),
                  ),
                ),
                errorWidget: (context, url, error) => Center(
                  child: Text(
                    res.guestInitials,
                    style: const TextStyle(
                      color: skybnbPink,
                      fontWeight: FontWeight.bold,
                      fontSize: 16,
                    ),
                  ),
                ),
              )
            : Center(
                child: Text(
                  res.guestInitials,
                  style: const TextStyle(
                    color: skybnbPink,
                    fontWeight: FontWeight.bold,
                    fontSize: 16,
                  ),
                ),
              ),
      ),
    );
  }
}