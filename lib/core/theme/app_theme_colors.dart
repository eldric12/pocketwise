import 'package:flutter/material.dart';

@immutable
class AppThemeColors extends ThemeExtension<AppThemeColors> {
  const AppThemeColors({
    required this.background,
    required this.surface,
    required this.surfaceSoft,
    required this.textPrimary,
    required this.textSecondary,
    required this.border,
  });

  final Color background;
  final Color surface;
  final Color surfaceSoft;
  final Color textPrimary;
  final Color textSecondary;
  final Color border;

  static const dark = AppThemeColors(
    background: Color(0xFF0F172A),
    surface: Color(0xFF1E293B),
    surfaceSoft: Color(0xFF26344A),
    textPrimary: Color(0xFFFFFFFF),
    textSecondary: Color(0xFF9FB0CC),
    border: Color(0xFF334155),
  );

  static const light = AppThemeColors(
    background: Color(0xFFF5F7FB),
    surface: Color(0xFFFFFFFF),
    surfaceSoft: Color(0xFFEEF2F8),
    textPrimary: Color(0xFF172033),
    textSecondary: Color(0xFF65738B),
    border: Color(0xFFDCE3EE),
  );

  @override
  AppThemeColors copyWith({
    Color? background,
    Color? surface,
    Color? surfaceSoft,
    Color? textPrimary,
    Color? textSecondary,
    Color? border,
  }) {
    return AppThemeColors(
      background: background ?? this.background,
      surface: surface ?? this.surface,
      surfaceSoft: surfaceSoft ?? this.surfaceSoft,
      textPrimary: textPrimary ?? this.textPrimary,
      textSecondary: textSecondary ?? this.textSecondary,
      border: border ?? this.border,
    );
  }

  @override
  AppThemeColors lerp(covariant AppThemeColors? other, double t) {
    if (other == null) return this;
    return AppThemeColors(
      background: Color.lerp(background, other.background, t)!,
      surface: Color.lerp(surface, other.surface, t)!,
      surfaceSoft: Color.lerp(surfaceSoft, other.surfaceSoft, t)!,
      textPrimary: Color.lerp(textPrimary, other.textPrimary, t)!,
      textSecondary: Color.lerp(textSecondary, other.textSecondary, t)!,
      border: Color.lerp(border, other.border, t)!,
    );
  }
}

extension AppThemeContext on BuildContext {
  AppThemeColors get themeColors =>
      Theme.of(this).extension<AppThemeColors>()!;
}
