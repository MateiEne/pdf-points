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
  // static Future<List<Participant>> parseParticipantsFromExcel(String path) async {
  //   Uint8List bytes = File(path).readAsBytesSync();
  //
  //   return parseParticipantsExcel(bytes);
  // }

  // static Future<List<Participant>> parseParticipantsExcel(Uint8List bytes) async {
  //   var excel = Excel.decodeBytes(bytes);
  //
  //   List<Participant> participants = [];
  //
  //   Sheet pointsSheet = excel[kPoints];
  //   if (pointsSheet.maxRows == 0) {
  //     throw const ExcelParseException(message: "Could not find '$kPoints' sheet");
  //   }
  //
  //   var instructorsCell = _findCellWithValue(pointsSheet, kSkiAndSnowboardInstructors);
  //   instructorsCell ??= _findCellWithValue(pointsSheet, kSkiInstructors);
  //
  //   if (instructorsCell == null) {
  //     throw const ExcelParseException(
  //         message: "Could not find '$kSkiAndSnowboardInstructors' or '$kSkiInstructors' in '$kPoints' sheet");
  //   }
  //
  //   participants.addAll(
  //     _getParticipantsFromSheet(pointsSheet, instructorsCell),
  //   );
  //
  //   participants.addAll(_getInstructorsFromSheet(pointsSheet, instructorsCell));
  //
  //   return participants;
  // }

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

  // static List<Instructor> _getInstructorsFromSheet(Sheet sheet, Data instructorsCell) {
  //   var firstNameCell = _findCellWithValue(sheet, kFirstName, startRowIndex: instructorsCell.rowIndex + 1);
  //   if (firstNameCell == null) {
  //     throw const ExcelParseException(
  //         message: "Could not find '$kFirstName' column for the instructors table in '$kPoints' sheet");
  //   }
  //
  //   var lastNameCell = _findCellWithValue(sheet, kLastName, startRowIndex: instructorsCell.rowIndex + 1);
  //   if (lastNameCell == null) {
  //     throw const ExcelParseException(
  //         message: "Could not find '$kLastName' column for the instructors table in '$kPoints' sheet");
  //   }
  //
  //   var groupCell = _findCellWithValue(sheet, kGroup, startRowIndex: instructorsCell.rowIndex + 1);
  //
  //   List<Instructor> instructors = [];
  //
  //   for (int row = lastNameCell.rowIndex + 1; row < sheet.rows.length; row++) {
  //     var firstName = sheet.rows[row][firstNameCell.colIndex]?.value.toString();
  //     var lastName = sheet.rows[row][lastNameCell.colIndex]?.value.toString();
  //
  //     if (firstName == null && lastName == null) {
  //       break;
  //     }
  //
  //     var group = groupCell == null ? null : sheet.rows[row][groupCell.colIndex]?.value.toString();
  //
  //     instructors.add(
  //       Instructor(
  //         id: row.toString(),
  //         firstName: firstName,
  //         lastName: lastName,
  //         groupId: group == null ? row - lastNameCell.rowIndex : int.parse(group),
  //       ),
  //     );
  //   }
  //
  //   return instructors;
  // }

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
          id: row.toString(),
          firstName: firstName,
          lastName: lastName,
          // groupId: group == null ? null : int.tryParse(group),
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
      Participant(firstName: "Abel", lastName: "Pascariu", id: '1'),
      Participant(firstName: "Alin", lastName: "Bodnar", id: '2'),
      Participant(firstName: "Beni", lastName: "Radoi", id: '3'),
      Participant(firstName: "Cecilia Eliza", lastName: "Ciortea", id: '4'),
      Participant(firstName: "Cristian", lastName: "Raducan", id: '5'),
      Participant(firstName: "Cristiana Adina", lastName: "Salgau", id: '6'),
      Participant(firstName: "Eli", lastName: "Farkas", id: '7'),
      Participant(firstName: "Emanuela", lastName: "Mihai", id: '8'),
      Participant(firstName: "Johannes", lastName: "Turner", id: '9'),
      Participant(firstName: "Andreea", lastName: "Barbulescu", id: '10'),
      Participant(firstName: "Brigitta Melinda", lastName: "Pap", id: '11'),
      Participant(firstName: "Carla", lastName: "Petreanu", id: '12'),
      Participant(firstName: "Hajnalka", lastName: "Szasz", id: '13'),
      Participant(firstName: "Pavel", lastName: "Pamparau", id: '14'),
      Participant(firstName: "Alin Nathan", lastName: "Căbău", id: '15'),
      Participant(firstName: "Anca Delia", lastName: "Coroama", id: '16'),
      Participant(firstName: "Andrei", lastName: "Dinca", id: '17'),
      Participant(firstName: "Catalin Teodor", lastName: "Popescu", id: '18'),
      Participant(firstName: "Damaris", lastName: "Virtan", id: '19'),
      Participant(firstName: "Ela", lastName: "Crisan", id: '20'),
      Participant(firstName: "Emanuel", lastName: "Salgau", id: '21'),
      Participant(firstName: "Emanuela", lastName: "Dumitru", id: '22'),
      Participant(firstName: "Laura", lastName: "Luchian", id: '23'),
      Participant(firstName: "Naomi", lastName: "Petreanu", id: '24'),
      Participant(firstName: "Ovidiu", lastName: "Vătafu", id: '25'),
      Participant(firstName: "Silvia", lastName: "Vasiu", id: '26'),
      Participant(firstName: "Bianca", lastName: "Burdusel", id: '27'),
      Participant(firstName: "Christina", lastName: "Mihai", id: '28'),
      Participant(firstName: "Cristina", lastName: "Turda", id: '29'),
      Participant(firstName: "Dan Alexandru", lastName: "Dumitru", id: '30'),
      Participant(firstName: "Emanuel", lastName: "Danci", id: '31'),
      Participant(firstName: "Simona", lastName: "Vrenghea", id: '32'),
      Participant(firstName: "Alina", lastName: "Dumitrache", id: '33'),
      Participant(firstName: "Ana-Maria", lastName: "Cepoiu", id: '34'),
      Participant(firstName: "Cristina", lastName: "Pantazi", id: '35'),
      Participant(firstName: "Iulia", lastName: "Banu", id: '36'),
      Participant(firstName: "Mariana Mirela", lastName: "Popa", id: '37'),
      Participant(firstName: "Marta", lastName: "Arjan", id: '38'),
      Participant(firstName: "Ana", lastName: "Acomanoi", id: '39'),
      Participant(firstName: "Bogdan", lastName: "Iolu", id: '40'),
      Participant(firstName: "Clara Tabita", lastName: "Postatny", id: '41'),
      Participant(firstName: "Dina", lastName: "Ciurchea", id: '42'),
      Participant(firstName: "Ecaterina", lastName: "Enea", id: '43'),
      Participant(firstName: "Madalina", lastName: "Ilie", id: '44'),
      Participant(firstName: "Alin", lastName: "Ciortea", id: '45'),
      Participant(firstName: "Cristian", lastName: "Gazdac", id: '46'),
      Participant(firstName: "Cristian", lastName: "Nita", id: '47'),
      Participant(firstName: "David", lastName: "Constantinoiu", id: '48'),
      Participant(firstName: "David", lastName: "Fogorosiu", id: '49'),
      Participant(firstName: "Emanuel", lastName: "Chelu", id: '50'),
      Participant(firstName: "Emanuel", lastName: "Condria", id: '51'),
      Participant(firstName: "Emanuela", lastName: "Vlad", id: '52'),
      Participant(firstName: "Mioara", lastName: "Antonie", id: '53'),
      Participant(firstName: "Pele", lastName: "Ionut", id: '54'),
      Participant(firstName: "Corina", lastName: "Botean", id: '55'),
      Participant(firstName: "Florin", lastName: "Pojoga", id: '56'),
      Participant(firstName: "Andrei", lastName: "Hera", id: '57'),
      Participant(firstName: "Maria Paula", lastName: "Sinca", id: '58'),
      Participant(firstName: "Sabina Debora", lastName: "Stângă", id: '59'),
      Participant(firstName: "Elke", lastName: null, id: '60'),
    ];
  }
}
