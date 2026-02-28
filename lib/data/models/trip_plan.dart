import 'package:cloud_firestore/cloud_firestore.dart';

class TripPlan {
  final String id;
  final String ownerId;
  final String? groupId;
  final String city;
  final int days;
  final double budget;
  final double totalCost;
  final DateTime createdAt;
  final String status;
  final bool selected;

  TripPlan({
    required this.id,
    required this.ownerId,
    this.groupId,
    required this.city,
    required this.days,
    required this.budget,
    required this.totalCost,
    required this.createdAt,
    required this.status,
    required this.selected,
  });

  factory TripPlan.fromJson(Map<String, dynamic> json, String id) {
    return TripPlan(
      id: id,
      ownerId: json['ownerId'] as String? ?? '',
      groupId: json['groupId'] as String?,
      city: json['city'] as String? ?? 'Unknown',
      days: json['days'] as int? ?? 1,
      budget: (json['budget'] as num?)?.toDouble() ?? 0.0,
      totalCost: (json['totalCost'] as num?)?.toDouble() ?? 0.0,
      createdAt: (json['createdAt'] as Timestamp?)?.toDate() ?? DateTime.now(),
      status: json['status'] as String? ?? 'Draft',
      selected: json['selected'] as bool? ?? false,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'ownerId': ownerId,
      if (groupId != null) 'groupId': groupId,
      'city': city,
      'days': days,
      'budget': budget,
      'totalCost': totalCost,
      'createdAt': Timestamp.fromDate(createdAt),
      'status': status,
      'selected': selected,
    };
  }
}
