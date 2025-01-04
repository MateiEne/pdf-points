part of 'firebase_manager.dart';

const kCampSkiGroupsCollection = 'skiGroups';

extension SkiGroupExtension on FirebaseManager {
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
