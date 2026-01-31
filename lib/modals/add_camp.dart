import 'package:flutter/material.dart';
import 'package:pdf_points/const/values.dart';
import 'package:pdf_points/data/camp.dart';
import 'package:pdf_points/data/excel_camp_info.dart';
import 'package:pdf_points/view/widgets/add_camp_content.dart';
import 'package:wolt_modal_sheet/wolt_modal_sheet.dart';

class AddCampModal {
  static Future<Camp?> show<T>({
    required BuildContext context,
    ExcelCampInfo? campInfo,
  }) {
    return WoltModalSheet.show<Camp?>(
      context: context,
      pageListBuilder: (modalSheetContext) => [
        WoltModalSheetPage(
          hasSabGradient: false,
          topBarTitle: Text(
            'Add Camp',
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
            child: AddCampContentWidget(
              campInfo: campInfo,
              onCampAdded: (camp) {
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
