import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'app_colors.dart';

class AppTheme {
  AppTheme._();

  static ThemeData get dark => ThemeData(
        useMaterial3: true,
        brightness: Brightness.dark,
        scaffoldBackgroundColor: AppColors.background,
        colorScheme: ColorScheme.dark(
          surface: AppColors.surface,
          onSurface: AppColors.onSurface,
          surfaceContainer: AppColors.surfaceContainer,
          primary: AppColors.primary,
          onPrimary: AppColors.onPrimary,
          primaryContainer: AppColors.primaryContainer,
          onPrimaryContainer: AppColors.onPrimaryContainer,
          secondary: AppColors.secondary,
          onSecondary: AppColors.onSecondary,
          tertiary: AppColors.tertiary,
          onTertiary: AppColors.onTertiary,
          error: AppColors.error,
          onError: AppColors.onError,
          errorContainer: AppColors.errorContainer,
          onErrorContainer: AppColors.onErrorContainer,
          outline: AppColors.outline,
          outlineVariant: AppColors.outlineVariant,
          inverseSurface: AppColors.inverseSurface,
        ),
        textTheme: GoogleFonts.manropeTextTheme().copyWith(
          displayLarge: GoogleFonts.manrope(fontSize: 48, fontWeight: FontWeight.w700, letterSpacing: -0.02),
          displayMedium: GoogleFonts.manrope(fontSize: 44, fontWeight: FontWeight.w700),
          displaySmall: GoogleFonts.manrope(fontSize: 36, fontWeight: FontWeight.w700),
          headlineLarge: GoogleFonts.manrope(fontSize: 32, fontWeight: FontWeight.w600, letterSpacing: -0.01),
          headlineMedium: GoogleFonts.manrope(fontSize: 28, fontWeight: FontWeight.w600),
          headlineSmall: GoogleFonts.manrope(fontSize: 24, fontWeight: FontWeight.w600),
          titleLarge: GoogleFonts.manrope(fontSize: 22, fontWeight: FontWeight.w600),
          titleMedium: GoogleFonts.manrope(fontSize: 16, fontWeight: FontWeight.w600),
          titleSmall: GoogleFonts.manrope(fontSize: 14, fontWeight: FontWeight.w600),
          bodyLarge: GoogleFonts.manrope(fontSize: 18, fontWeight: FontWeight.w400, height: 1.6),
          bodyMedium: GoogleFonts.manrope(fontSize: 16, fontWeight: FontWeight.w400, height: 1.6),
          bodySmall: GoogleFonts.manrope(fontSize: 14, fontWeight: FontWeight.w400, height: 1.6),
          labelLarge: GoogleFonts.manrope(fontSize: 16, fontWeight: FontWeight.w600),
          labelMedium: GoogleFonts.manrope(fontSize: 14, fontWeight: FontWeight.w500, letterSpacing: 0.05),
          labelSmall: GoogleFonts.manrope(fontSize: 12, fontWeight: FontWeight.w600),
        ),
        appBarTheme: AppBarTheme(
          backgroundColor: AppColors.background,
          foregroundColor: AppColors.onSurface,
          elevation: 0,
          centerTitle: false,
          surfaceTintColor: Colors.transparent,
          titleTextStyle: GoogleFonts.manrope(
            color: AppColors.onSurface,
            fontSize: 20,
            fontWeight: FontWeight.w600,
          ),
        ),
        cardTheme: CardThemeData(
          color: AppColors.surfaceContainer,
          elevation: 0,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
          surfaceTintColor: Colors.transparent,
          margin: EdgeInsets.zero,
        ),
        inputDecorationTheme: InputDecorationTheme(
          filled: false,
          fillColor: Colors.transparent,
          border: UnderlineInputBorder(
            borderSide: BorderSide(color: AppColors.outline),
          ),
          enabledBorder: UnderlineInputBorder(
            borderSide: BorderSide(color: AppColors.outlineVariant),
          ),
          focusedBorder: UnderlineInputBorder(
            borderSide: BorderSide(color: AppColors.primaryContainer, width: 2),
          ),
          errorBorder: UnderlineInputBorder(
            borderSide: BorderSide(color: AppColors.error),
          ),
          focusedErrorBorder: UnderlineInputBorder(
            borderSide: BorderSide(color: AppColors.error, width: 2),
          ),
          contentPadding: const EdgeInsets.symmetric(horizontal: 0, vertical: 12),
          labelStyle: TextStyle(color: AppColors.onSurfaceVariant),
          hintStyle: TextStyle(color: AppColors.onSurfaceVariant),
          helperStyle: TextStyle(color: AppColors.onSurfaceVariant, fontSize: 12),
        ),
        elevatedButtonTheme: ElevatedButtonThemeData(
          style: ElevatedButton.styleFrom(
            backgroundColor: AppColors.primaryContainer,
            foregroundColor: AppColors.onPrimary,
            disabledBackgroundColor: AppColors.surfaceContainerHigh,
            disabledForegroundColor: AppColors.onSurfaceVariant,
            minimumSize: const Size(double.infinity, 52),
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
            textStyle: GoogleFonts.manrope(fontSize: 16, fontWeight: FontWeight.w600, letterSpacing: 0.05),
            elevation: 0,
            shadowColor: Colors.transparent,
          ),
        ),
        outlinedButtonTheme: OutlinedButtonThemeData(
          style: OutlinedButton.styleFrom(
            foregroundColor: AppColors.onSurface,
            disabledForegroundColor: AppColors.onSurfaceVariant,
            minimumSize: const Size(double.infinity, 52),
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
            side: BorderSide(color: AppColors.outline),
            textStyle: GoogleFonts.manrope(fontSize: 16, fontWeight: FontWeight.w600),
          ),
        ),
        textButtonTheme: TextButtonThemeData(
          style: TextButton.styleFrom(
            foregroundColor: AppColors.onSurfaceVariant,
            disabledForegroundColor: AppColors.onSurfaceVariant.withValues(alpha: 0.5),
            textStyle: GoogleFonts.manrope(fontSize: 14, fontWeight: FontWeight.w600),
          ),
        ),
        dividerTheme: DividerThemeData(
          color: AppColors.outlineVariant,
          thickness: 1,
          space: 1,
        ),
        bottomNavigationBarTheme: BottomNavigationBarThemeData(
          backgroundColor: AppColors.surfaceContainerLowest,
          selectedItemColor: AppColors.primaryContainer,
          unselectedItemColor: AppColors.onSurfaceVariant,
          type: BottomNavigationBarType.fixed,
          elevation: 0,
          selectedLabelStyle: GoogleFonts.manrope(fontSize: 12, fontWeight: FontWeight.w600),
          unselectedLabelStyle: GoogleFonts.manrope(fontSize: 12, fontWeight: FontWeight.w600),
        ),
        chipTheme: ChipThemeData(
          backgroundColor: AppColors.surfaceContainer,
          selectedColor: AppColors.surfaceContainerHigh,
          labelStyle: GoogleFonts.manrope(color: AppColors.onSurface, fontSize: 14),
          side: BorderSide(color: AppColors.outlineVariant),
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
        ),
        floatingActionButtonTheme: FloatingActionButtonThemeData(
          backgroundColor: AppColors.primaryContainer,
          foregroundColor: AppColors.onPrimary,
          elevation: 0,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        ),
      );
}
