import 'package:cloud_firestore/cloud_firestore.dart';

class CatalogRepository {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  static final Map<String, List<Map<String, dynamic>>> _hotelCache = {};
  static final Map<String, List<Map<String, dynamic>>> _activityCache = {};
  static final Map<String, List<Map<String, dynamic>>> _eventCache = {};

  String _norm(String value) => value.trim().toLowerCase();

  bool _matchesCity(Map<String, dynamic> data, String city) {
    final cityNorm = _norm(city);
    final cityField = data['city']?.toString();
    if (cityField != null && _norm(cityField) == cityNorm) {
      return true;
    }
    final location = data['location']?.toString();
    if (location != null && _norm(location).contains(cityNorm)) {
      return true;
    }
    return false;
  }

  Future<List<QueryDocumentSnapshot<Map<String, dynamic>>>> _safeReadCollection(
    String collectionName,
  ) async {
    try {
      final query = await _firestore.collection(collectionName).get();
      return query.docs;
    } on FirebaseException {
      // Keep fallbacks resilient when one collection path is inaccessible.
      return const <QueryDocumentSnapshot<Map<String, dynamic>>>[];
    }
  }

  Future<List<Map<String, dynamic>>> _fetchCollection(
    List<String> collectionNames,
  ) async {
    var docs = const <QueryDocumentSnapshot<Map<String, dynamic>>>[];
    for (final collectionName in collectionNames) {
      final snapshotDocs = await _safeReadCollection(collectionName);
      if (snapshotDocs.isNotEmpty) {
        docs = snapshotDocs;
        break;
      }
    }

    return docs.map((doc) {
      final data = doc.data();
      final resolvedId =
          data['id'] ??
          data['accommodationId'] ??
          data['hotelId'] ??
          data['activityId'] ??
          doc.id;

      return <String, dynamic>{
        ...data,
        'id': resolvedId.toString(),
        'name':
            data['name'] ??
            data['title'] ??
            data['hotelName'] ??
            data['accommodationName'],
        'title': data['title'] ?? data['name'],
        'location': data['location'] ?? data['address'],
        'lat': data['lat'] ?? data['latitude'],
        'lng': data['lng'] ?? data['longitude'],
        'mapsUrl': data['mapsUrl'] ?? data['googleMaps'],
        'googleMaps': data['googleMaps'] ?? data['mapsUrl'],
        'hotelId': data['hotelId'] ?? resolvedId.toString(),
        'accommodationId': data['accommodationId'] ?? resolvedId.toString(),
        'activityId': data['activityId'] ?? resolvedId.toString(),
      };
    }).toList();
  }

  Future<List<Map<String, dynamic>>> getHotelsByCity(String city) async {
    if (_hotelCache.containsKey(city) && _hotelCache[city]!.isNotEmpty) {
      return _hotelCache[city]!;
    }
    final all = await _fetchCollection(['accommodations', 'hotels', 'Hotels']);

    var filtered = all.where((h) => _matchesCity(h, city)).toList();
    if (filtered.isEmpty) {
      filtered = all; // fallback if city data is missing
    }

    if (filtered.isNotEmpty) {
      _hotelCache[city] = filtered;
    }
    return filtered;
  }

  Future<List<Map<String, dynamic>>> getActivitiesByCity(String city) async {
    if (_activityCache.containsKey(city) && _activityCache[city]!.isNotEmpty) {
      return _activityCache[city]!;
    }
    final all = await _fetchCollection(['activities', 'Activities']);

    var filtered = all.where((a) => _matchesCity(a, city)).toList();
    if (filtered.isEmpty) {
      filtered = all;
    }

    if (filtered.isNotEmpty) {
      _activityCache[city] = filtered;
    }
    return filtered;
  }

  Future<List<Map<String, dynamic>>> getEventsByCity(String city) async {
    if (_eventCache.containsKey(city) && _eventCache[city]!.isNotEmpty) {
      return _eventCache[city]!;
    }
    final all = await _fetchCollection(['events', 'Events']);

    var filtered = all.where((e) => _matchesCity(e, city)).toList();
    if (filtered.isEmpty) {
      filtered = all;
    }
    if (filtered.isNotEmpty) {
      _eventCache[city] = filtered;
    }
    return filtered;
  }
}
