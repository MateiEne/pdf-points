import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:pdf_points/const/values.dart';
import 'package:pdf_points/data/lift_participant_info.dart';
import 'package:pdf_points/data/participant.dart';
import 'package:pdf_points/data/ski_group.dart';
import 'package:pdf_points/services/firebase/firebase_manager.dart';
import 'package:pdf_points/view/extensions/snackbar_extensions.dart';
import 'package:wolt_modal_sheet/wolt_modal_sheet.dart';

class SkiGroupSummaryModal {
  static Future<void> show({
    required BuildContext context,
    required String campId,
    required SkiGroup skiGroup,
    required Instructor instructor,
    List<Participant>? students,
  }) async {
    List<Participant> finalStudents;

    // Check if provided students match skiGroup.studentsIds
    if (students != null && students.isNotEmpty) {
      final providedIds = students.map((s) => s.id).toSet();
      final expectedIds = skiGroup.studentsIds.toSet();

      // If they match, use provided students
      if (providedIds.containsAll(expectedIds) && expectedIds.containsAll(providedIds)) {
        finalStudents = students;
      } else {
        // Mismatch - fetch from Firebase
        finalStudents = await FirebaseManager.instance.fetchStudentsFromSkiGroup(
          campId: campId,
          skiGroupId: skiGroup.id,
        );
      }
    } else {
      // No students provided - fetch from Firebase
      finalStudents = await FirebaseManager.instance.fetchStudentsFromSkiGroup(
        campId: campId,
        skiGroupId: skiGroup.id,
      );
    }

    finalStudents.sort((a, b) => a.fullName.compareTo(b.fullName));

    if (!context.mounted) return;

    return WoltModalSheet.show(
      context: context,
      pageListBuilder: (modalSheetContext) {
        return [
          _summaryPage(modalSheetContext, campId, instructor, finalStudents, skiGroup.name),
        ];
      },
      modalTypeBuilder: (context) {
        final size = MediaQuery.sizeOf(context).width;
        return size < kPageWidthBreakpoint ? const WoltBottomSheetType() : const WoltDialogType();
      },
      onModalDismissedWithBarrierTap: () {
        Navigator.of(context).pop();
      },
    );
  }

  static WoltModalSheetPage _summaryPage(
    BuildContext modalSheetContext,
    String campId,
    Instructor instructor,
    List<Participant> students,
    String groupName,
  ) {
    return WoltModalSheetPage(
      topBarTitle: Text(
        'Group Summary',
        style: Theme.of(modalSheetContext).textTheme.titleMedium!.copyWith(
              fontWeight: FontWeight.bold,
            ),
      ),
      isTopBarLayerAlwaysVisible: true,
      trailingNavBarWidget: IconButton(
        padding: const EdgeInsets.all(16),
        icon: const Icon(Icons.close),
        onPressed: () => Navigator.of(modalSheetContext).pop(),
      ),
      hasSabGradient: true,
      stickyActionBar: Padding(
        padding: const EdgeInsets.all(16),
        child: ElevatedButton.icon(
          onPressed: () => _copySummaryToClipboard(modalSheetContext, campId, students, groupName),
          icon: const Icon(Icons.copy),
          label: const Text('Copy Summary to Clipboard'),
          style: ElevatedButton.styleFrom(
            backgroundColor: kAppSeedColor,
            foregroundColor: Colors.white,
            minimumSize: const Size(double.maxFinite, 56),
          ),
        ),
      ),
      child: Padding(
        padding: const EdgeInsets.all(16.0).add(const EdgeInsets.only(bottom: 56 + 16)),
        child: SkiGroupSummaryContent(
          campId: campId,
          instructor: instructor,
          students: students,
          groupName: groupName,
        ),
      ),
    );
  }

  static Future<void> _copySummaryToClipboard(
    BuildContext context,
    String campId,
    List<Participant> students,
    String groupName,
  ) async {
    final summaryText = await _generateSummaryText(campId, students, groupName);
    await Clipboard.setData(ClipboardData(text: summaryText));

    if (context.mounted) {
      ScaffoldMessenger.of(context).showSnackBarSuccess('Summary copied to clipboard!');
      
      // close the modal
      Navigator.of(context).pop();
    }
  }

