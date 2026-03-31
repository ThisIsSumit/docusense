import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:google_fonts/google_fonts.dart';

abstract class AppColors {
  // Void background scale
  static const void0 = Color(0xFF000000);
  static const void1 = Color(0xFF080808);
  static const void2 = Color(0xFF0E0E0E);
  static const void3 = Color(0xFF141414);
  static const void4 = Color(0xFF1C1C1C);
  static const void5 = Color(0xFF242424);

  // Surface scale
  static const surface0 = Color(0xFF1A1A1A);
  static const surface1 = Color(0xFF222222);
  static const surface2 = Color(0xFF2A2A2A);
  static const surface3 = Color(0xFF323232);
  static const Color accentAmber = Color(0xFFFFB020);
  // Accent - electric cyan
  static const accent = Color(0xFF00FFD1);
  static const accentDim = Color(0xFF00B894);
  static const accentGlow = Color(0x2600FFD1);
  static const accentFaint = Color(0x0D00FFD1);

  // Secondary accent - warm amber
  static const amber = Color(0xFFFFB347);
  static const amberDim = Color(0xFFCC8A2E);
  static const amberGlow = Color(0x26FFB347);
  static const amberTrace = Color(0x1AFFAA00);
  static const red = Color(0xFFFF3B3B);
  static const redDim = Color(0xFFCC2A2A);
  static const redTrace = Color(0x1AFF3B3B);
  static const green = Color(0xFF00D68F);
  static const greenTrace = Color(0x1A00D68F);

  // Semantic
  static const success = Color(0xFF00E676);
  static const error = Color(0xFFFF5252);
  static const warning = Color(0xFFFFD740);
  static const info = Color(0xFF40C4FF);

  // Text scale
  static const textPrimary = Color(0xFFF0F0F0);
  static const textSecondary = Color(0xFF9E9E9E);
  static const textTertiary = Color(0xFF5A5A5A);
  static const textDisabled = Color(0xFF3A3A3A);

  // Border
  static const border = Color(0xFF2A2A2A);
  static const borderFocus = Color(0xFF404040);

  // Gradient stops
  static const gradientTop = Color(0xFF0A0A0A);
  static const gradientBot = Color(0xFF000000);

  static const wire = Color(0xFF2A2A2A);
  static const wireDim = Color(0xFF1E1E1E);
  static const wireHot = Color(0xFF404040);

  static const ink0 = Color(0xFFF0F0F0);
  static const ink1 = Color(0xFF9A9A9A);
  static const ink2 = Color(0xFF5A5A5A);
  static const ink3 = Color(0xFF3A3A3A);

  static const signal = Color(0xFF00E5FF);
  static const signalDim = Color(0xFF0099B3);
  static const signalTrace = Color(0x1A00E5FF);
  static const signalGlow = Color(0x3300E5FF);
}

abstract class AppTextStyles {
  // Display - Syne
  static TextStyle displayXL = const TextStyle(
    fontFamily: 'Syne',
    fontSize: 48,
    fontWeight: FontWeight.w800,
    color: AppColors.textPrimary,
    letterSpacing: -2.0,
    height: 1.0,
  );

  static TextStyle displayLG = const TextStyle(
    fontFamily: 'Syne',
    fontSize: 36,
    fontWeight: FontWeight.w700,
    color: AppColors.textPrimary,
    letterSpacing: -1.5,
    height: 1.1,
  );

  static TextStyle displayMD = const TextStyle(
    fontFamily: 'Syne',
    fontSize: 28,
    fontWeight: FontWeight.w700,
    color: AppColors.textPrimary,
    letterSpacing: -1.0,
    height: 1.2,
  );

  static TextStyle headingLG = const TextStyle(
    fontFamily: 'Syne',
    fontSize: 22,
    fontWeight: FontWeight.w600,
    color: AppColors.textPrimary,
    letterSpacing: -0.5,
    height: 1.3,
  );

  static TextStyle headingMD = const TextStyle(
    fontFamily: 'Syne',
    fontSize: 18,
    fontWeight: FontWeight.w600,
    color: AppColors.textPrimary,
    letterSpacing: -0.3,
    height: 1.3,
  );

  static TextStyle headingSM = const TextStyle(
    fontFamily: 'Syne',
    fontSize: 15,
    fontWeight: FontWeight.w600,
    color: AppColors.textPrimary,
    letterSpacing: -0.2,
    height: 1.4,
  );

  // Body - system sans
  static TextStyle bodyLG = const TextStyle(
    fontSize: 16,
    fontWeight: FontWeight.w400,
    color: AppColors.textSecondary,
    height: 1.6,
  );

  static TextStyle bodyMD = const TextStyle(
    fontSize: 14,
    fontWeight: FontWeight.w400,
    color: AppColors.textSecondary,
    height: 1.5,
  );

  static TextStyle bodySM = const TextStyle(
    fontSize: 12,
    fontWeight: FontWeight.w400,
    color: AppColors.textTertiary,
    height: 1.5,
  );

