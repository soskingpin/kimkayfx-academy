import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'license_screen.dart';

class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});
  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> with SingleTickerProviderStateMixin {
  late AnimationController _loadingController;
  late Animation<double> _loadingAnimation;
  bool _disposed = false;

  @override
  void initState() {
    super.initState();
    _loadingController = AnimationController(vsync: this, duration: const Duration(milliseconds: 1500));
    _loadingAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(CurvedAnimation(parent: _loadingController, curve: Curves.easeInOut));
    _loadingController.repeat(reverse: true);
    Future.delayed(const Duration(milliseconds: 2500), () {
      if (!_disposed && mounted) {
        _loadingController.dispose();
        Navigator.pushReplacement(context, PageRouteBuilder(pageBuilder: (_, __, ___) => const LicenseScreen(), transitionsBuilder: (_, a, __, c) => FadeTransition(opacity: a, child: c), transitionDuration: const Duration(milliseconds: 600)));
      }
    });
  }

  @override
  void dispose() { _disposed = true; if (_loadingController.isAnimating) _loadingController.stop(); _loadingController.dispose(); super.dispose(); }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFFFFFFF),
      body: SafeArea(child: Center(child: Column(mainAxisAlignment: MainAxisAlignment.center, children: [
        Container(width: 160, height: 160, decoration: BoxDecoration(color: const Color(0xFF00C853).withOpacity(0.1), borderRadius: BorderRadius.circular(32), border: Border.all(color: const Color(0xFF00C853).withOpacity(0.3), width: 2), boxShadow: [BoxShadow(color: const Color(0xFF00C853).withOpacity(0.15), blurRadius: 24, spreadRadius: 4)]), child: Column(mainAxisAlignment: MainAxisAlignment.center, children: [Image.asset('assets/images/kimkay_logo.png', width: 90, height: 90, fit: BoxFit.contain)])).animate().scale(duration: 800.ms, curve: Curves.easeOutBack),
        const SizedBox(height: 24),
        const Text('KimKayFX', style: TextStyle(color: Color(0xFF1B5E20), fontSize: 32, fontWeight: FontWeight.bold, letterSpacing: 1)).animate().fadeIn(duration: 600.ms, delay: 300.ms),
        const Text('Academy Signals', style: TextStyle(color: Color(0xFF00C853), fontSize: 16, fontWeight: FontWeight.w500, letterSpacing: 2)).animate().fadeIn(duration: 600.ms, delay: 500.ms),
        const SizedBox(height: 40),
        AnimatedBuilder(animation: _loadingAnimation, builder: (context, child) => Container(width: 200, height: 4, decoration: BoxDecoration(color: Colors.grey[200], borderRadius: BorderRadius.circular(4)), child: FractionallySizedBox(alignment: Alignment.centerLeft, widthFactor: _loadingAnimation.value, child: Container(decoration: BoxDecoration(color: const Color(0xFF00C853), borderRadius: BorderRadius.circular(4)))))),
        const SizedBox(height: 16),
        Text('Connecting to signals...', style: TextStyle(color: Colors.grey[500], fontSize: 13)).animate().fadeIn(duration: 500.ms, delay: 900.ms),
      ]))),
    );
  }
}