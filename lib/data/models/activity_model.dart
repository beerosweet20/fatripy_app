import '../../domain/entities/activity.dart';

class ActivityModel extends Activity {
  ActivityModel({
    required super.id,
    required super.activityId,
    required super.name,
    super.price,
    super.lat,
    super.lng,
    super.rating,
    super.location,
    super.openHours,
    super.closeHours,
    super.googleMaps,
    super.bookingUrl,
    super.mapsUrl,
    super.distanceType,
  });

  factory ActivityModel.fromJson(Map<String, dynamic> json, [String? idStr]) {
    return ActivityModel(
      id: idStr ?? json['id'] ?? '',
      activityId: json['activityId'] ?? json['id'] ?? '',
      name: json['name'] as String? ?? 'Unknown Activity',
      price: (json['price'] as num?)?.toDouble(),
      lat: (json['lat'] as num?)?.toDouble(),
      lng: (json['lng'] as num?)?.toDouble(),
      rating: (json['rating'] as num?)?.toDouble(),
      location: json['location'] as String?,
      openHours: json['openHours'] ?? json['open'],
      closeHours: json['closeHours'] ?? json['close'],
      googleMaps: json['googleMaps'] as String?,
      bookingUrl: json['bookingUrl'] as String?,
      mapsUrl: json['mapsUrl'] as String?,
      distanceType: json['distanceType'] as String?,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'activityId': activityId,
      'name': name,
      if (price != null) 'price': price,
      if (lat != null) 'lat': lat,
      if (lng != null) 'lng': lng,
      if (rating != null) 'rating': rating,
      if (location != null) 'location': location,
      if (openHours != null) 'openHours': openHours,
      if (closeHours != null) 'closeHours': closeHours,
      if (googleMaps != null) 'googleMaps': googleMaps,
      if (bookingUrl != null) 'bookingUrl': bookingUrl,
      if (mapsUrl != null) 'mapsUrl': mapsUrl,
      if (distanceType != null) 'distanceType': distanceType,
    };
  }
}
