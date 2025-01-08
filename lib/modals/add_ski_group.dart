import 'package:flutter/material.dart';
import 'package:pdf_points/const/values.dart';
import 'package:pdf_points/data/ski_group.dart';
import 'package:pdf_points/widgets/add_ski_group_content.dart';
import 'package:wolt_modal_sheet/wolt_modal_sheet.dart';

class AddSkiGroupModal {
  static Future<SkiGroup?> show({
    required BuildContext context,
    required String campId,
    required String instructorId,
    String? defaultName,
  }) {
    return WoltModalSheet.show<SkiGroup?>(
      context: context,
      pageListBuilder: (modalSheetContext) => [
        WoltModalSheetPage(
          hasSabGradient: false,
          topBarTitle: Text(
            'Create Group',
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
            child: AddSkiGroupContentWidget(
              campId: campId,
              instructorId: instructorId,
              defaultName: defaultName,
              onSkiCampCreated: (skiGroup) {
                Navigator.of(modalSheetContext).pop(skiGroup);
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
