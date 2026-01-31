import 'package:flutter/material.dart';
import 'package:pdf_points/data/lift_info.dart';

Color kAppSeedColor = const Color.fromARGB(255, 60, 100, 100);

const int kPasswordLength = 6;

const int kCampDaysLength = 5;

const double kPageWidthBreakpoint = 768.0;

const List<String> kDefaultCampImages = [
  "assets/images/defaultCampImages/adolescentsCamp.jpg",
  "assets/images/defaultCampImages/otherCamp.jpeg",
  "assets/images/defaultCampImages/skiCamp.jpg",
  "assets/images/defaultCampImages/skiTourCamp.jpg",
  "assets/images/defaultCampImages/snowboardCamp.jpg",
];

const String kGondola = "Gondola";
const String kChairlift = "Chairlift";
const String kSkilift = "Skilift";
const String kCableCar = "Cable Car";

const String kCableCarIcon = "assets/images/skilifts/cable-car-2.png";
const String kGondolaIcon = "assets/images/skilifts/gondola-1.png";
const String kChairliftIcon = "assets/images/skilifts/chairlift-1.png";
const String kSkiliftIcon = "assets/images/skilifts/skilift-2.png";

const List<String> kCableCars = [
  // order by exit elevation.
  "Capra Neagra (A)",
  "Kanzel (B)",
];

const List<String> kGondolas = [
  // order by exit elevation.
  "Postavaru Epress (C)",
];

const List<String> kChairlifts = [
  // order by exit elevation.
  "Ruia (J)",
  "Lupul (I)",
];


const List<String> kSkilifts= [
  // order by exit elevation.
  "Kanzel (E)",
  "Ruia (F)",
  "Subteleferic (G)",
  "Bradul (D)",
  "Stadion (H)"
];

extension LiftInfoExtension on LiftInfo {
  String? get icon => switch (type) {
        kCableCar => kCableCarIcon, 
        kGondola => kGondolaIcon,
        kChairlift => kChairliftIcon,
        kSkilift => kSkiliftIcon,
        _ => null
      };
}