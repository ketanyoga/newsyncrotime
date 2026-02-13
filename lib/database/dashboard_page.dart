// // // import 'dart:async';
// // // import 'dart:convert';
// // // import 'package:flutter/material.dart';
// // // import 'package:sqflite/sqflite.dart';
// // // import '../../services/esp32_api_service.dart';
// // // import '../database/app_database.dart';
// // // import '../pages/category/category_list_page.dart';
// // // import '../pages/category/create_category_page.dart';
// // //
// // // class DashboardPage extends StatefulWidget {
// // //   const DashboardPage({super.key});
// // //
// // //   @override
// // //   State<DashboardPage> createState() => _DashboardPageState();
// // // }
// // //
// // // class _DashboardPageState extends State<DashboardPage> {
// // //   bool espConnected = false;
// // //   // This 'time' variable will now be the main display time.
// // //   // We'll update it to show the next period's time.
// // //   String time = "--:--";
// // //   String date = ""; // We can still keep the date from the ESP32
// // //   String nextPeriodInfo = "Loading..."; // For the small text below the time
// // //   Timer? timer;
// // //   bool hasSchedule = false;
// // //
// // //   late final Future<Database> _dbFuture;
// // //
// // //   @override
// // //   void initState() {
// // //     super.initState();
// // //     _dbFuture = AppDB.instance.database;
// // //     _init();
// // //   }
// // //
// // //   Future<void> _init() async {
// // //     final db = await _dbFuture;
// // //
// // //     final countResult = await db.rawQuery('SELECT COUNT(*) as c FROM categories');
// // //     if (mounted) {
// // //       setState(() {
// // //         final count = countResult.first['c'] as int?;
// // //         hasSchedule = (count ?? 0) > 0;
// // //       });
// // //     }
// // //
// // //     _checkEsp();
// // //     // We still load the date and check connection periodically
// // //     timer = Timer.periodic(const Duration(seconds: 3), (_) {
// // //       _checkEsp();
// // //       _loadDateFromEsp(); // Changed to only load date, as time is handled by schedule
// // //       _loadNextPeriod();
// // //     });
// // //   }
// // //
// // //   Future<void> _checkEsp() async {
// // //     final connected = await Esp32ApiService.checkConnection();
// // //     if (mounted) {
// // //       setState(() => espConnected = connected);
// // //     }
// // //   }
// // //
// // //   Future<void> _loadDateFromEsp() async {
// // //     if (!espConnected) return;
// // //     // Just send the command. Don't use `await` on a `void` and don't assign the result.
// // //     Esp32ApiService.getStatus();
// // //   }
// // //
// // //   // This helper function will be called by the stream listener
// // //   void _parseStatusAndUpdateUI(String statusString) {
// // //     if (mounted) {
// // //       final lines = statusString.split('\n');
// // //       String espDate = "";
// // //       for (var line in lines) {
// // //         if (line.startsWith("Date:")) {
// // //           espDate = line.replaceFirst("Date:", "").trim().split(' ')[0];
// // //           break;
// // //         }
// // //       }
// // //       setState(() {
// // //         date = espDate;
// // //       });
// // //     }
// // //   }
// // //
// // //   // MODIFIED SECTION
// // //   Future<void> _loadNextPeriod() async {
// // //     final db = await _dbFuture;
// // //     final now = TimeOfDay.now();
// // //     final currentTime = '${now.hour.toString().padLeft(2, '0')}:${now.minute.toString().padLeft(2, '0')}';
// // //
// // //     final List<Map<String, dynamic>> result = await db.rawQuery(
// // //       'SELECT * FROM periods WHERE startTime > ? ORDER BY startTime ASC LIMIT 1',
// // //       [currentTime],
// // //     );
// // //
// // //     if (mounted) {
// // //       setState(() {
// // //         if (result.isEmpty) {
// // //           // If no more periods, revert to showing ESP time or a message
// // //           time = "--:--";
// // //           nextPeriodInfo = "No more periods today";
// // //         } else {
// // //           final periodTitle = result.first['title'];
// // //           final periodTime = result.first['startTime'];
// // //
// // //           // *** THIS IS THE KEY CHANGE ***
// // //           // 1. Set the main time display to the next period's start time.
// // //           time = periodTime;
// // //
// // //           // 2. Set the descriptive text for the banner below.
// // //           nextPeriodInfo = "Next: $periodTitle";
// // //         }
// // //       });
// // //     }
// // //   }
// // //
// // //   @override
// // //   void dispose() {
// // //     timer?.cancel();
// // //     super.dispose();
// // //   }
// // //
// // //   // --- UI WIDGETS SECTION ---
// // //
// // //   @override
// // //   Widget build(BuildContext context) {
// // //     return Scaffold(
// // //       body: SafeArea(
// // //         child: Padding(
// // //           padding: const EdgeInsets.all(16),
// // //           child: Column(
// // //             crossAxisAlignment: CrossAxisAlignment.start,
// // //             children: [
// // //               _topBar(),
// // //               const SizedBox(height: 20),
// // //               // This card now correctly shows the next period's time in the large display.
// // //               _timeCard(),
// // //               const SizedBox(height: 20),
// // //               _scheduleButton(),
// // //               const SizedBox(height: 20),
// // //               _actionButtons(),
// // //               const Spacer(),
// // //               _bottomNav(context),
// // //             ],
// // //           ),
// // //         ),
// // //       ),
// // //     );
// // //   }
// // //
// // //   Widget _topBar() {
// // //     return Row(
// // //       mainAxisAlignment: MainAxisAlignment.spaceBetween,
// // //       children: [
// // //         const Text("Dashboard",
// // //             style: TextStyle(fontSize: 26, fontWeight: FontWeight.bold)),
// // //         Container(
// // //           padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
// // //           decoration: BoxDecoration(
// // //             color: espConnected ? Colors.green : Colors.red,
// // //             borderRadius: BorderRadius.circular(20),
// // //           ),
// // //           child: Row(
// // //             children: const [
// // //               Icon(Icons.wifi, color: Colors.white, size: 16),
// // //               SizedBox(width: 6),
// // //               Text("WiFi", style: TextStyle(color: Colors.white)),
// // //             ],
// // //           ),
// // //         )
// // //       ],
// // //     );
// // //   }
// // //
// // //   // The 'time' variable used here is now updated by _loadNextPeriod()
// // //   Widget _timeCard() {
// // //     return Container(
// // //       width: double.infinity,
// // //       padding: const EdgeInsets.all(20),
// // //       decoration: BoxDecoration(
// // //         color: Colors.blue,
// // //         borderRadius: BorderRadius.circular(20),
// // //       ),
// // //       child: Column(
// // //         children: [
// // //           Text(date, style: const TextStyle(color: Colors.white70)),
// // //           Text(time, // This now shows the next period's time
// // //               style: const TextStyle(
// // //                   fontSize: 48,
// // //                   color: Colors.white,
// // //                   fontWeight: FontWeight.bold)),
// // //           const SizedBox(height: 10),
// // //           Container(
// // //             padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
// // //             decoration: BoxDecoration(
// // //               color: Colors.white24,
// // //               borderRadius: BorderRadius.circular(20),
// // //             ),
// // //             child: Text(nextPeriodInfo, // This shows "Next: Period Name"
// // //                 style: const TextStyle(color: Colors.white)),
// // //           )
// // //         ],
// // //       ),
// // //     );
// // //   }
// // //
// // //   Widget _scheduleButton() {
// // //     return ElevatedButton(
// // //       onPressed: () {
// // //         Navigator.push(
// // //           context,
// // //           MaterialPageRoute(
// // //               builder: (_) =>
// // //               hasSchedule ? const CategoryListPage() : const CreateCategoryPage()),
// // //         );
// // //       },
// // //       style: ElevatedButton.styleFrom(
// // //         minimumSize: const Size(double.infinity, 50),
// // //         shape: RoundedRectangleBorder(
// // //             borderRadius: BorderRadius.circular(30)),
// // //       ),
// // //       child: Text(hasSchedule ? "View Schedules" : "Create Schedule"),
// // //     );
// // //   }
// // //
// // //   Widget _actionButtons() {
// // //     return Row(
// // //       mainAxisAlignment: MainAxisAlignment.spaceBetween,
// // //       // children: [
// // //       //   _smallButton("Skip Bell", () {
// // //       //     Esp32ApiService.sendCommand({"action": "skip_next_bell"});
// // //       //   }),
// // //       //   _smallButton("Announcement", () {
// // //       //     Navigator.pushNamed(context, "/announcement");
// // //       //   }),
// // //       //   _smallButton("Manual Ring", () {
// // //       //     Esp32ApiService.sendCommand(
// // //       //         {"action": "manual_ring", "sound": "default"});
// // //       //   }),
// // //       // ],
// // //       children: [
// // //         _smallButton("Skip Bell", () async {
// // //           await Esp32ApiService.sendRaw(
// // //               "\$SKIP#"
// // //           );
// // //         }),
// // //
// // //         _smallButton("Announcement", () {
// // //           Navigator.pushNamed(context, "/announcement");
// // //         }),
// // //
// // //         _smallButton("Manual Ring", () async {
// // //           await Esp32ApiService.sendRaw(
// // //               "\$T,1#"
// // //           );
// // //         }),
// // //       ],
// // //
// // //     );
// // //   }
// // //
// // //   Widget _smallButton(String text, VoidCallback onTap) {
// // //     return Expanded(
// // //       child: Padding(
// // //         padding: const EdgeInsets.symmetric(horizontal: 4),
// // //         child: OutlinedButton(
// // //           onPressed: onTap,
// // //           child: Text(text, textAlign: TextAlign.center),
// // //         ),
// // //       ),
// // //     );
// // //   }
// // //
// // //   Widget _bottomNav(BuildContext context) {
// // //     return Row(
// // //       mainAxisAlignment: MainAxisAlignment.spaceAround,
// // //       children: [
// // //         IconButton(icon: const Icon(Icons.home), onPressed: () {}),
// // //         IconButton(
// // //             icon: const Icon(Icons.calendar_today),
// // //             onPressed: () {
// // //               // today's schedule page
// // //             }),
// // //         IconButton(
// // //             icon: const Icon(Icons.settings),
// // //             onPressed: () {
// // //               Navigator.push(context,
// // //                   MaterialPageRoute(builder: (_) => const CategoryListPage()));
// // //             }),
// // //       ],
// // //     );
// // //   }
// // // }
// //
// //
// //
// //
// //
// // import 'dart:async';
// // import 'package:flutter/material.dart';
// // import 'package:sqflite/sqflite.dart';
// // import 'package:simple_animations/simple_animations.dart'; // Correct import
// // import '../../services/esp32_api_service.dart';
// // import '../database/app_database.dart';
// // import '../pages/category/category_list_page.dart';
// // import '../pages/category/create_category_page.dart';
// //
// // class DashboardPage extends StatefulWidget {
// //   const DashboardPage({super.key});
// //
// //   @override
// //   State<DashboardPage> createState() => _DashboardPageState();
// // }
// //
// // class _DashboardPageState extends State<DashboardPage> with TickerProviderStateMixin {
// //   bool espConnected = false;
// //   String time = "--:--";
// //   String date = "";
// //   String nextPeriodInfo = "Loading...";
// //   Timer? timer;
// //   bool hasSchedule = false;
// //
// //   late final Future<Database> _dbFuture;
// //   late AnimationController _animationController;
// //
// //   @override
// //   void initState() {
// //     super.initState();
// //     _dbFuture = AppDB.instance.database;
// //
// //     // Animation controller for the time card's breathing effect
// //     _animationController = AnimationController(
// //       vsync: this,
// //       duration: const Duration(seconds: 2),
// //     )..repeat(reverse: true);
// //
// //     _init();
// //   }
// //
// //   Future<void> _init() async {
// //     final db = await _dbFuture;
// //
// //     final countResult = await db.rawQuery('SELECT COUNT(*) as c FROM categories');
// //     if (mounted) {
// //       setState(() {
// //         final count = countResult.first['c'] as int?;
// //         hasSchedule = (count ?? 0) > 0;
// //       });
// //     }
// //
// //     _checkEsp();
// //     timer = Timer.periodic(const Duration(seconds: 3), (_) {
// //       _checkEsp();
// //       _loadDateFromEsp();
// //       _loadNextPeriod();
// //     });
// //   }
// //
// //   Future<void> _checkEsp() async {
// //     final connected = await Esp32ApiService.checkConnection();
// //     if (mounted) {
// //       setState(() => espConnected = connected);
// //     }
// //   }
// //
// //   Future<void> _loadDateFromEsp() async {
// //     if (!espConnected) return;
// //     Esp32ApiService.getStatus();
// //   }
// //
// //   void _parseStatusAndUpdateUI(String statusString) {
// //     if (mounted) {
// //       final lines = statusString.split('\n');
// //       String espDate = "";
// //       for (var line in lines) {
// //         if (line.startsWith("Date:")) {
// //           espDate = line.replaceFirst("Date:", "").trim().split(' ')[0];
// //           break;
// //         }
// //       }
// //       setState(() {
// //         date = espDate;
// //       });
// //     }
// //   }
// //
// //   Future<void> _loadNextPeriod() async {
// //     final db = await _dbFuture;
// //     final now = TimeOfDay.now();
// //     final currentTime = '${now.hour.toString().padLeft(2, '0')}:${now.minute.toString().padLeft(2, '0')}';
// //
// //     final List<Map<String, dynamic>> result = await db.rawQuery(
// //       'SELECT * FROM periods WHERE startTime > ? ORDER BY startTime ASC LIMIT 1',
// //       [currentTime],
// //     );
// //
// //     if (mounted) {
// //       setState(() {
// //         if (result.isEmpty) {
// //           time = "--:--";
// //           nextPeriodInfo = "No more periods today";
// //         } else {
// //           final periodTitle = result.first['title'];
// //           final periodTime = result.first['startTime'];
// //           time = periodTime;
// //           nextPeriodInfo = "Next: $periodTitle";
// //         }
// //       });
// //     }
// //   }
// //
// //   @override
// //   void dispose() {
// //     timer?.cancel();
// //     _animationController.dispose();
// //     super.dispose();
// //   }
// //
// //   // --- NEW AESTHETIC UI WIDGETS SECTION ---
// //
// //   @override
// //   Widget build(BuildContext context) {
// //     return Scaffold(
// //       backgroundColor: const Color(0xFFF4F7FC), // A light, clean background color
// //       body: SafeArea(
// //         child: Padding(
// //           padding: const EdgeInsets.symmetric(horizontal: 16.0),
// //           child: Column(
// //             children: [
// //               const SizedBox(height: 16),
// //               _topBar(),
// //               const SizedBox(height: 24),
// //               _timeCard(),
// //               const SizedBox(height: 24),
// //               _scheduleCard(),
// //               const SizedBox(height: 16),
// //               _actionCardGrid(),
// //               // const Spacer(),
// //               // _bottomNav(context),
// //             ],
// //           ),
// //         ),
// //       ),
// //     );
// //   }
// //
// //   Widget _topBar() {
// //     return Row(
// //       mainAxisAlignment: MainAxisAlignment.spaceBetween,
// //       children: [
// //         const Text("Dashboard",
// //             style: TextStyle(
// //                 fontSize: 28,
// //                 fontWeight: FontWeight.bold,
// //                 color: Color(0xFF1A2552))),
// //         Container(
// //           padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
// //           decoration: BoxDecoration(
// //             color: espConnected ? Colors.green.shade400 : Colors.red.shade400,
// //             borderRadius: BorderRadius.circular(20),
// //             boxShadow: [
// //               BoxShadow(
// //                   color: espConnected
// //                       ? Colors.green.withOpacity(0.3)
// //                       : Colors.red.withOpacity(0.3),
// //                   blurRadius: 8,
// //                   offset: const Offset(0, 4))
// //             ],
// //           ),
// //           child: Row(
// //             children: [
// //               Icon(espConnected ? Icons.wifi_rounded : Icons.wifi_off_rounded,
// //                   color: Colors.white, size: 18),
// //               const SizedBox(width: 8),
// //               Text(espConnected ? "Connected" : "Offline",
// //                   style: const TextStyle(
// //                       color: Colors.white, fontWeight: FontWeight.w600)),
// //             ],
// //           ),
// //         )
// //       ],
// //     );
// //   }
// //
// //   Widget _timeCard() {
// //     // This creates a "breathing" gradient animation for the background
// //     final tween = MovieTween()
// //       ..tween('begin', ColorTween(begin: Colors.blue.shade300, end: Colors.blue.shade400), duration: const Duration(seconds: 2))
// //       ..tween('end', ColorTween(begin: Colors.purple.shade300, end: Colors.purple.shade400), duration: const Duration(seconds: 2));
// //
// //
// //     return LoopAnimationBuilder<Movie>(
// //       tween: tween,
// //       duration: tween.duration,
// //       builder: (context, value, child) {
// //         return Container(
// //           width: double.infinity,
// //           padding: const EdgeInsets.all(24),
// //           decoration: BoxDecoration(
// //             gradient: LinearGradient(
// //               colors: [value.get('begin'), value.get('end')],
// //               begin: Alignment.topLeft,
// //               end: Alignment.bottomRight,
// //             ),
// //             borderRadius: BorderRadius.circular(24),
// //             boxShadow: [
// //               BoxShadow(
// //                 color: Colors.blue.withOpacity(0.25),
// //                 blurRadius: 15,
// //                 offset: const Offset(0, 8),
// //               )
// //             ],
// //           ),
// //           child: child,
// //         );
// //       },
// //       child: Column(
// //         children: [
// //           Text(date, style: const TextStyle(color: Colors.white70, fontSize: 16)),
// //           const SizedBox(height: 8),
// //           Text(
// //             time,
// //             style: const TextStyle(
// //               fontSize: 64,
// //               color: Colors.white,
// //               fontWeight: FontWeight.bold,
// //               shadows: [
// //                 Shadow(
// //                   color: Colors.black26,
// //                   blurRadius: 10,
// //                   offset: Offset(0, 4),
// //                 )
// //               ],
// //             ),
// //           ),
// //           const SizedBox(height: 12),
// //           Container(
// //             padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
// //             decoration: BoxDecoration(
// //               color: Colors.white.withOpacity(0.2),
// //               borderRadius: BorderRadius.circular(20),
// //             ),
// //             child: Text(nextPeriodInfo,
// //                 style: const TextStyle(
// //                     color: Colors.white,
// //                     fontSize: 14,
// //                     fontWeight: FontWeight.w500)),
// //           )
// //         ],
// //       ),
// //     );
// //   }
// //
// //   Widget _scheduleCard() {
// //     return Card(
// //       elevation: 2,
// //       shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
// //       clipBehavior: Clip.antiAlias, // Ensures InkWell ripple respects the border
// //       child: InkWell(
// //         onTap: () {
// //           Navigator.push(
// //             context,
// //             MaterialPageRoute(
// //                 builder: (_) => hasSchedule
// //                     ? const CategoryListPage()
// //                     : const CreateCategoryPage()),
// //           );
// //         },
// //         child: Padding(
// //           padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
// //           child: Row(
// //             children: [
// //               Icon(
// //                   hasSchedule
// //                       ? Icons.list_alt_rounded
// //                       : Icons.add_circle_outline_rounded,
// //                   color: Theme.of(context).primaryColor,
// //                   size: 32),
// //               const SizedBox(width: 16),
// //               Expanded(
// //                 child: Text(
// //                   hasSchedule ? "View Schedules" : "Create New Schedule",
// //                   style: const TextStyle(
// //                       fontSize: 18,
// //                       fontWeight: FontWeight.bold,
// //                       color: Color(0xFF1A2552)),
// //                 ),
// //               ),
// //               const Icon(Icons.arrow_forward_ios_rounded,
// //                   color: Colors.grey, size: 18),
// //             ],
// //           ),
// //         ),
// //       ),
// //     );
// //   }
// //
// //   Widget _actionCardGrid() {
// //     return Column(
// //       crossAxisAlignment: CrossAxisAlignment.start,
// //       children: [
// //         const Text(
// //           "Quick Actions",
// //           style: TextStyle(
// //               fontSize: 20,
// //               fontWeight: FontWeight.bold,
// //               color: Color(0xFF1A2552)),
// //         ),
// //         const SizedBox(height: 16),
// //         Row(
// //           children: [
// //             _smallActionCard(
// //                 "Skip Bell", Icons.skip_next_rounded, Colors.orange, () async {
// //               await Esp32ApiService.sendRaw("\$SKIP#");
// //             }),
// //             const SizedBox(width: 12),
// //             _smallActionCard("Announce", Icons.campaign_rounded, Colors.teal,
// //                     () {
// //                   Navigator.pushNamed(context, "/announcement");
// //                 }),
// //             const SizedBox(width: 12),
// //             _smallActionCard(
// //                 "Manual Ring", Icons.notifications_active_rounded, Colors.red,
// //                     () async {
// //                   await Esp32ApiService.sendRaw("\$T,1#");
// //                 }),
// //           ],
// //         ),
// //       ],
// //     );
// //   }
// //
// //   Widget _smallActionCard(
// //       String text, IconData icon, MaterialColor color, VoidCallback onTap) {
// //     return Expanded(
// //       child: Card(
// //         elevation: 2,
// //         shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
// //         clipBehavior: Clip.antiAlias,
// //         child: InkWell(
// //           onTap: onTap,
// //           child: Padding(
// //             padding: const EdgeInsets.symmetric(vertical: 20),
// //             child: Column(
// //               mainAxisAlignment: MainAxisAlignment.center,
// //               children: [
// //                 Icon(icon, color: color, size: 30),
// //                 const SizedBox(height: 10),
// //                 Text(
// //                   text,
// //                   textAlign: TextAlign.center,
// //                   style: TextStyle(
// //                       fontWeight: FontWeight.w600, color: color.shade800), // FIX: Now works with MaterialColor
// //                 ),
// //               ],
// //             ),
// //           ),
// //         ),
// //       ),
// //     );
// //   }
// //
// //   // Widget _bottomNav(BuildContext context) {
// //   //   return Container(
// //   //     padding: const EdgeInsets.symmetric(vertical: 12),
// //   //     margin: const EdgeInsets.only(bottom: 8),
// //   //     decoration: BoxDecoration(
// //   //       color: Colors.white,
// //   //       borderRadius: BorderRadius.circular(24),
// //   //       boxShadow: [
// //   //         BoxShadow(
// //   //             color: Colors.black.withOpacity(0.05),
// //   //             blurRadius: 10,
// //   //             spreadRadius: 2)
// //   //       ],
// //   //     ),
// //   //     child: Row(
// //   //       mainAxisAlignment: MainAxisAlignment.spaceAround,
// //   //       children: [
// //   //         IconButton(
// //   //             icon: const Icon(Icons.home_rounded, color: Colors.blue, size: 30),
// //   //             onPressed: () {}),
// //   //         IconButton(
// //   //             icon: const Icon(Icons.calendar_today_rounded, color: Colors.grey, size: 28),
// //   //             onPressed: () {
// //   //               // Navigate to today's schedule page
// //   //             }),
// //   //         IconButton(
// //   //             icon: const Icon(Icons.settings_rounded, color: Colors.grey, size: 28),
// //   //             onPressed: () {
// //   //               Navigator.push(context,
// //   //                   MaterialPageRoute(builder: (_) => const CategoryListPage()));
// //   //             }),
// //   //       ],
// //   //     ),
// //   //   );
// //   // }
// // }
// //
//
// // import 'dart:async';
// // import 'package:flutter/material.dart';
// // import 'package:newsyncrotime/pages/emergency/emergency_page.dart';
// // import 'package:sqflite/sqflite.dart';
// // import 'package:simple_animations/simple_animations.dart'; // Correct import
// // import '../../services/esp32_api_service.dart';
// // import '../database/app_database.dart';
// // import '../pages/announcement/announcement_page.dart';
// // import '../pages/category/category_list_page.dart';
// // import '../pages/category/create_category_page.dart';
// // import '../pages/today_schedule_page.dart';
// //
// // class DashboardPage extends StatefulWidget {
// //   const DashboardPage({super.key});
// //
// //   @override
// //   State<DashboardPage> createState() => _DashboardPageState();
// // }
// //
// // class _DashboardPageState extends State<DashboardPage> with TickerProviderStateMixin {
// //   bool espConnected = false;
// //   String time = "--:--";
// //   String date = "";
// //   String nextPeriodInfo = "Loading...";
// //   Timer? timer;
// //   bool hasSchedule = false;
// //
// //   late final Future<Database> _dbFuture;
// //   late AnimationController _animationController;
// //
// //   @override
// //   void initState() {
// //     super.initState();
// //     _dbFuture = AppDB.instance.database;
// //
// //     // Animation controller for the time card's breathing effect
// //     _animationController = AnimationController(
// //       vsync: this,
// //       duration: const Duration(seconds: 2),
// //     )..repeat(reverse: true);
// //
// //     _init();
// //   }
// //
// //   Future<void> _init() async {
// //     final db = await _dbFuture;
// //
// //     final countResult = await db.rawQuery('SELECT COUNT(*) as c FROM categories');
// //     if (mounted) {
// //       setState(() {
// //         final count = countResult.first['c'] as int?;
// //         hasSchedule = (count ?? 0) > 0;
// //       });
// //     }
// //
// //     _checkEsp();
// //     timer = Timer.periodic(const Duration(seconds: 3), (_) {
// //       _checkEsp();
// //       _loadDateFromEsp();
// //       _loadNextPeriod();
// //     });
// //   }
// //
// //   Future<void> _checkEsp() async {
// //     final connected = await Esp32ApiService.checkConnection();
// //     if (mounted) {
// //       setState(() => espConnected = connected);
// //     }
// //   }
// //
// //   Future<void> _loadDateFromEsp() async {
// //     if (!espConnected) return;
// //     Esp32ApiService.getStatus();
// //   }
// //
// //   void _parseStatusAndUpdateUI(String statusString) {
// //     if (mounted) {
// //       final lines = statusString.split('\n');
// //       String espDate = "";
// //       for (var line in lines) {
// //         if (line.startsWith("Date:")) {
// //           espDate = line.replaceFirst("Date:", "").trim().split(' ')[0];
// //           break;
// //         }
// //       }
// //       setState(() {
// //         date = espDate;
// //       });
// //     }
// //   }
// //
// //   Future<void> _loadNextPeriod() async {
// //     final db = await _dbFuture;
// //     final now = TimeOfDay.now();
// //     final currentTime = '${now.hour.toString().padLeft(2, '0')}:${now.minute.toString().padLeft(2, '0')}';
// //
// //     final List<Map<String, dynamic>> result = await db.rawQuery(
// //       'SELECT * FROM periods WHERE startTime > ? ORDER BY startTime ASC LIMIT 1',
// //       [currentTime],
// //     );
// //
// //     if (mounted) {
// //       setState(() {
// //         if (result.isEmpty) {
// //           time = "--:--";
// //           nextPeriodInfo = "No more periods today";
// //         } else {
// //           final periodTitle = result.first['title'];
// //           final periodTime = result.first['startTime'];
// //           time = periodTime;
// //           nextPeriodInfo = "Next: $periodTitle";
// //         }
// //       });
// //     }
// //   }
// //
// //   @override
// //   void dispose() {
// //     timer?.cancel();
// //     _animationController.dispose();
// //     super.dispose();
// //   }
// //
// //   // --- NEW AESTHETIC UI WIDGETS SECTION ---
// //
// //   @override
// //   Widget build(BuildContext context) {
// //     return Scaffold(
// //       backgroundColor: const Color(0xFFF4F7FC), // A light, clean background color
// //       body: SafeArea(
// //         child: Padding(
// //           padding: const EdgeInsets.symmetric(horizontal: 16.0),
// //           child: Column(
// //             children: [
// //               const SizedBox(height: 16),
// //               _topBar(),
// //               const SizedBox(height: 24),
// //               _timeCard(),
// //               const SizedBox(height: 24),
// //               _scheduleCard(),
// //               const SizedBox(height: 16),
// //               _actionCardGrid(),
// //               const SizedBox(height: 16),
// //               _emergencyCard(), // The new emergency card
// //               const Spacer(),
// //               // _bottomNav(context), // If you need this, uncomment it
// //             ],
// //           ),
// //         ),
// //       ),
// //     );
// //   }
// //
// //   Widget _topBar() {
// //     return Row(
// //       mainAxisAlignment: MainAxisAlignment.spaceBetween,
// //       children: [
// //         const Text("Dashboard",
// //             style: TextStyle(
// //                 fontSize: 28,
// //                 fontWeight: FontWeight.bold,
// //                 color: Color(0xFF1A2552))),
// //         Container(
// //           padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
// //           decoration: BoxDecoration(
// //             color: espConnected ? Colors.green.shade400 : Colors.red.shade400,
// //             borderRadius: BorderRadius.circular(20),
// //             boxShadow: [
// //               BoxShadow(
// //                   color: espConnected
// //                       ? Colors.green.withOpacity(0.3)
// //                       : Colors.red.withOpacity(0.3),
// //                   blurRadius: 8,
// //                   offset: const Offset(0, 4))
// //             ],
// //           ),
// //           child: Row(
// //             children: [
// //               Icon(espConnected ? Icons.wifi_rounded : Icons.wifi_off_rounded,
// //                   color: Colors.white, size: 18),
// //               const SizedBox(width: 8),
// //               Text(espConnected ? "Connected" : "Offline",
// //                   style: const TextStyle(
// //                       color: Colors.white, fontWeight: FontWeight.w600)),
// //             ],
// //           ),
// //         )
// //       ],
// //     );
// //   }
// //
// //   Widget _timeCard() {
// //     // This creates a "breathing" gradient animation for the background
// //     final tween = MovieTween()
// //       ..tween('begin', ColorTween(begin: Colors.blue.shade300, end: Colors.blue.shade400), duration: const Duration(seconds: 2))
// //       ..tween('end', ColorTween(begin: Colors.purple.shade300, end: Colors.purple.shade400), duration: const Duration(seconds: 2));
// //
// //
// //     return LoopAnimationBuilder<Movie>(
// //       tween: tween,
// //       duration: tween.duration,
// //       builder: (context, value, child) {
// //         return Container(
// //           width: double.infinity,
// //           padding: const EdgeInsets.all(24),
// //           decoration: BoxDecoration(
// //             gradient: LinearGradient(
// //               colors: [value.get('begin'), value.get('end')],
// //               begin: Alignment.topLeft,
// //               end: Alignment.bottomRight,
// //             ),
// //             borderRadius: BorderRadius.circular(24),
// //             boxShadow: [
// //               BoxShadow(
// //                 color: Colors.blue.withOpacity(0.25),
// //                 blurRadius: 15,
// //                 offset: const Offset(0, 8),
// //               )
// //             ],
// //           ),
// //           child: child,
// //         );
// //       },
// //       child: Column(
// //         children: [
// //           Text(date, style: const TextStyle(color: Colors.white70, fontSize: 16)),
// //           const SizedBox(height: 8),
// //           Text(
// //             time,
// //             style: const TextStyle(
// //               fontSize: 64,
// //               color: Colors.white,
// //               fontWeight: FontWeight.bold,
// //               shadows: [
// //                 Shadow(
// //                   color: Colors.black26,
// //                   blurRadius: 10,
// //                   offset: Offset(0, 4),
// //                 )
// //               ],
// //             ),
// //           ),
// //           const SizedBox(height: 12),
// //           Container(
// //             padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
// //             decoration: BoxDecoration(
// //               color: Colors.white.withOpacity(0.2),
// //               borderRadius: BorderRadius.circular(20),
// //             ),
// //             child: Text(nextPeriodInfo,
// //                 style: const TextStyle(
// //                     color: Colors.white,
// //                     fontSize: 14,
// //                     fontWeight: FontWeight.w500)),
// //           )
// //         ],
// //       ),
// //     );
// //   }
// //
// //
// //   Widget _scheduleCard() {
// //     return Card(
// //       elevation: 2,
// //       shape: RoundedRectangleBorder(
// //         borderRadius: BorderRadius.circular(16),
// //       ),
// //       clipBehavior: Clip.antiAlias, // InkWell ripple respects border
// //       child: InkWell(
// //         onTap: () {
// //           Navigator.push(
// //             context,
// //             MaterialPageRoute(
// //               builder: (_) => hasSchedule
// //                   ? const TodaySchedulePage()
// //                   : const CreateCategoryPage(),
// //             ),
// //           );
// //         },
// //         child: Padding(
// //           padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
// //           child: Row(
// //             children: [
// //               Icon(
// //                   hasSchedule
// //                       ? Icons.list_alt_rounded
// //                       : Icons.add_circle_outline_rounded,
// //                   color: Theme.of(context).primaryColor,
// //                   size: 32),
// //               const SizedBox(width: 16),
// //               Expanded(
// //                 child: Text(
// //                   hasSchedule ? "View Schedules" : "Create New Schedule",
// //                   style: const TextStyle(
// //                       fontSize: 18,
// //                       fontWeight: FontWeight.bold,
// //                       color: Color(0xFF1A2552)),
// //                 ),
// //               ),
// //               const Icon(Icons.arrow_forward_ios_rounded,
// //                   color: Colors.grey, size: 18),
// //             ],
// //           ),
// //         ),
// //       ),
// //     );
// //   }
// //
// //   Widget _actionCardGrid() {
// //     return Column(
// //       crossAxisAlignment: CrossAxisAlignment.start,
// //       children: [
// //         const Text(
// //           "Quick Actions",
// //           style: TextStyle(
// //             fontSize: 20,
// //             fontWeight: FontWeight.bold,
// //             color: Color(0xFF1A2552),
// //           ),
// //         ),
// //         const SizedBox(height: 16),
// //         Row(
// //           children: [
// //             _smallActionCard(
// //               "Skip Bell",
// //               Icons.skip_next_rounded,
// //               Colors.orange,
// //                   () async {
// //                 await Esp32ApiService.sendRaw("\$SKIP#");
// //               },
// //             ),
// //             const SizedBox(width: 12),
// //             _smallActionCard(
// //               "Announce",
// //               Icons.campaign_rounded,
// //               Colors.teal,
// //                   () {
// //                 Navigator.push(
// //                   context,
// //                   MaterialPageRoute(
// //                     builder: (context) => const AnnouncementPage(),
// //                   ),
// //                 );
// //               },
// //             ),
// //             const SizedBox(width: 12),
// //             _smallActionCard(
// //               "Manual Ring",
// //               Icons.touch_app_rounded,
// //               Colors.indigo,
// //                   () async {
// //                 await Esp32ApiService.sendRaw("\$T,1#");
// //               },
// //             ),
// //           ],
// //         ),
// //       ],
// //     );
// //   }
// //
// //
// //   Widget _smallActionCard(String title, IconData icon, Color color, VoidCallback onTap) {
// //     return Expanded(
// //       child: InkWell(
// //         onTap: onTap,
// //         borderRadius: BorderRadius.circular(16),
// //         child: Container(
// //           padding: const EdgeInsets.symmetric(vertical: 16),
// //           decoration: BoxDecoration(
// //             color: Colors.white,
// //             borderRadius: BorderRadius.circular(16),
// //             boxShadow: [
// //               BoxShadow(
// //                 color: Colors.grey.withOpacity(0.1),
// //                 blurRadius: 10,
// //                 offset: const Offset(0, 5),
// //               ),
// //             ],
// //             border: Border.all(color: Colors.grey.shade200, width: 1),
// //           ),
// //           child: Column(
// //             mainAxisAlignment: MainAxisAlignment.center,
// //             children: [
// //               Icon(icon, color: color, size: 28),
// //               const SizedBox(height: 8),
// //               Text(
// //                 title,
// //                 textAlign: TextAlign.center,
// //                 style: const TextStyle(
// //                   fontSize: 13,
// //                   fontWeight: FontWeight.w600,
// //                   color: Color(0xFF334268),
// //                 ),
// //               ),
// //             ],
// //           ),
// //         ),
// //       ),
// //     );
// //   }
// //
// //   // --- NEW WIDGET FOR EMERGENCY BUTTON ---
// //   Widget _emergencyCard() {
// //     return Card(
// //       elevation: 4,
// //       color: Colors.red.shade700,
// //       shadowColor: Colors.red.withOpacity(0.4),
// //       shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
// //       clipBehavior: Clip.antiAlias,
// //       child: InkWell(
// //         onTap: () {
// //           // Navigate to your emergency page
// //           Navigator.push(
// //             context,
// //             MaterialPageRoute(builder: (context) => const EmergencyPage()),
// //           );
// //
// //         },
// //         child: const Padding(
// //           padding: EdgeInsets.symmetric(horizontal: 20, vertical: 24),
// //           child: Row(
// //             mainAxisAlignment: MainAxisAlignment.center,
// //             children: [
// //               Icon(Icons.sos_rounded, color: Colors.white, size: 28),
// //               SizedBox(width: 12),
// //               Text(
// //                 "EMERGENCY",
// //                 style: TextStyle(
// //                   fontSize: 20,
// //                   fontWeight: FontWeight.bold,
// //                   color: Colors.white,
// //                   letterSpacing: 1.2,
// //                 ),
// //               ),
// //             ],
// //           ),
// //         ),
// //       ),
// //     );
// //   }
// // }
//
//
//
//
//
//
//
//
//
// import 'dart:async';
// import 'package:flutter/material.dart';
// import 'package:newsyncrotime/pages/emergency/emergency_page.dart';
// import 'package:sqflite/sqflite.dart';
// import 'package:simple_animations/simple_animations.dart'; // Correct import
// import '../../services/esp32_api_service.dart';
// import '../database/app_database.dart';
// import '../pages/announcement/announcement_page.dart';
// import '../pages/category/category_list_page.dart';
// import '../pages/category/create_category_page.dart';
// import '../pages/today_schedule_page.dart';
//
// class DashboardPage extends StatefulWidget {
//   const DashboardPage({super.key});
//
//   @override
//   State<DashboardPage> createState() => _DashboardPageState();
// }
//
// class _DashboardPageState extends State<DashboardPage> with TickerProviderStateMixin {
//   bool espConnected = false;
//   String time = "--:--";
//   String date = "";
//   String nextPeriodInfo = "Loading...";
//   Timer? timer;
//   bool hasSchedule = false;
//
//   late final Future<Database> _dbFuture;
//   late AnimationController _animationController;
//
//   @override
//   void initState() {
//     super.initState();
//     _dbFuture = AppDB.instance.database;
//
//     // Animation controller for the time card's breathing effect
//     _animationController = AnimationController(
//       vsync: this,
//       duration: const Duration(seconds: 2),
//     )..repeat(reverse: true);
//
//     _init();
//   }
//
//   Future<void> _init() async {
//     final db = await _dbFuture;
//
//     final countResult = await db.rawQuery('SELECT COUNT(*) as c FROM categories');
//     if (mounted) {
//       setState(() {
//         final count = countResult.first['c'] as int?;
//         hasSchedule = (count ?? 0) > 0;
//       });
//     }
//
//     _checkEsp();
//     timer = Timer.periodic(const Duration(seconds: 3), (_) {
//       _checkEsp();
//       _loadDateFromEsp();
//       _loadNextPeriod();
//     });
//   }
//
//   Future<void> _checkEsp() async {
//     final connected = await Esp32ApiService.checkConnection();
//     if (mounted) {
//       setState(() => espConnected = connected);
//     }
//   }
//
//   Future<void> _loadDateFromEsp() async {
//     if (!espConnected) return;
//     Esp32ApiService.getStatus();
//   }
//
//   void _parseStatusAndUpdateUI(String statusString) {
//     if (mounted) {
//       final lines = statusString.split('\n');
//       String espDate = "";
//       for (var line in lines) {
//         if (line.startsWith("Date:")) {
//           espDate = line.replaceFirst("Date:", "").trim().split(' ')[0];
//           break;
//         }
//       }
//       setState(() {
//         date = espDate;
//       });
//     }
//   }
//
//   Future<void> _loadNextPeriod() async {
//     final db = await _dbFuture;
//     final now = TimeOfDay.now();
//     final currentTime = '${now.hour.toString().padLeft(2, '0')}:${now.minute.toString().padLeft(2, '0')}';
//
//     final List<Map<String, dynamic>> result = await db.rawQuery(
//       'SELECT * FROM periods WHERE startTime > ? ORDER BY startTime ASC LIMIT 1',
//       [currentTime],
//     );
//
//     if (mounted) {
//       setState(() {
//         if (result.isEmpty) {
//           time = "--:--";
//           nextPeriodInfo = "No more periods today";
//         } else {
//           final periodTitle = result.first['title'];
//           final periodTime = result.first['startTime'];
//           time = periodTime;
//           nextPeriodInfo = "Next: $periodTitle";
//         }
//       });
//     }
//   }
//
//   @override
//   void dispose() {
//     timer?.cancel();
//     _animationController.dispose();
//     super.dispose();
//   }
//
//   // --- NEW AESTHETIC UI WIDGETS SECTION ---
//
//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//       backgroundColor: const Color(0xFFF4F7FC), // A light, clean background color
//       body: SafeArea(
//         child: Padding(
//           padding: const EdgeInsets.symmetric(horizontal: 16.0),
//           // 1. Wrap the Column with a SingleChildScrollView
//           child: SingleChildScrollView(
//             child: Column(
//               children: [
//                 const SizedBox(height: 16),
//                 _topBar(),
//                 const SizedBox(height: 24),
//                 _timeCard(),
//                 const SizedBox(height: 24),
//                 _scheduleCard(),
//                 const SizedBox(height: 16),
//                 _actionCardGrid(),
//                 const SizedBox(height: 16),
//                 _manageSchedulesCard(),
//                 const SizedBox(height: 16),
//                 _emergencyCard(),
//                 // 2. Remove the Spacer() to allow the column to determine its own size
//                 const SizedBox(height: 16), // Add some padding at the bottom
//               ],
//             ),
//           ),
//         ),
//       ),
//     );
//   }
//
//
//   Widget _topBar() {
//     return Row(
//       mainAxisAlignment: MainAxisAlignment.spaceBetween,
//       children: [
//         const Text("Dashboard",
//             style: TextStyle(
//                 fontSize: 28,
//                 fontWeight: FontWeight.bold,
//                 color: Color(0xFF1A2552))),
//         Container(
//           padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
//           decoration: BoxDecoration(
//             color: espConnected ? Colors.green.shade400 : Colors.red.shade400,
//             borderRadius: BorderRadius.circular(20),
//             boxShadow: [
//               BoxShadow(
//                   color: espConnected
//                       ? Colors.green.withOpacity(0.3)
//                       : Colors.red.withOpacity(0.3),
//                   blurRadius: 8,
//                   offset: const Offset(0, 4))
//             ],
//           ),
//           child: Row(
//             children: [
//               Icon(espConnected ? Icons.wifi_rounded : Icons.wifi_off_rounded,
//                   color: Colors.white, size: 18),
//               const SizedBox(width: 8),
//               Text(espConnected ? "Connected" : "Offline",
//                   style: const TextStyle(
//                       color: Colors.white, fontWeight: FontWeight.w600)),
//             ],
//           ),
//         )
//       ],
//     );
//   }
//
//   Widget _timeCard() {
//     // This creates a "breathing" gradient animation for the background
//     final tween = MovieTween()
//       ..tween('begin', ColorTween(begin: Colors.blue.shade300, end: Colors.blue.shade400), duration: const Duration(seconds: 2))
//       ..tween('end', ColorTween(begin: Colors.purple.shade300, end: Colors.purple.shade400), duration: const Duration(seconds: 2));
//
//
//     return LoopAnimationBuilder<Movie>(
//       tween: tween,
//       duration: tween.duration,
//       builder: (context, value, child) {
//         return Container(
//           width: double.infinity,
//           padding: const EdgeInsets.all(24),
//           decoration: BoxDecoration(
//             gradient: LinearGradient(
//               colors: [value.get('begin'), value.get('end')],
//               begin: Alignment.topLeft,
//               end: Alignment.bottomRight,
//             ),
//             borderRadius: BorderRadius.circular(24),
//             boxShadow: [
//               BoxShadow(
//                 color: Colors.blue.withOpacity(0.25),
//                 blurRadius: 15,
//                 offset: const Offset(0, 8),
//               )
//             ],
//           ),
//           child: child,
//         );
//       },
//       child: Column(
//         children: [
//           Text(date, style: const TextStyle(color: Colors.white70, fontSize: 16)),
//           const SizedBox(height: 8),
//           Text(
//             time,
//             style: const TextStyle(
//               fontSize: 64,
//               color: Colors.white,
//               fontWeight: FontWeight.bold,
//               shadows: [
//                 Shadow(
//                   color: Colors.black26,
//                   blurRadius: 10,
//                   offset: Offset(0, 4),
//                 )
//               ],
//             ),
//           ),
//           const SizedBox(height: 12),
//           Container(
//             padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
//             decoration: BoxDecoration(
//               color: Colors.white.withOpacity(0.2),
//               borderRadius: BorderRadius.circular(20),
//             ),
//             child: Text(nextPeriodInfo,
//                 style: const TextStyle(
//                     color: Colors.white,
//                     fontSize: 14,
//                     fontWeight: FontWeight.w500)),
//           )
//         ],
//       ),
//     );
//   }
//
//
//   Widget _scheduleCard() {
//     return Card(
//       elevation: 2,
//       shape: RoundedRectangleBorder(
//         borderRadius: BorderRadius.circular(16),
//       ),
//       clipBehavior: Clip.antiAlias, // InkWell ripple respects border
//       child: InkWell(
//         onTap: () {
//           Navigator.push(
//             context,
//             MaterialPageRoute(
//               builder: (_) => hasSchedule
//                   ? const TodaySchedulePage()
//                   : const CreateCategoryPage(),
//             ),
//           );
//         },
//         child: Padding(
//           padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
//           child: Row(
//             children: [
//               Icon(
//                   hasSchedule
//                       ? Icons.list_alt_rounded
//                       : Icons.add_circle_outline_rounded,
//                   color: Theme.of(context).primaryColor,
//                   size: 32),
//               const SizedBox(width: 16),
//               Expanded(
//                 child: Text(
//                   hasSchedule ? "View Schedules" : "Create New Schedule",
//                   style: const TextStyle(
//                       fontSize: 18,
//                       fontWeight: FontWeight.bold,
//                       color: Color(0xFF1A2552)),
//                 ),
//               ),
//               const Icon(Icons.arrow_forward_ios_rounded,
//                   color: Colors.grey, size: 18),
//             ],
//           ),
//         ),
//       ),
//     );
//   }
//
//   Widget _actionCardGrid() {
//     return Column(
//       crossAxisAlignment: CrossAxisAlignment.start,
//       children: [
//         const Text(
//           "Quick Actions",
//           style: TextStyle(
//             fontSize: 20,
//             fontWeight: FontWeight.bold,
//             color: Color(0xFF1A2552),
//           ),
//         ),
//         const SizedBox(height: 16),
//         Row(
//           children: [
//             _smallActionCard(
//               "Skip Bell",
//               Icons.skip_next_rounded,
//               Colors.orange,
//                   () async {
//                 await Esp32ApiService.sendRaw("\$S#");
//               },
//             ),
//             const SizedBox(width: 12),
//             _smallActionCard(
//               "Announce",
//               Icons.campaign_rounded,
//               Colors.teal,
//                   () {
//                 Navigator.push(
//                   context,
//                   MaterialPageRoute(
//                     builder: (context) => const AnnouncementPage(),
//                   ),
//                 );
//               },
//             ),
//             const SizedBox(width: 12),
//             _smallActionCard(
//               "Manual Ring",
//               Icons.touch_app_rounded,
//               Colors.indigo,
//                   () async {
//                 await Esp32ApiService.sendRaw("\$MR#");
//               },
//             ),
//           ],
//         ),
//       ],
//     );
//   }
//
//
//   Widget _smallActionCard(String title, IconData icon, Color color, VoidCallback onTap) {
//     return Expanded(
//       child: InkWell(
//         onTap: onTap,
//         borderRadius: BorderRadius.circular(16),
//         child: Container(
//           padding: const EdgeInsets.symmetric(vertical: 16),
//           decoration: BoxDecoration(
//             color: Colors.white,
//             borderRadius: BorderRadius.circular(16),
//             boxShadow: [
//               BoxShadow(
//                 color: Colors.grey.withOpacity(0.1),
//                 blurRadius: 10,
//                 offset: const Offset(0, 5),
//               ),
//             ],
//             border: Border.all(color: Colors.grey.shade200, width: 1),
//           ),
//           child: Column(
//             mainAxisAlignment: MainAxisAlignment.center,
//             children: [
//               Icon(icon, color: color, size: 28),
//               const SizedBox(height: 8),
//               Text(
//                 title,
//                 textAlign: TextAlign.center,
//                 style: const TextStyle(
//                   fontSize: 13,
//                   fontWeight: FontWeight.w600,
//                   color: Color(0xFF334268),
//                 ),
//               ),
//             ],
//           ),
//         ),
//       ),
//     );
//   }
//
//   // --- NEW WIDGET FOR EMERGENCY BUTTON ---
//   Widget _emergencyCard() {
//     return Card(
//       elevation: 4,
//       color: Colors.red.shade700,
//       shadowColor: Colors.red.withOpacity(0.4),
//       shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
//       clipBehavior: Clip.antiAlias,
//       child: InkWell(
//         onTap: () {
//           // Navigate to your emergency page
//           Navigator.push(
//             context,
//             MaterialPageRoute(builder: (context) => const EmergencyPage()),
//           );
//
//         },
//         child: const Padding(
//           padding: EdgeInsets.symmetric(horizontal: 20, vertical: 24),
//           child: Row(
//             mainAxisAlignment: MainAxisAlignment.center,
//             children: [
//               Icon(Icons.sos_rounded, color: Colors.white, size: 28),
//               SizedBox(width: 12),
//               Text(
//                 "EMERGENCY",
//                 style: TextStyle(
//                   fontSize: 20,
//                   fontWeight: FontWeight.bold,
//                   color: Colors.white,
//                   letterSpacing: 1.2,
//                 ),
//               ),
//             ],
//           ),
//         ),
//       ),
//     );
//   }
//
//   // --- NEW WIDGET FOR MANAGING SCHEDULES ---
//   Widget _manageSchedulesCard() {
//     return Card(
//       elevation: 2,
//       shape: RoundedRectangleBorder(
//         borderRadius: BorderRadius.circular(16),
//       ),
//       clipBehavior: Clip.antiAlias,
//       child: InkWell(
//         onTap: () {
//           Navigator.push(
//             context,
//             MaterialPageRoute(builder: (_) => const CategoryListPage()),
//           );
//         },
//         child: Padding(
//           padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
//           child: Row(
//             children: [
//               Icon(
//                 Icons.settings_rounded,
//                 color: Theme.of(context).primaryColor,
//                 size: 32,
//               ),
//               const SizedBox(width: 16),
//               const Expanded(
//                 child: Text(
//                   "Manage Schedules",
//                   style: TextStyle(
//                     fontSize: 18,
//                     fontWeight: FontWeight.bold,
//                     color: Color(0xFF1A2552),
//                   ),
//                 ),
//               ),
//               const Icon(
//                 Icons.arrow_forward_ios_rounded,
//                 color: Colors.grey,
//                 size: 18,
//               ),
//             ],
//           ),
//         ),
//       ),
//     );
//   }
// }
//
//
//
//
//
//
//
//
//
//
//
//
//
//
//
//
//
//
//
//
//
//
//
//
//
//
//
//
//
//
//
//
//
//
//
//
//
//
//
//
//
//
//
//
//
//
//
//
//
//
//
//
//
//
// import 'dart:async';
// import 'package:flutter/material.dart';
// import 'package:lottie/lottie.dart';
// import 'package:sqflite/sqflite.dart';
//
// import '../../services/esp32_api_service.dart';
// import '../database/app_database.dart';
// import '../pages/announcement/announcement_page.dart';
// import '../pages/category/category_list_page.dart';
// import '../pages/category/create_category_page.dart';
// import '../pages/emergency/emergency_page.dart';
// import '../pages/today_schedule_page.dart';
//
// class DashboardPage extends StatefulWidget {
//   const DashboardPage({super.key});
//
//   @override
//   State<DashboardPage> createState() => _DashboardPageState();
// }
//
// class _DashboardPageState extends State<DashboardPage> {
//   bool espConnected = false;
//   String time = "--:--";
//   String date = "";
//   String nextPeriodInfo = "Loading...";
//   Timer? timer;
//   bool hasSchedule = false;
//
//   late final Future<Database> _dbFuture;
//
//   // ───────────────────── LOGIC (UNCHANGED) ─────────────────────
//
//   @override
//   void initState() {
//     super.initState();
//     _dbFuture = AppDB.instance.database;
//     _init();
//   }
//
//   Future<void> _init() async {
//     final db = await _dbFuture;
//
//     final countResult =
//     await db.rawQuery('SELECT COUNT(*) as c FROM categories');
//     if (mounted) {
//       setState(() {
//         final count = countResult.first['c'] as int?;
//         hasSchedule = (count ?? 0) > 0;
//       });
//     }
//
//     _checkEsp();
//     timer = Timer.periodic(const Duration(seconds: 3), (_) {
//       _checkEsp();
//       _loadDateFromEsp();
//       _loadNextPeriod();
//     });
//   }
//
//   Future<void> _checkEsp() async {
//     final connected = await Esp32ApiService.checkConnection();
//     if (mounted) setState(() => espConnected = connected);
//   }
//
//   Future<void> _loadDateFromEsp() async {
//     if (!espConnected) return;
//     Esp32ApiService.getStatus();
//   }
//
//   Future<void> _loadNextPeriod() async {
//     final db = await _dbFuture;
//     final now = TimeOfDay.now();
//     final currentTime =
//         '${now.hour.toString().padLeft(2, '0')}:${now.minute.toString().padLeft(2, '0')}';
//
//     final result = await db.rawQuery(
//       'SELECT * FROM periods WHERE startTime > ? ORDER BY startTime ASC LIMIT 1',
//       [currentTime],
//     );
//
//     if (!mounted) return;
//
//     setState(() {
//       if (result.isEmpty) {
//         time = "--:--";
//         nextPeriodInfo = "No more periods today";
//       } else {
//         time = result.first['startTime'] as String;
//         nextPeriodInfo = "Next: ${result.first['title'] as String}";
//       }
//     });
//
//   }
//
//   @override
//   void dispose() {
//     timer?.cancel();
//     super.dispose();
//   }
//
//   // ───────────────────── UI (APPLE-LEVEL) ─────────────────────
//
//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//       backgroundColor: const Color(0xFFF2F2F7), // iOS grouped background
//       body: SafeArea(
//         child: ListView(
//           padding: const EdgeInsets.fromLTRB(16, 20, 16, 32),
//           children: [
//             _topBar(),
//             const SizedBox(height: 28),
//             _timeHeroCard(),
//             const SizedBox(height: 28),
//             _primaryActionCard(),
//             const SizedBox(height: 32),
//             _sectionTitle("Quick Actions"),
//             const SizedBox(height: 16),
//             _quickActionsRow(),
//             const SizedBox(height: 32),
//             _secondaryActionCard(),
//             const SizedBox(height: 24),
//             _emergencyCard(),
//           ],
//         ),
//       ),
//     );
//   }
//
//   // ───────────────────── TOP BAR ─────────────────────
//
//   Widget _topBar() {
//     return Row(
//       mainAxisAlignment: MainAxisAlignment.spaceBetween,
//       children: [
//         const Text(
//           "Dashboard",
//           style: TextStyle(
//             fontSize: 34,
//             fontWeight: FontWeight.w700,
//             letterSpacing: -0.5,
//             color: Colors.black,
//           ),
//         ),
//         Container(
//           padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 6),
//           decoration: BoxDecoration(
//             color: espConnected
//                 ? const Color(0xFFDFF5E3)
//                 : const Color(0xFFFCE4E4),
//             borderRadius: BorderRadius.circular(20),
//           ),
//           child: Row(
//             children: [
//               Icon(
//                 espConnected ? Icons.wifi : Icons.wifi_off,
//                 size: 16,
//                 color: espConnected
//                     ? const Color(0xFF2E7D32)
//                     : const Color(0xFFC62828),
//               ),
//               const SizedBox(width: 6),
//               Text(
//                 espConnected ? "Connected" : "Offline",
//                 style: TextStyle(
//                   fontSize: 13,
//                   fontWeight: FontWeight.w600,
//                   color: espConnected
//                       ? const Color(0xFF2E7D32)
//                       : const Color(0xFFC62828),
//                 ),
//               ),
//             ],
//           ),
//         )
//       ],
//     );
//   }
//
//   // ───────────────────── TIME HERO ─────────────────────
//
//   Widget _timeHeroCard() {
//     return Container(
//       padding: const EdgeInsets.all(24),
//       decoration: BoxDecoration(
//         color: const Color(0xFFFFFFFF),
//         borderRadius: BorderRadius.circular(28),
//       ),
//       child: Column(
//         children: [
//           SizedBox(
//             height: 120,
//             child: Lottie.asset(
//               'assets/lottie/clock.json',
//               repeat: true,
//             ),
//           ),
//           const SizedBox(height: 12),
//           Text(
//             time,
//             style: const TextStyle(
//               fontSize: 64,
//               fontWeight: FontWeight.w700,
//               letterSpacing: -1.5,
//               color: Colors.black,
//             ),
//           ),
//           const SizedBox(height: 6),
//           Text(
//             nextPeriodInfo,
//             textAlign: TextAlign.center,
//             style: const TextStyle(
//               fontSize: 15,
//               fontWeight: FontWeight.w500,
//               color: Color(0xFF6E6E73),
//             ),
//           ),
//         ],
//       ),
//     );
//   }
//
//   // ───────────────────── PRIMARY ACTION ─────────────────────
//
//   Widget _primaryActionCard() {
//     return _iosNavCard(
//       icon: Icons.calendar_today_rounded,
//       title: hasSchedule ? "View Today’s Schedule" : "Create Schedule",
//       onTap: () {
//         Navigator.push(
//           context,
//           MaterialPageRoute(
//             builder: (_) =>
//             hasSchedule ? const TodaySchedulePage() : const CreateCategoryPage(),
//           ),
//         );
//       },
//     );
//   }
//
//   // ───────────────────── QUICK ACTIONS ─────────────────────
//
//   Widget _quickActionsRow() {
//     return Row(
//       children: [
//         _quickAction(
//           "Skip Bell",
//           Icons.skip_next_rounded,
//               () => Esp32ApiService.sendRaw("\$S#"),
//         ),
//         const SizedBox(width: 12),
//         _quickAction(
//           "Announce",
//           Icons.campaign_rounded,
//               () {
//             Navigator.push(
//               context,
//               MaterialPageRoute(builder: (_) => const AnnouncementPage()),
//             );
//           },
//         ),
//         const SizedBox(width: 12),
//         _quickAction(
//           "Manual Ring",
//           Icons.touch_app_rounded,
//               () => Esp32ApiService.sendRaw("\$MR#"),
//         ),
//       ],
//     );
//   }
//
//   Widget _quickAction(String label, IconData icon, VoidCallback onTap) {
//     return Expanded(
//       child: InkWell(
//         onTap: onTap,
//         borderRadius: BorderRadius.circular(22),
//         child: Container(
//           padding: const EdgeInsets.symmetric(vertical: 18),
//           decoration: BoxDecoration(
//             color: const Color(0xFFFFFFFF),
//             borderRadius: BorderRadius.circular(22),
//           ),
//           child: Column(
//             children: [
//               Icon(icon, size: 26, color: const Color(0xFF007AFF)),
//               const SizedBox(height: 10),
//               Text(
//                 label,
//                 style: const TextStyle(
//                   fontSize: 13,
//                   fontWeight: FontWeight.w600,
//                 ),
//               )
//             ],
//           ),
//         ),
//       ),
//     );
//   }
//
//   // ───────────────────── SECONDARY ─────────────────────
//
//   Widget _secondaryActionCard() {
//     return _iosNavCard(
//       icon: Icons.settings_rounded,
//       title: "Manage Schedules",
//       onTap: () {
//         Navigator.push(
//           context,
//           MaterialPageRoute(builder: (_) => const CategoryListPage()),
//         );
//       },
//     );
//   }
//
//   Widget _iosNavCard({
//     required IconData icon,
//     required String title,
//     required VoidCallback onTap,
//   }) {
//     return InkWell(
//       onTap: onTap,
//       borderRadius: BorderRadius.circular(24),
//       child: Container(
//         padding: const EdgeInsets.all(20),
//         decoration: BoxDecoration(
//           color: const Color(0xFFFFFFFF),
//           borderRadius: BorderRadius.circular(24),
//         ),
//         child: Row(
//           children: [
//             Icon(icon, size: 26, color: const Color(0xFF007AFF)),
//             const SizedBox(width: 16),
//             Expanded(
//               child: Text(
//                 title,
//                 style: const TextStyle(
//                   fontSize: 17,
//                   fontWeight: FontWeight.w600,
//                 ),
//               ),
//             ),
//             const Icon(
//               Icons.chevron_right,
//               size: 22,
//               color: Color(0xFFAEAEB2),
//             ),
//           ],
//         ),
//       ),
//     );
//   }
//
//   // ───────────────────── EMERGENCY ─────────────────────
//
//   Widget _emergencyCard() {
//     return InkWell(
//       borderRadius: BorderRadius.circular(28),
//       onTap: () {
//         Navigator.push(
//           context,
//           MaterialPageRoute(builder: (_) => const EmergencyPage()),
//         );
//       },
//       child: Container(
//         padding: const EdgeInsets.symmetric(vertical: 22),
//         decoration: BoxDecoration(
//           color: const Color(0xFFFF3B30), // iOS system red
//           borderRadius: BorderRadius.circular(28),
//         ),
//         child: const Center(
//           child: Text(
//             "EMERGENCY",
//             style: TextStyle(
//               fontSize: 20,
//               fontWeight: FontWeight.w700,
//               letterSpacing: 1.1,
//               color: Colors.white,
//             ),
//           ),
//         ),
//       ),
//     );
//   }
//
//   // ───────────────────── HELPERS ─────────────────────
//
//   Widget _sectionTitle(String text) {
//     return Text(
//       text,
//       style: const TextStyle(
//         fontSize: 20,
//         fontWeight: FontWeight.w700,
//         letterSpacing: -0.3,
//         color: Colors.black,
//       ),
//     );
//   }
// }








