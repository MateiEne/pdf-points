part of 'firebase_manager.dart';

const kUsersCollection = 'users';

extension UserExtension on FirebaseManager {
  Future<bool> isSuperUser() async {
    final user = FirebaseAuth.instance.currentUser;
    if (user == null) {
      return false;
    }

    final pdfUser = await fetchUser(user.uid);

    return pdfUser.isSuper;
  }

  Future<PdFUser> fetchUser(String userId) async {
    var snapshot = await FirebaseFirestore.instance.collection(kUsersCollection).doc(userId).get();

    return PdFUser.fromSnapshot(snapshot);
  }
}
