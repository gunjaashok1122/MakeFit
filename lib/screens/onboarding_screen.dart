import 'package:flutter/material';
import '../themes/app_theme.dart';
import '../widgets/neon_button.dart';
import 'auth_screen.dart';

class OnboardingScreen extends StatefulWidget {
  const OnboardingScreen({Key? key}) : super(key: key);

  @override
  State<OnboardingScreen> createState() => _OnboardingScreenState();
}

class _OnboardingScreenState extends State<OnboardingScreen> {
  final PageController _pageController = PageController();
  int _currentPage = 0;

  final List<OnboardingData> _onboardingPages = [
    OnboardingData(
      title: 'Track Your Workouts',
      description: 'Track workouts, steps, calories and all your activities in one place.',
      icon: Icons.directions_run_rounded,
      glowColor: AppTheme.neonPurple,
    ),
    OnboardingData(
      title: 'Stay Healthy Every Day',
      description: 'Set goals, build healthy habits and stay consistent for a better you.',
      icon: Icons.spa_rounded,
      glowColor: AppTheme.neonBlue,
    ),
    OnboardingData(
      title: 'Achieve Your Fitness Goals',
      description: 'Get insights, track progress and achieve your fitness goals faster.',
      icon: Icons.emoji_events_rounded,
      glowColor: AppTheme.neonPink,
    ),
  ];

  @override
  void dispose() {
    _pageController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        decoration: const BoxDecoration(
          gradient: AppTheme.bgGradient,
        ),
        child: SafeArea(
          child: Column(
            children: [
              // Skip Button
              Align(
                alignment: Alignment.topRight,
                child: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                  child: TextButton(
                    onPressed: _goToLogin,
                    child: const Text(
                      'Skip',
                      style: TextStyle(
                        color: AppTheme.textGrey,
                        fontSize: 16,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ),
                ),
              ),
              // Sliding view
              Expanded(
                child: PageView.builder(
                  controller: _pageController,
                  onPageChanged: (index) {
                    setState(() {
                      _currentPage = index;
                    });
                  },
                  itemCount: _onboardingPages.length,
                  itemBuilder: (context, index) {
                    final data = _onboardingPages[index];
                    return Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 32.0),
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          // Styled Neon Icon representation
                          Container(
                            height: 220,
                            width: 220,
                            decoration: BoxDecoration(
                              shape: BoxShape.circle,
                              color: data.glowColor.withOpacity(0.06),
                              border: Border.all(
                                color: data.glowColor.withOpacity(0.2),
                                width: 2,
                              ),
                              boxShadow: [
                                BoxShadow(
                                  color: data.glowColor.withOpacity(0.1),
                                  blurRadius: 40,
                                  spreadRadius: 5,
                                ),
                              ],
                            ),
                            child: Center(
                              child: Icon(
                                data.icon,
                                size: 100,
                                color: data.glowColor,
                              ),
                            ),
                          ),
                          const SizedBox(height: 50),
                          // Title
                          Text(
                            data.title,
                            textAlign: TextAlign.center,
                            style: const TextStyle(
                              fontSize: 28,
                              fontWeight: FontWeight.bold,
                              color: AppTheme.textWhite,
                              fontFamily: 'Outfit',
                            ),
                          ),
                          const SizedBox(height: 16),
                          // Description
                          Text(
                            data.description,
                            textAlign: TextAlign.center,
                            style: const TextStyle(
                              fontSize: 15,
                              color: AppTheme.textGrey,
                              height: 1.5,
                            ),
                          ),
                        ],
                      ),
                    );
                  },
                ),
              ),
              // Pagination and Action Buttons
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 32.0, vertical: 32),
                child: Column(
                  children: [
                    // Dot Indicator
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: List.generate(
                        _onboardingPages.length,
                        (index) => AnimatedContainer(
                          duration: const Duration(milliseconds: 300),
                          margin: const EdgeInsets.symmetric(horizontal: 4),
                          height: 8,
                          width: _currentPage == index ? 24 : 8,
                          decoration: BoxDecoration(
                            borderRadius: BorderRadius.circular(4),
                            color: _currentPage == index
                                ? AppTheme.neonPurple
                                : AppTheme.cardNavyLight,
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(height: 40),
                    // Action Neon Button
                    NeonButton(
                      onTap: () {
                        if (_currentPage < _onboardingPages.length - 1) {
                          _pageController.nextPage(
                            duration: const Duration(milliseconds: 500),
                            curve: Curves.easeInOutCubic,
                          );
                        } else {
                          _goToLogin();
                        }
                      },
                      child: Text(
                        _currentPage == _onboardingPages.length - 1
                            ? 'Get Started'
                            : 'Next',
                        style: const TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                          color: AppTheme.textWhite,
                          letterSpacing: 1.0,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  void _goToLogin() {
    Navigator.of(context).pushReplacement(
      PageRouteBuilder(
        pageBuilder: (context, animation, secondaryAnimation) => const AuthScreen(),
        transitionsBuilder: (context, animation, secondaryAnimation, child) {
          return SlideTransition(
            position: Tween<Offset>(
              begin: const Offset(1, 0),
              end: Offset.zero,
            ).animate(
              CurvedAnimation(parent: animation, curve: Curves.easeInOutCubic),
            ),
            child: child,
          );
        },
        transitionDuration: const Duration(milliseconds: 650),
      ),
    );
  }
}

class OnboardingData {
  final String title;
  final String description;
  final IconData icon;
  final Color glowColor;

  OnboardingData({
    required this.title,
    required this.description,
    required this.icon,
    required this.glowColor,
  });
}
