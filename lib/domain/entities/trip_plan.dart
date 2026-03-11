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
  final double? aiElapsedMs;
  final int? selectedPlanIndex;
  final String? selectedPlanTitle;
  final DateTime? selectedAt;
  final String? budgetStatus;
  final double? minimumRequired;
  final List<dynamic>? generatedPlans;

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
    this.aiElapsedMs,
    this.selectedPlanIndex,
    this.selectedPlanTitle,
    this.selectedAt,
    this.budgetStatus,
    this.minimumRequired,
    this.generatedPlans,
  });

  static double? _asDouble(dynamic value) {
    if (value is num) return value.toDouble();
    if (value is String) return double.tryParse(value.trim());
    return null;
  }

  static List<dynamic>? _normalizeGeneratedPlans(dynamic rawPlans) {
    if (rawPlans is! List) return null;
    return rawPlans.map((rawItem) {
      if (rawItem is! Map) return rawItem;
      final map = Map<String, dynamic>.from(rawItem);

      final status = map['budgetStatus'] ?? map['budget_status'];
      if (status != null) {
        final statusText = status.toString();
        map['budgetStatus'] = statusText;
        map['budget_status'] = statusText;
      }

      final minimum = _asDouble(
        map['minimumRequired'] ?? map['minimum_required'],
      );
      if (minimum != null) {
        map['minimumRequired'] = minimum;
        map['minimum_required'] = minimum;
      }

      return map;
    }).toList();
  }

  factory TripPlan.fromJson(Map<String, dynamic> json, String id) {
    final normalizedGeneratedPlans = _normalizeGeneratedPlans(
      json['generatedPlans'],
    );
    final firstGeneratedPlan =
        normalizedGeneratedPlans != null &&
            normalizedGeneratedPlans.isNotEmpty &&
            normalizedGeneratedPlans.first is Map
        ? Map<String, dynamic>.from(normalizedGeneratedPlans.first as Map)
        : const <String, dynamic>{};

    return TripPlan(
      id: id,
      ownerId: json['ownerId'] as String? ?? '',
      groupId: json['groupId'] as String?,
      city: json['city'] as String? ?? 'Unknown',
      days: (json['days'] as num?)?.toInt() ?? 1,
      budget: (json['budget'] as num?)?.toDouble() ?? 0.0,
      totalCost: (json['totalCost'] as num?)?.toDouble() ?? 0.0,
      createdAt: (json['createdAt'] as Timestamp?)?.toDate() ?? DateTime.now(),
      status: json['status'] as String? ?? 'Draft',
      selected: json['selected'] as bool? ?? false,
      aiElapsedMs: (json['aiElapsedMs'] as num?)?.toDouble(),
      selectedPlanIndex: (json['selectedPlanIndex'] as num?)?.toInt(),
      selectedPlanTitle: json['selectedPlanTitle'] as String?,
      selectedAt: (json['selectedAt'] as Timestamp?)?.toDate(),
      budgetStatus:
          (json['budgetStatus'] ??
                  json['budget_status'] ??
                  firstGeneratedPlan['budgetStatus'] ??
                  firstGeneratedPlan['budget_status'])
              ?.toString(),
      minimumRequired: _asDouble(
        json['minimumRequired'] ??
            json['minimum_required'] ??
            firstGeneratedPlan['minimumRequired'] ??
            firstGeneratedPlan['minimum_required'],
      ),
      generatedPlans: normalizedGeneratedPlans,
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
      if (aiElapsedMs != null) 'aiElapsedMs': aiElapsedMs,
      if (selectedPlanIndex != null) 'selectedPlanIndex': selectedPlanIndex,
      if (selectedPlanTitle != null) 'selectedPlanTitle': selectedPlanTitle,
      if (selectedAt != null) 'selectedAt': Timestamp.fromDate(selectedAt!),
      if (budgetStatus != null) 'budgetStatus': budgetStatus,
      if (minimumRequired != null) 'minimumRequired': minimumRequired,
      if (generatedPlans != null) 'generatedPlans': generatedPlans,
    };
  }
}
