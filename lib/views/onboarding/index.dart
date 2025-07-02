import 'package:back2u/l10n/app_localizations.dart';
import 'package:back2u/views/onboarding/connect_page.dart';
import 'package:back2u/views/onboarding/how_it_works_oage.dart';
import 'package:back2u/views/onboarding/welcome_page.dart';
import 'package:back2u/views/onboarding/get_started_page.dart';
import 'package:flutter/material.dart';
import 'package:smooth_page_indicator/smooth_page_indicator.dart';
import 'package:back2u/views/home/index.dart'; // Ensure this path is correct
// import 'package:back2u/views/onboarding/pages/welcome_page.dart';
// import 'package:back2u/views/onboarding/pages/how_it_works_page.dart';
// import 'package:back2u/views/onboarding/pages/connect_page.dart';
// import 'package:back2u/views/onboarding/pages/get_started_page.dart';

class Onboarding extends StatefulWidget {
  const Onboarding({super.key});

  @override
  State<Onboarding> createState() => _OnboardingState();
}

class _OnboardingState extends State<Onboarding> {
  final PageController _pageController = PageController();
  bool _isLastPage = false;

  @override
  void initState() {
    super.initState();
    _pageController.addListener(() {
      setState(() {
        _isLastPage = (_pageController.page?.round() == 3); // Index 3 is the 4th page (GetStartedPage)
      });
    });
  }

  @override
  void dispose() {
    _pageController.dispose();
    super.dispose();
  }

  void _navigateToHome() {
    Navigator.pushReplacement(
      context,
      MaterialPageRoute(builder: (context) => const Home()),
    );
  }

  @override
  Widget build(BuildContext context) {
    // Using Material 3 colors from the theme
    final ColorScheme colorScheme = Theme.of(context).colorScheme;
    final loc = AppLocalizations.of(context);

    return Scaffold(
      body: SafeArea(child:Stack(
        children: [
          PageView(
            controller: _pageController,
            onPageChanged: (index) {
              setState(() {
                _isLastPage = (index == 3); // Update _isLastPage based on current page index
              });
            },
            children: const [
              WelcomePage(),
              HowItWorksPage(),
              ConnectPage(),
              GetStartedPage(),
            ],
          ),

          // Skip button
          Positioned(
            top: MediaQuery.of(context).padding.top + 16.0, // Adjust for safe area
            right: 16.0,
            child: TextButton(
              onPressed: _navigateToHome,
              style: TextButton.styleFrom(
                foregroundColor: colorScheme.onBackground, // Use theme color
                textStyle: Theme.of(context).textTheme.titleMedium?.copyWith(
                  fontWeight: FontWeight.bold,
                ),
              ),
              child: Text(loc.skip),
            ),
          ),

          // Bottom navigation area (dots and buttons)
          Align(
            alignment: Alignment.bottomCenter,
            child: Padding(
              padding: const EdgeInsets.only(bottom: 40.0, left: 24.0, right: 24.0),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  // Page Indicator Dots
                  SmoothPageIndicator(
                    controller: _pageController,
                    count: 4, // Number of onboarding pages
                    effect: ExpandingDotsEffect(
                      activeDotColor: colorScheme.primary, // Material 3 primary color
                      dotColor: colorScheme.onSurfaceVariant, // Material 3 secondary color
                      dotHeight: 8.0,
                      dotWidth: 8.0,
                      spacing: 4.0,
                    ),
                  ),

                  // Next / Get Started Button
                  ElevatedButton(
                    onPressed: () {
                      if (_isLastPage) {
                        _navigateToHome();
                      } else {
                        _pageController.nextPage(
                          duration: const Duration(milliseconds: 400),
                          curve: Curves.easeIn,
                        );
                      }
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: colorScheme.primary, // Material 3 primary color
                      foregroundColor: colorScheme.onPrimary, // Text color on primary
                      padding: const EdgeInsets.symmetric(horizontal: 30, vertical: 12),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(20), // Rounded corners
                      ),
                      textStyle: Theme.of(context).textTheme.titleMedium?.copyWith(
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    child: Text(_isLastPage ? loc.getStarted : loc.next),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    ),
  );}
}