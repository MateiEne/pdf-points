import 'dart:typed_data';

import 'package:flutter/material.dart';
import 'package:pdf_points/const/values.dart';
import 'package:pdf_points/data/excel_camp_info.dart';
import 'package:pdf_points/data/participant.dart';
import 'package:pdf_points/widgets/add_camp_content.dart';
import 'package:wolt_modal_sheet/wolt_modal_sheet.dart';

class AddCampModal {
  static Future<T?> show<T>({
    required BuildContext context,
    required Future<void> Function(
      BuildContext context,
      String name,
      String password,
      DateTime startDate,
      DateTime endDate,
      Uint8List? image,
      List<Participant> participants,
    ) onAddCamp,
    Future<Uint8List?> Function()? onAddPicture,
    ExcelCampInfo? campInfo,
  }) {
    return WoltModalSheet.show<T>(
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
              onAddImage: onAddPicture,
              onAddCamp: (name, password, startDate, endDate, image, participants) => onAddCamp(
                modalSheetContext,
                name,
                password,
                startDate,
                endDate,
                image,
                participants,
              ),
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
