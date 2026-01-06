import 'dart:math' show sin, pi;
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/theme_provider.dart';
import '../providers/app_provider.dart';
import 'home_screen.dart';

class SplashScreen extends StatefulWidget {
  const SplashScreen({Key? key}) : super(key: key);

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _scaleAnimation;
  late Animation<double> _fadeAnimation;

  @override
  void initState() {
    super.initState();
    
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 2000),
    );

    _scaleAnimation = Tween<double>(begin: 0.5, end: 1.0).animate(
      CurvedAnimation(
        parent: _controller,
        curve: const Interval(0.0, 0.6, curve: Curves.easeOutBack),
      ),
    );

    _fadeAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(
        parent: _controller,
        curve: const Interval(0.3, 0.8, curve: Curves.easeIn),
      ),
    );

    _controller.forward();
    
    _initializeApp();
  }

  Future<void> _initializeApp() async {
    final appProvider = Provider.of<AppProvider>(context, listen: false);
    final themeProvider = Provider.of<ThemeProvider>(context, listen: false);
    
    await Future.wait([
      appProvider.initialize(),
      themeProvider.initialize(),
    ]);

    await Future.delayed(const Duration(milliseconds: 2500));

    if (mounted) {
      Navigator.of(context).pushReplacement(
        PageRouteBuilder(
          pageBuilder: (context, animation, secondaryAnimation) => const HomeScreen(),
          transitionsBuilder: (context, animation, secondaryAnimation, child) {
            const begin = Offset(1.0, 0.0);
            const end = Offset.zero;
            const curve = Curves.easeInOutCubic;
            var tween = Tween(begin: begin, end: end).chain(CurveTween(curve: curve));
            var offsetAnimation = animation.drive(tween);
            return SlideTransition(position: offsetAnimation, child: child);
          },
          transitionDuration: const Duration(milliseconds: 600),
        ),
      );
    }
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final themeProvider = Provider.of<ThemeProvider>(context);
    final size = MediaQuery.of(context).size;

    return Scaffold(
      body: Container(
        width: size.width,
        height: size.height,
        decoration: BoxDecoration(
          gradient: themeProvider.getMainGradient(),
        ),
        child: AnimatedBuilder(
          animation: _controller,
          builder: (context, child) {
            return Stack(
              children: [
                Positioned.fill(
                  child: CustomPaint(
                    painter: LiquidBackgroundPainter(
                      animation: _controller,
                      isDark: themeProvider.isDarkMode,
                    ),
                  ),
                ),
                Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Transform.scale(
                        scale: _scaleAnimation.value,
                        child: Opacity(
                          opacity: _fadeAnimation.value,
                          child: Container(
                            width: 120,
                            height: 120,
                            decoration: BoxDecoration(
                              color: Colors.white.withOpacity(0.15),
                              borderRadius: BorderRadius.circular(30),
                              boxShadow: [
                                BoxShadow(
                                  color: Colors.black.withOpacity(0.1),
                                  blurRadius: 30,
                                  spreadRadius: 5,
                                ),
                              ],
                            ),
                            child: Icon(
                              Icons.trending_up_rounded,
                              size: 60,
                              color: Colors.white,
                            ),
                          ),
                        ),
                      ),
                      const SizedBox(height: 30),
                      Opacity(
                        opacity: _fadeAnimation.value,
                        child: Text(
                          'AI YouTube Boost',
                          style: Theme.of(context).textTheme.displayMedium?.copyWith(
                                color: Colors.white,
                                fontWeight: FontWeight.bold,
                                letterSpacing: -1,
                              ),
                        ),
                      ),
                      const SizedBox(height: 10),
                      Opacity(
                        opacity: _fadeAnimation.value * 0.8,
                        child: Text(
                          'Analyze. Optimize. Grow.',
                          style: Theme.of(context).textTheme.titleLarge?.copyWith(
                                color: Colors.white.withOpacity(0.9),
                                fontWeight: FontWeight.w400,
                              ),
                        ),
                      ),
                      const SizedBox(height: 60),
                      Opacity(
                        opacity: _fadeAnimation.value,
                        child: SizedBox(
                          width: 40,
                          height: 40,
                          child: CircularProgressIndicator(
                            strokeWidth: 3,
                            valueColor: AlwaysStoppedAnimation<Color>(
                              Colors.white.withOpacity(0.8),
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            );
          },
        ),
      ),
    );
  }
}

class LiquidBackgroundPainter extends CustomPainter {
  final Animation<double> animation;
  final bool isDark;

  LiquidBackgroundPainter({
    required this.animation,
    required this.isDark,
  }) : super(repaint: animation);

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..style = PaintingStyle.fill
      ..strokeWidth = 2;

    final path1 = Path();
    final path2 = Path();
    final path3 = Path();

    final progress = animation.value;
    
    final waveHeight = size.height * 0.3;
    final waveWidth = size.width;

    paint.color = isDark 
        ? Colors.white.withOpacity(0.03)
        : Colors.white.withOpacity(0.15);
    
    path1.moveTo(0, size.height * 0.4);
    for (double i = 0; i <= waveWidth; i++) {
      path1.lineTo(
        i,
        size.height * 0.4 + 
            waveHeight * 0.3 * 
            (0.5 + 0.5 * _sin(i / waveWidth + progress)),
      );
    }
    path1.lineTo(waveWidth, size.height);
    path1.lineTo(0, size.height);
    path1.close();
    canvas.drawPath(path1, paint);

    paint.color = isDark
        ? Colors.white.withOpacity(0.02)
        : Colors.white.withOpacity(0.1);
    
    path2.moveTo(0, size.height * 0.6);
    for (double i = 0; i <= waveWidth; i++) {
      path2.lineTo(
        i,
        size.height * 0.6 + 
            waveHeight * 0.4 * 
            (0.5 + 0.5 * _sin(i / waveWidth * 1.5 - progress)),
      );
    }
    path2.lineTo(waveWidth, size.height);
    path2.lineTo(0, size.height);
    path2.close();
    canvas.drawPath(path2, paint);

    paint.color = isDark
        ? Colors.white.withOpacity(0.01)
        : Colors.white.withOpacity(0.05);
    
    path3.moveTo(0, size.height * 0.8);
    for (double i = 0; i <= waveWidth; i++) {
      path3.lineTo(
        i,
        size.height * 0.8 + 
            waveHeight * 0.2 * 
            (0.5 + 0.5 * _sin(i / waveWidth * 2 + progress * 1.5)),
      );
    }
    path3.lineTo(waveWidth, size.height);
    path3.lineTo(0, size.height);
    path3.close();
    canvas.drawPath(path3, paint);
  }

  @override
  bool shouldRepaint(covariant LiquidBackgroundPainter oldDelegate) {
    return animation != oldDelegate.animation || isDark != oldDelegate.isDark;
  }
}

double _sin(double value) {
  return sin(value * pi);
}
