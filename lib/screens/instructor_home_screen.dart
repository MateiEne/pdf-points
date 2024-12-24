import 'package:auto_size_text/auto_size_text.dart';
import 'package:flutter/material.dart';
import 'package:pdf_points/const/values.dart';
import 'package:pdf_points/data/participant.dart';
import 'package:pdf_points/data/ski_group.dart';
import 'package:pdf_points/modals/search_participant.dart';
import 'package:pdf_points/modals/update_participant.dart';
import 'package:pdf_points/services/firebase/firebase_manager.dart';
import 'package:pdf_points/utils/pdf_points_exel_parser.dart';
import 'package:pdf_points/utils/safe_setState.dart';
import 'package:pdf_points/widgets/add_points_fab.dart';
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
      // _skiGroup = null;
      _skiGroup = SkiGroup(
        name: "Abi",
        instructor: widget.instructor,
        students: PdfPointsExelParser.dummyListParticipants().sublist(0, 5).toList(),
      );
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
        if (skiGroup.students.isEmpty) ...[
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

        // Participants list
        ListView.builder(
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          itemCount: skiGroup.students.length,
          itemBuilder: (context, index) {
            final participant = skiGroup.students[index];

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
            backgroundColor: skiGroup.hasStudents ? null : kAppSeedColor,
            foregroundColor: skiGroup.hasStudents ? Theme.of(context).colorScheme.primary : Colors.white,
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

  Future<void> _onSelectedParticipantToSkiGroup(BuildContext modalSheetContext, Participant participant) async {
    // close the search participants modal
    if (!modalSheetContext.mounted) return;

    Navigator.of(modalSheetContext).pop();

    // if the participant has no phone number => update phone number
    if (participant.phone == null) {
      Participant? updatedParticipant = await UpdateParticipantModal.show(
        context: context,
        participant: participant,
      );

      if (updatedParticipant == null) return;

      participant = updatedParticipant;
    }

    // if the participant is not in any group => add to my group
    if (participant.groupId == null) {
      await _onAddParticipantToSkiGroup(participant);
      return;
    }

    // if the participant is already in my group => do nothing
    if (participant.groupId == widget.instructor.groupId) {
      return;
    }

    if (!mounted) return;

    // the participant is in another group => ask to remove from that group and add to my group
    await showDialog(
      context: context,
      builder: (dialogContext) => AlertDialog(
        title: Text(
          'Participant already in a group',
          style: Theme.of(context).textTheme.titleLarge!.copyWith(fontWeight: FontWeight.bold),
        ),
        content: Text(
          'Are you sure you want to remove ${participant.fullName} from the current group and add them to your group?',
          style: const TextStyle(fontSize: 16),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(dialogContext),
            child: const Text('Cancel'), // cancel button  -> close the dialog
          ),
          ElevatedButton(
            onPressed: () => _onAddParticipantToSkiGroup(participant),
            child: const Text('Add'), // add button  -> add the participant to ski group
          ),
        ],
      ),
    );
  }

  Future<void> _onAddParticipantToSkiGroup(Participant participant) async {
    safeSetState(() {
      _isLoading = true;
    });
    // TODO: add participant to my group in firebase:
    // FirebaseManager.instance.addParticipantToSkiGroup(
    //   ...
    // );
    await Future.delayed(const Duration(seconds: 1));

    safeSetState(() {
      _skiGroup!.addStudent(participant);
      _isLoading = false;
    });
  }

  void _openParticipantsSearchModal() {
    SearchParticipantModal.show(
      context: context,
      onSelected: _onSelectedParticipantToSkiGroup,
      showNavBar: false,
      excludeGroupId: widget.instructor.groupId,
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
              child: _skiGroup == null //
                  ? NoSkiGroup(instructor: widget.instructor, onAddSkiGroup: _onAddSkiGroup)
                  : _showGroupScreen(),
            ),

            // loading indicator
            if (_isLoading) const Center(child: CircularProgressIndicator()),
          ],
        ),
      ),
      floatingActionButtonLocation: AddPointsFab.location,
      floatingActionButton: _skiGroup != null && _skiGroup!.hasStudents //
          ? AddPointsFab(students: _skiGroup!.students)
          : null,
    );
  }
}
