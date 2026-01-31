import 'package:flutter/material.dart';
import 'package:pdf_points/const/values.dart';
import 'package:pdf_points/data/participant.dart';
import 'package:pdf_points/view/widgets/add_or_update_participant_content.dart';
import 'package:wolt_modal_sheet/wolt_modal_sheet.dart';

class AddParticipantModal {
  static Future<Participant?> show({
    required BuildContext context,
    required String campId,
    String? defaultFirstName,
    String? defaultLastName,
    String? defaultPhone,
  }) {
    return WoltModalSheet.show<Participant?>(
      context: context,
      pageListBuilder: (modalSheetContext) => [
        WoltModalSheetPage(
          hasSabGradient: false,
          topBarTitle: Text(
            'Add Participant',
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
            child: AddOrUpdateParticipantContentWidget(
              campId: campId,
              defaultFirstName: defaultFirstName,
              defaultLastName: defaultLastName,
              defaultPhone: defaultPhone,
              onAddParticipantAdded: (newParticipant) {
                Navigator.of(modalSheetContext).pop(newParticipant);
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
