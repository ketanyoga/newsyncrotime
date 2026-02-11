import 'package:flutter/material.dart';
import 'database/dashboard_page.dart';

void main() {
  // Ensures that Flutter's widget binding is ready before running the app.
  WidgetsFlutterBinding.ensureInitialized();
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Synncrotime',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        primarySwatch: Colors.blue,
        // Using ColorScheme for more modern theming
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.blueAccent),
        useMaterial3: true,
      ),
      // Set the SplashScreen as the entry point of the app.
      // The SplashScreen will then handle navigating to the DashboardPage.
      home: const DashboardPage(),
    );
  }
}
