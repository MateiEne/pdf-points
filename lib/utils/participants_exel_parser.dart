import 'dart:io';

import 'package:flutter_excel/excel.dart';
import 'package:pdf_points/data/participant.dart';
import 'package:pdf_points/errors/excel_parse_exception.dart';

const kSkiInstructors = "Ski Instructors";
const kSkiAndSnowboardInstructors = "Ski & SB Instructors";
const kFirstName = "First Name";
const kLastName = "Last Name";
const kPoints = "Points";
const kGroup = "Group";

class ParticipantsExelParser {
  static Future<List<Participant>> parseParticipantsExcel(String path) async {
    var bytes = File(path).readAsBytesSync();
    var excel = Excel.decodeBytes(bytes);

    List<Participant> participants = [];

    Sheet pointsSheet = excel[kPoints];
    if (pointsSheet.maxRows == 0) {
      throw const ExcelParseException(message: "Could not find '$kPoints' sheet");
    }

    var instructorsCell = _findCellWithValue(pointsSheet, kSkiAndSnowboardInstructors);
    instructorsCell ??= _findCellWithValue(pointsSheet, kSkiInstructors);

    if (instructorsCell == null) {
      throw const ExcelParseException(
          message: "Could not find '$kSkiAndSnowboardInstructors' or '$kSkiInstructors' in '$kPoints' sheet");
    }

    print(instructorsCell);

    var firstNameCell = _findCellWithValue(pointsSheet, kFirstName);
    if (firstNameCell == null) {
      throw const ExcelParseException(
          message: "Could not find '$kFirstName' column in the participants table in '$kPoints' sheet");
    }

    var lastNameCell = _findCellWithValue(pointsSheet, kLastName);
    if (lastNameCell == null) {
      throw const ExcelParseException(
          message: "Could not find '$kLastName' column in the participants table in '$kPoints' sheet");
    }

    var groupCell = _findCellWithValue(pointsSheet, kGroup);

    print(firstNameCell);
    print(lastNameCell);

    for (int row = lastNameCell.rowIndex + 1; row < instructorsCell.rowIndex; row++) {
      var firstName = pointsSheet.rows[row][firstNameCell.colIndex]?.value.toString();
      var lastName = pointsSheet.rows[row][lastNameCell.colIndex]?.value.toString();

      if (firstName == null && lastName == null) {
        continue;
      }

      var group = groupCell == null ? null : pointsSheet.rows[row][groupCell.colIndex]?.value.toString();
      print("Group: $group, firstName: $firstName, lastName: $lastName");

      participants.add(
        Participant(
          firstName: firstName,
          lastName: lastName,
          groupId: group == null ? null : int.parse(group),
        ),
      );
    }

    return participants;
  }

  static Data? _findCellWithValue(Sheet sheet, String value, {bool caseSensitive = false}) {
    for (var row in sheet.rows) {
      for (var cell in row) {
        if (cell == null) {
          continue;
        }

        var cellValue = cell.value.toString();
        if (caseSensitive ? cellValue == value : cellValue.toLowerCase() == value.toLowerCase()) {
          return cell;
        }
      }
    }

    return null;
  }
}
