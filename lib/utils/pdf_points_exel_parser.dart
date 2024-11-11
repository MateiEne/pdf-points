import 'dart:io';
import 'dart:typed_data';

import 'package:any_date/any_date.dart';
import 'package:flutter_excel/excel.dart';
import 'package:pdf_points/data/excel_camp_info.dart';
import 'package:pdf_points/data/participant.dart';
import 'package:pdf_points/errors/excel_parse_exception.dart';
import 'package:pdf_points/utils/date_utils.dart';

const kSkiInstructors = "Ski Instructors";
const kSkiAndSnowboardInstructors = "Ski & SB Instructors";
const kFirstName = "First Name";
const kLastName = "Last Name";
const kPoints = "Points";
const kGroup = "Group";
const kTotal = "Total";

class PdfPointsExelParser {
  static Future<List<Participant>> parseParticipantsFromExcel(String path) async {
    Uint8List bytes = File(path).readAsBytesSync();

    return parseParticipantsExcel(bytes);
  }

  static Future<List<Participant>> parseParticipantsExcel(Uint8List bytes) async {
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

    participants.addAll(
      _getParticipantsFromSheet(pointsSheet, instructorsCell),
    );

    participants.addAll(_getInstructorsFromSheet(pointsSheet, instructorsCell));

    return participants;
  }

  static Future<List<Participant>> getParticipantsFromExcel(Uint8List bytes) async {
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

    participants.addAll(
      _getParticipantsFromSheet(pointsSheet, instructorsCell),
    );

    return participants;
  }

  static Future<ExcelCampInfo> getCampInfoFromExcel(Uint8List bytes) async {
    var excel = Excel.decodeBytes(bytes);

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

    var campName = _getCampName(pointsSheet);
    var startDate = _getCampStartDate(pointsSheet);
    var endDate = _getCampEndDate(pointsSheet);
    List<Participant> participants = _getParticipantsFromSheet(pointsSheet, instructorsCell);

    return ExcelCampInfo(
      name: campName,
      startSkiDate: startDate,
      endSkiDate: endDate,
      participants: participants,
    );
  }

