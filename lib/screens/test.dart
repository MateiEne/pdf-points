import 'package:flutter/material.dart';
import 'package:pdf_points/widgets/search_participant_content.dart';

class TestScreen extends StatelessWidget {
  const TestScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Test'),
      ),
      body: SearchParticipantContent(onSelected: (_){}),
    );
  }
}
