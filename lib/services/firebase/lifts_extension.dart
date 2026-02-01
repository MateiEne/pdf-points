part of 'firebase_manager.dart';

const kCampLiftsCollection = 'lifts';

extension LiftsExtension on FirebaseManager {
  Future<void> addLift({
    required String campId,
    required LiftParticipantInfo lift,
  }) async {
    await FirebaseFirestore.instance
        .collection(kCampsCollection)
        .doc(campId)
        .collection(kCampLiftsCollection)
        .add(lift.toJson());
  }

  Future<List<LiftParticipantInfo>> fetchLiftsForPerson({
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

    return snapshot.docs.map((doc) => LiftParticipantInfo.fromSnapshot(doc)).toList();
  }

  Future<List<LiftParticipantInfo>> fetchTodaysLiftsForPerson({
    required String campId,
    required String personId,
  }) async {
    final now = DateTime.now();
    final snapshot = await FirebaseFirestore.instance
        .collection(kCampsCollection)
        .doc(campId)
        .collection(kCampLiftsCollection)
        .where('personId', isEqualTo: personId)
        .orderBy('createdAt', descending: true)
        .get();

    return snapshot.docs
        .map((doc) => LiftParticipantInfo.fromSnapshot(doc))
        .where((lift) {
          final liftDate = lift.createdAt;
          return liftDate.year == now.year &&
              liftDate.month == now.month &&
              liftDate.day == now.day;
        })
        .toList();
  }

  Stream<List<LiftParticipantInfo>> listenToLiftsForPerson({
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
        .map((snapshot) => snapshot.docs.map((doc) => LiftParticipantInfo.fromSnapshot(doc)).toList());
  }
}
