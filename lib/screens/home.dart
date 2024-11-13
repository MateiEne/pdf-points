import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:pdf_points/screens/camp_screen.dart';
import 'package:pdf_points/screens/instructor_home_screen.dart';
import 'package:pdf_points/utils/safe_setState.dart';
import 'package:pdf_points/widgets/add_camp_fab.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  bool _isSuperUser = false;
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _checkSuperUser();
  }

  void _checkSuperUser() async {
    safeSetState(() {
      _isLoading = true;
    });

    final user = FirebaseAuth.instance.currentUser!;
    // TODO: add user model class
    final userData = await FirebaseFirestore.instance //
        .collection('users')
        .doc(user.uid)
        .get();

    // TODO: check user.isSuperuser once the user model is added
    if (userData.data()!['is_super'] != null) {
      safeSetState(() {
        _isSuperUser = true;
        _isLoading = false;
      });

      return;
    }

    safeSetState(() {
      _isSuperUser = false;
      _isLoading = false;
    });
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
                  Text('Coming soon ... ${_isSuperUser ? 'super user' : 'normal user'}'),
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
                        MaterialPageRoute(builder: (context) => InstructorHomeScreen(user: FirebaseAuth.instance.currentUser!)),
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
