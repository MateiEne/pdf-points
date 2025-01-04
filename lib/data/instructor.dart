import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:pdf_points/data/lift_user.dart';
import 'package:pdf_points/data/pdf_user.dart';

class Instructor implements PdFUser, LiftUser {
  @override
  final String id;
  final String firstName;
  final String lastName;
  final String phone;

  @override
  String get fullName => "$firstName $lastName";

  Instructor({
    required this.id,
    required this.firstName,
    required this.lastName,
    required this.phone,
  });

  Instructor copyWith({String? id, String? firstName, String? lastName, String? phone}) {
    return Instructor(
      id: id ?? this.id,
      firstName: firstName ?? this.firstName,
      lastName: lastName ?? this.lastName,
      phone: phone ?? this.phone,
    );
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;

    if (other.runtimeType != runtimeType) return false;

    return other is Instructor &&
        other.id == id &&
        other.firstName == firstName &&
        other.lastName == lastName &&
        other.phone == phone;
  }

  @override
  int get hashCode {
    return id.hashCode ^ firstName.hashCode ^ lastName.hashCode ^ phone.hashCode;
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'firstName': firstName,
      'lastName': lastName,
      'phone': phone,
    };
  }

  factory Instructor.fromJson(Map<String, dynamic> json) {
    return Instructor(
      id: json['id'],
      firstName: json['firstName'],
      lastName: json['lastName'],
      phone: json['phone'],
    );
  }

  static List<Instructor> fromJsonList(List<dynamic> jsonList) {
    return jsonList.map((json) => Instructor.fromJson(json)).toList();
  }

  factory Instructor.fromSnapshot(DocumentSnapshot snapshot) {
    return Instructor.fromJson(snapshot.data() as Map<String, dynamic>);
  }

  @override
  String toString() {
    return 'Instructor(id: $id, firstName: $firstName, lastName: $lastName, phone: $phone)';
  }
}
