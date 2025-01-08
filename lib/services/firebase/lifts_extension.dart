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
}
