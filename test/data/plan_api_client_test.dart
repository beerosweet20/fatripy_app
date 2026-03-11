import 'package:flutter_test/flutter_test.dart';
import 'package:fatripy_app/data/api/plan_api_client.dart';

void main() {
  group('PlanGenerationResult', () {
    test('parses generated plans and aiElapsedMs', () {
      final result = PlanGenerationResult.fromMap({
        'generatedPlans': [
          {'title': 'Cultural Plan.'},
          {'title': 'Adventure Plan.'},
        ],
        'aiElapsedMs': 2450.7,
      });

      expect(result.generatedPlans, hasLength(2));
      expect(result.generatedPlans.first['title'], 'Cultural Plan.');
      expect(result.aiElapsedMs, 2450.7);
    });

    test('handles missing fields safely', () {
      final result = PlanGenerationResult.fromMap({});
      expect(result.generatedPlans, isEmpty);
      expect(result.aiElapsedMs, isNull);
    });
  });
}
