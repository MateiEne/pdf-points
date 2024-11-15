import 'package:auto_size_text/auto_size_text.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:pdf_points/const/values.dart';
import 'package:pdf_points/data/participant.dart';
import 'package:pdf_points/data/ski_group.dart';
import 'package:pdf_points/utils/safe_setState.dart';
import 'package:pdf_points/widgets/ski_group/no_ski_group.dart';

class InstructorHomeScreen extends StatefulWidget {
  const InstructorHomeScreen({super.key, required this.instructor});

  final Participant instructor;

  @override
  State<InstructorHomeScreen> createState() => _InstructorHomeScreenState();
}

class _InstructorHomeScreenState extends State<InstructorHomeScreen> {
  bool _isLoading = true;
  SkiGroup? _skiGroup;

  @override
  void initState() {
    super.initState();

    _fetchGroup(widget.instructor.id);
  }

  Future<void> _fetchGroup(String uid) async {
    safeSetState(() {
      _isLoading = true;
    });

    // TODO: Check if this instructor has a group
    await Future.delayed(const Duration(milliseconds: 500));

    safeSetState(() {
      _isLoading = false;
      _skiGroup = null;
      // _group = SkiGroup(name: "name", instructor: Participant(firstName: "Abi"));
    });
  }

  void _onAddSkiGroup(SkiGroup skiGroup) {
    safeSetState(() {
      _skiGroup = skiGroup;
    });
  }

  Widget _showGroupScreen() {
    SkiGroup? skiGroup = _skiGroup;

    if (skiGroup == null) {
      return const SizedBox.shrink();
    }

    return Column(
      children: [
        if (skiGroup.participants.isEmpty) ...[
          // top padding
          SizedBox(height: MediaQuery.sizeOf(context).height * 0.1),

          // Title
          Text(
            "You don't have students yet.",
            style: Theme.of(context).textTheme.titleLarge,
          ),

          const SizedBox(height: 48),

          // Instructions to add ski group
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            child: Text(
              'Add all your students to this group using the button below.',
              style: Theme.of(context).textTheme.bodyLarge,
              textAlign: TextAlign.center,
            ),
          ),
        ],

        const SizedBox(height: 32),

        // Add ski group button
        ElevatedButton(
          style: ElevatedButton.styleFrom(
            backgroundColor: kAppSeedColor,
            foregroundColor: Colors.white,
            maximumSize: const Size(double.infinity, 56),
          ),
          onPressed: () {},
          child: const Center(
            child: Text('Add Student'),
          ),
        ),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        centerTitle: true,
        title: AutoSizeText(
          _skiGroup == null //
              ? widget.instructor.shortName
              : _skiGroup!.name,
          maxLines: 1,
        ),
        actions: [
          IconButton(
            onPressed: () {
              FirebaseAuth.instance.signOut();
            },
            icon: const Icon(Icons.logout),
          ),
        ],
      ),
      body: Padding(
        padding: const EdgeInsets.all(8.0),
        child: _isLoading
            ? const Center(child: CircularProgressIndicator())
            : SingleChildScrollView(
                child: _skiGroup == null //
                    ? NoSkiGroup(instructor: widget.instructor, onAddSkiGroup: _onAddSkiGroup)
                    : _showGroupScreen(),
              ),
      ),
    );
  }
}
