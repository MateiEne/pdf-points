import 'package:flutter/material.dart';
import 'package:pdf_points/data/camp.dart';
import 'package:pdf_points/data/participant.dart';
import 'package:pdf_points/modals/enroll_instructor_to_camp.dart';
import 'package:pdf_points/services/firebase/firebase_manager.dart';
import 'package:pdf_points/utils/safe_setState.dart';
import 'package:pdf_points/view/pages/instructor_main_screen.dart';
import 'package:pdf_points/view/pages/login.dart';
import 'package:pdf_points/view/widgets/camp_card.dart';

class InstructorSelectCampScreen extends StatefulWidget {
  final Instructor instructor;

  const InstructorSelectCampScreen({super.key, required this.instructor});

  @override
  State<InstructorSelectCampScreen> createState() => _InstructorSelectCampScreenState();
}

class _InstructorSelectCampScreenState extends State<InstructorSelectCampScreen> {
  bool _isLoading = true;
  List<Camp> _camps = [];

  @override
  void initState() {
    super.initState();
    _fetchCamps();
  }

  Future<void> _fetchCamps() async {
    safeSetState(() => _isLoading = true);
    try {
      final camps = await FirebaseManager.instance.fetchActiveCampsForInstructor(
        instructorId: widget.instructor.id,
      );

      safeSetState(() {
        _camps = camps;
        _isLoading = false;
      });
    } catch (e) {
      debugPrint("Error fetching camps: $e");
      safeSetState(() => _isLoading = false);
    }
  }

  void _onCampSelected(Camp camp) {
    Navigator.of(context).pushReplacement(
      MaterialPageRoute(
        builder: (_) => InstructorMainScreen(
          instructor: widget.instructor,
          camp: camp,
        ),
      ),
    );
  }

  Widget _buildNoCampsContent(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.cabin_outlined,
              size: 92,
              color: Theme.of(context).colorScheme.secondary.withValues(alpha: 0.5),
            ),
            const SizedBox(height: 24),
            Text(
              "You're not assigned to any camp.",
              style: Theme.of(context).textTheme.headlineLarge,
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 12),
            Text(
              "Use the action button below to enroll yourself to a camp.",
              style: Theme.of(context).textTheme.titleLarge?.copyWith(
                    color: Theme.of(context).colorScheme.onSurface.withValues(alpha: 0.6),
                  ),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }

  Future<void> _onLogout() async {
    await FirebaseManager.instance.signOut();
    if (!mounted) return;

    Navigator.of(context).pushReplacement(
      MaterialPageRoute(builder: (_) => const LoginScreen()),
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

    // Navigate to the main screen with the newly enrolled camp
    Navigator.of(context).pushReplacement(
      MaterialPageRoute(
        builder: (_) => InstructorMainScreen(
          instructor: widget.instructor,
          camp: camp,
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Select Camp'),
        centerTitle: true,
        actions: [
          IconButton(
            onPressed: _onLogout,
            icon: const Icon(Icons.logout),
          ),
        ],
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : _camps.isEmpty
              ? _buildNoCampsContent(context)
              : ListView.builder(
                  padding: const EdgeInsets.symmetric(vertical: 8.0),
                  itemCount: _camps.length,
                  itemBuilder: (context, index) {
                    return InkWell(
                      onTap: () => _onCampSelected(_camps[index]),
                      child: CampCard(camp: _camps[index]),
                    );
                  },
                ),
      floatingActionButtonLocation: FloatingActionButtonLocation.endFloat,
      floatingActionButton: FloatingActionButton(
        onPressed: _openEnrollInstructorToCampDialog,
        child: const Icon(Icons.add),
      ),
    );
  }
}
