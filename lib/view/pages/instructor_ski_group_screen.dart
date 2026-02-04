import 'dart:async';

import 'package:auto_size_text/auto_size_text.dart';
import 'package:flutter/material.dart';
import 'package:pdf_points/const/values.dart';
import 'package:pdf_points/data/camp.dart';
import 'package:pdf_points/data/lift_participant_info.dart';
import 'package:pdf_points/data/participant.dart';
import 'package:pdf_points/data/ski_group.dart';
import 'package:pdf_points/modals/add_lifts.dart';
import 'package:pdf_points/modals/add_ski_group.dart';
import 'package:pdf_points/modals/search_participant.dart';
import 'package:pdf_points/modals/ski_group_summary.dart';
import 'package:pdf_points/modals/update_participant.dart';
import 'package:pdf_points/services/firebase/firebase_manager.dart';
import 'package:pdf_points/utils/number_utils.dart';
import 'package:pdf_points/utils/safe_setState.dart';
import 'package:pdf_points/view/extensions/snackbar_extensions.dart';
import 'package:styled_text/styled_text.dart';
import 'package:url_launcher/url_launcher.dart';

class InstructorSkiGroupScreen extends StatefulWidget {
  const InstructorSkiGroupScreen({super.key, required this.instructor, required this.camp});

  final Instructor instructor;
  final Camp camp;

  @override
  State<InstructorSkiGroupScreen> createState() => _InstructorSkiGroupScreenState();
}

