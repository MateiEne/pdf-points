import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:pdf_points/data/lift_user.dart';

class Participant implements LiftUser {
  @override
  final String id;
  final String? firstName;
  final String? lastName;
  final String? phone;
  final String? groupId;

  @override
  String get fullName => [firstName, lastName].where((name) => name != null).join(' ');

  String get shortName {
    if (firstName != null) {
      return firstName!;
    }

    if (lastName != null) {
      return lastName!;
    }

    return "";
  }

  Participant({
    required this.id,
    this.firstName,
    this.lastName,
    this.phone,
    this.groupId,
  }) : assert(firstName != null || lastName != null, 'Both firstName and lastName cannot be null at the same time.');

  Participant copyWith({
    String? id,
    String? firstName,
    String? lastName,
    String? phone,
    String? groupId,
    bool? isInstructor,
  }) {
    return Participant(
      id: id ?? this.id,
      firstName: firstName ?? this.firstName,
      lastName: lastName ?? this.lastName,
      phone: phone ?? this.phone,
      groupId: groupId ?? this.groupId,
    );
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;

    if (other.runtimeType != runtimeType) return false;

    return other is Participant &&
        other.id == id &&
        other.firstName == firstName &&
        other.lastName == lastName &&
        other.phone == phone &&
        other.groupId == groupId;
  }

  @override
  int get hashCode {
    return id.hashCode ^ firstName.hashCode ^ lastName.hashCode ^ phone.hashCode ^ groupId.hashCode;
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'firstName': firstName,
      'lastName': lastName,
      'phone': phone,
      'groupId': groupId,
    };
  }

  factory Participant.fromJson(Map<String, dynamic> json) {
    return Participant(
      id: json['id'],
      firstName: json['firstName'],
      lastName: json['lastName'],
      phone: json['phone'],
      groupId: json['groupId'],
    );
  }

  static List<Participant> fromJsonList(List<dynamic> jsonList) {
    return jsonList.map((json) => Participant.fromJson(json)).toList();
  }

  factory Participant.fromSnapshot(DocumentSnapshot snapshot) {
    return Participant.fromJson(snapshot.data() as Map<String, dynamic>);
  }

  @override
  String toString() {
    return 'Participant(id: $id, firstName: $firstName, lastName: $lastName, phone: $phone, groupId: $groupId)';
  }
}
