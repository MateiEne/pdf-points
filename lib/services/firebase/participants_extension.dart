part of 'firebase_manager.dart';

const kCampParticipantsCollection = 'participants';

extension ParticipantsExtension on FirebaseManager {
  StreamSubscription<DocumentSnapshot<Map<String, dynamic>>> listenToParticipantChanges({
    required String campId,
    required String participantId,
    required Function(Participant) onParticipantChanged,
  }) {
    return FirebaseFirestore.instance
        .collection(kCampsCollection)
        .doc(campId)
        .collection(kCampParticipantsCollection)
        .doc(participantId)
        .snapshots()
        .listen((snapshot) {
      if (snapshot.exists) {
        onParticipantChanged(Participant.fromJson(snapshot.data()!));
      }
    });
  }

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

  Future<Participant> addParticipantToCamp({
    required String campId,
    String? firstName,
    String? lastName,
    String? phone,
    String? id,
  }) async {
    var participantRef = FirebaseFirestore.instance
        .collection(kCampsCollection)
        .doc(campId)
        .collection(kCampParticipantsCollection)
        .doc(id);

    // Create the Participant object
    var participant = Participant(
      id: participantRef.id,
      firstName: firstName,
      lastName: lastName,
      phone: phone,
    );

    // Save the Participant document
    await participantRef.set(participant.toJson());

    // Return the Participant object
    return participant;
  }

  Future<Participant> addParticipantToSkiGroup({
    required String campId,
    required String skiGroupId,
    required Participant participant,
  }) async {
    var skiGroupRef = FirebaseFirestore.instance
        .collection(kCampsCollection)
        .doc(campId)
        .collection(kCampSkiGroupsCollection)
        .doc(skiGroupId);

    // Get skiGroup document
    var skiGroupSnapshot = await skiGroupRef.get();

    if (!skiGroupSnapshot.exists) {
      return participant;
    }

    // Update the studentsIds array in the skiGroup document
    await skiGroupRef.update({
      'studentsIds': FieldValue.arrayUnion([participant.id]),
    });

    // Update the groupId in the participant document
    var participantRef = FirebaseFirestore.instance
        .collection(kCampsCollection)
        .doc(campId)
        .collection(kCampParticipantsCollection)
        .doc(participant.id);

    await participantRef.update({
      'groupId': skiGroupId,
    });

    return participant.copyWith(groupId: skiGroupId);
  }

  Future<Participant> updateParticipantSkiGroup({
    required String campId,
    required String participantId,
    required String skiGroupId,
  }) async {
    var participantRef = FirebaseFirestore.instance
        .collection(kCampsCollection)
        .doc(campId)
        .collection(kCampParticipantsCollection)
        .doc(participantId);

    // Update the groupId in the participant document
    await participantRef.update({
      'groupId': skiGroupId,
    });

    // Get the participant document
    var participantSnapshot = await participantRef.get();

    return Participant.fromJson(participantSnapshot.data()!);
  }
}
