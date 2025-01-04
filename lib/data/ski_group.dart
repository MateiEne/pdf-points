import 'package:cloud_firestore/cloud_firestore.dart';

import 'participant.dart';

class SkiGroup {
  final String id;
  final String name;
  final String? image;
  final String instructorId;
  final List<String> studentsIds;
  final DateTime createdAt;

  SkiGroup({
    required this.id,
    required this.name,
    required this.instructorId,
    this.image,
    this.studentsIds = const [],
    required this.createdAt,
  });

  void addStudent(Participant participant) {
    studentsIds.add(participant.id);
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'image': image,
      'instructorId': instructorId,
      'studentsIds': studentsIds,
      'createdAt': Timestamp.fromDate(createdAt),
    };
  }

  factory SkiGroup.fromJson(Map<String, dynamic> json) {
    return SkiGroup(
      id: json['id'],
      name: json['name'],
      image: json['image'],
      instructorId: json['instructorId'],
      studentsIds: List<String>.from(json['studentsIds'] ?? []),
      createdAt: (json['createdAt'] as Timestamp).toDate(),
    );
  }

  factory SkiGroup.fromSnapshot(DocumentSnapshot snapshot) {
    return SkiGroup.fromJson(snapshot.data() as Map<String, dynamic>);
  }

  @override
  String toString() {
    return 'SkiGroup{name: $name, image: $image,  ${studentsIds.length} students, instructorId: $instructorId, createdAt: $createdAt}';
  }
}
