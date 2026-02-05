import 'package:flutter/material.dart';
import 'package:pdf_points/const/values.dart';
import 'package:pdf_points/data/lift_info.dart';
import 'package:pdf_points/data/participant.dart';
import 'package:pdf_points/view/widgets/update_lift_points_content.dart';
import 'package:wolt_modal_sheet/wolt_modal_sheet.dart';

class UpdateLiftPointsModal {
  static Future<void> show({
    required BuildContext context,
    required LiftInfo liftInfo,
    required Instructor instructor,
  }) async {
    WoltModalSheet.show(
      context: context,
      pageListBuilder: (modalSheetContext) => [
        WoltModalSheetPage(
          hasSabGradient: false,
          topBarTitle: Text(
            "Update Lift Points",
            style: Theme.of(context).textTheme.titleLarge!.copyWith(fontWeight: FontWeight.bold),
          ),
          isTopBarLayerAlwaysVisible: true,
          trailingNavBarWidget: IconButton(
            padding: const EdgeInsets.all(16.0),
            icon: const Icon(Icons.close),
            onPressed: Navigator.of(modalSheetContext).pop,
          ),
          child: UpdateLiftPointsContent(
            liftInfo: liftInfo,
            onCancel: () => Navigator.of(modalSheetContext).pop(),
            onPointsUpdated: () => Navigator.of(modalSheetContext).pop(),
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