  // Mono - JetBrains Mono
  static TextStyle monoLG = const TextStyle(
    fontFamily: 'JetBrainsMono',
    fontSize: 14,
    fontWeight: FontWeight.w400,
    color: AppColors.accent,
    letterSpacing: 0.5,
    height: 1.5,
  );

  static TextStyle monoMD = const TextStyle(
    fontFamily: 'JetBrainsMono',
    fontSize: 12,
    fontWeight: FontWeight.w400,
    color: AppColors.accent,
    letterSpacing: 0.3,
  );

  static TextStyle monoSM = const TextStyle(
    fontFamily: 'JetBrainsMono',
    fontSize: 10,
    fontWeight: FontWeight.w400,
    color: AppColors.accentDim,
    letterSpacing: 0.5,
  );

  // Label
  static TextStyle labelLG = const TextStyle(
    fontFamily: 'Syne',
    fontSize: 13,
    fontWeight: FontWeight.w500,
    color: AppColors.textSecondary,
    letterSpacing: 0.8,
  );

  static TextStyle labelMD = const TextStyle(
    fontFamily: 'Syne',
    fontSize: 11,
    fontWeight: FontWeight.w500,
    color: AppColors.textTertiary,
    letterSpacing: 1.2,
  );
}

class AppTheme {
  static ThemeData get dark {
    return ThemeData(
      useMaterial3: true,
      brightness: Brightness.dark,
      scaffoldBackgroundColor: AppColors.void1,
      colorScheme: const ColorScheme.dark(
        primary: AppColors.accent,
        secondary: AppColors.amber,
        surface: AppColors.surface0,
        error: AppColors.error,
        onPrimary: AppColors.void0,
        onSecondary: AppColors.void0,
        onSurface: AppColors.textPrimary,
      ),
      textTheme: TextTheme(
        displayLarge: AppTextStyles.displayXL,
        displayMedium: AppTextStyles.displayLG,
        displaySmall: AppTextStyles.displayMD,
        headlineLarge: AppTextStyles.headingLG,
        headlineMedium: AppTextStyles.headingMD,
        headlineSmall: AppTextStyles.headingSM,
        bodyLarge: AppTextStyles.bodyLG,
        bodyMedium: AppTextStyles.bodyMD,
        bodySmall: AppTextStyles.bodySM,
        labelLarge: AppTextStyles.labelLG,
        labelMedium: AppTextStyles.labelMD,
      ),
      appBarTheme: const AppBarTheme(
        backgroundColor: Colors.transparent,
        elevation: 0,
        scrolledUnderElevation: 0,
        systemOverlayStyle: SystemUiOverlayStyle(
          statusBarColor: Colors.transparent,
          statusBarIconBrightness: Brightness.light,
        ),
        titleTextStyle: TextStyle(
          fontFamily: 'Syne',
          fontSize: 18,
          fontWeight: FontWeight.w700,
          color: AppColors.textPrimary,
        ),
        iconTheme: IconThemeData(color: AppColors.textSecondary),
      ),
      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: AppColors.surface0,
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: AppColors.border, width: 1),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: AppColors.border, width: 1),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: AppColors.accent, width: 1),
        ),
        errorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: AppColors.error, width: 1),
        ),
        hintStyle: AppTextStyles.bodyMD.copyWith(color: AppColors.textTertiary),
        labelStyle: AppTextStyles.bodyMD,
        contentPadding:
            const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
      ),
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          backgroundColor: AppColors.accent,
          foregroundColor: AppColors.void0,
          minimumSize: const Size(double.infinity, 52),
          shape:
              RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
          textStyle: const TextStyle(
            fontFamily: 'Syne',
            fontSize: 15,
            fontWeight: FontWeight.w700,
            letterSpacing: 0.5,
          ),
          elevation: 0,
        ),
      ),
      textButtonTheme: TextButtonThemeData(
        style: TextButton.styleFrom(
          foregroundColor: AppColors.accent,
          textStyle: const TextStyle(
            fontFamily: 'Syne',
            fontSize: 14,
            fontWeight: FontWeight.w600,
          ),
        ),
      ),
      cardTheme: CardThemeData(
        color: AppColors.surface0,
        elevation: 0,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16),
          side: const BorderSide(color: AppColors.border, width: 1),
        ),
        margin: EdgeInsets.zero,
      ),
      dividerTheme: const DividerThemeData(
        color: AppColors.border,
        thickness: 1,
        space: 1,
      ),
      bottomNavigationBarTheme: const BottomNavigationBarThemeData(
        backgroundColor: AppColors.void2,
        selectedItemColor: AppColors.accent,
        unselectedItemColor: AppColors.textTertiary,
      ),
      pageTransitionsTheme: const PageTransitionsTheme(
        builders: {
          TargetPlatform.android: CupertinoPageTransitionsBuilder(),
          TargetPlatform.iOS: CupertinoPageTransitionsBuilder(),
        },
      ),
    );
  }
}
