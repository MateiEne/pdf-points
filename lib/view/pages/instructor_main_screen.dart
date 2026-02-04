import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:pdf_points/const/values.dart';
import 'package:pdf_points/data/participant.dart';
import 'package:pdf_points/view/mixins/resumable_state.dart';
import 'package:pdf_points/view/pages/edit_lift_points.dart';
import 'package:pdf_points/view/pages/instructor_ski_group_screen.dart';
import 'package:pdf_points/data/camp.dart';
import 'package:pdf_points/view/pages/participants_screen.dart';

class InstructorMainScreen extends StatefulWidget {
  final Instructor instructor;
  final Camp camp;

  const InstructorMainScreen({super.key, required this.instructor, required this.camp});

  @override
  State<InstructorMainScreen> createState() => _InstructorMainScreenState();
}

class _InstructorMainScreenState extends State<InstructorMainScreen> {
  int _selectedIndex = 1; // Start at Home

  final List<GlobalKey<NavigatorState>> _navigatorKeys = [
    GlobalKey<NavigatorState>(),
    GlobalKey<NavigatorState>(),
    GlobalKey<NavigatorState>(),
    GlobalKey<NavigatorState>(),
    GlobalKey<NavigatorState>(),
  ];

  final Map<int, GlobalKey<ResumableState>> _resumableKeys = {
    3: GlobalKey<ResumableState>(),
  };

  void _onItemTapped(int index) {
    if (_selectedIndex == index) {
      // If tapping the active tab, pop to the first route
      _navigatorKeys[index].currentState?.popUntil((route) => route.isFirst);
    } else {
      setState(() {
        _selectedIndex = index;
      });

      // Call onResume on the selected tab's state.
      // This is necessary because IndexedStack preserves the state of its children,
      // so initState is not called again when switching tabs.
      // onResume allows the screen to refresh its data (e.g. re-fetch from Firebase).
      _resumableKeys[index]?.currentState?.onResume();
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
              ParticipantsScreen(campId: widget.camp.id),
            ),
            _buildNavigator(
              2,
              InstructorSkiGroupScreen(
                instructor: widget.instructor,
                camp: widget.camp,
              ),
            ),
            _buildNavigator(
              3,
              EditLiftPointsScreen(
                key: _resumableKeys[3],
                instructor: widget.instructor,
              ),
            ),
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
