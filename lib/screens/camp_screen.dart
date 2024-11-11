import 'package:collection/collection.dart';
import 'package:data_table_2/data_table_2.dart';
import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';
import 'package:material_loading_buttons/material_loading_buttons.dart';
import 'package:pdf_points/const/values.dart';
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
      var participants = await ParticipantsExelParser.getParticipantsFromExcel(fileBytes);
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
                    // Students
                    Text(
                      'Participants: ${_participants.length}',
                      style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                    ),

                    const SizedBox(height: 8),

                    Expanded(
                      child: DataTable2(
                        headingRowColor: WidgetStateColor.resolveWith((states) => kAppSeedColor),
                        headingTextStyle: const TextStyle(color: Colors.white),
                        isHorizontalScrollBarVisible: true,
                        isVerticalScrollBarVisible: true,
                        columnSpacing: 6,
                        horizontalMargin: 0,
                        border: const TableBorder(
                            top: BorderSide(color: Colors.grey),
                            bottom: BorderSide(color: Colors.grey),
                            left: BorderSide(color: Colors.grey),
                            right: BorderSide(color: Colors.grey),
                            verticalInside: BorderSide(color: Colors.grey),
                            horizontalInside: BorderSide(color: Colors.grey, width: 1)),
                        dividerThickness: 1,
                        // this one will be ignored if [border] is set above
                        columns: const [
                          DataColumn2(
                            label: Text('No.'),
                            numeric: true,
                            fixedWidth: 32,
                          ),
                          DataColumn2(
                            label: Text('Group'),
                            size: ColumnSize.S,
                          ),
                          DataColumn2(
                            label: Text('Last Name'),
                            size: ColumnSize.L,
                          ),
                          DataColumn2(
                            label: Text('First Name'),
                            size: ColumnSize.L,
                          ),
                        ],
                        rows: _participants
                            .mapIndexed((index, p) => DataRow(
                                  color: WidgetStateColor.resolveWith(
                                      (states) => index.isEven ? kAppSeedColor.withOpacity(0.3) : Colors.white),
                                  cells: [
                                    DataCell(
                                      Text(
                                        "${index + 1}.",
                                        style: TextStyle(color: Colors.grey[600]),
                                      ),
                                    ),
                                    DataCell(
                                      Center(child: Text("${p.groupId ?? 'N/A'}")),
                                    ),
                                    DataCell(
                                      Text(p.lastName ?? 'N/A'),
                                    ),
                                    DataCell(
                                      Text(p.firstName ?? 'N/A'),
                                    ),
                                  ],
                                ))
                            .toList(),
                      ),
                    ),
                  ],
                ),
        ),
      ),
    );
  }
}
