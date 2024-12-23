part of 'firebase_manager.dart';

extension CampExtension on FirebaseManager {
  void listenToCampChanges(StreamController<ChangeListener<Camp>> campChangedStreamController) {
    FirebaseFirestore.instance.collection('camp').snapshots().listen(
      (snapshot) {
        for (var change in snapshot.docChanges) {
          campChangedStreamController.add(ChangeListener<Camp>(change.type, Camp.fromSnapshot(change.doc)));
        }
      },
    );
  }

  Future<List<Camp>> fetchCamps() async {
    var snapshot = await FirebaseFirestore.instance.collection('camps').get();

    return snapshot.docs.map((doc) => Camp.fromSnapshot(doc)).toList();
  }

  Future<Camp> addCamp({
    required String name,
    required String password,
    required DateTime startDate,
    required DateTime endDate,
    required List<Participant> participants,
    required List<Participant> instructors,
    Uint8List? image,
    String? campId,
  }) async {
    var campRef = FirebaseFirestore.instance.collection('camps').doc(campId);

    Camp camp = Camp(
      id: campRef.id,
      name: name,
      password: password,
      startDate: startDate,
      endDate: endDate,
      instructors: instructors,
      participants: participants,
    );

    await campRef.set(camp.toJson());

    return camp;
  }
}
