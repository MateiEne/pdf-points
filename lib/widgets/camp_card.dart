import 'package:flutter/material.dart';
import 'package:pdf_points/data/camp.dart';
import 'package:pdf_points/services/firebase/firebase_manager.dart';
import 'package:pdf_points/utils/date_utils.dart';

class CampCard extends StatefulWidget {
  final Camp camp;

  const CampCard({
    super.key,
    required this.camp,
  });

  @override
  State<CampCard> createState() => _CampCardState();
}

class _CampCardState extends State<CampCard> {
  bool _loadingParticipantsCount = false;
  int _participantsCount = 0;

  @override
  void initState() {
    super.initState();

    _startFirebaseEvents();
  }

  Future<void> _startFirebaseEvents() async {
    _fetchParticipantsCount();
    _listenToParticipantsCountChanges();
  }

  Future<void> _fetchParticipantsCount() async {
    setState(() {
      _loadingParticipantsCount = true;
    });

    var count = await FirebaseManager.instance.fetchParticipantsCountForCamp(campId: widget.camp.id);

    setState(() {
      _participantsCount = count;
      _loadingParticipantsCount = false;
    });
  }

  void _listenToParticipantsCountChanges() {
    FirebaseManager.instance.listenToParticipantsCountChanges(
      campId: widget.camp.id,
      onParticipantsCountChanged: (count) {
        setState(() {
          _participantsCount = count;
        });
      },
    );
  }

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
                    widget.camp.name,
                    style: Theme.of(context).textTheme.titleLarge,
                  ),
                  const SizedBox(height: 8.0),
                  Text(
                    "Start: ${widget.camp.startDate.toLocal().toDateString()}",
                    style: Theme.of(context).textTheme.bodyMedium,
                  ),
                  Text(
                    "End: ${widget.camp.endDate.toLocal().toDateString()}",
                    style: Theme.of(context).textTheme.bodyMedium,
                  ),
                  const SizedBox(height: 8.0),
                  Text(
                    "Instructors: ${widget.camp.instructorsIds.length}",
                    style: Theme.of(context).textTheme.bodyMedium,
                  ),
                  Row(
                    children: [
                      Text(
                        "Participants: ",
                        style: Theme.of(context).textTheme.bodyMedium,
                      ),
                      if (_loadingParticipantsCount)
                        Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 4.0),
                          child: SizedBox(
                            width: Theme.of(context).textTheme.bodyMedium?.fontSize ?? 10,
                            height: Theme.of(context).textTheme.bodyMedium?.fontSize ?? 10,
                            child: const CircularProgressIndicator(strokeWidth: 2),
                          ),
                        )
                      else
                        Text(
                          "$_participantsCount",
                          style: Theme.of(context).textTheme.bodyMedium,
                        ),
                    ],
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
