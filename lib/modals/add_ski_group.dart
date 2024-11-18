import 'package:flutter/material.dart';
import 'package:pdf_points/const/values.dart';
import 'package:pdf_points/widgets/ski_group/add_ski_group_content.dart';
import 'package:wolt_modal_sheet/wolt_modal_sheet.dart';

class AddSkiGroupModal {
  static Future<T?> show<T>({
    required BuildContext context,
    required Future<T> Function(BuildContext context, String name) onAddSkiCamp,
    String? defaultName,
  }) {
    return WoltModalSheet.show<T>(
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
              defaultName: defaultName,
              onAddSkiCamp: (name) => onAddSkiCamp(modalSheetContext, name),
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
