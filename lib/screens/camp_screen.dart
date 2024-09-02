import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';
import 'package:pdf_points/errors/excel_parse_exception.dart';
import 'package:pdf_points/utils/context_utils.dart';
import 'package:pdf_points/utils/participants_exel_parser.dart';

class CampScreen extends StatefulWidget {
  const CampScreen({super.key});

  @override
  State<CampScreen> createState() => _CampScreenState();
}

class _CampScreenState extends State<CampScreen> {
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
      // var participants = await ParticipantsExelParser.dummyListParticipants();
    } on ExcelParseException catch (e) {
      if (context.mounted) {
        context.showToast(e.message, negative: true);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Camp Name'),
        actions: const [],
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            ElevatedButton(
              onPressed: _selectFile,
              child: const Text("Import participants excel"),
            )
          ],
        ),
      ),
    );
  }
}
