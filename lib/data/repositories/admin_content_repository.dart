import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

class AdminStats {
  final int users;
  final int tripPlans;
  final int bookings;
  final int hotels;
  final int activities;

  const AdminStats({
    required this.users,
    required this.tripPlans,
    required this.bookings,
    required this.hotels,
    required this.activities,
  });
}

class AdminDashboardAnalytics {
  final AdminStats stats;
  final Map<String, int> bookingStatusCounts;
  final Map<String, int> topCities;
  final Map<String, int> topSelectedPlanTitles;
  final int selectedPlans;
  final double averageAiElapsedMs;
  final int slowAiResponses;

  const AdminDashboardAnalytics({
    required this.stats,
    required this.bookingStatusCounts,
    required this.topCities,
    required this.topSelectedPlanTitles,
    required this.selectedPlans,
    required this.averageAiElapsedMs,
    required this.slowAiResponses,
  });
}

class AdminDoc {
  final String id;
  final Map<String, dynamic> data;

  const AdminDoc({required this.id, required this.data});
}

class AdminContentRepository {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final FirebaseAuth _auth = FirebaseAuth.instance;
  static const String _hotelsCollection = 'hotels';

  Future<void> _refreshToken({bool force = false}) async {
    final user = _auth.currentUser;
    if (user == null) {
      return;
    }
    await user.getIdToken(force);
  }

  Future<int> _countCollection(String collection) async {
    final aggregate = await _firestore.collection(collection).count().get();
    return aggregate.count;
  }

  Future<AdminStats> fetchStats() async {
    Future<List<int>> loadCounts() {
      return Future.wait<int>([
        _countCollection('users'),
        _countCollection('tripPlans'),
        _countCollection('bookings'),
        _countCollection(_hotelsCollection),
        _countCollection('activities'),
      ]);
    }

    List<int> counts;
    try {
      counts = await loadCounts();
    } on FirebaseException catch (e) {
      // Claims refresh can lag on first request after role change.
      if (e.code != 'permission-denied') rethrow;
      await _refreshToken(force: true);
      counts = await loadCounts();
    }

    return AdminStats(
      users: counts[0],
      tripPlans: counts[1],
      bookings: counts[2],
      hotels: counts[3],
      activities: counts[4],
    );
  }

  Future<AdminDashboardAnalytics> fetchDashboardAnalytics() async {
    Future<AdminDashboardAnalytics> loadAnalytics() async {
      final stats = await fetchStats();
      final bookingsSnapshot = await _firestore
          .collection('bookings')
          .limit(500)
          .get();
      final tripPlansSnapshot = await _firestore
          .collection('tripPlans')
          .limit(500)
          .get();

      final bookingStatus = <String, int>{
        'pending': 0,
        'confirmed': 0,
        'cancelled': 0,
        'other': 0,
      };
      for (final doc in bookingsSnapshot.docs) {
        final data = doc.data();
        final normalized = _normalizeStatus(data['status']?.toString());
        bookingStatus[normalized] = (bookingStatus[normalized] ?? 0) + 1;
      }

      final cityCounts = <String, int>{};
      final selectedPlanTitles = <String, int>{};
      var selectedPlans = 0;
      var aiCount = 0;
      var aiTotal = 0.0;
      var slowAiResponses = 0;

      for (final doc in tripPlansSnapshot.docs) {
        final data = doc.data();
        final city = (data['city']?.toString().trim() ?? '');
        if (city.isNotEmpty) {
          cityCounts[city] = (cityCounts[city] ?? 0) + 1;
        }

        if (data['selected'] == true) {
          selectedPlans += 1;
          final selectedTitle = data['selectedPlanTitle']?.toString().trim();
          if (selectedTitle != null && selectedTitle.isNotEmpty) {
            selectedPlanTitles[selectedTitle] =
                (selectedPlanTitles[selectedTitle] ?? 0) + 1;
          }
        }

        final aiElapsed = (data['aiElapsedMs'] as num?)?.toDouble();
        if (aiElapsed != null && aiElapsed > 0) {
          aiCount += 1;
          aiTotal += aiElapsed;
          if (aiElapsed > 3000) {
            slowAiResponses += 1;
          }
        }
      }

      return AdminDashboardAnalytics(
        stats: stats,
        bookingStatusCounts: bookingStatus,
        topCities: _takeTopEntries(cityCounts),
        topSelectedPlanTitles: _takeTopEntries(selectedPlanTitles),
        selectedPlans: selectedPlans,
        averageAiElapsedMs: aiCount == 0 ? 0 : aiTotal / aiCount,
        slowAiResponses: slowAiResponses,
      );
    }

    try {
      return await loadAnalytics();
    } on FirebaseException catch (e) {
      if (e.code != 'permission-denied') rethrow;
      await _refreshToken(force: true);
      return loadAnalytics();
    }
  }

