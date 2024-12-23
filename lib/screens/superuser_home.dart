import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:pdf_points/data/participant.dart';
import 'package:pdf_points/screens/camp_screen.dart';
import 'package:pdf_points/screens/instructor_home_screen.dart';
import 'package:pdf_points/services/firebase/firebase_manager.dart';
import 'package:pdf_points/utils/safe_setState.dart';
import 'package:pdf_points/widgets/add_camp_fab.dart';

class SuperUserHomeScreen extends StatefulWidget {
  const SuperUserHomeScreen({super.key});

  @override
  State<SuperUserHomeScreen> createState() => _SuperUserHomeScreenState();
}

class _SuperUserHomeScreenState extends State<SuperUserHomeScreen> {
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();

    _isLoading = false;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Home'),
        actions: [
          IconButton(
            onPressed: () {
              FirebaseAuth.instance.signOut();
            },
            icon: const Icon(Icons.logout),
          ),
        ],
      ),
      drawer: const Drawer(),
      body: Center(
        child: _isLoading
            ? const CircularProgressIndicator()
            : Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  ElevatedButton(
                    onPressed: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(builder: (context) => const CampScreen()),
                      );
                    },
                    child: const Text("Go to camp"),
                  ),
                  ElevatedButton(
                    onPressed: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => InstructorHomeScreen(
                            instructor: Participant(
                              isInstructor: true,
                              id: "129",
                              firstName: "Abi",
                              phone: "+40751561142",
                              groupId: 1,
                            ),
                          ),
                        ),
                      );
                    },
                    child: const Text("Go instructor home"),
                  ),
                ],
              ),
      ),
      floatingActionButtonLocation: AddCampFab.location,
      floatingActionButton: const AddCampFab(),
    );
  }
}