class _InstructorSkiGroupScreenState extends State<InstructorSkiGroupScreen> {
  bool _isLoading = false;
  bool _isInitialLoading = false;
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
      _isInitialLoading = true;
    });

    try {
      // fetch ski group for this instructor
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
        _isInitialLoading = false;

        _skiGroup = skiGroup;
        _students = students;
      });
    } catch (e) {
      safeSetState(() {
        _isInitialLoading = false;
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

    final updatedParticipant = await FirebaseManager.instance.addParticipantToSkiGroup(
      campId: widget.camp.id,
      skiGroupId: _skiGroup!.id,
      participant: participant,
    );

    safeSetState(() {
      _skiGroup!.addStudent(updatedParticipant);
      _students = _sortStudents([..._students, updatedParticipant]);
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

  Future<void> _callStudent(Participant participant) async {
    if (participant.phone == null) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBarError('This student has no phone number');
      }
      return;
    }

    final Uri phoneUri = Uri(scheme: 'tel', path: participant.phone);

    try {
      if (await canLaunchUrl(phoneUri)) {
        await launchUrl(phoneUri);
      } else {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBarError('Cannot make phone call');
        }
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBarError('Error: ${e.toString()}');
      }
    }
  }

  Future<void> _removeStudentFromGroup(Participant participant) async {
    if (_skiGroup == null) return;

    final confirmed = await showDialog<bool>(
      context: context,
      builder: (dialogContext) => AlertDialog(
        title: const Text('Remove Student'),
        content: StyledText(
          text: 'Are you sure you want to remove <bold>${participant.fullName}</bold> from your group?',
          tags: {
            "bold": StyledTextTag(style: const TextStyle(fontWeight: FontWeight.w600)),
          },
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(dialogContext, false),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () => Navigator.pop(dialogContext, true),
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.red,
              foregroundColor: Colors.white,
            ),
            child: const Text('Remove'),
          ),
        ],
      ),
    );

    if (confirmed != true || !mounted) return;

    try {
      safeSetState(() {
        _isLoading = true;
      });

      await FirebaseManager.instance.removeParticipantFromSkiGroup(
        campId: widget.camp.id,
        skiGroupId: _skiGroup!.id,
        participantId: participant.id,
      );

      safeSetState(() {
        _skiGroup?.studentsIds.remove(participant.id);
        _students.removeWhere((s) => s.id == participant.id);
      });

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBarSuccess('${participant.fullName} removed from group');
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBarError('Error removing student: ${e.toString()}');
      }
    } finally {
      safeSetState(() {
        _isLoading = false;
      });
    }
  }

  Widget _showNoSkiGroupContent() {
    return Column(
      children: [
        // Icon
        Icon(
          Icons.groups,
          size: 92,
          color: Theme.of(context).colorScheme.secondary.withValues(alpha: 0.5),
        ),

        const SizedBox(height: 16),

        // Title
        Text(
          "You don't have a group yet.",
          style: Theme.of(context).textTheme.headlineLarge,
        ),

        const SizedBox(height: 48),

        // Instructions to add ski group
        Text(
          '1. First create your group',
          style: Theme.of(context).textTheme.titleLarge,
        ),
        const SizedBox(height: 8),
        Text(
          '2. Then add your participants',
          style: Theme.of(context).textTheme.titleLarge,
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

  Widget _showNoStudentsContent() {
    return Column(
      children: [
        // Icon
        Icon(
          Icons.person_add,
          size: 92,
          color: Theme.of(context).colorScheme.secondary.withValues(alpha: 0.5),
        ),

        const SizedBox(height: 16),

        // Title
        Text(
          "No students in your group",
          style: Theme.of(context).textTheme.headlineLarge,
          textAlign: TextAlign.center,
        ),

        const SizedBox(height: 16),

        // Instructions to add students
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16),
          child: Text(
            'Start building your group by adding students using the button below.',
            style: Theme.of(context).textTheme.titleLarge?.copyWith(
                  color: Theme.of(context).colorScheme.onSurface.withValues(alpha: 0.6),
                ),
            textAlign: TextAlign.center,
          ),
        ),
      ],
    );
  }

  Widget _showGroupContent() {
    return Column(
      children: [
        if (_students.isEmpty) _showNoStudentsContent() else _buildSkiGroupParticipantsList(),

        const SizedBox(height: 32),

        // Add student button
        _buildAddStudentButton(),

        const SizedBox(height: 32),
      ],
    );
  }

  Widget _buildSkiGroupParticipantsList() {
    return ListView.builder(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      itemCount: _students.length + 1, // +1 for instructor
      itemBuilder: (context, index) {
        // First row: Instructor
        if (index == 0) {
          return _buildParticipantCard(index, _instructor, isInstructor: true);
        }

        // Subsequent rows: Students
        return _buildParticipantCard(index, _students[index - 1]);
      },
    );
  }

  Widget _buildParticipantCard(int index, Participant participant, {bool isInstructor = false}) {
    return Card(
      key: ValueKey(participant.id),
      margin: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      child: StreamBuilder<List<LiftParticipantInfo>>(
        stream: FirebaseManager.instance.listenToLiftsForPerson(
          campId: widget.camp.id,
          personId: participant.id,
        ),
        builder: (context, liftSnapshot) {
          final allLifts = liftSnapshot.data ?? [];

          // Filter lifts for today only
          final now = DateTime.now();
          final lifts = allLifts.where((lift) {
            final liftDate = lift.createdAt;
            return liftDate.year == now.year && liftDate.month == now.month && liftDate.day == now.day;
          }).toList();

          lifts.sort((a, b) => a.createdAt.compareTo(b.createdAt));

          return ListTileTheme(
            minLeadingWidth: 0,
            horizontalTitleGap: 8,
            child: ExpansionTile(
              shape: RoundedRectangleBorder(
                side: BorderSide(
                  color: isInstructor ? kAppSeedColor : Colors.grey.shade300,
                  width: 1,
                ),
                borderRadius: BorderRadius.circular(8),
              ),
              collapsedShape: RoundedRectangleBorder(
                side: BorderSide(
                  color: isInstructor ? kAppSeedColor : Colors.grey.shade300,
                  width: 1,
                ),
                borderRadius: BorderRadius.circular(8),
              ),
              tilePadding: const EdgeInsets.only(left: 8, right: 16, top: 4, bottom: 4),
              leading: Text(
                "${index + 1}.",
                style: Theme.of(context).textTheme.bodyLarge,
              ),
              title: _buildParticipantTitleRow(participant, lifts, isInstructor: isInstructor),
              children: [
                if (!isInstructor) _buildParticipantActions(participant),
                _buildLiftDetails(lifts, participant),
              ],
            ),
          );
        },
      ),
    );
  }

  Widget _buildParticipantTitleRow(Participant participant, List<LiftParticipantInfo> lifts,
      {bool isInstructor = false}) {
    return Row(
      children: [
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                participant.fullName,
                style: const TextStyle(fontWeight: FontWeight.bold),
              ),
              Text(
                participant.phone ?? "No phone number",
                style: Theme.of(context).textTheme.bodySmall,
              ),
            ],
          ),
        ),
        if (lifts.isNotEmpty) ...[
          const SizedBox(width: 8),
          Expanded(
            child: Wrap(
              spacing: 4,
              runSpacing: 4,
              children: lifts.map((lift) {
                return lift.icon != null
                    ? Image.asset(
                        lift.icon!,
                        width: 20,
                        height: 20,
                      )
                    : const Icon(
                        Icons.cable_rounded,
                        size: 18,
                      );
              }).toList(),
            ),
          ),
        ],
      ],
    );
  }

  Widget _buildParticipantActions(Participant participant) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
        children: [
          // Remove button
          OutlinedButton.icon(
            onPressed: () => _removeStudentFromGroup(participant),
            icon: const Icon(Icons.person_remove, size: 18),
            label: const Text('Remove'),
            style: OutlinedButton.styleFrom(
              foregroundColor: Theme.of(context).colorScheme.error,
              side: BorderSide(color: Theme.of(context).colorScheme.error),
            ),
          ),

          // Call button
          if (participant.phone != null)
            ElevatedButton.icon(
              onPressed: () => _callStudent(participant),
              icon: const Icon(Icons.phone, size: 18),
              label: const Text('Call'),
              style: ElevatedButton.styleFrom(
                backgroundColor: Theme.of(context).colorScheme.primary,
                foregroundColor: Colors.white,
              ),
            ),
        ],
      ),
    );
  }

  Widget _buildLiftDetails(List<LiftParticipantInfo> lifts, Participant participant) {
    if (lifts.isEmpty) {
      return Padding(
        padding: const EdgeInsets.all(16.0),
        child: Text(
          'No lifts recorded yet',
          style: TextStyle(
            color: Theme.of(context).colorScheme.onSurface.withValues(alpha: 0.6),
          ),
        ),
      );
    }

    return ListView.builder(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      itemCount: lifts.length,
      itemBuilder: (context, liftIndex) {
        return _buildLiftListTile(lifts[liftIndex], participant);
      },
    );
  }

  Widget _buildLiftListTile(LiftParticipantInfo lift, Participant participant) {
    return ListTile(
      dense: true,
      leading: lift.icon != null
          ? Image.asset(lift.icon!, width: 24, height: 24)
          : const Icon(Icons.cable_rounded, size: 20),
      title: Text(
        lift.name,
        style: const TextStyle(fontSize: 14),
      ),
      subtitle: Text(
        lift.type,
        style: const TextStyle(fontSize: 12),
      ),
      trailing: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(
            '${lift.createdAt.hour}:${lift.createdAt.minute.toPaddedString(2)}',
            style: TextStyle(
              fontSize: 12,
              color: Theme.of(context).colorScheme.onSurface.withValues(alpha: 0.6),
            ),
          ),
          const SizedBox(width: 8),
          IconButton(
            icon: const Icon(Icons.delete_outline, size: 24),
            color: Theme.of(context).colorScheme.error,
            onPressed: () => _removeLift(lift, participant),
            padding: EdgeInsets.zero,
            constraints: const BoxConstraints(),
          ),
        ],
      ),
    );
  }

  Future<void> _removeLift(LiftParticipantInfo lift, Participant participant) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (dialogContext) => AlertDialog(
        title: const Text('Remove Lift'),
        content: StyledText(
          text:
              'Are you sure you want to remove this <bold>${lift.name} ${lift.type}</bold> from <bold>${participant.fullName}</bold>?',
          tags: {
            "bold": StyledTextTag(style: const TextStyle(fontWeight: FontWeight.w600)),
          },
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(dialogContext, false),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () => Navigator.pop(dialogContext, true),
            style: ElevatedButton.styleFrom(
              backgroundColor: Theme.of(context).colorScheme.error,
              foregroundColor: Colors.white,
            ),
            child: const Text('Remove'),
          ),
        ],
      ),
    );

    if (confirmed != true || !mounted) return;

    try {
      await FirebaseManager.instance.removeLift(
        campId: widget.camp.id,
        liftId: lift.id,
      );

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBarSuccess('Lift removed successfully');
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBarError('Error removing lift: ${e.toString()}');
      }
    }
  }

  Widget _buildAddStudentButton() {
    return OutlinedButton(
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
    );
  }

  void _showGroupSummary() {
    if (_skiGroup == null) return;

    SkiGroupSummaryModal.show(
      context: context,
      campId: widget.camp.id,
      skiGroup: _skiGroup!,
      instructor: _instructor,
      students: _students,
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
          if (_students.isNotEmpty)
            IconButton(
              icon: const Icon(Icons.summarize),
              onPressed: _showGroupSummary,
              tooltip: 'Group Summary',
            ),
        ],
      ),
      body: _isInitialLoading
          ? const Center(child: CircularProgressIndicator())
          : Padding(
              padding: const EdgeInsets.all(4.0),
              child: Stack(
                children: [
                  // page content
                  SingleChildScrollView(
                    child: _instructor.groupId == null //
                        ? _showNoSkiGroupContent()
                        : _showGroupContent(),
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
