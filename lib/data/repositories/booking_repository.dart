import 'package:cloud_firestore/cloud_firestore.dart';
import '../models/booking.dart';

class BookingRepository {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  CollectionReference<Booking> get _bookingsRef => _firestore
      .collection('bookings')
      .withConverter<Booking>(
        fromFirestore: (snapshot, _) =>
            Booking.fromJson(snapshot.data()!, snapshot.id),
        toFirestore: (booking, _) => booking.toJson(),
      );

  /// Get the latest 3 bookings for a specific user
  Future<List<Booking>> getLatestBookings(String uid) async {
    final query = await _bookingsRef
        .where('uid', isEqualTo: uid)
        // Temporarily removed .orderBy('createdAt', descending: true) to prevent index FAILED_PRECONDITION
        .limit(3)
        .get();

    return query.docs.map((doc) => doc.data()).toList();
  }

  /// Get all bookings for a user
  Future<List<Booking>> getAllBookings(String uid) async {
    final query = await _bookingsRef
        .where('uid', isEqualTo: uid)
        // Temporarily removed .orderBy('createdAt', descending: true) to prevent index FAILED_PRECONDITION
        .get();

    return query.docs.map((doc) => doc.data()).toList();
  }
}
