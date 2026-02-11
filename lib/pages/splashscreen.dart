import 'package:animated_splash_screen/animated_splash_screen.dart';
import 'package:flutter/material.dart';
import 'package:lottie/lottie.dart';

import 'category/category_list_page.dart';

class SplashScreen extends StatelessWidget {
  const SplashScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return AnimatedSplashScreen(
      splash: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            // Lottie Animation
            Lottie.asset(
              'assets/lottie/blue loading.json', // Your Lottie file path
              width: 300,
              height: 300,
            ),
            const SizedBox(height: 20),

            // Animated Text
            const Text(
              'SYNNCROTIME',
              style: TextStyle(
                fontSize: 32,
                fontWeight: FontWeight.bold,
                color: Colors.blueAccent, // Choose a color you like
              ),
            ),
            const SizedBox(height: 100),

            // Company Logo at the bottom
            Image.asset(
              'assets/images/ic_spjlogo.png', // Your company logo path
              width: 100,
            ),
          ],
        ),
      ),
      // The next screen to show after the splash screen is done
      nextScreen: const CategoryListPage(), // Changed this from DashboardPage
      splashIconSize: 600, // Increase size to fit all content
      duration: 3000, // Splash screen duration in milliseconds (e.g., 3 seconds)
      backgroundColor: Colors.white, // Background color of the splash screen
    );
  }
}