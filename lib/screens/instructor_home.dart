import 'dart:async';

import 'package:flutter/material.dart';
import 'package:pdf_points/data/camp.dart';
import 'package:pdf_points/data/instructor.dart';
import 'package:pdf_points/screens/camp_screen.dart';
import 'package:pdf_points/services/firebase/firebase_manager.dart';
import 'package:pdf_points/utils/safe_setState.dart';
import 'package:pdf_points/widgets/add_camp_fab.dart';
import 'package:pdf_points/widgets/camp_card.dart';

class InstructorHomeScreen extends StatefulWidget {
  final Instructor instructor;

  const InstructorHomeScreen({super.key, required this.instructor});

  @override
  State<InstructorHomeScreen> createState() => _InstructorHomeScreenState();
}

class _InstructorHomeScreenState extends State<InstructorHomeScreen> {
  bool _isLoading = true;
  List<Camp> _camps = [];

  @override
  void initState() {
    super.initState();

    _startFirebaseEvents();
  }

  Future<void> _startFirebaseEvents() async {
    _fetchCamps();
  }

  Future<void> _fetchCamps() async {
    safeSetState(() {
      _isLoading = true;
    });

    try {
      List<Camp> camps = await FirebaseManager.instance.fetchCampsForInstructor(widget.instructor);
      camps = _sortCamps(camps);

      safeSetState(() {
        _isLoading = false;

        _camps = camps;
      });
    } catch (e) {
      safeSetState(() {
        _isLoading = false;
        // TODO: better error handling
        debugPrint(e.toString());
      });
    }
  }

  List<Camp> _sortCamps(List<Camp> camps) {
    camps.sort((a, b) => a.startDate.compareTo(b.startDate));

    return camps.toList();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Home'),
        actions: [
          IconButton(
            onPressed: () {
              FirebaseManager.instance.signOut();
            },
            icon: const Icon(Icons.logout),
          ),
        ],
      ),
      drawer: const Drawer(),
      body: RefreshIndicator(
        onRefresh: () {
          return _fetchCamps();
        },
        child: Center(
          child: _isLoading
              ? const CircularProgressIndicator()
              : _camps.isEmpty
                  ? const Text('No camps found.')
                  : ListView.builder(
                      padding: const EdgeInsets.symmetric(vertical: 8.0),
                      itemCount: _camps.length,
                      itemBuilder: (context, index) {
                        return InkWell(
                          onTap: () {
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (context) => CampScreen(camp: _camps[index]),
                              ),
                            );
                          },
                          child: CampCard(camp: _camps[index]),
                        );
                      },
                    ),
        ),
      ),
      floatingActionButtonLocation: AddCampFab.location,
      floatingActionButton: const AddCampFab(),
    );
  }

  @override
  void dispose() {
    super.dispose();
  }
}
