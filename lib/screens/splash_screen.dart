import 'dart:async';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../themes/app_theme.dart';
import '../providers/auth_provider.dart';
import 'onboarding_screen.dart';
import 'main_navigation_wrapper.dart';

class SplashScreen extends StatefulWidget {
  const SplashScreen({Key? key}) : super(key: key);

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen>
    with SingleTickerProviderStateMixin {
  late AnimationController _animController;
  late Animation<double> _fadeAnimation;
  double _loadingProgress = 0.0;
  Timer? _progressTimer;

  @override
  void initState() {
    super.initState();
    _animController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1500),
    );
    _fadeAnimation = CurvedAnimation(
      parent: _animController,
      curve: Curves.easeIn,
    );

    _animController.forward();
    _startLoadingSimulation();
  }

  void _startLoadingSimulation() {
    const totalTicks = 50;
    const duration = Duration(milliseconds: 2500);
    final tickDuration = duration ~/ totalTicks;

    _progressTimer = Timer.periodic(tickDuration, (timer) {
      setState(() {
        if (_loadingProgress >= 1.0) {
          _progressTimer?.cancel();
          _navigateToNext();
        } else {
          _loadingProgress += 1.0 / totalTicks;
        }
      });
    });
  }

  void _navigateToNext() {
    final authProvider = Provider.of<AuthProvider>(context, listen: false);

    Navigator.of(context).pushReplacement(
      PageRouteBuilder(
        pageBuilder: (context, animation, secondaryAnimation) =>
            authProvider.isAuthenticated
                ? const MainNavigationWrapper()
                : const OnboardingScreen(),
        transitionsBuilder: (context, animation, secondaryAnimation, child) {
          return FadeTransition(opacity: animation, child: child);
        },
        transitionDuration: const Duration(milliseconds: 800),
      ),
    );
  }

  @override
  void dispose() {
    _animController.dispose();
    _progressTimer?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        decoration: const BoxDecoration(
          gradient: AppTheme.bgGradient,
        ),
        child: FadeTransition(
          opacity: _fadeAnimation,
          child: Stack(
            alignment: Alignment.center,
            children: [
              // Glowing purple background circles
              Positioned(
                top: -100,
                right: -100,
                child: Container(
                  width: 300,
                  height: 300,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    boxShadow: [
                      BoxShadow(
                        color: AppTheme.neonPurple.withOpacity(0.15),
                        blurRadius: 100,
                      ),
                    ],
                  ),
                ),
              ),
              Positioned(
                bottom: -150,
                left: -100,
                child: Container(
                  width: 350,
                  height: 350,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    boxShadow: [
                      BoxShadow(
                        color: AppTheme.neonPink.withOpacity(0.1),
                        blurRadius: 120,
                      ),
                    ],
                  ),
                ),
              ),
              Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  // Vector Running Character Custom Paint
                  SizedBox(
                    height: 180,
                    width: 180,
                    child: CustomPaint(
                      painter: _RunnerPainter(),
                    ),
                  ),
                  const SizedBox(height: 40),
                  // App Title with Neon glow text
                  Text(
                    'Make Fit',
                    style: TextStyle(
                      fontFamily: 'Outfit',
                      fontSize: 42,
                      fontWeight: FontWeight.bold,
                      color: AppTheme.textWhite,
                      letterSpacing: 1.5,
                      shadows: [
                        Shadow(
                          color: AppTheme.neonPurple.withOpacity(0.8),
                          blurRadius: 20,
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 8),
                  const Text(
                    'Your Health, Your Strength',
                    style: TextStyle(
                      fontSize: 16,
                      color: AppTheme.textGrey,
                      letterSpacing: 1.2,
                    ),
                  ),
                  const SizedBox(height: 80),
                  // Loading progress elements
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 48.0),
                    child: Column(
                      children: [
                        // Animated Loading progress bar
                        Container(
                          height: 6,
                          width: double.infinity,
                          decoration: BoxDecoration(
                            color: AppTheme.cardNavyLight,
                            borderRadius: BorderRadius.circular(3),
                          ),
                          child: Stack(
                            children: [
                              FractionallySizedBox(
                                widthFactor: _loadingProgress,
                                child: Container(
                                  decoration: BoxDecoration(
                                    gradient: AppTheme.primaryGradient,
                                    borderRadius: BorderRadius.circular(3),
                                    boxShadow: [
                                      BoxShadow(
                                        color: AppTheme.neonPurple.withOpacity(0.5),
                                        blurRadius: 6,
                                        spreadRadius: 1,
                                      ),
                                    ],
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),
                        const SizedBox(height: 12),
                        Text(
                          'Loading... ${(realProg() * 100).toInt()}%',
                          style: const TextStyle(
                            fontSize: 12,
                            color: AppTheme.textGrey,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  double realProg() => _loadingProgress.clamp(0.0, 1.0);
}

class _RunnerPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = AppTheme.textWhite
      ..strokeWidth = 4.5
      ..strokeCap = StrokeCap.round
      ..style = PaintingStyle.stroke;

    final glowPaint = Paint()
      ..color = AppTheme.neonPurple.withOpacity(0.5)
      ..strokeWidth = 9.0
      ..strokeCap = StrokeCap.round
      ..style = PaintingStyle.stroke
      ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 5);

    final centerX = size.width / 2;
    final centerY = size.height / 2;

    // Draw energy trails in the back
    final trailPaint = Paint()
      ..color = AppTheme.neonPink.withOpacity(0.3)
      ..strokeWidth = 2.0
      ..style = PaintingStyle.stroke;

    canvas.drawLine(Offset(centerX - 35, centerY - 15), Offset(centerX - 65, centerY - 15), trailPaint);
    canvas.drawLine(Offset(centerX - 40, centerY), Offset(centerX - 70, centerY), trailPaint);
    canvas.drawLine(Offset(centerX - 35, centerY + 15), Offset(centerX - 60, centerY + 15), trailPaint);

    void drawSegment(Offset p1, Offset p2) {
      canvas.drawLine(p1, p2, glowPaint);
      canvas.drawLine(p1, p2, paint);
    }

    // Runner coordinates
    // Head
    final head = Offset(centerX + 15, centerY - 45);
    final fillPaint = Paint()
      ..color = AppTheme.textWhite
      ..style = PaintingStyle.fill;
    
    final headGlowPaint = Paint()
      ..color = AppTheme.neonPurple.withOpacity(0.6)
      ..style = PaintingStyle.fill
      ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 6);

    canvas.drawCircle(head, 9, headGlowPaint);
    canvas.drawCircle(head, 7, fillPaint);

    // Torso / Spine
    final neck = Offset(centerX + 10, centerY - 32);
    final hip = Offset(centerX - 5, centerY + 5);
    drawSegment(neck, hip);

    // Front arm (bending forward)
    final shoulder = Offset(centerX + 8, centerY - 25);
    final elbowFront = Offset(centerX + 25, centerY - 15);
    final handFront = Offset(centerX + 35, centerY - 30);
    drawSegment(shoulder, elbowFront);
    drawSegment(elbowFront, handFront);

    // Back arm (swinging backwards)
    final elbowBack = Offset(centerX - 10, centerY - 28);
    final handBack = Offset(centerX - 25, centerY - 15);
    drawSegment(shoulder, elbowBack);
    drawSegment(elbowBack, handBack);

    // Front leg (bent high, going forward)
    final kneeFront = Offset(centerX + 20, centerY + 15);
    final footFront = Offset(centerX + 15, centerY + 40);
    drawSegment(hip, kneeFront);
    drawSegment(kneeFront, footFront);

    // Back leg (reaching backwards)
    final kneeBack = Offset(centerX - 15, centerY + 18);
    final footBack = Offset(centerX - 32, centerY + 30);
    drawSegment(hip, kneeBack);
    drawSegment(kneeBack, footBack);
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}

