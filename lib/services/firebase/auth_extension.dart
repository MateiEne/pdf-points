part of 'firebase_manager.dart';

extension AuthExtension on FirebaseManager {
  Future<PdFUser?> signInWithEmailAndPassword({required String email, required String password}) async {
    return FirebaseAuth.instance.signInWithEmailAndPassword(email: email, password: password).then(
      (UserCredential userCredential) {
        if (userCredential.user == null) {
          return null;
        }

        return fetchPdfUser(userCredential.user!.uid);
      },
    );
  }

  Future<Instructor?> createInstructorUser({
    required String email,
    required String password,
    required String firstName,
    required String lastName,
    required String phone,
    File? profileImage,
  }) async {
    // Create the user in Firebase Auth
    final userCredentials = await FirebaseAuth.instance.createUserWithEmailAndPassword(
      email: email,
      password: password,
    );

    if (userCredentials.user == null) {
      return null;
    }

    String? imageUrl;

    // save the profile image
    if (profileImage != null) {
      final storageRef = FirebaseStorage.instance //
          .ref()
          .child('user_images')
          .child('${userCredentials.user!.uid}.jpg');
      await storageRef.putFile(profileImage);

      imageUrl = await storageRef.getDownloadURL();
    }

    // Create the user in Firestore
    Instructor instructor = Instructor(
      id: userCredentials.user!.uid,
      firstName: firstName,
      lastName: lastName,
      phone: phone,
      email: email,
      isInstructor: true,
      // imageUrl: imageUrl,
    );

    await FirebaseFirestore.instance
        .collection(kUsersCollection)
        .doc(userCredentials.user!.uid)
        .set(instructor.toJson());

    return instructor;
  }

  Future<void> signOut() async {
    close();

    return FirebaseAuth.instance.signOut();
  }
}
