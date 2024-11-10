import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';
import 'package:material_loading_buttons/material_loading_buttons.dart';
import 'package:pdf_points/data/participant.dart';
import 'package:pdf_points/errors/excel_parse_exception.dart';
import 'package:pdf_points/utils/context_utils.dart';
import 'package:pdf_points/utils/participants_exel_parser.dart';
import 'package:pdf_points/utils/platform_file_utils.dart';
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

    if (!mounted || pickedFile == null) {
      return;
    }

    if (pickedFile.files.isEmpty) {
      context.showToast("Empty selection", negative: true);
      return;
    }

    final fileBytes = pickedFile.files.first.getBytes();
    if (fileBytes == null) {
      context.showToast("Could not open the file", negative: true);
      return;
    }

    try {
      var participants = await ParticipantsExelParser.parseParticipantsExcel(fileBytes);
      safeSetState(() {
        _participants = participants;
      });
    } on ExcelParseException catch (e) {
      if (mounted) {
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
              ? ElevatedAutoLoadingButton(
                  onPressed: _selectFile,
                  child: const Text("Import participants excel"),
                )
              : Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    // Instructors
                    Expanded(
                      flex: 5,
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
