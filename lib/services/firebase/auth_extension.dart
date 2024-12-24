part of 'firebase_manager.dart';

extension AuthExtension on FirebaseManager {

  Future<void> signOut() async {
    close();

    return FirebaseAuth.instance.signOut();
  }
}