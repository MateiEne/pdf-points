import 'package:cloud_firestore/cloud_firestore.dart';

class LiftInfo {
  final String name;
  final String type;
  final String personId;
  final DateTime createdAt;
  final String createdBy;

  LiftInfo({
    required this.name,
    required this.type,
    required this.personId,
    required this.createdAt,
    required this.createdBy,
  });

  Map<String, dynamic> toJson() {
    return {
      'name': name,
      'type': type,
      'personId': personId,
      'createdAt': Timestamp.fromDate(createdAt),
      'createdBy': createdBy,
    };
  }

  factory LiftInfo.fromJson(Map<String, dynamic> json) {
    return LiftInfo(
      name: json['name'],
      type: json['type'],
      personId: json['personId'],
      createdAt: (json['createdAt'] as Timestamp).toDate(),
      createdBy: json['createdBy'],
    );
  }

  factory LiftInfo.fromSnapshot(DocumentSnapshot snapshot) {
    return LiftInfo.fromJson(snapshot.data() as Map<String, dynamic>);
  }

  @override
  String toString() {
    return 'LiftInfo{name: $name, type: $type, personId: $personId, createdAt: $createdAt, createdBy: $createdBy}';
  }
}
