import '../../domain/entities/accommodation.dart';

class AccommodationModel extends Accommodation {
  AccommodationModel({
    required super.accommodationId,
    required super.name,
    required super.pricePerNight,
    super.priceMin,
    super.priceMax,
    super.lat,
    super.lng,
    super.rating,
    super.location,
    super.amenities,
    super.facilities,
    super.planType,
    super.googleMaps,
    super.bookingUrl,
    super.mapsUrl,
  });

  factory AccommodationModel.fromJson(Map<String, dynamic> json, [String? id]) {
    return AccommodationModel(
      accommodationId: id ?? json['accommodationId'] ?? json['id'] ?? '',
      name: json['name'] as String? ?? 'Unknown Accommodation',
      pricePerNight: (json['pricePerNight'] as num?)?.toDouble() ?? 0.0,
      priceMin: (json['priceMin'] as num?)?.toDouble(),
      priceMax: (json['priceMax'] as num?)?.toDouble(),
      lat: (json['lat'] as num?)?.toDouble(),
      lng: (json['lng'] as num?)?.toDouble(),
      rating: (json['rating'] as num?)?.toDouble(),
      location: json['location'] as String?,
      amenities: json['amenities'] is List
          ? (json['amenities'] as List).join(', ')
          : json['amenities'] as String?,
      facilities: (json['facilities'] as List<dynamic>?)
          ?.map((e) => e.toString())
          .toList(),
      planType: json['planType'] as String?,
      googleMaps: json['googleMaps'] as String?,
      bookingUrl: json['bookingUrl'] as String?,
      mapsUrl: json['mapsUrl'] as String?,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'accommodationId': accommodationId,
      'name': name,
      'pricePerNight': pricePerNight,
      if (priceMin != null) 'priceMin': priceMin,
      if (priceMax != null) 'priceMax': priceMax,
      if (lat != null) 'lat': lat,
      if (lng != null) 'lng': lng,
      if (rating != null) 'rating': rating,
      if (location != null) 'location': location,
      if (amenities != null) 'amenities': amenities,
      if (facilities != null) 'facilities': facilities,
      if (planType != null) 'planType': planType,
      if (googleMaps != null) 'googleMaps': googleMaps,
      if (bookingUrl != null) 'bookingUrl': bookingUrl,
      if (mapsUrl != null) 'mapsUrl': mapsUrl,
    };
  }
}
