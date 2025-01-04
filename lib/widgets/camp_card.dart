import 'package:flutter/material.dart';
import 'package:pdf_points/data/camp.dart';
import 'package:pdf_points/utils/date_utils.dart';

class CampCard extends StatelessWidget {
  final Camp camp;

  const CampCard({super.key, required this.camp});

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.symmetric(vertical: 8.0, horizontal: 16.0),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12.0)),
      elevation: 4.0,
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Image
            Container(
              width: 80,
              height: 80,
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(8.0),
                color: Colors.grey[300],
              ),
              child: const Icon(
                Icons.image,
                size: 40,
                color: Colors.grey,
              ),
            ),
            const SizedBox(width: 16.0),
            // Camp details
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    camp.name,
                    style: Theme.of(context).textTheme.titleLarge,
                  ),
                  const SizedBox(height: 8.0),
                  Text(
                    "Start: ${camp.startDate.toLocal().toDateString()}",
                    style: Theme.of(context).textTheme.bodyMedium,
                  ),
                  Text(
                    "End: ${camp.endDate.toLocal().toDateString()}",
                    style: Theme.of(context).textTheme.bodyMedium,
                  ),
                  const SizedBox(height: 8.0),
                  Text(
                    "Instructors: ${camp.instructorsIds.length}",
                    style: Theme.of(context).textTheme.bodyMedium,
                  ),
                  Text(
                    "Participants: ${camp.numOfParticipants}",
                    style: Theme.of(context).textTheme.bodyMedium,
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
