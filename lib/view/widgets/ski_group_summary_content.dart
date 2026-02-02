import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:pdf_points/const/values.dart';
import 'package:pdf_points/data/participant.dart';
import 'package:pdf_points/services/firebase/firebase_manager.dart';
import 'package:pdf_points/view/extensions/snackbar_extensions.dart';

class SkiGroupSummaryContent extends StatefulWidget {
  final String campId;
  final List<Participant> students;
  final String groupName;
  final Instructor instructor;
  final VoidCallback? onCopyButtonPressed;

  const SkiGroupSummaryContent({
    super.key,
    required this.campId,
    required this.instructor,
    required this.students,
    required this.groupName,
    this.onCopyButtonPressed,
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

  Future<void> _copySummaryToClipboard() async {
    final summaryText = _generateSummaryText();
    await Clipboard.setData(ClipboardData(text: summaryText));

    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBarSuccess('Summary copied to clipboard!');
    }

    widget.onCopyButtonPressed?.call();
  }

  // Generate summary text using already calculated points (avoids duplicate Firebase calls)
  String _generateSummaryText() {
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
    buffer.writeln('${widget.instructor.fullName}: $instructorPoints pts');

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
      itemCount: widget.students.length + 3, // +1 for instructor +1 for total +1 for button
      itemBuilder: (context, index) {
        // First row: Instructor
        if (index == 0) {
          return _buildRow(widget.instructor, index + 1, _totalPoints[widget.instructor.id] ?? 0);
        }

        // Students rows
        if (index <= widget.students.length) {
          return _buildRow(
            widget.students[index - 1],
            index + 1,
            _totalPoints[widget.students[index - 1].id] ?? 0,
          );
        }

        // Total row
        if (index == widget.students.length + 1) {
          final totalPoints = _totalPoints.values.fold<int>(0, (sum, pts) => sum + pts);
          return Center(
            child: Padding(
              padding: const EdgeInsets.only(top: 16.0),
              child: Text(
                'Total Points: $totalPoints pts',
                style: Theme.of(context).textTheme.titleMedium!.copyWith(
                      fontWeight: FontWeight.bold,
                    ),
              ),
            ),
          );
        }

        // Last row: Button
        return Padding(
          padding: const EdgeInsets.all(16.0),
          child: ElevatedButton.icon(
            onPressed: _copySummaryToClipboard,
            icon: const Icon(Icons.copy),
            label: const Text('Copy Summary to Clipboard'),
            style: ElevatedButton.styleFrom(
              backgroundColor: kAppSeedColor,
              foregroundColor: Colors.white,
              minimumSize: const Size(double.maxFinite, 56),
            ),
          ),
        );
      },
    );
  }
}
