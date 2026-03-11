import 'package:cloud_firestore/cloud_firestore.dart';
import '../../domain/entities/trip_plan.dart';

class TripRepository {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  CollectionReference<TripPlan> get _tripPlansRef => _firestore
      .collection('tripPlans')
      .withConverter<TripPlan>(
        fromFirestore: (snapshot, _) =>
            TripPlan.fromJson(snapshot.data()!, snapshot.id),
        toFirestore: (plan, _) => plan.toJson(),
      );

  /// Get the latest 5 plans for a specific user
  Future<List<TripPlan>> getLatestPlans(String uid) async {
    final query = await _tripPlansRef
        .where('ownerId', isEqualTo: uid)
        // Temporarily removed .orderBy('createdAt', descending: true) to prevent index FAILED_PRECONDITION
        .limit(5)
        .get();

    return query.docs.map((doc) => doc.data()).toList();
  }

  /// Get all plans for a specific user
  Future<List<TripPlan>> getAllPlans(String uid) async {
    final query = await _tripPlansRef
        .where('ownerId', isEqualTo: uid)
        // Temporarily removed .orderBy('createdAt', descending: true) to prevent index FAILED_PRECONDITION
        .get();

    return query.docs.map((doc) => doc.data()).toList();
  }

  /// Add a new plan
  Future<void> addPlan(TripPlan plan) async {
    await _tripPlansRef.add(plan);
  }

  /// Persist the chosen generated plan option for a trip.
  Future<void> markPlanSelection({
    required String tripPlanId,
    required int selectedPlanIndex,
    required String selectedPlanTitle,
  }) async {
    await _firestore.collection('tripPlans').doc(tripPlanId).set({
      'selected': true,
      'selectedPlanIndex': selectedPlanIndex,
      'selectedPlanTitle': selectedPlanTitle,
      'selectedAt': FieldValue.serverTimestamp(),
    }, SetOptions(merge: true));
  }
}
