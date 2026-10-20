import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:regalo_by_amna/theme/app_colors.dart';

abstract final class AppTheme {
  static ThemeData light() {
    final scheme =
        ColorScheme.fromSeed(
          seedColor: AppColors.forest,
          brightness: Brightness.light,
        ).copyWith(
          primary: AppColors.forest,
          onPrimary: AppColors.cream,
          secondary: AppColors.sageDeep,
          onSecondary: AppColors.cream,
          tertiary: AppColors.blushDeep,
          onTertiary: AppColors.cream,
          surface: AppColors.cream,
          onSurface: AppColors.ink,
        );

    final textTheme = TextTheme(
      headlineLarge: GoogleFonts.cormorantGaramond(
        fontSize: 40,
        fontWeight: FontWeight.w600,
        height: 1.05,
        color: AppColors.ink,
      ),
      headlineMedium: GoogleFonts.cormorantGaramond(
        fontSize: 34,
        fontWeight: FontWeight.w600,
        height: 1.1,
        color: AppColors.ink,
      ),
      headlineSmall: GoogleFonts.cormorantGaramond(
        fontSize: 26,
        fontWeight: FontWeight.w600,
        color: AppColors.ink,
      ),
      titleLarge: GoogleFonts.outfit(
        fontSize: 18,
        fontWeight: FontWeight.w600,
        color: AppColors.ink,
      ),
      titleMedium: GoogleFonts.outfit(
        fontSize: 16,
        fontWeight: FontWeight.w600,
        color: AppColors.ink,
      ),
      bodyLarge: GoogleFonts.outfit(
        fontSize: 15,
        height: 1.45,
        color: AppColors.ink,
      ),
      bodyMedium: GoogleFonts.outfit(
        fontSize: 14,
        height: 1.4,
        color: AppColors.ink,
      ),
      bodySmall: GoogleFonts.outfit(fontSize: 12, color: AppColors.muted),
      labelLarge: GoogleFonts.outfit(
        fontSize: 14,
        fontWeight: FontWeight.w600,
        color: AppColors.ink,
      ),
      labelMedium: GoogleFonts.outfit(
        fontSize: 12,
        fontWeight: FontWeight.w600,
        color: AppColors.ink,
      ),
      labelSmall: GoogleFonts.outfit(
        fontSize: 11,
        fontWeight: FontWeight.w600,
        color: AppColors.muted,
      ),
    );

    final border = OutlineInputBorder(
      borderRadius: BorderRadius.circular(12),
      borderSide: const BorderSide(color: AppColors.line),
    );

    return ThemeData(
      useMaterial3: true,
      colorScheme: scheme,
      scaffoldBackgroundColor: AppColors.cream,
      textTheme: textTheme,
      splashFactory: InkRipple.splashFactory,
      appBarTheme: AppBarTheme(
        backgroundColor: AppColors.cream,
        foregroundColor: AppColors.ink,
        elevation: 0,
        scrolledUnderElevation: 0,
        centerTitle: false,
        titleTextStyle: GoogleFonts.cormorantGaramond(
          fontSize: 26,
          fontWeight: FontWeight.w600,
          color: AppColors.ink,
        ),
      ),
      dividerTheme: const DividerThemeData(
        color: AppColors.line,
        space: 1,
        thickness: 1,
      ),
      dialogTheme: DialogThemeData(
        backgroundColor: AppColors.card,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
      ),
      snackBarTheme: SnackBarThemeData(
        behavior: SnackBarBehavior.floating,
        backgroundColor: AppColors.forest,
        contentTextStyle: GoogleFonts.outfit(color: AppColors.cream),
      ),
      filledButtonTheme: FilledButtonThemeData(
        style: FilledButton.styleFrom(
          backgroundColor: AppColors.forest,
          foregroundColor: AppColors.cream,
          textStyle: GoogleFonts.outfit(fontWeight: FontWeight.w600),
        ),
      ),
      textButtonTheme: TextButtonThemeData(
        style: TextButton.styleFrom(
          foregroundColor: AppColors.forest,
          textStyle: GoogleFonts.outfit(fontWeight: FontWeight.w600),
        ),
      ),
      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: AppColors.card,
        contentPadding: const EdgeInsets.symmetric(
          horizontal: 14,
          vertical: 14,
        ),
        labelStyle: GoogleFonts.outfit(color: AppColors.muted),
        hintStyle: GoogleFonts.outfit(color: AppColors.muted),
        border: border,
        enabledBorder: border,
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: AppColors.forest, width: 1.4),
        ),
      ),
    );
  }
}
