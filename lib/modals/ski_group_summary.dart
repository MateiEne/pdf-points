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
    // Create a GlobalKey to access the state directly
    final contentKey = GlobalKey<_SkiGroupSummaryContentState>();

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
          onPressed: () => _copySummaryToClipboard(modalSheetContext, contentKey),
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
          key: contentKey,
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
    GlobalKey<_SkiGroupSummaryContentState> contentKey,
  ) async {
    // Access the state directly using the GlobalKey
    final state = contentKey.currentState;

    if (state == null || state._isLoading) {
      // If state not found or still loading, show message
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBarError('Please wait for data to load');
      }
      return;
    }

    // Use the cached data from state (no duplicate Firebase calls!)
    final summaryText = state.generateSummaryText();
    await Clipboard.setData(ClipboardData(text: summaryText));

    if (context.mounted) {
      ScaffoldMessenger.of(context).showSnackBarSuccess('Summary copied to clipboard!');

      // close the modal
      Navigator.of(context).pop();
    }
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

  // Generate summary text using already calculated points (avoids duplicate Firebase calls)
  String generateSummaryText() {
    final buffer = StringBuffer();
    buffer.writeln('${widget.groupName} - Group Summary');
    buffer.writeln('Date: ${DateTime.now().toString().split(' ')[0]}');
    buffer.writeln('');

    // Add students
    for (var i = 0; i < widget.students.length; i++) {
      final student = widget.students[i];
      final studentPoints = _totalPoints[student.id] ?? 0;

      buffer.writeln('${student.fullName}: $studentPoints pts');
    }

    // Add instructor last
    final instructorPoints = _totalPoints[widget.instructor.id] ?? 0;
    buffer.writeln('${widget.instructor.fullName}:\t $instructorPoints pts');

    return buffer.toString();
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
