import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:fatripy_app/domain/entities/trip_plan.dart';

void main() {
  test('TripPlan serializes selection and ai elapsed fields', () {
    final createdAt = DateTime(2026, 1, 1);
    final selectedAt = DateTime(2026, 1, 2);

    final plan = TripPlan(
      id: 'trip_1',
      ownerId: 'user_1',
      city: 'Riyadh',
      days: 3,
      budget: 5000,
      totalCost: 4200,
      createdAt: createdAt,
      status: 'Generated',
      selected: true,
      aiElapsedMs: 1800,
      selectedPlanIndex: 1,
      selectedPlanTitle: 'Adventure Plan.',
      selectedAt: selectedAt,
      generatedPlans: const [
        {'title': 'Cultural Plan.'},
      ],
    );

    final json = plan.toJson();
    expect(json['selected'], true);
    expect(json['selectedPlanIndex'], 1);
    expect(json['selectedPlanTitle'], 'Adventure Plan.');
    expect(json['aiElapsedMs'], 1800);

    final hydrated = TripPlan.fromJson({
      ...json,
      'createdAt': Timestamp.fromDate(createdAt),
      'selectedAt': Timestamp.fromDate(selectedAt),
    }, 'trip_1');

    expect(hydrated.selectedPlanIndex, 1);
    expect(hydrated.selectedPlanTitle, 'Adventure Plan.');
    expect(hydrated.aiElapsedMs, 1800);
    expect(hydrated.selectedAt, selectedAt);
  });
}
