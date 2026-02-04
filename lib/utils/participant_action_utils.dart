import 'package:flutter/material.dart';
import 'package:pdf_points/data/participant.dart';
import 'package:pdf_points/modals/update_participant.dart';
import 'package:pdf_points/view/extensions/snackbar_extensions.dart';
import 'package:url_launcher/url_launcher.dart';

class ParticipantActionUtils {
  static Future<Participant?> callOrUpdateParticipantPhone({
    required BuildContext context,
    required String campId,
    required Participant participant,
  }) async {
    if (participant.phone == null) {
      return await UpdateParticipantModal.show(
        context: context,
        campId: campId,
        participant: participant,
      );
    }

    final Uri phoneUri = Uri(scheme: 'tel', path: participant.phone);

    try {
      if (await canLaunchUrl(phoneUri)) {
        await launchUrl(phoneUri);
      } else {
        if (context.mounted) {
          ScaffoldMessenger.of(context).showSnackBarError('Cannot make phone call');
        }
      }
    } catch (e) {
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBarError('Error: ${e.toString()}');
      }
    }

    return null;
  }
}
