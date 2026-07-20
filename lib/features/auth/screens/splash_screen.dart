import 'dart:async';

import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

import 'login_screen.dart';

class _SplashPatternPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = Colors.white.withValues(alpha: 0.10)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1.2;

    void drawBlob(Offset center, double radius) {
      canvas.drawCircle(center, radius, paint);
      canvas.drawCircle(center, radius * 0.65, paint);
    }

    drawBlob(Offset(size.width * 0.15, size.height * 0.20), 90);
    drawBlob(Offset(size.width * 0.85, size.height * 0.12), 70);
    drawBlob(Offset(size.width * 0.75, size.height * 0.45), 110);
    drawBlob(Offset(size.width * 0.20, size.height * 0.60), 60);
    drawBlob(Offset(size.width * 0.60, size.height * 0.80), 85);

    final wavyPath1 = Path()
      ..moveTo(0, size.height * 0.3)
      ..quadraticBezierTo(
        size.width * 0.3,
        size.height * 0.22,
        size.width * 0.6,
        size.height * 0.33,
      )
      ..quadraticBezierTo(
        size.width * 0.8,
        size.height * 0.40,
        size.width,
        size.height * 0.25,
      );
    canvas.drawPath(wavyPath1, paint);

    final wavyPath2 = Path()
      ..moveTo(0, size.height * 0.65)
      ..quadraticBezierTo(
        size.width * 0.35,
        size.height * 0.75,
        size.width * 0.65,
        size.height * 0.62,
      )
      ..quadraticBezierTo(
        size.width * 0.9,
        size.height * 0.52,
        size.width,
        size.height * 0.7,
      );
    canvas.drawPath(wavyPath2, paint);
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}

class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key, required this.onToggleTheme});

  final VoidCallback onToggleTheme;

  @override
  State<SplashScreen> createState() => _WelcomeScreenState();
}

class _WelcomeScreenState extends State<SplashScreen> {
  @override
  void initState() {
    super.initState();
    Timer(const Duration(seconds: 6), () {
      if (!mounted) return;
      Navigator.of(context).pushReplacement(
        MaterialPageRoute(
          builder: (context) =>
              LoginScreen(onToggleTheme: widget.onToggleTheme),
        ),
      );
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        width: double.infinity,
        height: double.infinity,
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [Color(0xFF1E3A8A), Color(0xFF0F172A)],
          ),
        ),
        child: Stack(
          children: [
            Positioned.fill(
              child: CustomPaint(painter: _SplashPatternPainter()),
            ),
            Center(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  const Icon(
                    Icons.account_balance_wallet_rounded,
                    color: Colors.white,
                    size: 64,
                  ),
                  const SizedBox(height: 16),
                  Text(
                    'PocketWise',
                    style: GoogleFonts.inter(
                      color: Colors.white,
                      fontSize: 36,
                      fontWeight: FontWeight.w800,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