import 'dart:async';
import 'package:flutter/material.dart';
import 'package:lottie/lottie.dart';
import 'package:sqflite/sqflite.dart';

import '../../services/esp32_api_service.dart';
import '../database/app_database.dart';
import '../pages/announcement/announcement_page.dart';
import '../pages/category/category_list_page.dart';
import '../pages/category/create_category_page.dart';
import '../pages/emergency/emergency_page.dart';
import '../pages/today_schedule_page.dart';

class DashboardPage extends StatefulWidget {
  const DashboardPage({super.key});

  @override
  State<DashboardPage> createState() => _DashboardPageState();
}

class _DashboardPageState extends State<DashboardPage> {
  bool espConnected = false;
  String time = "--:--";
  String date = "";
  String nextPeriodInfo = "Loading...";
  Timer? timer;
  bool hasSchedule = false;

  late final Future<Database> _dbFuture;

  // ───────────────────── LOGIC (MODIFIED) ─────────────────────

  @override
  void initState() {
    super.initState();
    _dbFuture = AppDB.instance.database;
    _init();
  }

  Future<void> _init() async {
    final db = await _dbFuture;

    final countResult =
    await db.rawQuery('SELECT COUNT(*) as c FROM categories');
    if (mounted) {
      setState(() {
        final count = countResult.first['c'] as int?;
        hasSchedule = (count ?? 0) > 0;
      });
    }

    _checkEsp();
    // Modified Timer: Removed the call to _loadDateFromEsp
    timer = Timer.periodic(const Duration(seconds: 3), (_) {
      _checkEsp();
      _loadNextPeriod();
    });
  }

