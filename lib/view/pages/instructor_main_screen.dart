import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:pdf_points/const/values.dart';
import 'package:pdf_points/data/participant.dart';
import 'package:pdf_points/view/pages/edit_lift_points.dart';
import 'package:pdf_points/view/pages/instructor_camp_screen.dart';
import 'package:pdf_points/view/pages/instructor_select_camp_screen.dart';
import 'package:pdf_points/view/pages/participants_screen.dart';

class InstructorMainScreen extends StatefulWidget {
  final Instructor instructor;

  const InstructorMainScreen({super.key, required this.instructor});

  @override
  State<InstructorMainScreen> createState() => _InstructorMainScreenState();
}

class _InstructorMainScreenState extends State<InstructorMainScreen> {
  int _selectedIndex = 2; // Start at Home

  final List<GlobalKey<NavigatorState>> _navigatorKeys = [
    GlobalKey<NavigatorState>(),
    GlobalKey<NavigatorState>(),
    GlobalKey<NavigatorState>(),
    GlobalKey<NavigatorState>(),
    GlobalKey<NavigatorState>(),
  ];

  void _onItemTapped(int index) {
    if (_selectedIndex == index) {
      // If tapping the active tab, pop to the first route
      _navigatorKeys[index].currentState?.popUntil((route) => route.isFirst);
    } else {
      setState(() {
        _selectedIndex = index;
      });
    }
  }

  Widget _buildNavigator(int index, Widget child) {
    return Navigator(
      key: _navigatorKeys[index],
      onGenerateRoute: (routeSettings) {
        return MaterialPageRoute(
          builder: (context) => child,
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return PopScope(
      canPop: false,
      onPopInvokedWithResult: (didPop, result) async {
        if (didPop) {
          return;
        }

        final NavigatorState? navigator = _navigatorKeys[_selectedIndex].currentState;
        if (navigator != null && navigator.canPop()) {
          navigator.pop();
          return;
        }

        if (_selectedIndex != 2) {
          setState(() {
            _selectedIndex = 2;
          });
          return;
        }

        // Exit the app
        SystemNavigator.pop();
      },
      child: Scaffold(
        body: IndexedStack(
          index: _selectedIndex,
          children: [
            _buildNavigator(0, const Scaffold(body: Center(child: Text("Map Screen")))),
            _buildNavigator(
              1,
              InstructorSelectCampScreen(
                instructor: widget.instructor,
                onCampSelected: (camp, hasMultiCamp) {
                  final route = MaterialPageRoute(
                    builder: (context) => ParticipantsScreen(campId: camp.id),
                  );
                  if (hasMultiCamp) {
                    _navigatorKeys[1].currentState?.push(route);
                  } else {
                    _navigatorKeys[1].currentState?.pushReplacement(route);
                  }
                },
              ),
            ),
            _buildNavigator(
              2,
              InstructorSelectCampScreen(
                instructor: widget.instructor,
                onCampSelected: (camp, hasMultiCamp) {
                  final route = MaterialPageRoute(
                    builder: (context) => InstructorCampScreen(
                      instructor: widget.instructor,
                      camp: camp,
                    ),
                  );
                  if (hasMultiCamp) {
                    _navigatorKeys[2].currentState?.push(route);
                  } else {
                    _navigatorKeys[2].currentState?.pushReplacement(route);
                  }
                },
              ),
            ),
            _buildNavigator(3, EditLiftPointsScreen(instructor: widget.instructor)),
            _buildNavigator(4, const Scaffold(body: Center(child: Text("More Screen")))),
          ],
        ),
        bottomNavigationBar: BottomNavigationBar(
          type: BottomNavigationBarType.fixed,
          items: const <BottomNavigationBarItem>[
            BottomNavigationBarItem(
              icon: Icon(Icons.map),
              label: 'Map',
            ),
            BottomNavigationBarItem(
              icon: Icon(Icons.people),
              label: 'Participants',
            ),
            BottomNavigationBarItem(
              icon: Icon(Icons.home),
              label: 'Home',
            ),
            BottomNavigationBarItem(
              icon: Icon(Icons.edit),
              label: 'Edit Lifts',
            ),
            BottomNavigationBarItem(
              icon: Icon(Icons.more_horiz),
              label: 'More',
            ),
          ],
          currentIndex: _selectedIndex,
          selectedItemColor: kAppSeedColor,
          onTap: _onItemTapped,
        ),
      ),
    );
  }
}
