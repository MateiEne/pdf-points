import 'package:cloud_firestore/cloud_firestore.dart';

class PdFUser {
  final String email;
  final String username;
  final String imageUrl;
  final bool isSuper;

  PdFUser({
    required this.email,
    required this.imageUrl,
    required this.isSuper,
    required this.username,
  });

  factory PdFUser.fromJson(Map<String, dynamic> data) {
    return PdFUser(
      email: data['email'] ?? '',
      imageUrl: data['image_url'] ?? '',
      isSuper: data['is_super'] ?? false,
      username: data['username'] ?? '',
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'email': email,
      'image_url': imageUrl,
      'is_super': isSuper,
      'username': username,
    };
  }

  static List<PdFUser> fromJsonList(List<dynamic> jsonList) {
    return jsonList.map((json) => PdFUser.fromJson(json)).toList();
  }

  factory PdFUser.fromSnapshot(DocumentSnapshot snapshot) {
    return PdFUser.fromJson(snapshot.data() as Map<String, dynamic>);
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;

    if (other.runtimeType != runtimeType) return false;

    return other is PdFUser &&
        other.email == email &&
        other.imageUrl == imageUrl &&
        other.isSuper == isSuper &&
        other.username == username;
  }

  @override
  int get hashCode {
    return Object.hash(email, imageUrl, isSuper, username);
  }

  @override
  String toString() {
    return 'PdfUser(email: $email, imageUrl: $imageUrl, isSuper: $isSuper, username: $username)';
  }
}