  Future<void> _checkEsp() async {
    final connected = await Esp32ApiService.checkConnection();
    if (mounted) setState(() => espConnected = connected);
  }

  // REMOVED: The _loadDateFromEsp function has been deleted as it sent the status.
  // Future<void> _loadDateFromEsp() async {
  //   if (!espConnected) return;
  //   Esp32ApiService.getStatus();
  // }

  Future<void> _loadNextPeriod() async {
    final db = await _dbFuture;
    final now = TimeOfDay.now();
    final currentTime =
        '${now.hour.toString().padLeft(2, '0')}:${now.minute.toString().padLeft(2, '0')}';

    final result = await db.rawQuery(
      'SELECT * FROM periods WHERE startTime > ? ORDER BY startTime ASC LIMIT 1',
      [currentTime],
    );

    if (!mounted) return;

    setState(() {
      if (result.isEmpty) {
        time = "--:--";
        nextPeriodInfo = "No more periods today";
      } else {
        time = result.first['startTime'] as String;
        nextPeriodInfo = "Next: ${result.first['title'] as String}";
      }
    });

  }

  @override
  void dispose() {
    timer?.cancel();
    super.dispose();
  }

  // ───────────────────── UI (UNCHANGED) ─────────────────────

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF2F2F7), // iOS grouped background
      body: SafeArea(
        child: ListView(
          padding: const EdgeInsets.fromLTRB(16, 20, 16, 32),
          children: [
            _topBar(),
            const SizedBox(height: 28),
            _timeHeroCard(),
            const SizedBox(height: 28),
            _primaryActionCard(),
            const SizedBox(height: 32),
            _sectionTitle("Quick Actions"),
            const SizedBox(height: 16),
            _quickActionsRow(),
            const SizedBox(height: 32),
            _secondaryActionCard(),
            const SizedBox(height: 24),
            _emergencyCard(),
          ],
        ),
      ),
    );
  }

  // ───────────────────── TOP BAR ─────────────────────

  Widget _topBar() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        const Text(
          "Dashboard",
          style: TextStyle(
            fontSize: 34,
            fontWeight: FontWeight.w700,
            letterSpacing: -0.5,
            color: Colors.black,
          ),
        ),
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 6),
          decoration: BoxDecoration(
            color: espConnected
                ? const Color(0xFFDFF5E3)
                : const Color(0xFFFCE4E4),
            borderRadius: BorderRadius.circular(20),
          ),
          child: Row(
            children: [
              Icon(
                espConnected ? Icons.wifi : Icons.wifi_off,
                size: 16,
                color: espConnected
                    ? const Color(0xFF2E7D32)
                    : const Color(0xFFC62828),
              ),
              const SizedBox(width: 6),
              Text(
                espConnected ? "Connected" : "Offline",
                style: TextStyle(
                  fontSize: 13,
                  fontWeight: FontWeight.w600,
                  color: espConnected
                      ? const Color(0xFF2E7D32)
                      : const Color(0xFFC62828),
                ),
              ),
            ],
          ),
        )
      ],
    );
  }

  // ───────────────────── TIME HERO ─────────────────────

  Widget _timeHeroCard() {
    return Container(
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: const Color(0xFFFFFFFF),
        borderRadius: BorderRadius.circular(28),
      ),
      child: Column(
        children: [
          SizedBox(
            height: 120,
            child: Lottie.asset(
              'assets/lottie/clock.json',
              repeat: true,
            ),
          ),
          const SizedBox(height: 12),
          Text(
            time,
            style: const TextStyle(
              fontSize: 64,
              fontWeight: FontWeight.w700,
              letterSpacing: -1.5,
              color: Colors.black,
            ),
          ),
          const SizedBox(height: 6),
          Text(
            nextPeriodInfo,
            textAlign: TextAlign.center,
            style: const TextStyle(
              fontSize: 15,
              fontWeight: FontWeight.w500,
              color: Color(0xFF6E6E73),
            ),
          ),
        ],
      ),
    );
  }

  // ───────────────────── PRIMARY ACTION ─────────────────────

  Widget _primaryActionCard() {
    return _iosNavCard(
      icon: Icons.calendar_today_rounded,
      title: hasSchedule ? "View Today’s Schedule" : "Create Schedule",
      onTap: () {
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (_) =>
            hasSchedule ? const TodaySchedulePage() : const CreateCategoryPage(),
          ),
        );
      },
    );
  }

  // ───────────────────── QUICK ACTIONS ─────────────────────

  Widget _quickActionsRow() {
    return Row(
      children: [
        _quickAction(
          "Skip Bell",
          Icons.skip_next_rounded,
              () => Esp32ApiService.sendRaw("\$S#"),
        ),
        const SizedBox(width: 12),
        _quickAction(
          "Announce",
          Icons.campaign_rounded,
              () {
            Navigator.push(
              context,
              MaterialPageRoute(builder: (_) => const AnnouncementPage()),
            );
          },
        ),
        const SizedBox(width: 12),
        _quickAction(
          "Manual Ring",
          Icons.touch_app_rounded,
              () => Esp32ApiService.sendRaw("\$T,mr.mp3#"),
        ),
      ],
    );
  }

  Widget _quickAction(String label, IconData icon, VoidCallback onTap) {
    return Expanded(
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(22),
        child: Container(
          padding: const EdgeInsets.symmetric(vertical: 18),
          decoration: BoxDecoration(
            color: const Color(0xFFFFFFFF),
            borderRadius: BorderRadius.circular(22),
          ),
          child: Column(
            children: [
              Icon(icon, size: 26, color: const Color(0xFF007AFF)),
              const SizedBox(height: 10),
              Text(
                label,
                style: const TextStyle(
                  fontSize: 13,
                  fontWeight: FontWeight.w600,
                ),
              )
            ],
          ),
        ),
      ),
    );
  }

  // ───────────────────── SECONDARY ─────────────────────

  Widget _secondaryActionCard() {
    return _iosNavCard(
      icon: Icons.settings_rounded,
      title: "Manage Schedules",
      onTap: () {
        Navigator.push(
          context,
          MaterialPageRoute(builder: (_) => const CategoryListPage()),
        );
      },
    );
  }

  Widget _iosNavCard({
    required IconData icon,
    required String title,
    required VoidCallback onTap,
  }) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(24),
      child: Container(
        padding: const EdgeInsets.all(20),
        decoration: BoxDecoration(
          color: const Color(0xFFFFFFFF),
          borderRadius: BorderRadius.circular(24),
        ),
        child: Row(
          children: [
            Icon(icon, size: 26, color: const Color(0xFF007AFF)),
            const SizedBox(width: 16),
            Expanded(
              child: Text(
                title,
                style: const TextStyle(
                  fontSize: 17,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
            const Icon(
              Icons.chevron_right,
              size: 22,
              color: Color(0xFFAEAEB2),
            ),
          ],
        ),
      ),
    );
  }

  // ───────────────────── EMERGENCY ─────────────────────

  Widget _emergencyCard() {
    return InkWell(
      borderRadius: BorderRadius.circular(28),
      onTap: () {
        Navigator.push(
          context,
          MaterialPageRoute(builder: (_) => const EmergencyPage()),
        );
      },
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 22),
        decoration: BoxDecoration(
          color: const Color(0xFFFF3B30), // iOS system red
          borderRadius: BorderRadius.circular(28),
        ),
        child: const Center(
          child: Text(
            "EMERGENCY",
            style: TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.w700,
              letterSpacing: 1.1,
              color: Colors.white,
            ),
          ),
        ),
      ),
    );
  }

  // ───────────────────── HELPERS ─────────────────────

  Widget _sectionTitle(String text) {
    return Text(
      text,
      style: const TextStyle(
        fontSize: 20,
        fontWeight: FontWeight.w700,
        letterSpacing: -0.3,
        color: Colors.black,
      ),
    );
  }
}
