import 'package:cloud_firestore/cloud_firestore.dart';

class LiftPendingUpdate {
  final String id;
  final String name;
  final int currentPoints;

  LiftPendingUpdate({
    required this.id,
    required this.name,
    required this.currentPoints,
  });

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'currentPoints': currentPoints,
    };
  }

  factory LiftPendingUpdate.fromJson(Map<String, dynamic> json) {
    return LiftPendingUpdate(
      id: json['id'],
      name: json['name'],
      currentPoints: json['currentPoints'],
    );
  }

  factory LiftPendingUpdate.fromSnapshot(DocumentSnapshot snapshot) {
    return LiftPendingUpdate.fromJson(snapshot.data() as Map<String, dynamic>);
  }

  @override
  String toString() {
    return 'LiftPendingUpdate{id: $id, name: $name, currentPoints: $currentPoints}';
  }
}