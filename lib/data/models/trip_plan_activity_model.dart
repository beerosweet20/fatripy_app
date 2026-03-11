import 'package:cloud_firestore/cloud_firestore.dart';
import '../../domain/entities/trip_plan_activity.dart';

class TripPlanActivityModel extends TripPlanActivity {
  TripPlanActivityModel({
    required super.tripPlanId,
    required super.activityId,
    required super.scheduledAt,
  });

  factory TripPlanActivityModel.fromJson(Map<String, dynamic> json) {
    return TripPlanActivityModel(
      tripPlanId: json['tripPlanId'] as String? ?? '',
      activityId: json['activityId'] as String? ?? '',
      scheduledAt:
          (json['scheduledAt'] as Timestamp?)?.toDate() ?? DateTime.now(),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'tripPlanId': tripPlanId,
      'activityId': activityId,
      'scheduledAt': Timestamp.fromDate(scheduledAt),
    };
  }
}
