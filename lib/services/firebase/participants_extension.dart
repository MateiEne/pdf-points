part of 'firebase_manager.dart';

const kCampParticipantsCollection = 'participants';

extension ParticipantsExtension on FirebaseManager {

  Future<List<Participant>> fetchParticipantsForCamp({required String campId}) async {
    var snapshot = await FirebaseFirestore.instance
        .collection(kCampsCollection)
        .doc(campId)
        .collection(kCampParticipantsCollection)
        .get();

    return snapshot.docs.map((doc) => Participant.fromJson(doc.data())).toList();
  }

  Future<void> addParticipantsToCamp({
    required String campId,
    required List<Participant> participants,
  }) async {
    var participantsCollection =
        FirebaseFirestore.instance.collection(kCampsCollection).doc(campId).collection(kCampParticipantsCollection);

    var batch = FirebaseFirestore.instance.batch();

    for (var participant in participants) {
      var ref = participantsCollection.doc(participant.id);
      batch.set(ref, participant.toJson());
    }

    await batch.commit();
  }
}
