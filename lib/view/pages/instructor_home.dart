import 'dart:async';

import 'package:flutter/material.dart';
import 'package:pdf_points/data/camp.dart';
import 'package:pdf_points/data/participant.dart';
import 'package:pdf_points/modals/enroll_instructor_to_camp.dart';
import 'package:pdf_points/view/pages/instructor_camp_screen.dart';
import 'package:pdf_points/view/pages/login.dart';
import 'package:pdf_points/services/firebase/firebase_manager.dart';
import 'package:pdf_points/utils/safe_setState.dart';
import 'package:pdf_points/view/widgets/camp_card.dart';

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
      List<Camp> camps = await FirebaseManager.instance.fetchCampsForInstructor(instructorId: widget.instructor.id);
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

  Widget _buildNoCampsView(BuildContext context) {
    return Column(
      children: [
        // top padding
        SizedBox(height: MediaQuery.sizeOf(context).height * 0.2),

        // Title
        Text(
          "You're not assigned to any camp.",
          style: Theme.of(context).textTheme.titleLarge,
        ),

        const SizedBox(height: 48),

        // Subtitle
        Text(
          "Use the action button below to enroll yourself to a camp.",
          style: Theme.of(context).textTheme.bodyLarge,
          textAlign: TextAlign.center,
        ),
      ],
    );
  }

  Future<void> _openEnrollInstructorToCampDialog() async {
    var camp = await EnrollInstructorToCampModal.show(
      context: context,
      instructor: widget.instructor,
    );

    if (camp == null || !mounted) return;

    // add this camp only if it's not already in the list
    if (_camps.any((c) => c.id == camp.id)) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('You are already enrolled in this camp.'),
        ),
      );
      return;
    }

    safeSetState(() {
      _camps.add(camp);
      _camps = _sortCamps(_camps);
    });
  }

  Future<void> _onLogout() async {
    await FirebaseManager.instance.signOut();
    if (!mounted) return;

    Navigator.of(context).pushReplacement(
      MaterialPageRoute(builder: (_) => const LoginScreen()),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Home'),
        actions: [
          IconButton(
            onPressed: _onLogout,
            icon: const Icon(Icons.logout),
          ),
        ],
      ),
      drawer: const Drawer(),
      body: RefreshIndicator(
        onRefresh: _fetchCamps,
        child: Center(
          child: _isLoading
              ? const CircularProgressIndicator()
              : _camps.isEmpty
                  ? _buildNoCampsView(context)
                  : ListView.builder(
                      padding: const EdgeInsets.symmetric(vertical: 8.0),
                      itemCount: _camps.length,
                      itemBuilder: (context, index) {
                        return InkWell(
                          onTap: () {
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (context) => InstructorCampScreen(
                                  instructor: widget.instructor,
                                  camp: _camps[index],
                                ),
                              ),
                            );
                          },
                          child: CampCard(camp: _camps[index]),
                        );
                      },
                    ),
        ),
      ),
      floatingActionButtonLocation: FloatingActionButtonLocation.endFloat,
      floatingActionButton: FloatingActionButton(
        onPressed: _openEnrollInstructorToCampDialog,
        child: const Icon(Icons.add),
      ),
    );
  }

  @override
  void dispose() {
    super.dispose();
  }
}
