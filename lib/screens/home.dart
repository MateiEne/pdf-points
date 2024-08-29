import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  bool _isSuperUser = false;

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
  void initState() {
    super.initState();
    _checkSuperUser();
  }

  @override
  Widget build(BuildContext context) {
    Widget content = const Center(
      child: Text('Coming soon ...'),
    );

    if (_isSuperUser) {
      content = const Center(
        child: Text('Coming soon ... super user .......'),
      );
    }

    return Scaffold(
      appBar: AppBar(
        title: Text(
          'Home',
          style: TextStyle(
            /// TO DO: inherit this style for all the app bars, from main
            color: Theme.of(context).colorScheme.onSecondary,
          ),
        ),
        backgroundColor: Theme.of(context).colorScheme.primary,
        actions: [
          IconButton(
            onPressed: () {
              FirebaseAuth.instance.signOut();
            },
            icon: const Icon(Icons.logout),
            color: Theme.of(context).colorScheme.onSecondary,
          ),
        ],
      ),
      body: content,
    );
  }
}