  static Future<String> _generateSummaryText(
    String campId,
    List<Participant> students,
    String groupName,
  ) async {
    final buffer = StringBuffer();
    buffer.writeln('$groupName - Group Summary');
    buffer.writeln('Date: ${DateTime.now().toString().split(' ')[0]}');
    buffer.writeln('');

    final now = DateTime.now();

    for (var i = 0; i < students.length; i++) {
      final student = students[i];
      final allLifts = await FirebaseManager.instance.fetchLiftsForPerson(
        campId: campId,
        personId: student.id,
      );

      // Filter for today's lifts
      final todayLifts = allLifts.where((lift) {
        final liftDate = lift.createdAt;
        return liftDate.year == now.year && liftDate.month == now.month && liftDate.day == now.day;
      }).toList();

      todayLifts.sort((a, b) => a.createdAt.compareTo(b.createdAt));

      buffer.writeln('${i + 1}. ${student.fullName}');

      if (todayLifts.isEmpty) {
        buffer.writeln('   No lifts recorded');
      } else {
        buffer.writeln('   Lifts (${todayLifts.length}):');
        for (var lift in todayLifts) {
          final time = '${lift.createdAt.hour}:${lift.createdAt.minute.toString().padLeft(2, '0')}';
          buffer.writeln('   - $time: ${lift.name} (${lift.type})');
        }
      }
      buffer.writeln('');
    }

    return buffer.toString();
  }
}

class SkiGroupSummaryContent extends StatefulWidget {
  final String campId;
  final List<Participant> students;
  final String groupName;
  final Instructor instructor;

  const SkiGroupSummaryContent({
    super.key,
    required this.campId,
    required this.instructor,
    required this.students,
    required this.groupName,
  });

  @override
  State<SkiGroupSummaryContent> createState() => _SkiGroupSummaryContentState();
}

class _SkiGroupSummaryContentState extends State<SkiGroupSummaryContent> {
  final Map<String, int> _totalPoints = {};
  final Map<String, int> _liftPointsMap = {}; // Cache for lift points from Firebase
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadPointsForAllStudents();
  }

  Future<void> _loadPointsForAllStudents() async {
    setState(() => _isLoading = true);

    try {
      // Fetch all lift info from Firebase
      final allLiftsInfo = await FirebaseManager.instance.fetchAllLiftsInfo();
      
      // Build a map of lift name -> points
      for (var liftInfo in allLiftsInfo) {
        _liftPointsMap[liftInfo.name] = liftInfo.points;
      }

      // Load instructor points
      final instructorLifts = await FirebaseManager.instance.fetchTodaysLiftsForPerson(
        campId: widget.campId,
        personId: widget.instructor.id,
      );
      int instructorPoints = 0;
      for (var lift in instructorLifts) {
        final liftPoints = _liftPointsMap[lift.name] ?? 0;
        instructorPoints += liftPoints;
      }
      _totalPoints[widget.instructor.id] = instructorPoints;

      // Load students points
      for (var student in widget.students) {
        final todayLifts = await FirebaseManager.instance.fetchTodaysLiftsForPerson(
          campId: widget.campId,
          personId: student.id,
        );

        // Calculate total points
        int totalPoints = 0;
        for (var lift in todayLifts) {
          final liftPoints = _liftPointsMap[lift.name] ?? 0;
          totalPoints += liftPoints;
        }
        _totalPoints[student.id] = totalPoints;
      }
    } catch (e) {
      debugPrint('Error loading points: $e');
    } finally {
      if (mounted) {
        setState(() => _isLoading = false);
      }
    }
  }

  Widget _buildRow(Participant person, int index, int points) {
    return Column(
      children: [
        Padding(
          padding: const EdgeInsets.all(4.0),
          child: Row(
            children: [
              // Number
              Text('$index.'),
              const SizedBox(width: 12),

              // Person name
              Expanded(
                child: Text(
                  person.fullName,
                  style: const TextStyle(fontWeight: FontWeight.bold),
                ),
              ),

              // Points
              if (points > 0)
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                  decoration: BoxDecoration(
                    color: kAppSeedColor.withValues(alpha: 0.1),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Text(
                    '$points pts',
                    style: TextStyle(
                      fontWeight: FontWeight.bold,
                      color: kAppSeedColor,
                    ),
                  ),
                ),
            ],
          ),
        ),
        const Divider(),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    if (_isLoading) {
      return const Center(
        child: Padding(
          padding: EdgeInsets.all(32.0),
          child: CircularProgressIndicator(),
        ),
      );
    }

    return ListView.builder(
      shrinkWrap: true,
      itemCount: widget.students.length + 1, // +1 for instructor
      itemBuilder: (context, index) {
        // First row: Instructor
        if (index == 0) {
          return _buildRow(widget.instructor, index + 1, _totalPoints[widget.instructor.id] ?? 0);
        }

        // Subsequent rows: Students
        return _buildRow(
          widget.students[index - 1],
          index + 1,
          _totalPoints[widget.students[index - 1].id] ?? 0,
        );
      },
    );
  }
}
