import 'package:flutter/material.dart';
import 'package:pdf_points/data/participant.dart';
import 'package:pdf_points/utils/pdf_points_exel_parser.dart';
import 'package:pdf_points/utils/safe_setState.dart';

class SearchParticipantContent extends StatefulWidget {
  const SearchParticipantContent({super.key, required this.onSelected});

  final void Function(Participant participant) onSelected;

  @override
  State<SearchParticipantContent> createState() => _SearchParticipantContentState();
}

class _SearchParticipantContentState extends State<SearchParticipantContent> {
  List<Participant> _allParticipants = [];
  List<Participant> _showParticipants = [];

  bool _loadingParticipants = false;

  final TextEditingController _searchController = TextEditingController();

  @override
  void initState() {
    super.initState();

    _loadParticipants();

    _searchController.addListener(_filterParticipantsByName);
  }

  Future<void> _loadParticipants() async {
    safeSetState(() {
      _loadingParticipants = true;
    });

    try {
      // TODO: fetch participants from firebase
      // List<Participant> participants = await FirebaseService.getInstance().then((instance) => instance.fetchRegistrations());
      List<Participant> participants = PdfPointsExelParser.dummyListParticipants();
      participants = _sortParticipants(participants);

      safeSetState(() {
        _loadingParticipants = false;

        _allParticipants = participants;
        _resetShowParticipants();
      });
    } catch (e) {
      safeSetState(() {
        _loadingParticipants = false;
        // TODO: better error handling
        debugPrint(e.toString());
      });
    }
  }

  void _resetShowParticipants() {
    _showParticipants = _allParticipants;
  }

  List<Participant> _sortParticipants(List<Participant> participants) {
    participants.sort((a, b) => a.fullName.compareTo(b.fullName));

    return participants;
  }

  void _filterParticipantsByName() {
    safeSetState(() {
      String toSearch = _searchController.text.trim().toLowerCase();
      if (toSearch.isEmpty) {
        _resetShowParticipants();
        return;
      }

      _showParticipants = _allParticipants //
          .where((p) => p.fullName.toLowerCase().contains(toSearch))
          .toList();
    });
  }

  @override
  Widget build(BuildContext context) {
    return CustomScrollView(
      slivers: [
        SliverToBoxAdapter(
          child: TextField(
            controller: _searchController,
            decoration: InputDecoration(
              labelText: 'Search name',
              prefixIcon: const Icon(Icons.search),
              suffixIcon: IconButton(
                onPressed: _searchController.clear,
                icon: const Icon(Icons.clear),
              ),
            ),
          ),
        ),
        const SliverToBoxAdapter(
          child: SizedBox(height: 32),
        ),
        SliverList(
          delegate: SliverChildBuilderDelegate(
            childCount: _showParticipants.length,
            (BuildContext context, int index) {
              Participant participant = _showParticipants[index];
              return ListTile(
                title: Text(participant.fullName),
                subtitle: Text(participant.phone ?? "No phone number"),
                leading: Text(index.toString()),
              );
            },
          ),
        ),

        SliverToBoxAdapter(
          child: SizedBox(height: MediaQuery.of(context).viewInsets.bottom),
        ),
      ],
    );

    // return ListView.builder(
    //   shrinkWrap: true,
    //   physics: ClampingScrollPhysics(),
    //   itemCount: _showParticipants.length + 1,
    //   itemBuilder: (_, index) {
    //     if (index == 0) {
    //       // Search field
    //       return TextField(
    //         controller: _searchController,
    //         decoration: InputDecoration(
    //           labelText: 'Search name',
    //           prefixIcon: const Icon(Icons.search),
    //           suffixIcon: IconButton(
    //             onPressed: _searchController.clear,
    //             icon: const Icon(Icons.clear),
    //           ),
    //         ),
    //       );
    //     }
    //
    //     Participant participant = _showParticipants[index - 1];
    //     return ListTile(
    //       title: Text(participant.fullName),
    //       subtitle: Text(participant.phone ?? "No phone number"),
    //       trailing: Text(index.toString()),
    //     );
    //   },
    // );

    return SingleChildScrollView(
      child: Column(
        children: [
          // Search field
          TextField(
            controller: _searchController,
            decoration: InputDecoration(
              labelText: 'Search name',
              prefixIcon: const Icon(Icons.search),
              suffixIcon: IconButton(
                onPressed: _searchController.clear,
                icon: const Icon(Icons.clear),
              ),
            ),
          ),

          const SizedBox(height: 4),

          // Participants list
          Expanded(
            child: ListView.builder(
              itemCount: _showParticipants.length,
              physics: NeverScrollableScrollPhysics(),
              itemBuilder: (_, index) {
                Participant participant = _showParticipants[index];
                return ListTile(
                  title: Text(participant.fullName),
                  subtitle: Text(participant.phone ?? "No phone number"),
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}