  String _normalizeStatus(String? rawStatus) {
    final status = (rawStatus ?? '').trim().toLowerCase();
    if (status.contains('confirm')) {
      return 'confirmed';
    }
    if (status.contains('cancel')) {
      return 'cancelled';
    }
    if (status.contains('pend')) {
      return 'pending';
    }
    if (status.isEmpty) {
      return 'pending';
    }
    return 'other';
  }

  Map<String, int> _takeTopEntries(Map<String, int> source, {int limit = 5}) {
    final entries = source.entries.toList()
      ..sort((a, b) => b.value.compareTo(a.value));
    final sliced = entries.take(limit);
    return Map<String, int>.fromEntries(sliced);
  }

  Stream<List<AdminDoc>> watchCollection(String collection) {
    final legacy = _legacyCollectionName(collection);
    return _firestore.collection(collection).snapshots().asyncMap((
      snapshot,
    ) async {
      final primaryDocs = snapshot.docs
          .map((doc) => AdminDoc(id: doc.id, data: doc.data()))
          .toList();
      if (primaryDocs.isNotEmpty || legacy == null) {
        return primaryDocs;
      }

      final legacySnapshot = await _firestore.collection(legacy).get();
      if (legacySnapshot.docs.isEmpty) {
        return primaryDocs;
      }

      // Migrate old collection naming into the standardized lowercase path.
      await _migrateLegacyCollection(
        targetCollection: collection,
        legacyDocs: legacySnapshot.docs,
      );
      return legacySnapshot.docs
          .map((doc) => AdminDoc(id: doc.id, data: doc.data()))
          .toList();
    });
  }

  String? _legacyCollectionName(String collection) {
    switch (collection) {
      case 'hotels':
        return 'Hotels';
      case 'activities':
        return 'Activities';
      case 'events':
        return 'Events';
      default:
        return null;
    }
  }

  Future<void> _migrateLegacyCollection({
    required String targetCollection,
    required List<QueryDocumentSnapshot<Map<String, dynamic>>> legacyDocs,
  }) async {
    final batch = _firestore.batch();
    for (final doc in legacyDocs) {
      final source = Map<String, dynamic>.from(doc.data());
      if (targetCollection == 'events') {
        source['title'] = (source['title'] ?? source['name'] ?? '').toString();
      }
      if (targetCollection == 'activities') {
        source['title'] = (source['title'] ?? source['name'] ?? '').toString();
        source['name'] = (source['name'] ?? source['title'] ?? '').toString();
      }
      source['id'] = (source['id'] ?? doc.id).toString();
      source['updatedAt'] = FieldValue.serverTimestamp();
      final targetRef = _firestore.collection(targetCollection).doc(doc.id);
      batch.set(targetRef, source, SetOptions(merge: true));
    }
    await batch.commit();
  }

