import 'package:flutter/material.dart';
import 'package:pdf_points/data/participant.dart';
import 'package:pdf_points/data/pdf_user.dart';
import 'package:pdf_points/data/super_user.dart';
import 'package:pdf_points/screens/instructor_home.dart';
import 'package:pdf_points/screens/superuser_home.dart';
import 'package:pdf_points/services/firebase/firebase_manager.dart';

class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Material(
      child: Center(
        child: FutureBuilder<PdFUser?>(
          future: FirebaseManager.instance.getCurrentPdfUser(),
          builder: (context, snapshot) {
            if (snapshot.connectionState == ConnectionState.waiting) {
              return const CircularProgressIndicator();
            }

            if (snapshot.hasError || !snapshot.hasData || snapshot.data == null) {
              return const Center(
                child: Text("Error loading data. Please try again later."),
              );
            }

            if (snapshot.data is SuperUser) {
              // navigate to super user screen
              return SuperUserHomeScreen(superUser: snapshot.data as SuperUser);
            } else {
              // navigate to instructor screen
              return InstructorHomeScreen(instructor: snapshot.data as Instructor);
            }
          },
        ),
      ),
    );
  }
}
