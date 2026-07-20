import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class _WaveHeaderClipper extends CustomClipper<Path> {
  @override
  Path getClip(Size size) {
    final path = Path();
    path.lineTo(0, size.height * 0.72);
    path.cubicTo(
      size.width * 0.22,
      size.height * 0.60,
      size.width * 0.28,
      size.height,
      size.width * 0.55,
      size.height * 0.90,
    );
    path.cubicTo(
      size.width * 0.80,
      size.height * 0.82,
      size.width * 0.85,
      size.height * 1.0,
      size.width,
      size.height * 0.78,
    );
    path.lineTo(size.width, 0);
    path.close();
    return path;
  }

  @override
  bool shouldReclip(covariant CustomClipper<Path> oldClipper) => false;
}

class _TopographicPatternPainter extends CustomPainter {
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

    drawBlob(Offset(size.width * 0.15, size.height * 0.25), 55);
    drawBlob(Offset(size.width * 0.85, size.height * 0.15), 40);
    drawBlob(Offset(size.width * 0.7, size.height * 0.55), 70);
    drawBlob(Offset(size.width * 0.25, size.height * 0.65), 35);

    final wavyPath1 = Path()
      ..moveTo(0, size.height * 0.4)
      ..quadraticBezierTo(
        size.width * 0.3,
        size.height * 0.3,
        size.width * 0.6,
        size.height * 0.45,
      )
      ..quadraticBezierTo(
        size.width * 0.8,
        size.height * 0.55,
        size.width,
        size.height * 0.35,
      );
    canvas.drawPath(wavyPath1, paint);

    final wavyPath2 = Path()
      ..moveTo(0, size.height * 0.6)
      ..quadraticBezierTo(
        size.width * 0.35,
        size.height * 0.75,
        size.width * 0.65,
        size.height * 0.6,
      )
      ..quadraticBezierTo(
        size.width * 0.9,
        size.height * 0.5,
        size.width,
        size.height * 0.65,
      );
    canvas.drawPath(wavyPath2, paint);
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}

class AuthHeaderWave extends StatelessWidget {
  const AuthHeaderWave({
    super.key,
    this.onBackPressed,
    this.height = 300,
    this.showBrand = true,
    this.centerBrand = false,
  });

  /// Pass null to hide the back button (e.g. on the screen that has no
  /// previous screen to return to yet).
  final VoidCallback? onBackPressed;
  final double height;
  final bool showBrand;

  /// When true, shows the brand centered and larger (used on Welcome only).
  /// When false, shows it top-left, below the back button (Login/Signup).
  final bool centerBrand;

  @override
  Widget build(BuildContext context) {
    return ClipPath(
      clipper: _WaveHeaderClipper(),
      child: Container(
        height: height,
        width: double.infinity,
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
              child: CustomPaint(painter: _TopographicPatternPainter()),
            ),
            if (centerBrand) ...[
              if (onBackPressed != null)
                SafeArea(
                  bottom: false,
                  child: Align(
                    alignment: Alignment.topLeft,
                    child: Padding(
                      padding: const EdgeInsets.only(left: 8, top: 4),
                      child: IconButton(
                        onPressed: onBackPressed,
                        icon: const Icon(
                          Icons.arrow_back_ios_new_rounded,
                          color: Colors.white,
                          size: 20,
                        ),
                      ),
                    ),
                  ),
                ),
              if (showBrand)
                Center(
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      const Icon(
                        Icons.account_balance_wallet_rounded,
                        color: Colors.white,
                        size: 44,
                      ),
                      const SizedBox(width: 12),
                      Text(
                        'PocketWise',
                        style: GoogleFonts.inter(
                          color: Colors.white,
                          fontSize: 32,
                          fontWeight: FontWeight.w800,
                        ),
                      ),
                    ],
                  ),
                ),
            ] else
              SafeArea(
                bottom: false,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    if (onBackPressed != null)
                      Padding(
                        padding: const EdgeInsets.only(left: 8, top: 4),
                        child: IconButton(
                          onPressed: onBackPressed,
                          icon: const Icon(
                            Icons.arrow_back_ios_new_rounded,
                            color: Colors.white,
                            size: 20,
                          ),
                        ),
                      )
                    else
                      const SizedBox(height: 48),
                    if (showBrand)
                      Padding(
                        padding: const EdgeInsets.only(left: 24, top: 12),
                        child: Row(
                          children: [
                            const Icon(
                              Icons.account_balance_wallet_rounded,
                              color: Colors.white,
                              size: 34,
                            ),
                            const SizedBox(width: 10),
                            Text(
                              'PocketWise',
                              style: GoogleFonts.inter(
                                color: Colors.white,
                                fontSize: 26,
                                fontWeight: FontWeight.w800,
                              ),
                            ),
                          ],
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
