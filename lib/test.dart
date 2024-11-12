// import 'package:flutter/material.dart';
// import 'package:pdf_points/data/excel_camp_info.dart';
// import 'package:pdf_points/utils/date_utils.dart';
// import 'package:pdf_points/utils/safe_setState.dart';
// import 'package:pdf_points/widgets/date_time_picker_widget.dart';
// import 'package:wolt_modal_sheet/wolt_modal_sheet.dart';
//
// void main() {
//   runApp(const MainApp());
// }
//
// const kCampDaysLength = 5;
// const double _bottomPaddingForButton = 150.0;
// const double _buttonHeight = 56.0;
// const double _buttonWidth = 200.0;
// const double _pagePadding = 16.0;
// const double _pageBreakpoint = 768.0;
// const double _heroImageHeight = 250.0;
// const Color _lightThemeShadowColor = Color(0xFFE4E4E4);
// const Color _darkThemeShadowColor = Color(0xFF121212);
// const Color _darkSabGradientColor = Color(0xFF313236);
// final materialColorsInGrid = allMaterialColors.take(20).toList();
// final materialColorsInSliverList = allMaterialColors.sublist(20, 25);
//
// class MainApp extends StatefulWidget {
//   const MainApp({super.key});
//
//   @override
//   State<MainApp> createState() => _MainAppState();
// }
//
// class _MainAppState extends State<MainApp> {
//   bool _isLightTheme = true;
//
//   SliverWoltModalSheetPage page1(BuildContext modalSheetContext) {
//     return WoltModalSheetPage(
//       hasSabGradient: false,
//       topBarTitle: Text('Add Camp', style: Theme.of(context).textTheme.titleLarge),
//       isTopBarLayerAlwaysVisible: true,
//       trailingNavBarWidget: IconButton(
//         padding: const EdgeInsets.all(_pagePadding),
//         icon: const Icon(Icons.close),
//         onPressed: Navigator.of(modalSheetContext).pop,
//       ),
//       // heroImage: Padding(
//       //   padding: const EdgeInsets.all(_pagePadding),
//       //   child: Image(
//       //     image: NetworkImage(
//       //       'https://raw.githubusercontent.com/woltapp/wolt_modal_sheet/main/example/lib/assets/images/material_colors_hero${_isLightTheme ? '_light' : '_dark'}.png',
//       //     ),
//       //     fit: BoxFit.cover,
//       //   ),
//       // ),
//       child: const Padding(
//         padding: EdgeInsets.all(_pagePadding),
//         child: AddCampContentWidget(campInfo: null),
//       ),
//     );
//   }
//
//   void _openModal(BuildContext context) {
//     WoltModalSheet.show<void>(
//       context: context,
//       pageListBuilder: (modalSheetContext) => [
//         WoltModalSheetPage(
//           hasSabGradient: false,
//           topBarTitle: Text('Add Camp', style: Theme.of(context).textTheme.titleLarge),
//           isTopBarLayerAlwaysVisible: true,
//           trailingNavBarWidget: IconButton(
//             padding: const EdgeInsets.all(_pagePadding),
//             icon: const Icon(Icons.close),
//             onPressed: Navigator.of(modalSheetContext).pop,
//           ),
//           child: const Padding(
//             padding: EdgeInsets.all(_pagePadding),
//             child: AddCampContentWidget(campInfo: null),
//           ),
//         ),
//       ],
//       modalTypeBuilder: (context) {
//         final size = MediaQuery.sizeOf(context).width;
//
//         return size < _pageBreakpoint //
//             ? const WoltBottomSheetType()
//             : const WoltDialogType();
//       },
//       onModalDismissedWithBarrierTap: () {
//         Navigator.of(context).pop();
//       },
//     );
//   }
//
//   @override
//   Widget build(BuildContext context) {
//     return MaterialApp(
//       themeMode: _isLightTheme ? ThemeMode.light : ThemeMode.dark,
//       theme: ThemeData.light().copyWith(
//         extensions: const <ThemeExtension>[
//           WoltModalSheetThemeData(
//             heroImageHeight: _heroImageHeight,
//             topBarShadowColor: _lightThemeShadowColor,
//             modalBarrierColor: Colors.black54,
//             mainContentScrollPhysics: ClampingScrollPhysics(),
//           ),
//         ],
//       ),
//       darkTheme: ThemeData.dark().copyWith(
//         extensions: const <ThemeExtension>[
//           WoltModalSheetThemeData(
//             topBarShadowColor: _darkThemeShadowColor,
//             modalBarrierColor: Colors.white12,
//             sabGradientColor: _darkSabGradientColor,
//             mainContentScrollPhysics: ClampingScrollPhysics(),
//           ),
//         ],
//       ),
//       home: Scaffold(
//         body: Builder(
//           builder: (context) {
//             return Column(
//               mainAxisAlignment: MainAxisAlignment.center,
//               children: [
//                 Row(
//                   mainAxisAlignment: MainAxisAlignment.center,
//                   children: [
//                     const Text('Light Theme'),
//                     Padding(
//                       padding: const EdgeInsets.all(_pagePadding),
//                       child: Switch(
//                         value: !_isLightTheme,
//                         onChanged: (_) => setState(() => _isLightTheme = !_isLightTheme),
//                       ),
//                     ),
//                     const Text('Dark Theme'),
//                   ],
//                 ),
//                 ElevatedButton(
//                   onPressed: () {
//                     _openModal(context);
//                   },
//                   child: const SizedBox(
//                     height: _buttonHeight,
//                     width: _buttonWidth,
//                     child: Center(child: Text('Show Modal Sheet')),
//                   ),
//                 ),
//               ],
//             );
//           },
//         ),
//       ),
//     );
//   }
// }
//
// class ColorTile extends StatelessWidget {
//   final Color color;
//
//   const ColorTile({super.key, required this.color});
//
//   @override
//   Widget build(BuildContext context) {
//     return Container(
//       color: color,
//       height: 600,
//       child: Center(
//         child: Text(
//           color.toString(),
//           style: TextStyle(
//             color: color.computeLuminance() > 0.5 ? Colors.black : Colors.white,
//             fontWeight: FontWeight.bold,
//           ),
//         ),
//       ),
//     );
//   }
// }
//
// List<Color> get allMaterialColors {
//   List<Color> allMaterialColorsWithShades = [];
//
//   for (MaterialColor color in Colors.primaries) {
//     allMaterialColorsWithShades.add(color.shade100);
//     allMaterialColorsWithShades.add(color.shade200);
//     allMaterialColorsWithShades.add(color.shade300);
//     allMaterialColorsWithShades.add(color.shade400);
//     allMaterialColorsWithShades.add(color.shade500);
//     allMaterialColorsWithShades.add(color.shade600);
//     allMaterialColorsWithShades.add(color.shade700);
//     allMaterialColorsWithShades.add(color.shade800);
//     allMaterialColorsWithShades.add(color.shade900);
//   }
//   return allMaterialColorsWithShades;
// }
//
// class AddCampContentWidget extends StatefulWidget {
//   const AddCampContentWidget({super.key, this.campInfo});
//
//   final ExcelCampInfo? campInfo;
//
//   @override
//   State<AddCampContentWidget> createState() => _AddCampContentWidgetState();
// }
//
// class _AddCampContentWidgetState extends State<AddCampContentWidget> {
//   final _formKey = GlobalKey<FormState>();
//   final _confirmPasswordFieldKey = GlobalKey<FormFieldState<String>>();
//   late DateTime _startDate;
//   late DateTime _endDate;
//   late String _name;
//   String _password = "";
//   String _confirmPassword = "";
//
//   bool _isPasswordVisible = false;
//   bool _isConfirmPasswordVisible = false;
//
//   @override
//   void initState() {
//     super.initState();
//
//     _startDate = widget.campInfo?.startSkiDate?.subtract(const Duration(days: 1)) ?? DateTimeUtils.today();
//     _endDate = widget.campInfo?.endSkiDate ?? _startDate.add(const Duration(days: kCampDaysLength - 1));
//     _name = widget.campInfo?.name ?? "";
//   }
//
//   void _onStartDateChanged(DateTime? date) {
//     if (date == null) {
//       return;
//     }
//
//     safeSetState(() {
//       _startDate = date;
//
//       _endDate = _startDate.add(const Duration(days: kCampDaysLength - 1));
//     });
//   }
//
//   void _onEndDateChanged(DateTime? date) {
//     if (date == null) {
//       return;
//     }
//
//     safeSetState(() {
//       _endDate = date;
//     });
//   }
//
//   Future<void> _onAddCamp() async {
//     var valid = _formKey.currentState?.validate() ?? false;
//     if (!valid) {
//       return;
//     }
//
//     // TODO: save the camp to firebase:
//     // FirebaseManager.instance.addCamp(
//     //   name: _name,
//     //   password: _password,
//     //   startDate: _startDate,
//     //   endDate: _endDate,
//     //   participants: widget.campInfo?.participants ?? [],
//     //   instructors: [],
//     // );
//     await Future.delayed(const Duration(seconds: 1));
//
//     if (!mounted) {
//       return;
//     }
//
//     Navigator.of(context).pop();
//   }
//
//   bool _validName(String? value) {
//     if (value == null || value.trim().isEmpty) {
//       return false;
//     }
//
//     return true;
//   }
//
//   bool _validPassword(String? value) {
//     if (value == null || value.trim().isEmpty) {
//       return false;
//     }
//
//     return true;
//   }
//
//   bool _validConfirmPassword(String? value) {
//     return value == _password;
//   }
//
//   bool _validData() {
//     if (!_validName(_name)) {
//       return false;
//     }
//
//     if (!_validPassword(_password)) {
//       return false;
//     }
//
//     if (!_validConfirmPassword(_confirmPassword)) {
//       return false;
//     }
//
//     if (_startDate.isAfter(_endDate)) {
//       return false;
//     }
//
//     return true;
//   }
//
//   @override
//   Widget build(BuildContext context) {
//     return Form(
//       key: _formKey,
//       child: Column(
//         mainAxisSize: MainAxisSize.min,
//         crossAxisAlignment: CrossAxisAlignment.start,
//         children: [
//           // Camp Image
//           Center(
//             child: Image(
//               image: NetworkImage(
//                 'https://raw.githubusercontent.com/woltapp/wolt_modal_sheet/main/example/lib/assets/images/material_colors_hero_light.png',
//               ),
//               fit: BoxFit.cover,
//             ),
//           ),
//
//           const SizedBox(height: 4),
//
//           // Camp name
//           TextFormField(
//             initialValue: _name,
//             decoration: const InputDecoration(labelText: "Name"),
//             keyboardType: TextInputType.name,
//             textCapitalization: TextCapitalization.words,
//             validator: (value) {
//               if (!_validName(value)) {
//                 return "Please enter a name";
//               }
//               return null;
//             },
//             onChanged: (value) {
//               safeSetState(() {
//                 _name = value;
//               });
//             },
//           ),
//
//           const SizedBox(height: 4),
//
//           // Camp password
//           TextFormField(
//             decoration: InputDecoration(
//               labelText: 'Password',
//               suffixIcon: IconButton(
//                 icon: Icon(
//                   _isPasswordVisible //
//                       ? Icons.visibility_rounded
//                       : Icons.visibility_off_rounded,
//                 ),
//                 onPressed: () {
//                   safeSetState(() {
//                     _isPasswordVisible = !_isPasswordVisible;
//                   });
//                 },
//               ),
//             ),
//             enableSuggestions: true,
//             obscureText: !_isPasswordVisible,
//             validator: (value) {
//               if (!_validPassword(value)) {
//                 return "Please enter a password";
//               }
//
//               return null;
//             },
//             onChanged: (value) {
//               safeSetState(() {
//                 _password = value;
//               });
//
//               if (_confirmPassword.isNotEmpty) {
//                 _confirmPasswordFieldKey.currentState?.validate();
//               }
//             },
//           ),
//
//           const SizedBox(height: 4),
//
//           // Camp password again
//           TextFormField(
//             key: _confirmPasswordFieldKey,
//             decoration: InputDecoration(
//               labelText: 'Confirm password',
//               suffixIcon: IconButton(
//                 icon: Icon(
//                   _isConfirmPasswordVisible //
//                       ? Icons.visibility_rounded
//                       : Icons.visibility_off_rounded,
//                 ),
//                 onPressed: () {
//                   safeSetState(() {
//                     _isConfirmPasswordVisible = !_isConfirmPasswordVisible;
//                   });
//                 },
//               ),
//             ),
//             enableSuggestions: true,
//             obscureText: !_isConfirmPasswordVisible,
//             validator: (value) {
//               if (!_validConfirmPassword(value)) {
//                 return "Passwords do not match";
//               }
//               return null;
//             },
//             onChanged: (value) {
//               _confirmPasswordFieldKey.currentState?.validate();
//
//               safeSetState(() {
//                 _confirmPassword = value;
//               });
//             },
//           ),
//
//           const SizedBox(height: 12),
//
//           // Camp start date
//           DateTimePickerWidget(
//             leading: const Text("Start date:"),
//             startDate: DateTime.now(),
//             initialDate: _startDate,
//             onChanged: _onStartDateChanged,
//             showTime: false,
//           ),
//
//           // Camp end date
//           DateTimePickerWidget(
//             leading: const Text("End date:"),
//             startDate: _startDate,
//             initialDate: _endDate,
//             onChanged: _onEndDateChanged,
//             showTime: false,
//           ),
//
//           if (widget.campInfo?.participants != null) ...[
//             const SizedBox(height: 12),
//             Text("Participants: ${widget.campInfo!.participants.length}"),
//           ],
//
//           const SizedBox(height: 12),
//
//           ElevatedButton(
//             onPressed: _onAddCamp,
//             child: const SizedBox(
//               height: _buttonHeight,
//               width: double.infinity,
//               child: Center(child: Text('Add Camp')),
//             ),
//           ),
//         ],
//       ),
//     );
//   }
// }
