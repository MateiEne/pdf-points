import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:pdf_points/data/lift_user.dart';
import 'package:pdf_points/data/pdf_user.dart';

typedef Instructor = Participant;

class Participant implements PdFUser, LiftUser {
  @override
  final String id;
  final String? firstName;
  final String? lastName;
  final String? phone;
  final String? email;
  final String? groupId;
  final String? groupName;
  final bool isInstructor;

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
    this.email,
    this.groupId,
    this.groupName,
    this.isInstructor = false,
  }) : assert(firstName != null || lastName != null, 'Both firstName and lastName cannot be null at the same time.');

  Participant copyWith({
    String? id,
    String? firstName,
    String? lastName,
    String? phone,
    String? email,
    String? groupId,
    String? groupName,
    bool? isInstructor,
  }) {
    return Participant(
      id: id ?? this.id,
      firstName: firstName ?? this.firstName,
      lastName: lastName ?? this.lastName,
      phone: phone ?? this.phone,
      email: email ?? this.email,
      groupId: groupId ?? this.groupId,
      groupName: groupName ?? this.groupName,
      isInstructor: isInstructor ?? this.isInstructor,
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
        other.email == email &&
        other.groupId == groupId &&
        other.groupName == groupName &&
        other.isInstructor == isInstructor;
  }

  @override
  int get hashCode {
    return id.hashCode ^
        firstName.hashCode ^
        lastName.hashCode ^
        phone.hashCode ^
        email.hashCode ^
        groupId.hashCode ^
        groupName.hashCode ^
        isInstructor.hashCode;
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'firstName': firstName,
      'lastName': lastName,
      'phone': phone,
      'email': email,
      'groupId': groupId,
      'groupName': groupName,
      'isInstructor': isInstructor,
    };
  }

  factory Participant.fromJson(Map<String, dynamic> json) {
    return Participant(
      id: json['id'],
      firstName: json['firstName'],
      lastName: json['lastName'],
      phone: json['phone'],
      email: json['email'],
      groupId: json['groupId'],
      groupName: json['groupName'],
      isInstructor: json['isInstructor'] ?? false,
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
    if (isInstructor) {
      return 'Instructor(id: $id, firstName: $firstName, lastName: $lastName, phone: $phone, email: $email groupId: $groupId, groupName: $groupName)';
    }

    return 'Participant(id: $id, firstName: $firstName, lastName: $lastName, phone: $phone, email: $email groupId: $groupId, groupName: $groupName)';
  }
}
