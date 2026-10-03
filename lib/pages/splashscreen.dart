import 'dart:io';
import 'package:animated_splash_screen/animated_splash_screen.dart';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'dashboard/dashboard_page.dart';

class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> {
  String? _orgName;
  String? _logoPath;
  bool _isLoaded = false;

  @override
  void initState() {
    super.initState();
    _loadBranding();
  }

  Future<void> _loadBranding() async {
    final prefs = await SharedPreferences.getInstance();
    if (mounted) {
      setState(() {
        _orgName = prefs.getString('org_name');
        _logoPath = prefs.getString('org_logo');
        _isLoaded = true;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    if (!_isLoaded) return const Scaffold(backgroundColor: Colors.white);

    return AnimatedSplashScreen(
      splash: Material(
        color: Colors.white,
        child: Column(
          children: [
            const Spacer(flex: 4),

            // Organisation or App Logo
            _logoPath != null
                ? Image.file(
                    File(_logoPath!),
                    width: 260,
                    height: 260,
                    fit: BoxFit.contain,
                  )
                : Image.asset(
                    'assets/images/syncrobelllogo.png',
                    width: 260,
                    height: 260,
                  ),
            const SizedBox(height: 24),

            // Organisation or App Name
            Text(
              (_orgName != null && _orgName!.isNotEmpty) ? _orgName!.toUpperCase() : 'SYNCROBELL',
              textAlign: TextAlign.center,
              style: const TextStyle(
                fontSize: 32,
                fontWeight: FontWeight.w900,
                letterSpacing: 1.5,
                color: Color(0xFF007AFF),
              ),
            ),

            const Spacer(flex: 5),

            // Professional Footer
            const Text(
              'POWERED BY',
              style: TextStyle(
                fontSize: 10,
                fontWeight: FontWeight.w700,
                letterSpacing: 2.0,
                color: Color(0xFF8E8E93),
              ),
            ),
            const SizedBox(height: 8),
            const Text(
              'SPJ EMBEDDED TECHNOLOGY PVT LTD',
              style: TextStyle(
                fontSize: 12,
                fontWeight: FontWeight.w800,
                letterSpacing: 0.5,
                color: Colors.black87,
              ),
            ),
            const SizedBox(height: 16),
            Image.asset(
              'assets/images/ic_spjlogo.png',
              width: 50,
            ),
          ],
        ),
      ),
      nextScreen: const DashboardPage(),
      splashIconSize: 800,
      duration: 3000,
      backgroundColor: Colors.white,
      splashTransition: SplashTransition.fadeTransition,
    );
  }
}
