part of 'firebase_manager.dart';

const kLiftValuePointsCollection = 'lift-points';

extension LiftValuePointsExtension on FirebaseManager {
  Future<void> addLiftValuePoints({
    required String liftName,
    required int points,
    required String type,
    required DateTime modifiedAt,
    required String modifiedBy,
  }) async {
    // add a new lift value point document with the id the same as the lift name
    await FirebaseFirestore.instance.collection(kLiftValuePointsCollection).doc(liftName).set({
      'name': liftName,
      'points': points,
      'type': type,
      'modifiedAt': modifiedAt,
      'modifiedBy': modifiedBy,
    });
  }

  Future<List<LiftInfo>> fetchAllLiftsInfo() async {
    final snapshot = await FirebaseFirestore.instance.collection(kLiftValuePointsCollection).get();

    return snapshot.docs.map((doc) => LiftInfo.fromSnapshot(doc)).toList();
  }

  Future<LiftInfo?> fetchLiftInfo(String liftName) async {
    final snapshot = await FirebaseFirestore.instance.collection(kLiftValuePointsCollection).doc(liftName).get();

    if (!snapshot.exists) {
      return null;
    }

    return LiftInfo.fromSnapshot(snapshot);
  }
}
