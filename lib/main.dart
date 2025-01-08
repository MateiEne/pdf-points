import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:pdf_points/const/values.dart';
import 'package:pdf_points/data/pdf_user.dart';
import 'package:pdf_points/data/super_user.dart';
import 'package:pdf_points/screens/instructor_home.dart';
import 'package:pdf_points/screens/login.dart';
import 'package:pdf_points/screens/splash.dart';
import 'package:pdf_points/screens/superuser_home.dart';
import 'package:pdf_points/services/firebase/firebase_manager.dart';

import 'data/participant.dart';
import 'firebase_options.dart';

final ColorScheme kColorScheme = ColorScheme.fromSeed(
  seedColor: kAppSeedColor,
);

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );

  runApp(const PdfPointsApp());
}

class PdfPointsApp extends StatelessWidget {
  const PdfPointsApp({super.key});

  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'PdF Points',
      theme: ThemeData().copyWith(
        colorScheme: kColorScheme,
        appBarTheme: const AppBarTheme().copyWith(
          backgroundColor: kColorScheme.onPrimaryContainer,
          foregroundColor: kColorScheme.onPrimary,
        ),
      ),
      home: FutureBuilder<PdFUser?>(
        future: FirebaseManager.instance.getCurrentPdfUser(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const SplashScreen();
          }

          if (snapshot.hasError || !snapshot.hasData || snapshot.data == null) {
            return const LoginScreen();
          }

          if (snapshot.data is SuperUser) {
            // navigate to super user screen
            return SuperUserHomeScreen(superUser: snapshot.data as SuperUser);
          } else {
            // navigate to instructor screen
            return InstructorHomeScreen(instructor: snapshot.data as Instructor);
          }
        },
      ),
    );
  }
}
