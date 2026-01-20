import 'package:flutter/material.dart';

class AppTheme {
  // Primary Colors
  static const Color primaryBlack = Color(0xFF000000); // Pure Black
  static const Color darkSurface = Color(0xFF141414); // Very Dark Grey

  // Luxury Theme Colors
  static const Color primaryAction = Color(0xFFE50914); // Premium Red
  static const Color secondaryHighlight = Color(0xFFFFD700); // Gold

  // Legacy mappings for backward compatibility (Restored to fix lints)
  static const Color accentGold = secondaryHighlight;
  static const Color accentRed = primaryAction;
  static const Color accentGreen = Color(0xFF34C759);
  static const Color accentBlue = Color(0xFF0A84FF);
  static const Color primaryDarkGrey = Color(0xFF1C1C1C);
  static const Color secondaryDarkGrey = Color(0xFF2C2C2C);

  // Legacy/Mappings
  static const Color backgroundColor = Color(0xFFEEEEEE); // Light Grey
  static const Color cardColor = Colors.white;
  static const Color surfaceColor = Colors.white;
  static const Color scaffoldBackgroundColor = Color(0xFFEEEEEE); // Light Grey

  // Text Colors
  static const Color textBlack = Color(0xFF000000); // New Black for Light Theme
  static const Color textDarkGrey = Color(
    0xFF424242,
  ); // Darker grey for contrast
  static const Color textMediumGrey = Color(0xFF757575); // Restored

  // Legacy aliases for backward compatibility (mapped to suitable light theme colors)
  static const Color textWhite =
      textBlack; // Map 'textWhite' references to Black
  static const Color textLightGrey =
      textDarkGrey; // Map 'textLightGrey' to Dark Grey

  // Gradients
  static const LinearGradient accentGradient = LinearGradient(
    colors: [primaryAction, Color(0xFFB71C1C)],
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
  );

  static const LinearGradient goldGradient = LinearGradient(
    colors: [secondaryHighlight, Color(0xFFFFA000)],
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
  );

  // Theme Data
  static ThemeData get darkTheme {
    return ThemeData(
      useMaterial3: true,
      brightness: Brightness.light, // Changed to Light
      primaryColor: primaryAction,
      scaffoldBackgroundColor: backgroundColor,

      // AppBar Theme
      appBarTheme: const AppBarTheme(
        backgroundColor: Colors.transparent, // Transparent for modern look
        elevation: 0,
        centerTitle: true,
        iconTheme: IconThemeData(color: Colors.black),
        titleTextStyle: TextStyle(
          color: textWhite,
          fontSize: 20,
          fontWeight: FontWeight.bold,
          letterSpacing: 1,
        ),
      ),

      // Card Theme
      cardTheme: CardThemeData(
        color: cardColor,
        elevation: 0,
        margin: const EdgeInsets.symmetric(vertical: 8),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16),
          side: BorderSide(color: Colors.white.withOpacity(0.05)),
        ),
      ),

      // Elevated Button Theme (Primary Actions - Red)
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          backgroundColor: primaryAction,
          foregroundColor: textWhite,
          elevation: 4,
          shadowColor: primaryAction.withOpacity(0.4),
          padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 24),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
          textStyle: const TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.bold,
            letterSpacing: 0.5,
          ),
        ),
      ),

      // Outlined Button Theme
      outlinedButtonTheme: OutlinedButtonThemeData(
        style: OutlinedButton.styleFrom(
          foregroundColor: secondaryHighlight,
          side: const BorderSide(color: secondaryHighlight, width: 2),
          padding: const EdgeInsets.symmetric(vertical: 14, horizontal: 24),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
          textStyle: const TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
        ),
      ),

      // Input Decoration Theme (White Background)
      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: Colors.white,
        contentPadding: const EdgeInsets.symmetric(
          vertical: 18,
          horizontal: 16,
        ),

        // Text styles inside input
        labelStyle: const TextStyle(
          color: Color(0xFF757575),
          fontWeight: FontWeight.w500,
        ),
        hintStyle: const TextStyle(color: Color(0xFF9E9E9E)),
        floatingLabelStyle: const TextStyle(
          color: primaryAction,
          fontWeight: FontWeight.bold,
        ),

        // Icon colors inside input
        prefixIconColor: const Color(0xFF757575),
        suffixIconColor: const Color(0xFF757575),

        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide.none,
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide.none,
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: primaryAction, width: 2),
        ),
        errorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: Colors.red, width: 1.5),
        ),
      ),

      // Text Theme
      textTheme: const TextTheme(
        displayLarge: TextStyle(
          color: textWhite,
          fontSize: 32,
          fontWeight: FontWeight.bold,
        ),
        displayMedium: TextStyle(
          color: textWhite,
          fontSize: 28,
          fontWeight: FontWeight.w700,
        ),
        headlineLarge: TextStyle(
          color: textWhite,
          fontSize: 24,
          fontWeight: FontWeight.bold,
        ),
        headlineMedium: TextStyle(
          color: textWhite,
          fontSize: 20,
          fontWeight: FontWeight.w600,
        ),
        titleLarge: TextStyle(
          color: textWhite,
          fontSize: 18,
          fontWeight: FontWeight.w600,
        ),
        titleMedium: TextStyle(
          color: textLightGrey,
          fontSize: 16,
          fontWeight: FontWeight.w500,
        ),
        bodyLarge: TextStyle(color: textWhite, fontSize: 16),
        bodyMedium: TextStyle(color: textLightGrey, fontSize: 14),
      ),

      floatingActionButtonTheme: FloatingActionButtonThemeData(
        backgroundColor: primaryAction,
        foregroundColor: textWhite,
        elevation: 8,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      ),

      dividerColor: Colors.white.withOpacity(0.1),
    );
  }
}

