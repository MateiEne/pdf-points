import 'package:flutter/material.dart';
import 'package:pdf_points/const/values.dart';
import 'package:pdf_points/data/camp.dart';
import 'package:pdf_points/data/participant.dart';
import 'package:pdf_points/view/widgets/enroll_instructor_to_camp_content.dart';
import 'package:wolt_modal_sheet/wolt_modal_sheet.dart';

class EnrollInstructorToCampModal {
  static Future<Camp?> show({
    required BuildContext context,
    required Instructor instructor,
  }) {
    return WoltModalSheet.show<Camp?>(
      context: context,
      pageListBuilder: (modalSheetContext) => [
        WoltModalSheetPage(
          hasSabGradient: false,
          topBarTitle: Text(
            'Enroll to Camp',
            style: Theme.of(context).textTheme.titleLarge!.copyWith(fontWeight: FontWeight.bold),
          ),
          isTopBarLayerAlwaysVisible: true,
          trailingNavBarWidget: IconButton(
            padding: const EdgeInsets.all(16.0),
            icon: const Icon(Icons.close),
            onPressed: Navigator.of(modalSheetContext).pop,
          ),
          child: Padding(
            padding: const EdgeInsets.all(16.0),
            child: EnrollInstructorToCampContentWidget(
              instructor: instructor,
              onEnrolled: (camp) {
                Navigator.of(modalSheetContext).pop(camp);
              },
            ),
          ),
        ),
      ],
      modalTypeBuilder: (context) {
        final size = MediaQuery.sizeOf(context).width;

        return size < kPageWidthBreakpoint //
            ? const WoltBottomSheetType()
            : const WoltDialogType();
      },
      onModalDismissedWithBarrierTap: () {
        Navigator.of(context).pop();
      },
    );
  }
}
