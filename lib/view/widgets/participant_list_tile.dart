import 'package:flutter/material.dart';
import 'package:pdf_points/data/participant.dart';
import 'package:styled_text/styled_text.dart';

class ParticipantListTile extends StatelessWidget {
  const ParticipantListTile({
    super.key,
    required this.index,
    required this.participant,
  });

  final int index;
  final Participant participant;

  @override
  Widget build(BuildContext context) {
    return ListTile(
      leading: Text("$index."),
      title: Text(
        participant.fullName,
        style: const TextStyle(fontWeight: FontWeight.bold),
      ),
      subtitle: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          if (participant.groupId != null)
            StyledText(
              text: '<bold>GroupId:</bold> ${participant.groupId}',
              tags: {
                "bold": StyledTextTag(style: const TextStyle(fontWeight: FontWeight.w600)),
              },
            ),
          if (participant.phone != null)
            StyledText(
              text: '<bold>Phone:</bold> ${participant.phone}',
              tags: {
                "bold": StyledTextTag(style: const TextStyle(fontWeight: FontWeight.w600)),
              },
            ),
        ],
      ),
      isThreeLine: participant.groupId != null && participant.phone != null,
    );
  }
}
