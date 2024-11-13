import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:pdf_points/data/participant.dart';
import 'package:pdf_points/data/ski_group.dart';
import 'package:pdf_points/utils/safe_setState.dart';
import 'package:pdf_points/widgets/add_ski_group_fab.dart';

class InstructorHomeScreen extends StatefulWidget {
  const InstructorHomeScreen({super.key, required this.user});

  final User user;

  @override
  State<InstructorHomeScreen> createState() => _InstructorHomeScreenState();
}

class _InstructorHomeScreenState extends State<InstructorHomeScreen> {
  bool _isLoading = true;
  SkiGroup? _group;

  @override
  void initState() {
    super.initState();

    _fetchGroup(widget.user.uid);
  }

  Future<void> _fetchGroup(String uid) async {
    safeSetState(() {
      _isLoading = true;
    });

    // TODO: Check if this instructor has a group
    await Future.delayed(const Duration(seconds: 2));

    safeSetState(() {
      _isLoading = false;
      _group = null;
      // _group = SkiGroup(name: "name", instructor: Participant(firstName: "Abi"));
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Instructor Name / Group Name'),
        actions: [
          IconButton(
            onPressed: () {
              FirebaseAuth.instance.signOut();
            },
            icon: const Icon(Icons.logout),
          ),
        ],
      ),
      body: Center(
        child: _isLoading
            ? const CircularProgressIndicator()
            : const Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text('Coming soon ... '),
                ],
              ),
      ),
      floatingActionButtonLocation: AddSkiGroupFab.location,
      floatingActionButton: _isLoading
          ? null
          : _group == null
              ? AddSkiGroupFab(instructorId: widget.user.uid)
              : null,
    );
  }
}
