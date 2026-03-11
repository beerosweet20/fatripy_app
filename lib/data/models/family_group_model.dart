import 'package:cloud_firestore/cloud_firestore.dart';
import '../../domain/entities/family_group.dart';

class FamilyGroupModel extends FamilyGroup {
  FamilyGroupModel({
    required super.groupId,
    required super.groupName,
    required super.budget,
    required super.startDate,
    required super.endDate,
  });

  factory FamilyGroupModel.fromJson(Map<String, dynamic> json, String id) {
    return FamilyGroupModel(
      groupId: id,
      groupName: json['groupName'] as String? ?? '',
      budget: (json['budget'] as num?)?.toDouble() ?? 0.0,
      startDate: (json['startDate'] as Timestamp?)?.toDate() ?? DateTime.now(),
      endDate: (json['endDate'] as Timestamp?)?.toDate() ?? DateTime.now(),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'groupName': groupName,
      'budget': budget,
      'startDate': Timestamp.fromDate(startDate),
      'endDate': Timestamp.fromDate(endDate),
    };
  }
}
