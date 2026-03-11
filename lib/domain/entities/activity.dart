class Activity {
  final String id;
  final String activityId;
  final String name;
  final double? price;
  final double? lat;
  final double? lng;
  final double? rating;
  final String? location;
  final String? openHours;
  final String? closeHours;
  final String? googleMaps;
  final String? bookingUrl;
  final String? mapsUrl;
  final String? distanceType;

  Activity({
    required this.id,
    required this.activityId,
    required this.name,
    this.price,
    this.lat,
    this.lng,
    this.rating,
    this.location,
    this.openHours,
    this.closeHours,
    this.googleMaps,
    this.bookingUrl,
    this.mapsUrl,
    this.distanceType,
  });
}
