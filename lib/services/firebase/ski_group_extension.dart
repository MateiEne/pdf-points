part of 'firebase_manager.dart';

const kCampSkiGroupsCollection = 'skiGroups';

extension SkiGroupExtension on FirebaseManager {
  Future<SkiGroup?> fetchSkiGroup({
    required String campId,
    required String skiGroupId,
  }) async {
    var snapshot = await FirebaseFirestore.instance
        .collection(kCampsCollection)
        .doc(campId)
        .collection(kCampSkiGroupsCollection)
        .doc(skiGroupId)
        .get();

    if (!snapshot.exists) {
      return null;
    }

    return SkiGroup.fromSnapshot(snapshot);
  }

  Future<SkiGroup?> fetchSkiGroupForInstructor({
    required String campId,
    required String instructorId,
  }) async {
    var snapshot = await FirebaseFirestore.instance
        .collection(kCampsCollection)
        .doc(campId)
        .collection(kCampSkiGroupsCollection)
        .where('instructorId', isEqualTo: instructorId)
        .get();

    if (snapshot.size == 0) {
      return null;
    }

    return SkiGroup.fromSnapshot(snapshot.docs.first);
  }

  Future<List<Participant>> fetchStudentsFromSkiGroup({
    required String campId,
    required String skiGroupId,
  }) async {
    // get the ski group
    var skiGroupSnapshot = await FirebaseFirestore.instance
        .collection(kCampsCollection)
        .doc(campId)
        .collection(kCampSkiGroupsCollection)
        .doc(skiGroupId)
        .get();

    if (!skiGroupSnapshot.exists) {
      return [];
    }

    var skiGroupData = skiGroupSnapshot.data();
    if (skiGroupData == null || skiGroupData['studentsIds'] == null) {
      return [];
    }

    List<String> studentsIds = List<String>.from(skiGroupData['studentsIds']);

    if (studentsIds.isEmpty) {
      return [];
    }

    // get only the students that are in the ski group
    var participantsSnapshot = await FirebaseFirestore.instance
        .collection(kCampsCollection)
        .doc(campId)
        .collection(kCampParticipantsCollection)
        .where(FieldPath.documentId, whereIn: studentsIds)
        .get();

    if (participantsSnapshot.size == 0) {
      return [];
    }

    return participantsSnapshot.docs.map((doc) => Participant.fromSnapshot(doc)).toList();
  }

  Future<SkiGroup> addSkiGroupToCamp({
    required String campId,
    required String instructorId,
    required String name,
    List<String> studentsIds = const [],
    String? image,
    String? skiGroupId,
  }) async {
    var skiGroupRef = FirebaseFirestore.instance
        .collection(kCampsCollection)
        .doc(campId)
        .collection(kCampSkiGroupsCollection)
        .doc(skiGroupId);

    // Create the SkiGroup object
    var skiGroup = SkiGroup(
      id: skiGroupRef.id,
      name: name,
      instructorId: instructorId,
      studentsIds: studentsIds,
      image: image,
      createdAt: DateTime.now(),
    );

    // Save the SkiGroup object
    await skiGroupRef.set(skiGroup.toJson());

    // update the instructor ski group
    await FirebaseManager.instance.updateParticipantSkiGroup(
      campId: campId,
      participantId: instructorId,
      skiGroupId: skiGroup.id,
    );

    // Return the SkiGroup object
    return skiGroup;
  }

  Future<bool> checkIfSkiGroupExistWithName({
    required String campId,
    required String name,
  }) async {
    var snapshot = await FirebaseFirestore.instance
        .collection(kCampsCollection)
        .doc(campId)
        .collection(kCampSkiGroupsCollection)
        .where('name', isEqualTo: name)
        .get();

    return snapshot.size > 0;
  }
}
