import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:pdf_points/const/values.dart';
import 'package:pdf_points/data/lift_participant_info.dart';
import 'package:pdf_points/data/participant.dart';
import 'package:pdf_points/services/firebase/firebase_manager.dart';
import 'package:pdf_points/view/extensions/snackbar_extensions.dart';
import 'package:wolt_modal_sheet/wolt_modal_sheet.dart';

class GroupSummaryModal {
  static Future<void> show({
    required BuildContext context,
    required String campId,
    required List<Participant> students,
    required String groupName,
  }) {
    return WoltModalSheet.show(
      context: context,
      pageListBuilder: (modalSheetContext) {
        return [
          _summaryPage(modalSheetContext, campId, students, groupName),
        ];
      },
      modalTypeBuilder: (context) {
        final size = MediaQuery.sizeOf(context).width;
        return size < kPageWidthBreakpoint
            ? const WoltBottomSheetType()
            : const WoltDialogType();
      },
      onModalDismissedWithBarrierTap: () {
        Navigator.of(context).pop();
      },
    );
  }

  static WoltModalSheetPage _summaryPage(
    BuildContext modalSheetContext,
    String campId,
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
        child: GroupSummaryContent(
          campId: campId,
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
        return liftDate.year == now.year &&
            liftDate.month == now.month &&
            liftDate.day == now.day;
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

class GroupSummaryContent extends StatefulWidget {
  final String campId;
  final List<Participant> students;
  final String groupName;

  const GroupSummaryContent({
    super.key,
    required this.campId,
    required this.students,
    required this.groupName,
  });

  @override
  State<GroupSummaryContent> createState() => _GroupSummaryContentState();
}

class _GroupSummaryContentState extends State<GroupSummaryContent> {
  final Map<String, List<LiftParticipantInfo>> _studentsLifts = {};
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadLiftsForAllStudents();
  }

  Future<void> _loadLiftsForAllStudents() async {
    setState(() => _isLoading = true);

    try {
      final now = DateTime.now();

      for (var student in widget.students) {
        final allLifts = await FirebaseManager.instance.fetchLiftsForPerson(
          campId: widget.campId,
          personId: student.id,
        );

        // Filter for today's lifts
        final todayLifts = allLifts.where((lift) {
          final liftDate = lift.createdAt;
          return liftDate.year == now.year &&
              liftDate.month == now.month &&
              liftDate.day == now.day;
        }).toList();

        todayLifts.sort((a, b) => a.createdAt.compareTo(b.createdAt));
        _studentsLifts[student.id] = todayLifts;
      }
    } catch (e) {
      debugPrint('Error loading lifts: $e');
    } finally {
      if (mounted) {
        setState(() => _isLoading = false);
      }
    }
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
      itemCount: widget.students.length,
      itemBuilder: (context, index) {
        final student = widget.students[index];
        final lifts = _studentsLifts[student.id] ?? [];

        return Card(
          margin: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
          child: Padding(
            padding: const EdgeInsets.all(12.0),
            child: Row(
              children: [
                // Number
                Text(
                  '${index + 1}',
                  style: Theme.of(context).textTheme.bodyLarge,
                ),
                const SizedBox(width: 12),

                // Student name
                Expanded(
                  child: Text(
                    student.fullName,
                    style: const TextStyle(fontWeight: FontWeight.bold),
                  ),
                ),

                // Lift icons
                if (lifts.isNotEmpty) ...[
                  const SizedBox(width: 8),
                  Expanded(
                    child: Wrap(
                      spacing: 4,
                      runSpacing: 4,
                      children: lifts.map((lift) {
                        return const Icon(
                          Icons.cable_rounded,
                          size: 18,
                        );
                      }).toList(),
                    ),
                  ),
                ],
              ],
            ),
          ),
        );
      },
    );
  }
}
