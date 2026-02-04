import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:pdf_points/const/values.dart';
import 'package:pdf_points/data/pdf_user.dart';
import 'package:pdf_points/data/super_user.dart';
import 'package:pdf_points/view/pages/auth_check_screen.dart';
import 'firebase_options.dart';

final ColorScheme kColorScheme = ColorScheme.fromSeed(
  seedColor: kAppSeedColor,
);

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );

  // await DummyDataUtils.instance.addLiftValuePoints();

  runApp(const PdfPointsApp());
}

class PdfPointsApp extends StatelessWidget {
  const PdfPointsApp({super.key});

  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return ScreenUtilInit(
      designSize: const Size(375, 812),
      minTextAdapt: true,
      splitScreenMode: true,
      builder: (context, child) {
        return MaterialApp(
          title: 'PdF Points',
          debugShowCheckedModeBanner: false,
          theme: ThemeData().copyWith(
            colorScheme: kColorScheme,
            appBarTheme: const AppBarTheme().copyWith(
              backgroundColor: kColorScheme.onPrimaryContainer,
              foregroundColor: kColorScheme.onPrimary,
            ),
          ),
          home: const AuthCheckScreen(),
        );
      },
    );
  }
}
