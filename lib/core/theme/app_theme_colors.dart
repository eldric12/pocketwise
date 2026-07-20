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
    required this.dangerBackground,
    required this.dangerText,
    required this.expenseBackground,
    required this.expenseText,
    required this.incomeBackground,
    required this.incomeText,
    required this.categoryBackground,
    required this.categoryText,
    required this.warningBackground,
    required this.warningText,
  });

  final Color background;
  final Color surface;
  final Color surfaceSoft;
  final Color textPrimary;
  final Color textSecondary;
  final Color border;
  final Color dangerBackground;
  final Color dangerText;
  final Color expenseBackground;
  final Color expenseText;
  final Color incomeBackground;
  final Color incomeText;
  final Color categoryBackground;
  final Color categoryText;
  final Color warningBackground;
  final Color warningText;

  static const dark = AppThemeColors(
    background: Color(0xFF0F172A),
    surface: Color(0xFF1E293B),
    surfaceSoft: Color(0xFF26344A),
    textPrimary: Color(0xFFFFFFFF),
    textSecondary: Color(0xFF9FB0CC),
    border: Color(0xFF334155),
    dangerBackground: Color(0xFF3A1F26),
    dangerText: Color(0xFFFF7A7A),
    expenseBackground: Color(0xFF3A1F26),
    expenseText: Color(0xFFFF7A7A),
    incomeBackground: Color(0xFF163A2A),
    incomeText: Color(0xFF34D399),
    categoryBackground: Color(0xFF30204A),
    categoryText: Color(0xFFC084FC),
    warningBackground: Color(0xFF3A3015),
    warningText: Color(0xFFFBBF24),
  );

  static const light = AppThemeColors(
    background: Color(0xFFF5F7FB),
    surface: Color(0xFFFFFFFF),
    surfaceSoft: Color(0xFFEEF2F8),
    textPrimary: Color(0xFF172033),
    textSecondary: Color(0xFF65738B),
    border: Color(0xFFDCE3EE),
    dangerBackground: Color(0xFFFFEEEE),
    dangerText: Color(0xFFE53935),
    expenseBackground: Color(0xFFFFEEEE),
    expenseText: Color(0xFFE53935),
    incomeBackground: Color(0xFFE8F8EF),
    incomeText: Color(0xFF16A34A),
    categoryBackground: Color(0xFFF3E8FF),
    categoryText: Color(0xFF9333EA),
    warningBackground: Color(0xFFFFF7DB),
    warningText: Color(0xFFD97706),
  );

  @override
  AppThemeColors copyWith({
    Color? background,
    Color? surface,
    Color? surfaceSoft,
    Color? textPrimary,
    Color? textSecondary,
    Color? border,
    Color? dangerBackground,
    Color? dangerText,
    Color? expenseBackground,
    Color? expenseText,
    Color? incomeBackground,
    Color? incomeText,
    Color? categoryBackground,
    Color? categoryText,
    Color? warningBackground,
    Color? warningText,
  }) {
    return AppThemeColors(
      background: background ?? this.background,
      surface: surface ?? this.surface,
      surfaceSoft: surfaceSoft ?? this.surfaceSoft,
      textPrimary: textPrimary ?? this.textPrimary,
      textSecondary: textSecondary ?? this.textSecondary,
      border: border ?? this.border,
      dangerBackground: dangerBackground ?? this.dangerBackground,
      dangerText: dangerText ?? this.dangerText,
      expenseBackground: expenseBackground ?? this.expenseBackground,
      expenseText: expenseText ?? this.expenseText,
      incomeBackground: incomeBackground ?? this.incomeBackground,
      incomeText: incomeText ?? this.incomeText,
      categoryBackground: categoryBackground ?? this.categoryBackground,
      categoryText: categoryText ?? this.categoryText,
      warningBackground: warningBackground ?? this.warningBackground,
      warningText: warningText ?? this.warningText,
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
      dangerBackground: Color.lerp(
        dangerBackground,
        other.dangerBackground,
        t,
      )!,
      dangerText: Color.lerp(dangerText, other.dangerText, t)!,
      expenseBackground: Color.lerp(
        expenseBackground,
        other.expenseBackground,
        t,
      )!,
      expenseText: Color.lerp(expenseText, other.expenseText, t)!,
      incomeBackground: Color.lerp(
        incomeBackground,
        other.incomeBackground,
        t,
      )!,
      incomeText: Color.lerp(incomeText, other.incomeText, t)!,
      categoryBackground: Color.lerp(
        categoryBackground,
        other.categoryBackground,
        t,
      )!,
      categoryText: Color.lerp(categoryText, other.categoryText, t)!,
      warningBackground: Color.lerp(
        warningBackground,
        other.warningBackground,
        t,
      )!,
      warningText: Color.lerp(warningText, other.warningText, t)!,
    );
  }
}

extension AppThemeContext on BuildContext {
  AppThemeColors get themeColors => Theme.of(this).extension<AppThemeColors>()!;
}
