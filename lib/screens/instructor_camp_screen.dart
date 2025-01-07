import 'dart:async';

import 'package:auto_size_text/auto_size_text.dart';
import 'package:flutter/material.dart';
import 'package:pdf_points/const/values.dart';
import 'package:pdf_points/data/camp.dart';
import 'package:pdf_points/data/participant.dart';
import 'package:pdf_points/data/ski_group.dart';
import 'package:pdf_points/modals/add_lifts.dart';
import 'package:pdf_points/modals/add_ski_group.dart';
import 'package:pdf_points/modals/search_participant.dart';
import 'package:pdf_points/modals/update_participant.dart';
import 'package:pdf_points/services/firebase/firebase_manager.dart';
import 'package:pdf_points/utils/safe_setState.dart';

class InstructorCampScreen extends StatefulWidget {
  const InstructorCampScreen({super.key, required this.instructor, required this.camp});

  final Instructor instructor;
  final Camp camp;

  @override
  State<InstructorCampScreen> createState() => _InstructorCampScreenState();
}

class _InstructorCampScreenState extends State<InstructorCampScreen> {
  bool _isLoading = true;
  late Instructor _instructor = widget.instructor;
  SkiGroup? _skiGroup;
  List<Participant> _students = [];

  StreamSubscription? _instructorChangedSubscription;

  @override
  void initState() {
    super.initState();

    _startFirebaseEvents();
  }

  Future<void> _startFirebaseEvents() async {
    _fetchGroupAndStudents();
    _listenToInstructorChanges();
  }

  Future<void> _fetchGroupAndStudents() async {
    safeSetState(() {
      _isLoading = true;
    });

    try {
      SkiGroup? skiGroup = await FirebaseManager.instance.fetchSkiGroupForInstructor(
        campId: widget.camp.id,
        instructorId: _instructor.id,
      );

      List<Participant> students = [];

      if (skiGroup != null) {
        students = await FirebaseManager.instance.fetchStudentsFromSkiGroup(
          campId: widget.camp.id,
          skiGroupId: skiGroup.id,
        );

        students = _sortStudents(students);
      }

      safeSetState(() {
        _isLoading = false;

        _skiGroup = skiGroup;
        _students = students;
      });
    } catch (e) {
      safeSetState(() {
        _isLoading = false;
        // TODO: better error handling
        debugPrint(e.toString());
      });
    }
  }

  void _listenToInstructorChanges() {
    _instructorChangedSubscription = FirebaseManager.instance.listenToParticipantChanges(
      campId: widget.camp.id,
      participantId: _instructor.id,
      onParticipantChanged: (participant) {
        if (!mounted) return;

        safeSetState(() {
          _instructor = participant;
        });
      },
    );
  }

  List<Participant> _sortStudents(List<Participant> participants) {
    participants.sort((a, b) => a.fullName.compareTo(b.fullName));

    return participants.toList();
  }

  /// TODO: Update this method to return the index of the instructor group
  int? _getInstructorGroupId() {
    // for (int i = 0; i < widget.camp.instructors.length; i++) {
    //   if (widget.camp.instructors[i].id == widget.instructor.id) {
    //     return i;
    //   }
    // }

    return null;
  }

  Future<void> _addSkiGroup(BuildContext context) async {
    var skiGroup = await AddSkiGroupModal.show(
      context: context,
      instructorId: _instructor.id,
      campId: widget.camp.id,
      defaultName: "${_instructor.shortName}'s Group",
    );

    if (skiGroup == null) return;

    safeSetState(() {
      _skiGroup = skiGroup;
      _students = [];
    });
  }

  Future<void> _addParticipantToMySkiGroup(Participant participant) async {
    if (_skiGroup == null) {
      return;
    }

    safeSetState(() {
      _isLoading = true;
    });

    FirebaseManager.instance.addParticipantToSkiGroup(
      campId: widget.camp.id,
      skiGroupId: _skiGroup!.id,
      participant: participant,
    );

    safeSetState(() {
      _skiGroup!.addStudent(participant);
      _students = _sortStudents([..._students, participant]);
      _isLoading = false;
    });
  }

