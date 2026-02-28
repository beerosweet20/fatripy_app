import 'package:cloud_firestore/cloud_firestore.dart';

class Booking {
  final String id;
  final String uid;
  final String planId;
  final String itemType;
  final String itemId;
  final String status;
  final DateTime createdAt;

  Booking({
    required this.id,
    required this.uid,
    required this.planId,
    required this.itemType,
    required this.itemId,
    required this.status,
    required this.createdAt,
  });

  factory Booking.fromJson(Map<String, dynamic> json, String id) {
    return Booking(
      id: id,
      uid: json['uid'] as String? ?? '',
      planId: json['planId'] as String? ?? '',
      itemType: json['itemType'] as String? ?? '',
      itemId: json['itemId'] as String? ?? '',
      status: json['status'] as String? ?? 'Pending',
      createdAt: (json['createdAt'] as Timestamp?)?.toDate() ?? DateTime.now(),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'uid': uid,
      'planId': planId,
      'itemType': itemType,
      'itemId': itemId,
      'status': status,
      'createdAt': Timestamp.fromDate(createdAt),
    };
  }
}
