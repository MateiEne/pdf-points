import 'package:flutter/material.dart';
import 'package:pdf_points/const/values.dart';
import 'package:pdf_points/data/participant.dart';
import 'package:pdf_points/widgets/add_or_update_participant_content.dart';
import 'package:wolt_modal_sheet/wolt_modal_sheet.dart';

class UpdateParticipantModal {
  static Future<Participant?> show({
    required BuildContext context,
    required String campId,
    required Participant participant,
  }) {
    return WoltModalSheet.show<Participant?>(
      context: context,
      pageListBuilder: (modalSheetContext) => [
        WoltModalSheetPage(
          hasSabGradient: false,
          topBarTitle: Text(
            'Edit Participant',
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
              participantId: participant.id,
              defaultFirstName: participant.firstName,
              defaultLastName: participant.lastName,
              defaultPhone: participant.phone,
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
