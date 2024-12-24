import 'package:flutter/material.dart';
import 'package:pdf_points/data/participant.dart';
import 'package:pdf_points/screens/instructor_home_screen.dart';
import 'package:pdf_points/screens/superuser_home.dart';
import 'package:pdf_points/services/firebase/firebase_manager.dart';

class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Material(
      child: Center(
        child: FutureBuilder<bool>(
          future: FirebaseManager.instance.isSuperUser(),
          builder: (context, snapshot) {
            if (snapshot.connectionState == ConnectionState.waiting) {
              return const CircularProgressIndicator();
            }

            if (snapshot.hasError || !snapshot.hasData) {
              return const Center(
                child: Text("Error loading data. Please try again later."),
              );
            }

            if (snapshot.data!) {
              // navigate to super user screen
              return const SuperUserHomeScreen();
            } else {
              // navigate to instructor screen
              return InstructorHomeScreen(
                instructor: Participant(
                  isInstructor: true,
                  id: "129",
                  firstName: "Abi",
                  phone: "+40751561142",
                  groupId: 1,
                ),
              );
            }
          },
        ),
      ),
    );
  }
}
