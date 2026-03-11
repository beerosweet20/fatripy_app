class Accommodation {
  final String accommodationId;
  final String name;
  final double pricePerNight;
  final double? priceMin;
  final double? priceMax;
  final double? lat;
  final double? lng;
  final double? rating;
  final String? location;
  final String? amenities;
  final List<String>? facilities;
  final String? planType;
  final String? googleMaps;
  final String? bookingUrl;
  final String? mapsUrl;

  Accommodation({
    required this.accommodationId,
    required this.name,
    required this.pricePerNight,
    this.priceMin,
    this.priceMax,
    this.lat,
    this.lng,
    this.rating,
    this.location,
    this.amenities,
    this.facilities,
    this.planType,
    this.googleMaps,
    this.bookingUrl,
    this.mapsUrl,
  });
}
