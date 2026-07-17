import 'package:device_preview/device_preview.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:google_fonts/google_fonts.dart';

import '../core/constants/app_colors.dart';
import '../core/theme/app_theme_colors.dart';
import '../features/auth/screens/splash_screen.dart';

class PocketWiseApp extends StatefulWidget {
  const PocketWiseApp({super.key});

  @override
  State<PocketWiseApp> createState() => _PocketWiseAppState();
}

class _PocketWiseAppState extends State<PocketWiseApp> {
  ThemeMode _themeMode = ThemeMode.dark;

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'PocketWise',
      debugShowCheckedModeBanner: false,
      useInheritedMediaQuery: true,
      locale: DevicePreview.locale(context),
      themeMode: _themeMode,
      themeAnimationDuration: const Duration(milliseconds: 280),
      themeAnimationCurve: Curves.easeOutCubic,
      theme: _buildTheme(Brightness.light, AppThemeColors.light),
      darkTheme: _buildTheme(Brightness.dark, AppThemeColors.dark),
      builder: (context, child) {
        final isDark = Theme.of(context).brightness == Brightness.dark;
        final colors = context.themeColors;
        return AnnotatedRegion<SystemUiOverlayStyle>(
          value: (isDark
                  ? SystemUiOverlayStyle.light
                  : SystemUiOverlayStyle.dark)
              .copyWith(
            statusBarColor: Colors.transparent,
            systemNavigationBarColor: colors.background,
            systemNavigationBarIconBrightness:
                isDark ? Brightness.light : Brightness.dark,
          ),
          child: DevicePreview.appBuilder(context, child),
        );
      },
      home: SplashScreen(onToggleTheme: _toggleTheme),
    ); // MaterialApp
  }

  void _toggleTheme() {
    setState(() {
      _themeMode = _themeMode == ThemeMode.dark
          ? ThemeMode.light
          : ThemeMode.dark;
    });
  }

  ThemeData _buildTheme(Brightness brightness, AppThemeColors colors) {
    final isDark = brightness == Brightness.dark;
    final textTheme = GoogleFonts.interTextTheme(
      isDark ? ThemeData.dark().textTheme : ThemeData.light().textTheme,
    ).apply(
      bodyColor: colors.textPrimary,
      displayColor: colors.textPrimary,
    );

    return ThemeData(
      useMaterial3: true,
      brightness: brightness,
      scaffoldBackgroundColor: colors.background,
      primaryColor: AppColors.primary,
      colorScheme: ColorScheme.fromSeed(
        seedColor: isDark ? AppColors.primary : const Color(0xFF5369E8),
        brightness: brightness,
        primary: isDark ? AppColors.primary : const Color(0xFF5369E8),
        surface: colors.surface,
        onSurface: colors.textPrimary,
      ),
      extensions: [colors],
      textTheme: textTheme,
      splashFactory: InkRipple.splashFactory,
      dividerColor: colors.border,
      snackBarTheme: SnackBarThemeData(
        backgroundColor: colors.surface,
        contentTextStyle: textTheme.bodyMedium?.copyWith(
          color: colors.textPrimary,
        ),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
        behavior: SnackBarBehavior.floating,
      ),
      filledButtonTheme: FilledButtonThemeData(
        style: FilledButton.styleFrom(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
          ),
        ),
      ),
    );
  }
}