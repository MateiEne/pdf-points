import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:pdf_points/data/participant.dart';
import 'package:pdf_points/utils/date_utils.dart';

class Camp {
  final String id;
  final String name;
  // final String coverImage;
  final DateTime startDate;
  final DateTime endDate;
  final String password;
  final List<Participant> instructors;
  final List<String> instructorsIds;
  final List<Participant> participants;

  const Camp({
    required this.id,
    required this.name,
    // required this.coverImage,
    required this.startDate,
    required this.endDate,
    required this.password,
    this.instructors = const [],
    this.instructorsIds = const [],
    this.participants = const [],
  });

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      // 'coverImage': coverImage,
      'startDate': startDate.toTimestamp(),
      'endDate': endDate.toTimestamp(),
      'password': password,
      'instructors': instructors.map((e) => e.toJson()).toList(),
      'participants': participants.map((e) => e.toJson()).toList(),
      'instructorsIds': instructorsIds,
    };
  }

  factory Camp.fromJson(Map<String, dynamic> json) {
    return Camp(
      id: json['id'],
      name: json['name'],
      // coverImage: json['coverImage'],
      startDate: (json['startDate'] as Timestamp).toDate(),
      endDate: (json['endDate'] as Timestamp).toDate(),
      password: json['password'],
      instructors: (json['instructors'] as List).map((e) => Participant.fromJson(e)).toList(),
      participants: (json['participants'] as List).map((e) => Participant.fromJson(e)).toList(),
      instructorsIds: (json['instructorsIds'] as List?)?.map((e) => e.toString()).toList() ?? [],
    );
  }

  factory Camp.fromSnapshot(DocumentSnapshot snapshot) {
    return Camp.fromJson(snapshot.data() as Map<String, dynamic>);
  }
}