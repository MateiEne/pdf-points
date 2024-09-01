import 'dart:io';

import 'package:excel/excel.dart';
import 'package:pdf_points/data/participant.dart';

class ParticipantsExelParser {
  static Future<List<Participant>> parseParticipantsExcel(String path) async {
    var bytes = File(path).readAsBytesSync();
    var excel = Excel.decodeBytes(bytes);

    List<Participant> participants = [];

    Sheet pointsSheet = excel['Points'];

    //pointsSheet.cell(CellIndex.indexByString("A1")).value;

    var firstNameCell = _findCellWithValue(pointsSheet, "First Name");
    var lastNameCell = _findCellWithValue(pointsSheet, "Last Name");

    print(firstNameCell);
    print(lastNameCell);


    return participants;
  }

  static Data? _findCellWithValue(Sheet sheet, String value) {
    for (var row in sheet.rows) {
      for (var cell in row) {
        if (cell != null && cell.value.toString() == value) {
          return cell;
        }
      }
    }

    return null;
  }
}