  Future<void> saveHotel({
    String? id,
    required String name,
    required String city,
    required double rating,
    required String priceRange,
    required String description,
    required String location,
    required double latitude,
    required double longitude,
    required String mapsUrl,
  }) async {
    final prices = RegExp(r'\d+(?:\.\d+)?')
        .allMatches(priceRange)
        .map((m) => double.tryParse(m.group(0)!))
        .whereType<double>()
        .toList();
    final parsedPriceMin = prices.isEmpty ? null : prices.first;
    final parsedPriceMax = prices.length > 1 ? prices[1] : parsedPriceMin;
    final parsedPricePerNight =
        (parsedPriceMin != null && parsedPriceMax != null)
        ? (parsedPriceMin + parsedPriceMax) / 2
        : parsedPriceMin;

    final docRef = id == null
        ? _firestore.collection(_hotelsCollection).doc()
        : _firestore.collection(_hotelsCollection).doc(id);

    final payload = <String, dynamic>{
      'id': docRef.id,
      'accommodationId': docRef.id,
      'name': name,
      'city': city,
      'rating': rating,
      'priceRange': priceRange,
      'description': description,
      'location': location,
      'pricePerNight': parsedPricePerNight,
      'priceMin': parsedPriceMin,
      'priceMax': parsedPriceMax,
      'lat': latitude,
      'lng': longitude,
      'latitude': latitude,
      'longitude': longitude,
      'googleMaps': mapsUrl,
      'mapsUrl': mapsUrl,
      'updatedAt': FieldValue.serverTimestamp(),
    }..removeWhere((_, value) => value == null);

    if (id == null) {
      payload['createdAt'] = FieldValue.serverTimestamp();
    }

    await docRef.set(payload, SetOptions(merge: true));
  }

  Future<void> deleteHotel(String id) async {
    await _firestore.collection(_hotelsCollection).doc(id).delete();
  }

  Future<void> saveActivity({
    String? id,
    required String title,
    required String category,
    required String city,
    required String location,
    required double rating,
    required String description,
    double? latitude,
    double? longitude,
    String? mapsUrl,
  }) async {
    final docRef = id == null
        ? _firestore.collection('activities').doc()
        : _firestore.collection('activities').doc(id);

    final payload = <String, dynamic>{
      'id': docRef.id,
      'activityId': docRef.id,
      // Keep both keys for compatibility with existing API schema reads.
      'title': title,
      'name': title,
      'category': category,
      'city': city,
      'location': location,
      'rating': rating,
      'description': description,
      if (latitude != null) ...{'latitude': latitude, 'lat': latitude},
      if (longitude != null) ...{'longitude': longitude, 'lng': longitude},
      if (mapsUrl?.trim().isNotEmpty ?? false) 'mapsUrl': mapsUrl!.trim(),
      'updatedAt': FieldValue.serverTimestamp(),
    };

    if (id == null) {
      payload['createdAt'] = FieldValue.serverTimestamp();
    }

    await docRef.set(payload, SetOptions(merge: true));
  }

  Future<void> deleteActivity(String id) async {
    await _firestore.collection('activities').doc(id).delete();
  }

  Future<void> saveEvent({
    String? id,
    required String title,
    required String date,
    required String location,
    required String description,
    required String city,
    double? latitude,
    double? longitude,
    String? mapsUrl,
  }) async {
    final docRef = id == null
        ? _firestore.collection('events').doc()
        : _firestore.collection('events').doc(id);

    final payload = <String, dynamic>{
      'id': docRef.id,
      'eventId': docRef.id,
      'title': title,
      'name': title,
      'date': date,
      'location': location,
      'description': description,
      'city': city,
      if (latitude != null) ...{'latitude': latitude, 'lat': latitude},
      if (longitude != null) ...{'longitude': longitude, 'lng': longitude},
      if (mapsUrl?.trim().isNotEmpty ?? false) 'mapsUrl': mapsUrl!.trim(),
      'updatedAt': FieldValue.serverTimestamp(),
    };

    if (id == null) {
      payload['createdAt'] = FieldValue.serverTimestamp();
    }

    await docRef.set(payload, SetOptions(merge: true));
  }

  Future<void> deleteEvent(String id) async {
    await _firestore.collection('events').doc(id).delete();
  }
}
