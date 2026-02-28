import 'package:cloud_firestore/cloud_firestore.dart';

class UserProfile {
  final String uid;
  final String fullName;
  final String username;
  final String email;
  final DateTime createdAt;
  final String? fcmToken;

  UserProfile({
    required this.uid,
    required this.fullName,
    required this.username,
    required this.email,
    required this.createdAt,
    this.fcmToken,
  });

  factory UserProfile.fromJson(Map<String, dynamic> json, String uid) {
    return UserProfile(
      uid: uid,
      fullName: json['fullName'] as String? ?? 'Family Member',
      username: json['username'] as String? ?? '',
      email: json['email'] as String? ?? '',
      createdAt: (json['createdAt'] as Timestamp?)?.toDate() ?? DateTime.now(),
      fcmToken: json['fcmToken'] as String?,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'fullName': fullName,
      'username': username,
      'email': email,
      'createdAt': Timestamp.fromDate(createdAt),
      if (fcmToken != null) 'fcmToken': fcmToken,
    };
  }
}
