part of 'firebase_manager.dart';

const kCampsCollection = 'camps';

extension CampExtension on FirebaseManager {
  void _listenToCampChanges(StreamController<ChangeListener<Camp>> campChangedStreamController) {
    FirebaseFirestore.instance.collection(kCampsCollection).snapshots().listen(
      (snapshot) {
        for (var change in snapshot.docChanges) {
          campChangedStreamController.add(ChangeListener<Camp>(change.type, Camp.fromSnapshot(change.doc)));
        }
      },
    );
  }

  void _stopListeningToCampChanges() {
    _campChangedStreamController?.close();
    _campChangedStreamController = null;
  }

  Future<List<Camp>> fetchCamps() async {
    // Fetch all Camp documents
    var snapshot = await FirebaseFirestore.instance.collection(kCampsCollection).get();

    return snapshot.docs.map((doc) => Camp.fromSnapshot(doc)).toList();
  }

  Future<List<Camp>> fetchCampsForInstructor({required String instructorId}) async {
    var snapshot = await FirebaseFirestore.instance
        .collection(kCampsCollection)
        .where('instructorsIds', arrayContains: instructorId)
        .get();

    return snapshot.docs.map((doc) => Camp.fromSnapshot(doc)).toList();
  }

  Future<int> fetchAllParticipantsCountForCamp({required String campId}) async {
    var snapshot =
        await FirebaseFirestore.instance.collection(kCampsCollection).doc(campId).collection('participants').get();

    return snapshot.size;
  }

  Future<Camp> addCamp({
    required String name,
    required String password,
    required DateTime startDate,
    required DateTime endDate,
    required List<Participant> participants,
    Uint8List? image,
    String? campId,
  }) async {
    var campRef = FirebaseFirestore.instance.collection(kCampsCollection).doc(campId);

    // Create the Camp object
    Camp camp = Camp(
      id: campRef.id,
      name: name,
      password: password,
      startDate: startDate,
      endDate: endDate,
    );

    // Save the main Camp document
    await campRef.set(camp.toJson());

    // Save participants as a sub-collection
    await addParticipantsToCamp(campId: campRef.id, participants: participants);

    // Return the Camp object
    return camp;
  }

  Future<bool> checkIfCampExistWithPassword({required String password}) async {
    var snapshot = await FirebaseFirestore.instance //
        .collection(kCampsCollection)
        .where('password', isEqualTo: password)
        .get();

    return snapshot.size > 0;
  }

  Future<Camp?> enrollInstructorToCamp({required String password, required Instructor instructor}) async {
    var snapshot = await FirebaseFirestore.instance //
        .collection(kCampsCollection)
        .where('password', isEqualTo: password)
        .get();

    if (snapshot.size == 0) {
      return null;
    }

    var camp = Camp.fromSnapshot(snapshot.docs.first);

    if (camp.instructorsIds.contains(instructor.id)) {
      return camp;
    }

    // add the instructor to the camp instructors list
    camp.instructorsIds.add(instructor.id);
    await snapshot.docs.first.reference.update({'instructorsIds': camp.instructorsIds});

    // add the instructor to the camp participants list
    await FirebaseManager.instance.addParticipantToCamp(
      campId: camp.id,
      firstName: instructor.firstName,
      lastName: instructor.lastName,
      phone: instructor.phone,
      id: instructor.id,
    );

    return camp;
  }
}
