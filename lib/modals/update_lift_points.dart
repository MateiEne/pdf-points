import 'package:flutter/material.dart';
import 'package:pdf_points/const/values.dart';
import 'package:pdf_points/data/lift_info.dart';
import 'package:pdf_points/data/participant.dart';
import 'package:pdf_points/services/firebase/firebase_manager.dart';
import 'package:pdf_points/view/widgets/update_lift_points_content.dart';
import 'package:wolt_modal_sheet/wolt_modal_sheet.dart';

class UpdateLiftPointsModal {
  static Future<void> show({
    required BuildContext context,
    required LiftInfo liftInfo,
    required Instructor instructor,
  }) {
    return WoltModalSheet.show<bool>(
      context: context,
      pageListBuilder: (context) => [
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
            onPressed: Navigator.of(context).pop,
          ),
          child: UpdateLiftPointsContent(
            liftInfo: liftInfo,
            onCancel: () => Navigator.of(context).pop(false),
            onPointsUpdated: () => Navigator.of(context).pop(true),
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
        // Navigator.of(context).pop(false);
      },
    ).then((bool? pointsUpdated) async {
      if (pointsUpdated != true) {
        // add this lift to the today's pending lifts update collection if the lift info was not modified today
        await FirebaseManager.instance.addTodaysPendingLiftUpdate(liftName: liftInfo.name);
      }
    });
  }
}
