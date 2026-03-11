import 'package:cloud_firestore/cloud_firestore.dart';

import '../../domain/entities/family_group.dart';
import '../../domain/entities/group_member.dart';

class FamilyAggregate {
  final FamilyGroup familyGroup;
  final List<GroupMember> members;
  final String destinationCity;
  final int durationDays;
  final int adults;
  final int children;
  final int infants;
  final String? budgetLabel;
  final String? startLabel;
  final String? endLabel;

  const FamilyAggregate({
    required this.familyGroup,
    required this.members,
    required this.destinationCity,
    required this.durationDays,
    required this.adults,
    required this.children,
    required this.infants,
    this.budgetLabel,
    this.startLabel,
    this.endLabel,
  });
}

class FamilyRepository {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  CollectionReference<Map<String, dynamic>> get _familyGroupsRef =>
      _firestore.collection('familyGroups');
  CollectionReference<Map<String, dynamic>> get _groupMembersRef =>
      _firestore.collection('groupMembers');

  Future<void> saveFamilyData({
    required String ownerId,
    required String groupName,
    required double budget,
    required DateTime startDate,
    required DateTime endDate,
    required String destinationCity,
    required int durationDays,
    required List<int> adultAges,
    required List<int> childAges,
    required List<int> infantAges,
    String? budgetLabel,
    String? startLabel,
    String? endLabel,
  }) async {
    final groupId = ownerId;
    final familyGroup = FamilyGroup(
      groupId: groupId,
      groupName: groupName,
      budget: budget,
      startDate: startDate,
      endDate: endDate,
    );

    final totalMembers =
        adultAges.length + childAges.length + infantAges.length;
    final payload = <String, dynamic>{
      'groupId': familyGroup.groupId,
      'ownerId': ownerId,
      'groupName': familyGroup.groupName,
      'budget': familyGroup.budget,
      'startDate': Timestamp.fromDate(familyGroup.startDate),
      'endDate': Timestamp.fromDate(familyGroup.endDate),
      'destinationCity': destinationCity,
      'durationDays': durationDays,
      'numberOfMembers': totalMembers,
      'adults': adultAges.length,
      'children': childAges.length,
      'infants': infantAges.length,
      if (budgetLabel != null && budgetLabel.trim().isNotEmpty)
        'budgetLabel': budgetLabel.trim(),
      if (startLabel != null && startLabel.trim().isNotEmpty)
        'startLabel': startLabel.trim(),
      if (endLabel != null && endLabel.trim().isNotEmpty)
        'endLabel': endLabel.trim(),
      'updatedAt': FieldValue.serverTimestamp(),
    };

    await _familyGroupsRef.doc(groupId).set(payload, SetOptions(merge: true));

    final previousMembers = await _groupMembersRef
        .where('ownerId', isEqualTo: ownerId)
        .get();
    final batch = _firestore.batch();
    for (final doc in previousMembers.docs) {
      final data = doc.data();
      if ((data['groupId'] ?? '').toString() == groupId) {
        batch.delete(doc.reference);
      }
    }

    final members = <GroupMember>[
      ..._buildMembers('Adult', adultAges),
      ..._buildMembers('Child', childAges),
      ..._buildMembers('Infant', infantAges),
    ];

    for (final member in members) {
      final docRef = _groupMembersRef.doc();
      batch.set(docRef, {
        'memberId': docRef.id,
        'groupId': groupId,
        'ownerId': ownerId,
        'name': member.name,
        'age': member.age,
        'ageGroup': member.ageGroup,
        'createdAt': FieldValue.serverTimestamp(),
        'updatedAt': FieldValue.serverTimestamp(),
      });
    }
    await batch.commit();
  }

  Future<FamilyAggregate?> getFamilyData(String ownerId) async {
    final familyDoc = await _familyGroupsRef.doc(ownerId).get();
    if (!familyDoc.exists) {
      return null;
    }

    final familyData = familyDoc.data() ?? <String, dynamic>{};
    final group = FamilyGroup(
      groupId: (familyData['groupId'] ?? familyDoc.id).toString(),
      groupName: (familyData['groupName'] ?? '').toString(),
      budget: _toDouble(familyData['budget']),
      startDate: _toDate(familyData['startDate']),
      endDate: _toDate(familyData['endDate']),
    );

    final membersSnapshot = await _groupMembersRef
        .where('ownerId', isEqualTo: ownerId)
        .get();
    final members =
        membersSnapshot.docs
            .where(
              (doc) =>
                  (doc.data()['groupId'] ?? '').toString() == group.groupId,
            )
            .map((doc) {
              final m = doc.data();
              return GroupMember(
                memberId: (m['memberId'] ?? doc.id).toString(),
                name: (m['name'] ?? '').toString(),
                age: _toInt(m['age']),
                ageGroup: (m['ageGroup'] ?? '').toString(),
              );
            })
            .toList()
          ..sort(
            (a, b) => a.name.toLowerCase().compareTo(b.name.toLowerCase()),
          );

    return FamilyAggregate(
      familyGroup: group,
      members: members,
      destinationCity: (familyData['destinationCity'] ?? '').toString(),
      durationDays: _toInt(familyData['durationDays']),
      adults: _toInt(familyData['adults']),
      children: _toInt(familyData['children']),
      infants: _toInt(familyData['infants']),
      budgetLabel: familyData['budgetLabel']?.toString(),
      startLabel: familyData['startLabel']?.toString(),
      endLabel: familyData['endLabel']?.toString(),
    );
  }

  List<GroupMember> _buildMembers(String ageGroup, List<int> ages) {
    final members = <GroupMember>[];
    for (var i = 0; i < ages.length; i++) {
      members.add(
        GroupMember(
          memberId: '',
          name: '$ageGroup ${i + 1}',
          age: ages[i],
          ageGroup: ageGroup,
        ),
      );
    }
    return members;
  }

  double _toDouble(dynamic value) {
    if (value is num) return value.toDouble();
    return double.tryParse(value?.toString() ?? '') ?? 0.0;
  }

  int _toInt(dynamic value) {
    if (value is num) return value.toInt();
    return int.tryParse(value?.toString() ?? '') ?? 0;
  }

  DateTime _toDate(dynamic value) {
    if (value is Timestamp) return value.toDate();
    if (value is DateTime) return value;
    if (value is String) {
      return DateTime.tryParse(value) ?? DateTime.now();
    }
    return DateTime.now();
  }
}
