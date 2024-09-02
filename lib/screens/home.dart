import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:pdf_points/screens/camp_screen.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  bool _isSuperUser = false;

  @override
  void initState() {
    super.initState();
    _checkSuperUser();
  }

  void _checkSuperUser() async {
    final user = FirebaseAuth.instance.currentUser!;
    final userData = await FirebaseFirestore.instance //
        .collection('users')
        .doc(user.uid)
        .get();

    if (userData.data()!['is_super'] != null) {
      setState(() {
        _isSuperUser = true;
      });

      return;
    }

    setState(() {
      _isSuperUser = false;
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
        child: Column(
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
          ],
        ),
      ),
    );
  }
}