  static Data? _findCellWithValue(Sheet sheet, String value,
      {bool caseSensitive = false, int startRowIndex = 0, int endRowIndex = -1}) {
    if (endRowIndex == -1) {
      endRowIndex = sheet.rows.length;
    }

    for (var rowIndex = startRowIndex; rowIndex < endRowIndex; rowIndex++) {
      for (var cell in sheet.rows[rowIndex]) {
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

  static List<Participant> _getInstructorsFromSheet(Sheet sheet, Data instructorsCell) {
    var firstNameCell = _findCellWithValue(sheet, kFirstName, startRowIndex: instructorsCell.rowIndex + 1);
    if (firstNameCell == null) {
      throw const ExcelParseException(
          message: "Could not find '$kFirstName' column for the instructors table in '$kPoints' sheet");
    }

    var lastNameCell = _findCellWithValue(sheet, kLastName, startRowIndex: instructorsCell.rowIndex + 1);
    if (lastNameCell == null) {
      throw const ExcelParseException(
          message: "Could not find '$kLastName' column for the instructors table in '$kPoints' sheet");
    }

    var groupCell = _findCellWithValue(sheet, kGroup, startRowIndex: instructorsCell.rowIndex + 1);

    List<Participant> instructors = [];

    for (int row = lastNameCell.rowIndex + 1; row < sheet.rows.length; row++) {
      var firstName = sheet.rows[row][firstNameCell.colIndex]?.value.toString();
      var lastName = sheet.rows[row][lastNameCell.colIndex]?.value.toString();

      if (firstName == null && lastName == null) {
        break;
      }

      var group = groupCell == null ? null : sheet.rows[row][groupCell.colIndex]?.value.toString();

      instructors.add(
        Participant(
          firstName: firstName,
          lastName: lastName,
          groupId: group == null ? row - lastNameCell.rowIndex : int.parse(group),
          isInstructor: true,
        ),
      );
    }

    return instructors;
  }

  static List<Participant> _getParticipantsFromSheet(Sheet sheet, Data instructorsCell) {
    var lastNameCell = _findCellWithValue(sheet, kLastName);
    if (lastNameCell == null) {
      throw const ExcelParseException(
          message: "Could not find '$kLastName' column for the participants table in '$kPoints' sheet");
    }

    var firstNameCell = _findCellWithValue(sheet, kFirstName);
    if (firstNameCell == null) {
      throw const ExcelParseException(
          message: "Could not find '$kFirstName' column for the participants table in '$kPoints' sheet");
    }

    var groupCell = _findCellWithValue(sheet, kGroup);

    List<Participant> participants = [];

    for (int row = lastNameCell.rowIndex + 1; row < instructorsCell.rowIndex; row++) {
      var firstName = sheet.rows[row][firstNameCell.colIndex]?.value.toString();
      var lastName = sheet.rows[row][lastNameCell.colIndex]?.value.toString();

      if (firstName == null && lastName == null) {
        continue;
      }

      var group = groupCell == null ? null : sheet.rows[row][groupCell.colIndex]?.value.toString();

      participants.add(
        Participant(
          firstName: firstName,
          lastName: lastName,
          groupId: group == null ? null : int.tryParse(group),
        ),
      );
    }

    return participants;
  }

  static String _getCampName(Sheet sheet) {
    // in The PdF points chart excel the camp name is in the B1 cell
    return sheet.rows[0][1]!.value.toString();
  }

  static DateTime? _getCampStartDate(Sheet sheet) {
    // in The PdF points chart excel the camp start date is the right cell of the First name cell
    var firstNameCell = _findCellWithValue(sheet, kFirstName);
    if (firstNameCell == null) {
      throw const ExcelParseException(
          message: "Could not find '$kFirstName' column for the participants table in '$kPoints' sheet");
    }

    var campStartDateCell = sheet.rows[firstNameCell.rowIndex][firstNameCell.colIndex + 1];
    if (campStartDateCell == null) {
      throw const ExcelParseException(
          message:
              "Could not find the start date after the '$kFirstName' column for the participants table in '$kPoints' sheet");
    }
    var value = campStartDateCell.value.toString();

    // add the current year to the date (in the excel file the date is only the day and month)
    var estimateDate = "$value-${DateTime.now().year}";

    // parse the value
    const parser = AnyDate();
    var date = parser.parse(estimateDate);

    // check if the date is after the current date. If not, it means that we added the wrong year to the date.
    if (date.isBefore(DateTime.now())) {
      estimateDate = "$value-${DateTime.now().nextYear()}";
      date = parser.parse(estimateDate);
    }

    return date;
  }

  static DateTime? _getCampEndDate(Sheet sheet) {
    // in The PdF points chart excel the camp end date is the left cell of the Total cell from the First name row
    var firstNameCell = _findCellWithValue(sheet, kFirstName);
    if (firstNameCell == null) {
      throw const ExcelParseException(
          message: "Could not find '$kFirstName' column for the participants table in '$kPoints' sheet");
    }

    var totalCell = _findCellWithValue(sheet, kTotal,
        startRowIndex: firstNameCell.rowIndex, endRowIndex: firstNameCell.rowIndex + 1);
    if (totalCell == null) {
      throw const ExcelParseException(
          message: "Could not find '$kTotal' column for the participants table in '$kPoints' sheet");
    }

    var campEndDateCell = sheet.rows[totalCell.rowIndex][totalCell.colIndex - 1];
    if (campEndDateCell == null) {
      throw const ExcelParseException(
          message:
              "Could not find the end date before the '$kTotal' column for the participants table from '$kPoints' sheet");
    }
    var value = campEndDateCell.value.toString();

    // add the current year to the date (in the excel file the date is only the day and month)
    var estimateDate = "$value-${DateTime.now().year}";

    // parse the value
    const parser = AnyDate();
    var date = parser.parse(estimateDate);

    // check if the date is after the current date. If not, it means that we added the wrong year to the date.
    if (date.isBefore(DateTime.now())) {
      estimateDate = "$value-${DateTime.now().nextYear()}";
      date = parser.parse(estimateDate);
    }

    return date;
  }

  static List<Participant> dummyListParticipants() {
    return [
      Participant(firstName: "Abel", lastName: "Pascariu"),
      Participant(firstName: "Alin", lastName: "Bodnar"),
      Participant(firstName: "Beni", lastName: "Radoi"),
      Participant(firstName: "Cecilia Eliza", lastName: "Ciortea"),
      Participant(firstName: "Cristian", lastName: "Raducan"),
      Participant(firstName: "Cristiana Adina", lastName: "Salgau"),
      Participant(firstName: "Eli", lastName: "Farkas"),
      Participant(firstName: "Emanuela", lastName: "Mihai"),
      Participant(firstName: "Johannes", lastName: "Turner"),
      Participant(firstName: "Andreea", lastName: "Barbulescu"),
      Participant(firstName: "Brigitta Melinda", lastName: "Pap"),
      Participant(firstName: "Carla", lastName: "Petreanu"),
      Participant(firstName: "Hajnalka", lastName: "Szasz"),
      Participant(firstName: "Pavel", lastName: "Pamparau"),
      Participant(firstName: "Alin Nathan", lastName: "Căbău"),
      Participant(firstName: "Anca Delia", lastName: "Coroama"),
      Participant(firstName: "Andrei", lastName: "Dinca"),
      Participant(firstName: "Catalin Teodor", lastName: "Popescu"),
      Participant(firstName: "Damaris", lastName: "Virtan"),
      Participant(firstName: "Ela", lastName: "Crisan"),
      Participant(firstName: "Emanuel", lastName: "Salgau"),
      Participant(firstName: "Emanuela", lastName: "Dumitru"),
      Participant(firstName: "Laura", lastName: "Luchian"),
      Participant(firstName: "Naomi", lastName: "Petreanu"),
      Participant(firstName: "Ovidiu", lastName: "Vătafu"),
      Participant(firstName: "Silvia", lastName: "Vasiu"),
      Participant(firstName: "Bianca", lastName: "Burdusel"),
      Participant(firstName: "Christina", lastName: "Mihai"),
      Participant(firstName: "Cristina", lastName: "Turda"),
      Participant(firstName: "Dan Alexandru", lastName: "Dumitru"),
      Participant(firstName: "Emanuel", lastName: "Danci"),
      Participant(firstName: "Simona", lastName: "Vrenghea"),
      Participant(firstName: "Alina", lastName: "Dumitrache"),
      Participant(firstName: "Ana-Maria", lastName: "Cepoiu"),
      Participant(firstName: "Cristina", lastName: "Pantazi"),
      Participant(firstName: "Iulia", lastName: "Banu"),
      Participant(firstName: "Mariana Mirela", lastName: "Popa"),
      Participant(firstName: "Marta", lastName: "Arjan"),
      Participant(firstName: "Ana", lastName: "Acomanoi"),
      Participant(firstName: "Bogdan", lastName: "Iolu"),
      Participant(firstName: "Clara Tabita", lastName: "Postatny"),
      Participant(firstName: "Dina", lastName: "Ciurchea"),
      Participant(firstName: "Ecaterina", lastName: "Enea"),
      Participant(firstName: "Madalina", lastName: "Ilie"),
      Participant(firstName: "Alin", lastName: "Ciortea"),
      Participant(firstName: "Cristian", lastName: "Gazdac"),
      Participant(firstName: "Cristian", lastName: "Nita"),
      Participant(firstName: "David", lastName: "Constantinoiu"),
      Participant(firstName: "David", lastName: "Fogorosiu"),
      Participant(firstName: "Emanuel", lastName: "Chelu"),
      Participant(firstName: "Emanuel", lastName: "Condria"),
      Participant(firstName: "Emanuela", lastName: "Vlad"),
      Participant(firstName: "Mioara", lastName: "Antonie"),
      Participant(firstName: "Pele", lastName: "Ionut"),
      Participant(firstName: "Corina", lastName: "Botean"),
      Participant(firstName: "Florin", lastName: "Pojoga"),
      Participant(firstName: "Andrei", lastName: "Hera"),
      Participant(firstName: "Maria Paula", lastName: "Sinca"),
      Participant(firstName: "Sabina Debora", lastName: "Stângă"),
      Participant(firstName: "Elke", lastName: null),
    ];
  }
}
