import 'dart:async';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:pdf_points/data/camp.dart';
import 'package:pdf_points/data/super_user.dart';
import 'package:pdf_points/screens/camp_screen.dart';
import 'package:pdf_points/services/firebase/firebase_manager.dart';
import 'package:pdf_points/utils/safe_setState.dart';
import 'package:pdf_points/widgets/add_camp_fab.dart';
import 'package:pdf_points/widgets/camp_card.dart';

class SuperUserHomeScreen extends StatefulWidget {
  final SuperUser superUser;

  const SuperUserHomeScreen({super.key, required this.superUser});

  @override
  State<SuperUserHomeScreen> createState() => _SuperUserHomeScreenState();
}

class _SuperUserHomeScreenState extends State<SuperUserHomeScreen> {
  bool _isLoading = false;
  List<Camp> _camps = [];

  StreamSubscription? _campChangedSubscription;

  @override
  void initState() {
    super.initState();

    _startFirebaseEvents();
  }

  Future<void> _startFirebaseEvents() async {
    _fetchCamps();
    _listenToCampChanges();
  }

  Future<void> _fetchCamps() async {
    safeSetState(() {
      _isLoading = true;
    });

    try {
      List<Camp> camps = await FirebaseManager.instance.fetchCamps();
      camps = _sortCamps(camps);

      safeSetState(() {
        _isLoading = false;

        _camps = camps;
      });
    } catch (e) {
      safeSetState(() {
        _isLoading = false;
        // TODO: better error handling
        debugPrint(e.toString());
      });
    }
  }

  Future<void> _listenToCampChanges() async {
    _campChangedSubscription = FirebaseManager.instance.campChangedStream.listen(
      (change) {
        switch (change.type) {
          case DocumentChangeType.added:
          case DocumentChangeType.modified:

            safeSetState(() {
              _camps.removeWhere((w) => w.id == change.object.id);
              _camps.add(change.object);
              _camps = _sortCamps(_camps);
            });
            break;
          case DocumentChangeType.removed:
            safeSetState(() {
              _camps.removeWhere((w) => w.id == change.object.id);
            });
            break;
        }
      },
    );
  }

  List<Camp> _sortCamps(List<Camp> camps) {
    camps.sort((a, b) => a.startDate.compareTo(b.startDate));

    return camps.toList();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Home'),
        actions: [
          IconButton(
            onPressed: () {
              FirebaseManager.instance.signOut();
            },
            icon: const Icon(Icons.logout),
          ),
        ],
      ),
      drawer: const Drawer(),
      body: RefreshIndicator(
        onRefresh: _fetchCamps,
        child: Center(
          child: _isLoading
              ? const CircularProgressIndicator()
              : ListView.builder(
                  padding: const EdgeInsets.symmetric(vertical: 8.0),
                  itemCount: _camps.length,
                  itemBuilder: (context, index) {
                    return InkWell(
                      onTap: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) => CampScreen(camp: _camps[index]),
                          ),
                        );
                      },
                      child: CampCard(camp: _camps[index]),
                    );
                  },
                ),
        ),
      ),
      floatingActionButtonLocation: AddCampFab.location,
      floatingActionButton: const AddCampFab(),
    );
  }

  @override
  void dispose() {
    _campChangedSubscription?.cancel();

    super.dispose();
  }
}
