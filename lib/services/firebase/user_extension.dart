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

  Future<Participant> updateInstructorSkiGroup({
    required String campId,
    required String instructorId,
    required String skiGroupId,
  }) async {
    var userRef = FirebaseFirestore.instance.collection(kUsersCollection).doc(instructorId);

    // Update the groupId in the participant document
    await userRef.update({
      'groupId': skiGroupId,
    });

    // Get the participant document
    var participantSnapshot = await userRef.get();

    return Participant.fromJson(participantSnapshot.data()!);
  }
}
