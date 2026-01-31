part of 'firebase_manager.dart';

const kCampLiftsCollection = 'lifts';

extension LiftsExtension on FirebaseManager {
  Future<void> addLift({
    required String campId,
    required LiftInfo lift,
  }) async {
    await FirebaseFirestore.instance
        .collection(kCampsCollection)
        .doc(campId)
        .collection(kCampLiftsCollection)
        .add(lift.toJson());
  }

  Future<List<LiftInfo>> fetchLiftsForPerson({
    required String campId,
    required String personId,
  }) async {
    final snapshot = await FirebaseFirestore.instance
        .collection(kCampsCollection)
        .doc(campId)
        .collection(kCampLiftsCollection)
        .where('personId', isEqualTo: personId)
        .orderBy('createdAt', descending: true)
        .get();

    return snapshot.docs.map((doc) => LiftInfo.fromSnapshot(doc)).toList();
  }

  Stream<List<LiftInfo>> listenToLiftsForPerson({
    required String campId,
    required String personId,
  }) {
    return FirebaseFirestore.instance
        .collection(kCampsCollection)
        .doc(campId)
        .collection(kCampLiftsCollection)
        .where('personId', isEqualTo: personId)
        .orderBy('createdAt', descending: true)
        .snapshots()
        .map((snapshot) => snapshot.docs.map((doc) => LiftInfo.fromSnapshot(doc)).toList());
  }
}
