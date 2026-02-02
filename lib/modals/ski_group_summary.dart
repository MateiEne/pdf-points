import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:pdf_points/const/values.dart';
import 'package:pdf_points/data/participant.dart';
import 'package:pdf_points/data/ski_group.dart';
import 'package:pdf_points/services/firebase/firebase_manager.dart';
import 'package:pdf_points/view/extensions/snackbar_extensions.dart';
import 'package:pdf_points/view/widgets/ski_group_summary_content.dart';
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
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: SkiGroupSummaryContent(
          campId: campId,
          instructor: instructor,
          students: students,
          groupName: groupName,
          onCopyButtonPressed: () {
            Navigator.of(modalSheetContext).pop();
          },
        ),
      ),
    );
  }
}
