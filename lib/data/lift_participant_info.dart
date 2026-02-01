import 'package:cloud_firestore/cloud_firestore.dart';

class LiftParticipantInfo {
  final String id; // Document ID from Firestore
  final String name;
  final String type;
  final String participantId;
  final DateTime createdAt;
  final String createdBy;

  LiftParticipantInfo({
    required this.id,
    required this.name,
    required this.type,
    required this.participantId,
    required this.createdAt,
    required this.createdBy,
  });

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'type': type,
      'personId': participantId,
      'createdAt': Timestamp.fromDate(createdAt),
      'createdBy': createdBy,
    };
  }

  factory LiftParticipantInfo.fromJson(Map<String, dynamic> json) {
    return LiftParticipantInfo(
      id: json['id'],
      name: json['name'],
      type: json['type'],
      participantId: json['personId'],
      createdAt: (json['createdAt'] as Timestamp).toDate(),
      createdBy: json['createdBy'],
    );
  }

  factory LiftParticipantInfo.fromSnapshot(DocumentSnapshot snapshot) {
    final data = snapshot.data() as Map<String, dynamic>;
    return LiftParticipantInfo.fromJson(data);
  }

  @override
  String toString() {
    return 'LiftParticipantInfo{id: $id, name: $name, type: $type, personId: $participantId, createdAt: $createdAt, createdBy: $createdBy}';
  }
}
