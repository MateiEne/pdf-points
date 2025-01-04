import 'package:collection/collection.dart';
import 'package:data_table_2/data_table_2.dart';
import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';
import 'package:material_loading_buttons/material_loading_buttons.dart';
import 'package:pdf_points/const/values.dart';
import 'package:pdf_points/data/camp.dart';
import 'package:pdf_points/data/participant.dart';
import 'package:pdf_points/errors/excel_parse_exception.dart';
import 'package:pdf_points/services/firebase/firebase_manager.dart';
import 'package:pdf_points/utils/context_utils.dart';
import 'package:pdf_points/utils/pdf_points_exel_parser.dart';
import 'package:pdf_points/utils/platform_file_utils.dart';
import 'package:pdf_points/utils/safe_setState.dart';

class CampScreen extends StatefulWidget {
  final Camp camp;

  const CampScreen({super.key, required this.camp});

  @override
  State<CampScreen> createState() => _CampScreenState();
}

class _CampScreenState extends State<CampScreen> {
  bool _isLoading = true;
  late List<Participant> _participants = [];

  @override
  void initState() {
    super.initState();

    _startFirebaseEvents();
  }

  Future<void> _startFirebaseEvents() async {
    _fetchParticipants();
    // TODO: Listen to participants changes
    //_listenToParticipantsChanges();
  }

  Future<void> _fetchParticipants() async {
    safeSetState(() {
      _isLoading = true;
    });

    try {
      List<Participant> participants = await FirebaseManager.instance.fetchParticipantsForCamp(widget.camp.id);
      participants = _sortParticipants(participants);

      safeSetState(() {
        _isLoading = false;

        _participants = participants;
      });
    } catch (e) {
      safeSetState(() {
        _isLoading = false;
        // TODO: better error handling
        debugPrint(e.toString());
      });
    }
  }

  List<Participant> _sortParticipants(List<Participant> participants) {
    participants.sort((a, b) => a.id.compareTo(b.id));

    return participants.toList();
  }

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
      var participants = await PdfPointsExelParser.getParticipantsFromExcel(fileBytes);
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
        title: Text(widget.camp.name),
        actions: const [],
      ),
      body: Padding(
        padding: const EdgeInsets.all(8.0),
        child: Center(
          child: _isLoading
              ? const CircularProgressIndicator()
              : _participants.isEmpty
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
