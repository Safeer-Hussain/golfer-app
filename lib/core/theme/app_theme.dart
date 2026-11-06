import 'package:flutter/material.dart';

class AppTheme {
  static const ColorScheme darkColorScheme = ColorScheme(
    brightness: Brightness.dark,
    primary: Color(0xFF10B981),
    onPrimary: Color(0xFF042F1A),
    primaryContainer: Color(0xFF064E2B),
    onPrimaryContainer: Color(0xFF6EE7B7),
    secondary: Color(0xFFE5C058),
    onSecondary: Color(0xFF332600),
    secondaryContainer: Color(0xFF4D3B00),
    onSecondaryContainer: Color(0xFFFDE68A),
    tertiary: Color(0xFF38BDF8),
    onTertiary: Color(0xFF082F49),
    error: Color(0xFFEF4444),
    onError: Color(0xFF450A0A),
    surface: Color(0xFF0A140F),
    onSurface: Color(0xFFE8F5E9),
    surfaceContainer: Color(0xFF13221A),
    surfaceContainerHigh: Color(0xFF172C21),
    surfaceContainerHighest: Color(0xFF1E3A2C),
    onSurfaceVariant: Color(0xFFA5D6A7),
    outline: Color(0xFF385743),
    outlineVariant: Color(0xFF233B2E),
  );

  static const ColorScheme lightColorScheme = ColorScheme(
    brightness: Brightness.light,
    primary: Color(0xFF15803D),
    onPrimary: Color(0xFFFFFFFF),
    primaryContainer: Color(0xFFDCFCE7),
    onPrimaryContainer: Color(0xFF14532D),
    secondary: Color(0xFFB45309),
    onSecondary: Color(0xFFFFFFFF),
    secondaryContainer: Color(0xFFFEF3C7),
    onSecondaryContainer: Color(0xFF78350F),
    tertiary: Color(0xFF0284C7),
    onTertiary: Color(0xFFFFFFFF),
    error: Color(0xFFDC2626),
    onError: Color(0xFFFFFFFF),
    surface: Color(0xFFF8FAF8),
    onSurface: Color(0xFF1C2B21),
    surfaceContainer: Color(0xFFEDF4EE),
    surfaceContainerHigh: Color(0xFFE2EDE4),
    surfaceContainerHighest: Color(0xFFD6E4D9),
    onSurfaceVariant: Color(0xFF3E5A47),
    outline: Color(0xFF829E8C),
    outlineVariant: Color(0xFFC0D4C5),
  );

  static ThemeData darkTheme = ThemeData(
    useMaterial3: true,
    brightness: Brightness.dark,
    colorScheme: darkColorScheme,
    scaffoldBackgroundColor: darkColorScheme.surface,
    canvasColor: darkColorScheme.surface,
    cardColor: darkColorScheme.surfaceContainer,
    dividerColor: darkColorScheme.outlineVariant,
    appBarTheme: AppBarTheme(
      backgroundColor: darkColorScheme.surface,
      foregroundColor: darkColorScheme.onSurface,
      elevation: 0,
      centerTitle: false,
      scrolledUnderElevation: 0,
    ),
    bottomSheetTheme: BottomSheetThemeData(
      backgroundColor: darkColorScheme.surfaceContainer,
      surfaceTintColor: Colors.transparent,
      modalBackgroundColor: darkColorScheme.surfaceContainer,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
    ),
  );

  static ThemeData lightTheme = ThemeData(
    useMaterial3: true,
    brightness: Brightness.light,
    colorScheme: lightColorScheme,
    scaffoldBackgroundColor: lightColorScheme.surface,
    canvasColor: lightColorScheme.surface,
    cardColor: lightColorScheme.surfaceContainer,
    dividerColor: lightColorScheme.outlineVariant,
    appBarTheme: AppBarTheme(
      backgroundColor: lightColorScheme.surface,
      foregroundColor: lightColorScheme.onSurface,
      elevation: 0,
      centerTitle: false,
      scrolledUnderElevation: 0,
    ),
    bottomSheetTheme: BottomSheetThemeData(
      backgroundColor: lightColorScheme.surfaceContainer,
      surfaceTintColor: Colors.transparent,
      modalBackgroundColor: lightColorScheme.surfaceContainer,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
    ),
  );
}
