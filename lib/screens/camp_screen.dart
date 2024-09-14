import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';
import 'package:pdf_points/data/participant.dart';
import 'package:pdf_points/errors/excel_parse_exception.dart';
import 'package:pdf_points/utils/context_utils.dart';
import 'package:pdf_points/utils/participants_exel_parser.dart';
import 'package:pdf_points/utils/safe_setState.dart';

class CampScreen extends StatefulWidget {
  const CampScreen({super.key});

  @override
  State<CampScreen> createState() => _CampScreenState();
}

class _CampScreenState extends State<CampScreen> {
  List<Participant> _participants = [];

  Future<void> _selectFile() async {
    FilePickerResult? pickedFile = await FilePicker.platform.pickFiles(
      type: FileType.custom,
      allowedExtensions: ['xlsx'],
      allowMultiple: false,
    );

    if (pickedFile == null) {
      return;
    }

    var path = pickedFile.files.first.path;
    if (path == null) {
      if (context.mounted) {
        context.showToast("Could not open the file", negative: true);
      }
      return;
    }

    try {
      var participants = await ParticipantsExelParser.parseParticipantsExcel(path);
      safeSetState(() {
        _participants = participants;
      });
    } on ExcelParseException catch (e) {
      if (context.mounted) {
        context.showToast(e.message, negative: true);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    // Filter instructors and students
    List<Participant> instructors = _participants.where((p) => p.isInstructor).toList();
    List<Participant> students = _participants.where((p) => !p.isInstructor).toList();

    return Scaffold(
      appBar: AppBar(
        title: const Text('Camp Name'),
        actions: const [],
      ),
      body: Padding(
        padding: const EdgeInsets.all(8.0),
        child: Center(
          child: _participants.isEmpty
              ? ElevatedButton(
                  onPressed: _selectFile,
                  child: const Text("Import participants excel"),
                )
              : Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    // Instructors
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Text(
                            'Instructors',
                            style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                          ),
                          Expanded(
                            child: ListView.builder(
                              itemCount: instructors.length,
                              itemBuilder: (context, index) {
                                return ListTile(
                                  title: Text('${instructors[index].firstName} ${instructors[index].lastName}'),
                                );
                              },
                            ),
                          ),
                        ],
                      ),
                    ),

                    const SizedBox(height: 16),

                    // Students
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Text(
                            'Participants',
                            style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                          ),
                          Expanded(
                            child: ListView.builder(
                              itemCount: students.length,
                              itemBuilder: (context, index) {
                                return ListTile(
                                  title: Text('${students[index].firstName} ${students[index].lastName}'),
                                );
                              },
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
        ),
      ),
    );
  }
}
