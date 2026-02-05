import 'package:cloud_firestore/cloud_firestore.dart';

class LiftPendingUpdate {
  final String name;

  LiftPendingUpdate({
    required this.name,
  });

  Map<String, dynamic> toJson() {
    return {
      'name': name,
    };
  }

  factory LiftPendingUpdate.fromJson(Map<String, dynamic> json) {
    return LiftPendingUpdate(
      name: json['name'],
    );
  }

  factory LiftPendingUpdate.fromSnapshot(DocumentSnapshot snapshot) {
    return LiftPendingUpdate.fromJson(snapshot.data() as Map<String, dynamic>);
  }

  @override
  String toString() {
    return 'LiftPendingUpdate{name: $name}';
  }
}