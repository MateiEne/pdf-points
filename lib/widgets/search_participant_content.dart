import 'package:flutter/material.dart';
import 'package:pdf_points/data/participant.dart';
import 'package:pdf_points/modals/add_participant.dart';
import 'package:pdf_points/utils/pdf_points_exel_parser.dart';
import 'package:pdf_points/utils/safe_setState.dart';

class SearchParticipantContent extends StatefulWidget {
  const SearchParticipantContent({
    super.key,
    required this.onSelected,
    this.excludeGroupId,
    this.addParticipantIfNotFound = true,
  });

  final void Function(Participant participant) onSelected;
  final int? excludeGroupId;
  final bool addParticipantIfNotFound;

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
      if (widget.excludeGroupId != null) {
        participants = participants.where((p) => p.groupId != widget.excludeGroupId).toList();
      }
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

  void _openAddParticipantModal() {
    var indexOfSpace = _searchController.text.indexOf(' ');
    var firstName = indexOfSpace == -1 ? _searchController.text : _searchController.text.substring(0, indexOfSpace);
    var lastName = indexOfSpace == -1 ? '' : _searchController.text.substring(indexOfSpace + 1);

    AddParticipantModal.show(
      context: context,
      onAddParticipant: _onAddParticipant,
      defaultFirstName: firstName,
      defaultLastName: lastName,
    );
  }

  Future<void> _onAddParticipant(
    BuildContext modalSheetContext,
    String firstName,
    String lastName,
    String phone,
  ) async {
    // TODO: add participant to firebase:
    // FirebaseManager.instance.addParticipantToSkiGroup(
    //   ...
    // );
    await Future.delayed(const Duration(seconds: 1));
    var participant = Participant(id: '1', firstName: firstName, lastName: lastName, phone: phone);
    _allParticipants.add(participant);
    _allParticipants = _sortParticipants(_allParticipants);

    safeSetState(() {
      _allParticipants = _allParticipants;
      _filterParticipantsByName();
    });

    if (!modalSheetContext.mounted) return;

    Navigator.of(modalSheetContext).pop();

    widget.onSelected(participant);
  }

  @override
  Widget build(BuildContext context) {
    return CustomScrollView(
      slivers: [
        // Search field
        SliverToBoxAdapter(
          child: TextField(
            controller: _searchController,
            decoration: InputDecoration(
              labelText: 'Search name',
              prefixIcon: const Icon(Icons.search),
              suffixIcon: _searchController.text.isNotEmpty
                  ? IconButton(
                      onPressed: _searchController.clear,
                      icon: const Icon(Icons.clear),
                    )
                  : null,
            ),
          ),
        ),

        const SliverToBoxAdapter(
          child: SizedBox(height: 32),
        ),

        // Participants list
        _loadingParticipants
            ? const SliverToBoxAdapter(
                child: Center(child: CircularProgressIndicator()),
              )
            : SliverList(
                delegate: SliverChildBuilderDelegate(
                  childCount: _showParticipants.length + 1,
                  (BuildContext context, int index) {
                    if (index == _showParticipants.length) {
                      return widget.addParticipantIfNotFound
                          ? TextButton(
                              onPressed: _openAddParticipantModal,
                              child: const Text('Add Participant'),
                            )
                          : const SizedBox.shrink();
                    }

                    Participant participant = _showParticipants[index];
                    return ListTile(
                      title: Text(participant.fullName),
                      subtitle: Text(participant.phone ?? "No phone number"),
                      leading: Text("${index + 1}"),
                      onTap: () => widget.onSelected(participant),
                    );
                  },
                ),
              ),

        // Bottom padding for keyboard
        SliverToBoxAdapter(
          child: SizedBox(height: MediaQuery.of(context).viewInsets.bottom),
        ),
      ],
    );
  }
}
