import 'package:cloud_firestore/cloud_firestore.dart';

class Camp {
  final String id;
  final String name;

  // final String coverImage;
  final DateTime startDate;
  final DateTime endDate;
  final String password;
  final List<String> instructorsIds;
  final int numOfParticipants;

  const Camp({
    required this.id,
    required this.name,
    // required this.coverImage,
    required this.startDate,
    required this.endDate,
    required this.password,
    this.instructorsIds = const [],
    this.numOfParticipants = 0,
  });

  Camp copyWith({
    String? id,
    String? name,
    DateTime? startDate,
    DateTime? endDate,
    String? password,
    List<String>? instructorsIds,
    int? numOfParticipants,
  }) {
    return Camp(
      id: id ?? this.id,
      name: name ?? this.name,
      startDate: startDate ?? this.startDate,
      endDate: endDate ?? this.endDate,
      password: password ?? this.password,
      instructorsIds: instructorsIds ?? this.instructorsIds,
      numOfParticipants: numOfParticipants ?? this.numOfParticipants,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      // 'coverImage': coverImage,
      'startDate': Timestamp.fromDate(startDate),
      'endDate': Timestamp.fromDate(endDate),
      'password': password,
      'instructorsIds': instructorsIds,
      'numOfParticipants': numOfParticipants,
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
      instructorsIds: List<String>.from(json['instructorsIds']),
      numOfParticipants: json['numOfParticipants'] ?? 0,
    );
  }

  factory Camp.fromSnapshot(DocumentSnapshot snapshot) {
    return Camp.fromJson(snapshot.data() as Map<String, dynamic>);
  }
}
