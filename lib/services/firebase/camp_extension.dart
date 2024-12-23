part of 'firebase_manager.dart';

extension CampExtension on FirebaseManager {
  /*
  // FirebaseManager.instance.addCamp(
    //   name: _name,
    //   password: _password,
    //   startDate: _startDate,
    //   endDate: _endDate,
    //   participants: widget.campInfo?.participants ?? [],
    //   instructors: [],
    //   image: _image,
    // );
   */

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
