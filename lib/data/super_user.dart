import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:pdf_points/data/pdf_user.dart';

class SuperUser implements PdFUser {
  final String id;
  final String username;
  final String email;
  final String? profileImageUrl;

  const SuperUser({
    required this.id,
    required this.username,
    required this.email,
    this.profileImageUrl,
  });

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;

    return other is SuperUser &&
        other.id == id &&
        other.username == username &&
        other.email == email &&
        other.profileImageUrl == profileImageUrl;
  }

  @override
  int get hashCode {
    return id.hashCode ^ username.hashCode ^ email.hashCode ^ profileImageUrl.hashCode;
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'username': username,
      'email': email,
      'image_url': profileImageUrl,
    };
  }

  factory SuperUser.fromJson(Map<String, dynamic> json) {
    return SuperUser(
      id: json['id'],
      username: json['username'],
      email: json['email'],
      profileImageUrl: json['image_url'],
    );
  }

  factory SuperUser.fromSnapshot(DocumentSnapshot snapshot) {
    return SuperUser.fromJson(snapshot.data() as Map<String, dynamic>);
  }

  @override
  String toString() {
    return 'SuperUser{id: $id, username: $username, email: $email, profileImageUrl: $profileImageUrl}';
  }
}
