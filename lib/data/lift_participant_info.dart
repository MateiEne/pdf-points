import 'package:cloud_firestore/cloud_firestore.dart';

class LiftParticipantInfo {
  final String name;
  final String type;
  final String participantId;
  final DateTime createdAt;
  final String createdBy;

  LiftParticipantInfo({
    required this.name,
    required this.type,
    required this.participantId,
    required this.createdAt,
    required this.createdBy,
  });

  Map<String, dynamic> toJson() {
    return {
      'name': name,
      'type': type,
      'personId': participantId,
      'createdAt': Timestamp.fromDate(createdAt),
      'createdBy': createdBy,
    };
  }

  factory LiftParticipantInfo.fromJson(Map<String, dynamic> json) {
    return LiftParticipantInfo(
      name: json['name'],
      type: json['type'],
      participantId: json['personId'],
      createdAt: (json['createdAt'] as Timestamp).toDate(),
      createdBy: json['createdBy'],
    );
  }

  factory LiftParticipantInfo.fromSnapshot(DocumentSnapshot snapshot) {
    return LiftParticipantInfo.fromJson(snapshot.data() as Map<String, dynamic>);
  }

  @override
  String toString() {
    return 'LiftParticipantInfo{name: $name, type: $type, personId: $participantId, createdAt: $createdAt, createdBy: $createdBy}';
  }
}
