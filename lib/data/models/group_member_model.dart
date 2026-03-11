import '../../domain/entities/group_member.dart';

class GroupMemberModel extends GroupMember {
  GroupMemberModel({
    required super.memberId,
    required super.name,
    required super.age,
    required super.ageGroup,
  });

  factory GroupMemberModel.fromJson(Map<String, dynamic> json, String id) {
    return GroupMemberModel(
      memberId: id,
      name: json['name'] as String? ?? 'Unknown',
      age: (json['age'] as num?)?.toInt() ?? 0,
      ageGroup: json['ageGroup'] as String? ?? 'Adult',
    );
  }

  Map<String, dynamic> toJson() {
    return {'name': name, 'age': age, 'ageGroup': ageGroup};
  }
}
