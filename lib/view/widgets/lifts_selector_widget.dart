import 'package:contained_tab_bar_view/contained_tab_bar_view.dart';
import 'package:flutter/material.dart';
import 'package:pdf_points/const/values.dart';
import 'package:pdf_points/utils/safe_setState.dart';

class LiftsSelectorWidget extends StatefulWidget {
  const LiftsSelectorWidget({
    super.key,
    required this.onLiftSelected,
    this.defaultLift,
  });

  final void Function(String lift, String liftType) onLiftSelected;
  final String? defaultLift;

  @override
  State<LiftsSelectorWidget> createState() => _LiftsSelectorWidgetState();
}

class _LiftsSelectorWidgetState extends State<LiftsSelectorWidget> {
  int _selectedLiftIndex = 0;
  int _tabIndex = 0;

  @override
  void initState() {
    super.initState();

    setDefaultLift(widget.defaultLift);
  }

  void setDefaultLift(String? defaultLift) {
    if (defaultLift == null) {
      _selectedLiftIndex = 0;
      _tabIndex = 0;
    } else if (kCableCars.contains(defaultLift)) {
      _tabIndex = 0;
      _selectedLiftIndex = kCableCars.indexOf(defaultLift);
    } else if (kGondolas.contains(defaultLift)) {
      _tabIndex = 1;
      _selectedLiftIndex = kGondolas.indexOf(defaultLift);
    } else if (kChairlifts.contains(defaultLift)) {
      _tabIndex = 2;
      _selectedLiftIndex = kChairlifts.indexOf(defaultLift);
    } else if (kSkilifts.contains(defaultLift)) {
      _tabIndex = 3;
      _selectedLiftIndex = kSkilifts.indexOf(defaultLift);
    } else {
      _selectedLiftIndex = 0;
      _tabIndex = 0;
    }

    _onLiftSelected();
  }

  Widget _buildList(List<String> lifts) {
    final ScrollController scrollController = ScrollController();
    return Column(
      children: [
        Divider(
          height: 2,
          thickness: 2,
          color: kAppSeedColor,
        ),
        Expanded(
          child: Scrollbar(
            controller: scrollController,
            thumbVisibility: true,
            trackVisibility: true,
            child: ListView.builder(
              // use shrinkWrap: true since the listview has maximum 5 items
              shrinkWrap: true,
              controller: scrollController,
              itemCount: lifts.length,
              itemBuilder: (context, index) {
                return ListTile(
                  title: Text(
                    lifts[index],
                    style: _selectedLiftIndex == index //
                        ? const TextStyle(fontWeight: FontWeight.bold)
                        : null,
                  ),
                  selectedTileColor: kAppSeedColor.withValues(alpha: 0.2),
                  selected: _selectedLiftIndex == index,
                  leading: Radio<int>(
                    value: index,
                    groupValue: _selectedLiftIndex,
                    onChanged: _onSelectedLiftIndexChanged,
                  ),
                  onTap: () => _onSelectedLiftIndexChanged(index),
                );
              },
            ),
          ),
        ),
      ],
    );
  }

  void _onSelectedLiftIndexChanged(int? index) {
    if (index == null) return;

    safeSetState(() {
      _selectedLiftIndex = index;
    });

    _onLiftSelected();
  }

  void _onLiftSelected() {
    switch (_tabIndex) {
      case 0:
        widget.onLiftSelected(kCableCars[_selectedLiftIndex], kCableCar);
        break;
      case 1:
        widget.onLiftSelected(kGondolas[_selectedLiftIndex], kGondola);
        break;
      case 2:
        widget.onLiftSelected(kChairlifts[_selectedLiftIndex], kChairlift);
        break;
      case 3:
        widget.onLiftSelected(kSkilifts[_selectedLiftIndex], kSkilift);
        break;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Expanded(
          child: ContainedTabBarView(
            initialIndex: _tabIndex,
            tabs: [
              Image.asset(
                kCableCarIcon,
                height: 48,
              ),
              Image.asset(
                kGondolaIcon,
                height: 48,
              ),
              Image.asset(
                kChairliftIcon,
                height: 48,
              ),
              Image.asset(
                kSkiliftIcon,
                height: 48,
              ),
            ],
            tabBarProperties: TabBarProperties(
              background: Container(
                decoration: BoxDecoration(
                  borderRadius: const BorderRadius.vertical(top: Radius.circular(8)),
                  color: kAppSeedColor.withValues(alpha: 0.3),
                ),
              ),
              indicatorSize: TabBarIndicatorSize.tab,
              indicator: BoxDecoration(
                color: kAppSeedColor.withValues(alpha: 0.7),
                // border: Border.all(color: kAppSeedColor, width: 1),
                borderRadius: const BorderRadius.vertical(top: Radius.circular(8)),
              ),
            ),
            views: [
              _buildList(kCableCars),
              _buildList(kGondolas),
              _buildList(kChairlifts),
              _buildList(kSkilifts),
            ],
            onChange: (index) {
              safeSetState(() {
                _selectedLiftIndex = 0;
                _tabIndex = index;

                _onLiftSelected();
              });
            },
          ),
        ),

        // const SizedBox(height: 12),
        //
        // // Next button
        // Align(
        //   alignment: Alignment.bottomRight,
        //   child: ElevatedButton(
        //     style: ElevatedButton.styleFrom(
        //       backgroundColor: kAppSeedColor,
        //       foregroundColor: Colors.white,
        //       minimumSize: const Size(128, 56),
        //     ),
        //     onPressed: _onLiftSelected,
        //     child: const Text('Next'),
        //   ),
        // ),
      ],
    );
  }
}
