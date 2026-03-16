/// Ubicación geográfica de una propiedad.
class Location {
  final String address;
  final String district;
  final String city;
  final String country;
  final double? lat;
  final double? lng;

  const Location({
    required this.address,
    required this.district,
    required this.city,
    required this.country,
    this.lat,
    this.lng,
  });

  String get fullAddress => '$address, $district, $city, $country';

  String get cityCountry => '$city, $country';

  @override
  bool operator ==(Object other) =>
      other is Location &&
      address == other.address &&
      district == other.district &&
      city == other.city &&
      country == other.country;

  @override
  int get hashCode => Object.hash(address, district, city, country);
}
