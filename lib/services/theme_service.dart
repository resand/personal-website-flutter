import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../models/website_config.dart';

class ThemeService {
  static Color _colorFromHex(String hexColor) {
    final hexCode = hexColor.replaceAll('#', '');
    return Color(int.parse('FF$hexCode', radix: 16));
  }

  static ColorScheme _createColorScheme(ColorSchemeConfig config, Brightness brightness) {
    final backgroundColor = _colorFromHex(config.background);
    
    return ColorScheme(
      brightness: brightness,
      primary: _colorFromHex(config.primary),
      onPrimary: _colorFromHex(config.onPrimary),
      secondary: _colorFromHex(config.secondary),
      onSecondary: _colorFromHex(config.onSecondary),
      surface: backgroundColor,
      onSurface: _colorFromHex(config.onSurface),
      error: _colorFromHex(config.error),
      onError: _colorFromHex(config.onError),
    );
  }

  static ThemeData createLightTheme(ThemeConfig themeConfig) {
    final colorScheme = _createColorScheme(themeConfig.lightColors, Brightness.light);
    
    return ThemeData(
      colorScheme: colorScheme,
      textTheme: _getTextTheme(themeConfig.fontFamily),
      useMaterial3: true,
      scaffoldBackgroundColor: colorScheme.surface,
      appBarTheme: AppBarTheme(
        backgroundColor: colorScheme.surface,
        foregroundColor: colorScheme.onSurface,
        elevation: 1,
      ),
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          backgroundColor: colorScheme.primary,
          foregroundColor: colorScheme.onPrimary,
        ),
      ),
      outlinedButtonTheme: OutlinedButtonThemeData(
        style: OutlinedButton.styleFrom(
          foregroundColor: colorScheme.primary,
          side: BorderSide(color: colorScheme.primary),
        ),
      ),
      textButtonTheme: TextButtonThemeData(
        style: TextButton.styleFrom(
          foregroundColor: colorScheme.primary,
        ),
      ),
      cardTheme: CardThemeData(
        color: colorScheme.surface,
        shadowColor: colorScheme.onSurface.withValues(alpha: 0.1),
        elevation: 2,
      ),
      pageTransitionsTheme: const PageTransitionsTheme(
        builders: {
          TargetPlatform.android: FadeUpwardsPageTransitionsBuilder(),
          TargetPlatform.iOS: CupertinoPageTransitionsBuilder(),
        },
      ),
    );
  }

  static ThemeData createDarkTheme(ThemeConfig themeConfig) {
    final colorScheme = _createColorScheme(themeConfig.darkColors, Brightness.dark);
    return ThemeData(
      colorScheme: colorScheme,
      textTheme: _getTextTheme(themeConfig.fontFamily, ThemeData.dark().textTheme),
      useMaterial3: true,
      scaffoldBackgroundColor: colorScheme.surface,
      appBarTheme: AppBarTheme(
        backgroundColor: colorScheme.surface,
        foregroundColor: colorScheme.onSurface,
        elevation: 1,
      ),
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          backgroundColor: colorScheme.primary,
          foregroundColor: colorScheme.onPrimary,
        ),
      ),
      outlinedButtonTheme: OutlinedButtonThemeData(
        style: OutlinedButton.styleFrom(
          foregroundColor: colorScheme.primary,
          side: BorderSide(color: colorScheme.primary),
        ),
      ),
      textButtonTheme: TextButtonThemeData(
        style: TextButton.styleFrom(
          foregroundColor: colorScheme.primary,
        ),
      ),
      cardTheme: CardThemeData(
        color: colorScheme.surface,
        shadowColor: colorScheme.onSurface.withValues(alpha: 0.1),
        elevation: 2,
      ),
      pageTransitionsTheme: const PageTransitionsTheme(
        builders: {
          TargetPlatform.android: FadeUpwardsPageTransitionsBuilder(),
          TargetPlatform.iOS: CupertinoPageTransitionsBuilder(),
        },
      ),
    );
  }


  static TextTheme _getTextTheme(String fontFamily, [TextTheme? baseTheme]) {
    switch (fontFamily.toLowerCase()) {
      case 'poppins':
        return GoogleFonts.poppinsTextTheme(baseTheme);
      case 'roboto':
        return GoogleFonts.robotoTextTheme(baseTheme);
      case 'montserrat':
        return GoogleFonts.montserratTextTheme(baseTheme);
      case 'lato':
        return GoogleFonts.latoTextTheme(baseTheme);
      case 'open sans':
        return GoogleFonts.openSansTextTheme(baseTheme);
      default:
        return GoogleFonts.poppinsTextTheme(baseTheme);
    }
  }
}