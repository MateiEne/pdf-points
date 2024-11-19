import 'package:flutter/material.dart';
import 'package:pdf_points/const/values.dart';
import 'package:pdf_points/data/participant.dart';
import 'package:pdf_points/widgets/add_participant_content.dart';
import 'package:wolt_modal_sheet/wolt_modal_sheet.dart';

class UpdateParticipantModal {
  static Future<Participant?> show({
    required BuildContext context,
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
            child: AddParticipantContentWidget(
              defaultFirstName: participant.firstName,
              defaultLastName: participant.lastName,
              defaultPhone: participant.phone,
              onAddParticipant: (firstName, lastName, phone) async {
                Participant? updatedParticipant = await _onUpdateParticipant(
                  firstName,
                  lastName,
                  phone,
                );

                if (!modalSheetContext.mounted) return;

                Navigator.of(modalSheetContext).pop(updatedParticipant);
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

  static Future<Participant?> _onUpdateParticipant(String firstName, String lastName, String phone) async {
    // TODO: update participant to firebase:
    // FirebaseManager.instance.updateParticipant(
    //   ...
    // );
    await Future.delayed(const Duration(seconds: 1));

    return Participant(
      id: '1',
      firstName: firstName,
      lastName: lastName,
      phone: phone,
    );
  }
}
