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

    participants.addAll(
      _getParticipantsFromSheet(pointsSheet, instructorsCell),
    );

    participants.addAll(
      _getInstructorsFromSheet(pointsSheet, instructorsCell)
    );

    return participants;
  }

  static Data? _findCellWithValue(Sheet sheet, String value, {bool caseSensitive = false, startRowIndex = 0}) {
    for (var rowIndex = startRowIndex; rowIndex < sheet.rows.length; rowIndex++) {
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
    var firstNameCell = _findCellWithValue(sheet, kFirstName);
    if (firstNameCell == null) {
      throw const ExcelParseException(
          message: "Could not find '$kFirstName' column for the participants table in '$kPoints' sheet");
    }

    var lastNameCell = _findCellWithValue(sheet, kLastName);
    if (lastNameCell == null) {
      throw const ExcelParseException(
          message: "Could not find '$kLastName' column for the participants table in '$kPoints' sheet");
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
          groupId: group == null ? null : int.parse(group),
        ),
      );
    }

    return participants;
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
