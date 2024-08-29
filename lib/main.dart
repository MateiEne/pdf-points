import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:pdf_points/screens/auth.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:pdf_points/screens/home.dart';
import 'package:pdf_points/screens/splash.dart';
import 'firebase_options.dart';

final ColorScheme kColorScheme = ColorScheme.fromSeed(
  seedColor: const Color.fromARGB(255, 60, 100, 100),
);

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );

  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

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
      // the existence of an auth token proves that the user provided valid data => the user did log in => show a different screen
      // also that token will be stored on the device, and that storage will be managed by firebase => if the user starts the app again
      // after he logged in, will be another screen shown, not the AuthScreen again (if the user logged in in the past, he will remain logged in)

      // similar to the FutureBuilder widget -> takes a stream and then will build a certain widget tree once that stream will emit a new value
      // this builder gives a snapshot that gives you info about the current state of the stream
      // the difference between a future and a stream is that a future will be done once it resolved => will only ever produce one value or error
      // a stream is capable of producing multiple values over time
      home: StreamBuilder(
        // here a listener is setup that is managed by the firebase SDK, and firebase will emit a new value whenever
        // anything auth related changes (e.g. a token becomes available, or is removed if the user logs out)
        stream: FirebaseAuth.instance.authStateChanges(),
        builder: (BuildContext context, AsyncSnapshot<dynamic> snapshot) {
          // snapshot will be a user data package, you could say, created and emitted by firebase
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const SplashScreen();
          }

          if (snapshot.hasData) {
            // snapshot.hasData -> this means that i have that token, the user did log in
            return const HomeScreen();
          }

          return const AuthScreen();
        },
      ),
    );
  }
}
