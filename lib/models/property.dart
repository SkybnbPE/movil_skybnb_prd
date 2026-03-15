/// ===============================
/// MODELOS DE DATOS - SKYBNB
/// ===============================
/// Actualizado con guest_pic y campos de perfil

/// Modelo de Propiedad
class Property {
  final String propertyId;
  final String ownerId;
  final String airbnbListingName;
  final String address;
  final String photoUrl;
  final String city;
  final String country;
  final double pricePerNight;

  Property({
    required this.propertyId,
    required this.ownerId,
    required this.airbnbListingName,
    required this.address,
    required this.photoUrl,
    required this.city,
    required this.country,
    required this.pricePerNight,
  });

  factory Property.fromMap(Map<String, dynamic> map) {
    return Property(
      propertyId: map['property_id'] ?? '',
      ownerId: map['owner_id'] ?? '',
      airbnbListingName: map['airbnb_listing_name'] ?? '',
      address: map['address'] ?? '',
      photoUrl: map['photo_url'] ?? '',
      city: map['city'] ?? '',
      country: map['country'] ?? '',
      pricePerNight: (map['price_per_night'] ?? 0).toDouble(),
    );
  }

  @override
  String toString() {
    return 'Property(id: $propertyId, name: $airbnbListingName, city: $city)';
  }
}

/// Modelo de Reserva (con guest_pic)
class Reservation {
  final String reservationId;
  final String propertyId;
  final String source;
  final String status;
  final String guestFullName;
  final DateTime checkIn;
  final DateTime checkOut;
  final int nights;
  final double grossAmount;
  final String currency;
  final String? notes;
  final String periodMonth;
  final String? guestPic; // ✅ Nueva columna

  Reservation({
    required this.reservationId,
    required this.propertyId,
    required this.source,
    required this.status,
    required this.guestFullName,
    required this.checkIn,
    required this.checkOut,
    required this.nights,
    required this.grossAmount,
    required this.currency,
    this.notes,
    required this.periodMonth,
    this.guestPic,
  });

  factory Reservation.fromMap(Map<String, dynamic> map) {
    return Reservation(
      reservationId: map['reservation_id'] ?? '',
      propertyId: map['property_id'] ?? '',
      source: map['source'] ?? '',
      status: map['status'] ?? '',
      guestFullName: map['guest_full_name'] ?? '',
      checkIn: DateTime.parse(map['check_in']),
      checkOut: DateTime.parse(map['check_out']),
      nights: map['nights'] ?? 0,
      grossAmount: (map['gross_amount'] ?? 0).toDouble(),
      currency: map['currency'] ?? 'Soles',
      notes: map['notes'],
      periodMonth: map['period_month'] ?? '',
      guestPic: map['guest_pic'],
    );
  }

  /// Obtiene las iniciales del huésped para usar si no hay foto
  String get guestInitials {
    final names = guestFullName.split(' ');
    if (names.isEmpty) return '?';
    if (names.length == 1) return names[0][0].toUpperCase();
    return '${names[0][0]}${names[names.length - 1][0]}'.toUpperCase();
  }
}

/// Modelo de Gastos
class Expense {
  final String expenseId;
  final String propertyId;
  final String periodMonth;
  final String category;
  final double amount;
  final String description;

  Expense({
    required this.expenseId,
    required this.propertyId,
    required this.periodMonth,
    required this.category,
    required this.amount,
    required this.description,
  });

  factory Expense.fromMap(Map<String, dynamic> map) {
    return Expense(
      expenseId: map['expense_id'] ?? '',
      propertyId: map['property_id'] ?? '',
      periodMonth: map['period_month'] ?? '',
      category: map['category'] ?? '',
      amount: (map['amount'] ?? 0).toDouble(),
      description: map['description'] ?? '',
    );
  }
}

/// Modelo de Liquidación Mensual (Statement)
class MonthlyStatement {
  final String propertyId;
  final String periodMonth;
  final double totalGross;
  final double airbnbFee3Pct;
  final double baseAfterAirbnb;
  final double totalExpenses;
  final double baseAfterExpenses;
  final double skybnbFee15Pct;
  final double igv18PctOnSkybnb;
  final double netToOwner;
  final List<Reservation> reservations;
  final List<Expense> expenses;

  MonthlyStatement({
    required this.propertyId,
    required this.periodMonth,
    required this.totalGross,
    required this.airbnbFee3Pct,
    required this.baseAfterAirbnb,
    required this.totalExpenses,
    required this.baseAfterExpenses,
    required this.skybnbFee15Pct,
    required this.igv18PctOnSkybnb,
    required this.netToOwner,
    required this.reservations,
    required this.expenses,
  });

  factory MonthlyStatement.fromMap(Map<String, dynamic> map) {
    return MonthlyStatement(
      propertyId: map['property_id'] ?? '',
      periodMonth: map['period_month'] ?? '',
      totalGross: (map['total_gross'] ?? 0).toDouble(),
      airbnbFee3Pct: (map['airbnb_fee_3pct'] ?? 0).toDouble(),
      baseAfterAirbnb: (map['base_after_airbnb'] ?? 0).toDouble(),
      totalExpenses: (map['total_expenses'] ?? 0).toDouble(),
      baseAfterExpenses: (map['base_after_expenses'] ?? 0).toDouble(),
      skybnbFee15Pct: (map['skybn_fee_15pct'] ?? 0).toDouble(),
      igv18PctOnSkybnb: (map['igv_18pct_on_skybn'] ?? 0).toDouble(),
      netToOwner: (map['net_to_owner'] ?? 0).toDouble(),
      reservations: [],
      expenses: [],
    );
  }

  int get totalNights {
    return reservations.fold(0, (sum, res) => sum + res.nights);
  }

  String get formattedPeriod {
    final parts = periodMonth.split('-');
    if (parts.length != 2) return periodMonth;

    final year = parts[0];
    final month = int.parse(parts[1]);

    const monthNames = [
      'Enero', 'Febrero', 'Marzo', 'Abril', 'Mayo', 'Junio',
      'Julio', 'Agosto', 'Septiembre', 'Octubre', 'Noviembre', 'Diciembre'
    ];

    return '${monthNames[month - 1]} $year';
  }
}

/// Modelo de Usuario/Propietario (para perfil)
class Owner {
  final String ownerId;
  final String ownerName;
  final String phone;
  final String email;
  final String? profilePicUrl;

  Owner({
    required this.ownerId,
    required this.ownerName,
    required this.phone,
    required this.email,
    this.profilePicUrl,
  });

  factory Owner.fromMap(Map<String, dynamic> map) {
    return Owner(
      ownerId: map['owner_id'] ?? '',
      ownerName: map['owner_name'] ?? '',
      phone: map['phone'] ?? '',
      email: map['e_mail'] ?? '',
      profilePicUrl: map['profile_pic_url'],
    );
  }

  /// Obtiene las iniciales del propietario
  String get initials {
    final names = ownerName.split(' ');
    if (names.isEmpty) return '?';
    if (names.length == 1) return names[0][0].toUpperCase();
    return '${names[0][0]}${names[names.length - 1][0]}'.toUpperCase();
  }
}