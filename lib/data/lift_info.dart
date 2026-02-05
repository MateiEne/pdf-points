import 'package:cloud_firestore/cloud_firestore.dart';

class LiftInfo {
  final String name;
  final String type;
  final int points;
  final DateTime modifiedAt;
  final String modifiedBy;

  LiftInfo({
    required this.name,
    required this.type,
    required this.points,
    required this.modifiedAt,
    required this.modifiedBy,
  });

  Map<String, dynamic> toJson() {
    return {
      'name': name,
      'type': type,
      'points': points,
      'modifiedAt': Timestamp.fromDate(modifiedAt),
      'modifiedBy': modifiedBy,
    };
  }

  factory LiftInfo.fromJson(Map<String, dynamic> json) {
    return LiftInfo(
      name: json['name'],
      type: json['type'],
      points: json['points'],
      modifiedAt: (json['modifiedAt'] as Timestamp).toDate(),
      modifiedBy: json['modifiedBy'],
    );
  }

  factory LiftInfo.fromSnapshot(DocumentSnapshot snapshot) {
    return LiftInfo.fromJson(snapshot.data() as Map<String, dynamic>);
  }

  bool isFromToday() {
    final now = DateTime.now();
    return modifiedAt.year == now.year && modifiedAt.month == now.month && modifiedAt.day == now.day;
  }

  bool isNotFromToday() {
    return !isFromToday();
  }

  String getStatusInfo() {
    final now = DateTime.now();
    final modifiedAt = this.modifiedAt;
    final today = DateTime(now.year, now.month, now.day);
    final modifiedDay = DateTime(modifiedAt.year, modifiedAt.month, modifiedAt.day);
    final daysDifference = today.difference(modifiedDay).inDays;

    String timeAgo;
    if (daysDifference == 0) {
      timeAgo = 'today';
    } else {
      timeAgo = '${daysDifference}d ago';
    }

    return '${points}p • Modified $timeAgo by $modifiedBy';
  }

  @override
  String toString() {
    return 'LiftInfo{name: $name, type: $type, points: $points, modifiedAt: $modifiedAt, modifiedBy: $modifiedBy}';
  }
}
