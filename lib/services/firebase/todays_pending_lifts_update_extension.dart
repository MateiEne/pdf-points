part of 'firebase_manager.dart';

const kTodaysPendingLiftsUpdateCollection = 'todays-pending-lifts-update';

extension TodaysPendingLiftsUpdateExtension on FirebaseManager {
Future<void> addTodaysPendingLiftUpdate({
  required String liftName,
}) async {
  // add or update a todays pending lift update document with the specified id
  await FirebaseFirestore.instance.collection(kTodaysPendingLiftsUpdateCollection).doc(liftName).set({
    'name': liftName,
  });
}

  Future<List<LiftPendingUpdate>> fetchAllTodaysPendingLiftUpdates() async {
    final snapshot = await FirebaseFirestore.instance.collection(kTodaysPendingLiftsUpdateCollection).get();

    return snapshot.docs.map((doc) => LiftPendingUpdate.fromSnapshot(doc)).toList();
  }

  Future<LiftPendingUpdate?> fetchTodaysPendingLiftUpdate(String liftName) async {
    final snapshot = await FirebaseFirestore.instance.collection(kTodaysPendingLiftsUpdateCollection).doc(liftName).get();

    if (!snapshot.exists) {
      return null;
    }

    return LiftPendingUpdate.fromSnapshot(snapshot);
  }

  Future<void> updateTodaysPendingLiftUpdate({
    required String liftName,
  }) async {
    await FirebaseFirestore.instance.collection(kTodaysPendingLiftsUpdateCollection).doc(liftName).update({
      'name': liftName,
    });
  }

Future<void> deleteTodaysPendingLiftUpdate(String liftName) async {
  await FirebaseFirestore.instance.collection(kTodaysPendingLiftsUpdateCollection).doc(liftName).delete();
}

Future<void> deleteTodaysPendingLiftsUpdate({
  required Map<String, int> liftsPoints,
}) async {
  // Use batch writes for efficiency - all deletions in one transaction
  final batch = FirebaseFirestore.instance.batch();

  liftsPoints.forEach((liftName, _) {
    final docRef = FirebaseFirestore.instance.collection(kTodaysPendingLiftsUpdateCollection).doc(liftName);
    batch.delete(docRef);
  });

  // Commit all deletions at once
  await batch.commit();
}

/// Listen to real-time updates for all todays pending lift updates
  Stream<List<LiftPendingUpdate>> listenToAllTodaysPendingLiftUpdates() {
    return FirebaseFirestore.instance
        .collection(kTodaysPendingLiftsUpdateCollection)
        .snapshots()
        .map((snapshot) => snapshot.docs.map((doc) => LiftPendingUpdate.fromSnapshot(doc)).toList());
  }
}