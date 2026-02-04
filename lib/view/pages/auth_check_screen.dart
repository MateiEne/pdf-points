import 'package:flutter/material.dart';
import 'package:pdf_points/data/participant.dart';
import 'package:pdf_points/data/super_user.dart';
import 'package:pdf_points/services/firebase/firebase_manager.dart';
import 'package:pdf_points/view/pages/instructor_select_camp_screen.dart';
import 'package:pdf_points/view/pages/instructor_main_screen.dart';
import 'package:pdf_points/view/pages/login.dart';
import 'package:pdf_points/view/pages/splash.dart';
import 'package:pdf_points/view/pages/superuser_home.dart';

class AuthCheckScreen extends StatefulWidget {
  const AuthCheckScreen({super.key});

  @override
  State<AuthCheckScreen> createState() => _AuthCheckScreenState();
}

class _AuthCheckScreenState extends State<AuthCheckScreen> {
  @override
  void initState() {
    super.initState();
    _checkAuth();
  }

  Future<void> _checkAuth() async {
    final user = await FirebaseManager.instance.getCurrentPdfUser();

    if (!mounted) return;

    if (user == null) {
      Navigator.of(context).pushReplacement(MaterialPageRoute(builder: (_) => const LoginScreen()));
      return;
    }

    if (user is SuperUser) {
      Navigator.of(context).pushReplacement(MaterialPageRoute(builder: (_) => SuperUserHomeScreen(superUser: user)));
      return;
    }

    if (user is Instructor) {
      try {
        final activeCamps = await FirebaseManager.instance.fetchActiveCampsForInstructor(instructorId: user.id);
        if (!mounted) return;

        if (activeCamps.length == 1) {
          Navigator.of(context).pushReplacement(
            MaterialPageRoute(builder: (_) => InstructorMainScreen(instructor: user, camp: activeCamps.first)),
          );
        } else {
          Navigator.of(context).pushReplacement(
            MaterialPageRoute(builder: (_) => InstructorSelectCampScreen(instructor: user)),
          );
        }
      } catch (e) {
        if (!mounted) return;
        Navigator.of(context).pushReplacement(
          MaterialPageRoute(builder: (_) => InstructorSelectCampScreen(instructor: user)),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return const SplashScreen();
  }
}
