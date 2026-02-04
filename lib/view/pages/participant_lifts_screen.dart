import 'package:auto_size_text/auto_size_text.dart';
import 'package:flutter/material.dart';
import 'package:pdf_points/const/values.dart';
import 'package:pdf_points/data/lift_participant_info.dart';
import 'package:pdf_points/data/participant.dart';
import 'package:pdf_points/services/firebase/firebase_manager.dart';
import 'package:pdf_points/utils/date_utils.dart';

class ParticipantLiftsScreen extends StatelessWidget {
  const ParticipantLiftsScreen({
    super.key,
    required this.campId,
    required this.participant,
  });

  final String campId;
  final Participant participant;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: AutoSizeText("${participant.shortName}'s Lifts", maxLines: 1),
      ),
      body: StreamBuilder<List<LiftParticipantInfo>>(
        stream: FirebaseManager.instance.listenToLiftsForPerson(
          campId: campId,
          personId: participant.id,
        ),
        builder: (context, snapshot) {
          if (snapshot.hasError) {
            return Center(child: Text('Error: ${snapshot.error}'));
          }

          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }

          final lifts = snapshot.data ?? [];

          if (lifts.isEmpty) {
            return const Center(child: Text("No lifts found"));
          }

          // Group by day
          final groupedLifts = <DateTime, List<LiftParticipantInfo>>{};
          for (var lift in lifts) {
            final date = lift.createdAt;
            final day = DateTime(date.year, date.month, date.day);
            if (!groupedLifts.containsKey(day)) {
              groupedLifts[day] = [];
            }
            groupedLifts[day]!.add(lift);
          }

          // Sort dates descending
          final sortedDates = groupedLifts.keys.toList()..sort((a, b) => b.compareTo(a));

          return ListView.builder(
            itemCount: sortedDates.length,
            itemBuilder: (context, index) {
              final date = sortedDates[index];
              final dayLifts = groupedLifts[date]!;

              // Sort lifts by time desc
              dayLifts.sort((a, b) => b.createdAt.compareTo(a.createdAt));

              return ExpansionTile(
                title: Text(date.format()), // E dd-MM-yyyy
                subtitle: Text("${dayLifts.length} lifts"),
                children: dayLifts.map((lift) {
                  return ListTile(
                    leading: lift.icon != null
                        ? Image.asset(lift.icon!, width: 24, height: 24)
                        : const Icon(Icons.cable),
                    title: Text(lift.name),
                    subtitle: Text(lift.type),
                    trailing: Text(lift.createdAt.toTimeString()),
                  );
                }).toList(),
              );
            },
          );
        },
      ),
    );
  }
}