  Future<void> _openParticipantsSearchModal() async {
    if (_skiGroup == null) {
      return;
    }

    Participant? participant = await SearchParticipantModal.show(
      context: context,
      campId: widget.camp.id,
      showNavBar: false,
      excludeGroupId: _skiGroup?.id,
    );

    if (!mounted || participant == null) return;

    // if the participant has no phone number => update phone number
    if (participant.phone == null) {
      Participant? updatedParticipant = await UpdateParticipantModal.show(
        context: context,
        campId: widget.camp.id,
        participant: participant,
      );

      if (!mounted || updatedParticipant == null) return;

      participant = updatedParticipant;
    }

    // if the participant is not in any group => add to my group
    if (participant.groupId == null) {
      await _addParticipantToMySkiGroup(participant);
      return;
    }

    // if the participant is already in my group => do nothing
    if (participant.groupId == _skiGroup!.id) {
      return;
    }

    // the participant is in another group => ask to remove from that group and add to my group
    await showDialog(
      context: context,
      builder: (dialogContext) => AlertDialog(
        title: Text(
          'Participant already in a group',
          style: Theme.of(context).textTheme.titleLarge!.copyWith(fontWeight: FontWeight.bold),
        ),
        content: Text(
          'Are you sure you want to remove ${participant!.fullName} from the current group and add them to your group?',
          style: const TextStyle(fontSize: 16),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(dialogContext),
            child: const Text('Cancel'), // cancel button  -> close the dialog
          ),
          ElevatedButton(
            onPressed: () => _addParticipantToMySkiGroup(participant!),
            child: const Text('Add'), // add button  -> add the participant to ski group
          ),
        ],
      ),
    );
  }

  void _openAddLiftsDialog() {
    AddLiftsModal.show(
      context: context,
      campId: widget.camp.id,
      instructor: _instructor,
      students: _students,
    );
  }

  Widget _showNoSkiGroupScreen() {
    return Column(
      children: [
        // top padding
        SizedBox(height: MediaQuery.sizeOf(context).height * 0.1),

        // Title
        Text(
          "You don't have a group yet.",
          style: Theme.of(context).textTheme.titleLarge,
        ),

        const SizedBox(height: 48),

        // Instructions to add ski group
        Text(
          '1. First create your group',
          style: Theme.of(context).textTheme.bodyLarge,
        ),
        const SizedBox(height: 8),
        Text(
          '2. Then add your participants',
          style: Theme.of(context).textTheme.bodyLarge,
        ),

        const SizedBox(height: 32),

        // Add ski group button
        ElevatedButton(
          style: ElevatedButton.styleFrom(
            backgroundColor: kAppSeedColor,
            foregroundColor: Colors.white,
            maximumSize: const Size(double.infinity, 56),
          ),
          onPressed: () => _addSkiGroup(context),
          child: const Center(
            child: Text('Create Your Group'),
          ),
        ),
      ],
    );
  }

  Widget _showGroupScreen() {
    return Column(
      children: [
        if (_students.isEmpty) ...[
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

        // Students list
        ListView.builder(
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          itemCount: _students.length,
          itemBuilder: (context, index) {
            final participant = _students[index];

            return ListTile(
              title: Text(participant.fullName),
              subtitle: Text(participant.phone ?? "No phone number"),
              leading: Text("${index + 1}"),
            );
          },
        ),

        const SizedBox(height: 32),

        // Add ski group button
        OutlinedButton(
          style: OutlinedButton.styleFrom(
            backgroundColor: _students.isEmpty ? kAppSeedColor : null,
            foregroundColor: _students.isEmpty ? Colors.white : Theme.of(context).colorScheme.primary,
            maximumSize: const Size(double.infinity, 56),
            side: BorderSide(color: Theme.of(context).colorScheme.primary),
          ),
          onPressed: _openParticipantsSearchModal,
          child: const Center(
            child: Text('Add Student'),
          ),
        ),

        const SizedBox(height: 32),
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
              ? "${_instructor.shortName}'s Group"
              : _skiGroup!.name,
          maxLines: 1,
        ),
        actions: [
          IconButton(
            onPressed: () {
              FirebaseManager.instance.signOut();
            },
            icon: const Icon(Icons.logout),
          ),
        ],
      ),
      body: Padding(
        padding: const EdgeInsets.all(8.0),
        child: Stack(
          children: [
            // page content
            SingleChildScrollView(
              child: _instructor.groupId == null //
                  ? _showNoSkiGroupScreen()
                  : _showGroupScreen(),
            ),

            // loading indicator
            if (_isLoading) const Center(child: CircularProgressIndicator()),
          ],
        ),
      ),
      floatingActionButtonLocation: FloatingActionButtonLocation.endFloat,
      floatingActionButton: _students.isNotEmpty //
          ? FloatingActionButton.extended(
              onPressed: _openAddLiftsDialog,
              label: const Text("Add Lifts"),
              icon: const Icon(Icons.add),
            )
          : null,
    );
  }

  @override
  void dispose() {
    _instructorChangedSubscription?.cancel();
    super.dispose();
  }
}
