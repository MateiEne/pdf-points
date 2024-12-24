part of 'firebase_manager.dart';

const kUsersCollection = 'users';

extension UserExtension on FirebaseManager {
  Future<PdFUser?> getCurrentPdfUser() async {
    final user = FirebaseAuth.instance.currentUser;
    if (user == null) {
      return null;
    }

    return fetchPdfUser(user.uid);
  }

  Future<PdFUser> fetchPdfUser(String userId) async {
    var snapshot = await FirebaseFirestore.instance.collection(kUsersCollection).doc(userId).get();

    if (snapshot.data()!['is_super'] != null) {
      return SuperUser.fromSnapshot(snapshot);
    }

    return Instructor.fromSnapshot(snapshot);
  }
}