// Custom Widget Styles
class CustomButtonStyles {
  static ButtonStyle goldGradientButton() {
    return ElevatedButton.styleFrom(
      backgroundColor: AppTheme.secondaryHighlight,
      foregroundColor: AppTheme.primaryBlack,
      elevation: 6,
      shadowColor: AppTheme.secondaryHighlight.withOpacity(0.5),
      padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 32),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
    );
  }

  static ButtonStyle blueGradientButton() {
    return ElevatedButton.styleFrom(
      backgroundColor: AppTheme.primaryAction, // Changed to primaryAction
      foregroundColor: AppTheme.textWhite,
      elevation: 6,
      shadowColor: AppTheme.primaryAction.withOpacity(
        0.5,
      ), // Changed to primaryAction
      padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 32),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
    );
  }

  static ButtonStyle greenGradientButton() {
    return ElevatedButton.styleFrom(
      backgroundColor: AppTheme.primaryAction, // Changed to primaryAction
      foregroundColor: AppTheme.primaryBlack,
      elevation: 6,
      shadowColor: AppTheme.primaryAction.withOpacity(
        0.5,
      ), // Changed to primaryAction
      padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 32),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
    );
  }
}

// Custom Card Styles
class CustomCardStyles {
  static BoxDecoration darkCardDecoration({double radius = 16}) {
    return BoxDecoration(
      color: AppTheme.cardColor,
      borderRadius: BorderRadius.circular(radius),
      boxShadow: [
        BoxShadow(
          color: Colors.black.withOpacity(0.4),
          blurRadius: 12,
          offset: const Offset(0, 6),
        ),
      ],
    );
  }

  static BoxDecoration darkCardWithBorderDecoration({
    double radius = 16,
    Color borderColor = AppTheme.darkSurface, // Changed to darkSurface
  }) {
    return BoxDecoration(
      color: AppTheme.cardColor,
      borderRadius: BorderRadius.circular(radius),
      border: Border.all(color: borderColor, width: 1),
      boxShadow: [
        BoxShadow(
          color: Colors.black.withOpacity(0.3),
          blurRadius: 8,
          offset: const Offset(0, 4),
        ),
      ],
    );
  }

  static BoxDecoration accentCardDecoration({double radius = 16}) {
    return BoxDecoration(
      gradient: LinearGradient(
        colors: [
          AppTheme.primaryAction.withOpacity(0.1), // Changed to primaryAction
          AppTheme.primaryAction.withOpacity(0.05), // Changed to primaryAction
        ],
        begin: Alignment.topLeft,
        end: Alignment.bottomRight,
      ),
      borderRadius: BorderRadius.circular(radius),
      border: Border.all(
        color: AppTheme.primaryAction.withOpacity(
          0.3,
        ), // Changed to primaryAction
        width: 1.5,
      ),
      boxShadow: [
        BoxShadow(
          color: AppTheme.primaryAction.withOpacity(
            0.2,
          ), // Changed to primaryAction
          blurRadius: 12,
          offset: const Offset(0, 6),
        ),
      ],
    );
  }
}

class ImageHelper {
  static String fixImageUrl(String? url) {
    if (url == null || url.isEmpty) return '';
    if (url.contains('placehold.co') && !url.contains('.png')) {
      // Insert .png before the query parameters or at the end
      if (url.contains('?')) {
        return url.replaceFirst('?', '.png?');
      } else {
        return '$url.png';
      }
    }
    return url;
  }
}
