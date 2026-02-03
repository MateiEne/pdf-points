import 'package:flutter/material.dart';
import 'package:pdf_points/data/participant.dart';
import 'package:pdf_points/modals/update_participant.dart';
import 'package:pdf_points/view/widgets/search_participant_content.dart';

class ParticipantsScreen extends StatefulWidget {
  final String campId;

  const ParticipantsScreen({
    super.key,
    required this.campId,
  });

  @override
  State<ParticipantsScreen> createState() => _ParticipantsScreenState();
}

class _ParticipantsScreenState extends State<ParticipantsScreen> {
  Key _contentKey = UniqueKey();

  void _handleParticipantSelected(Participant participant) async {
    final updatedParticipant = await UpdateParticipantModal.show(
      context: context,
      campId: widget.campId,
      participant: participant,
    );

    if (updatedParticipant != null) {
      setState(() {
        _contentKey = UniqueKey();
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Participants'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(4.0),
        child: SearchParticipantContent(
          key: _contentKey,
          campId: widget.campId,
          onSelected: _handleParticipantSelected,
        ),
      ),
    );
  }
}
