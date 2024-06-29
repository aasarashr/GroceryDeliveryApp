import 'package:flutter/material.dart';

// Define the custom colors
const Color primaryColor = Color.fromRGBO(2, 43, 96, 1); // Main color 1
const Color secondaryColor = Color(0xFFFF9202); // Main color 2
const Color accentColor1 = Color(0xFFC2CEDA); // Accent color 1
const Color accentColor2 = Color(0xFFB87F7F); // Accent color 2
const Color whiteColor = Colors.white; // White color

// Define the custom theme
final ThemeData myTheme = ThemeData(
  primaryColor: primaryColor,
  hintColor: secondaryColor,
  scaffoldBackgroundColor: whiteColor,
  appBarTheme: AppBarTheme(
    backgroundColor:  primaryColor,
    iconTheme: const IconThemeData(color: whiteColor),
  ),
  buttonTheme: ButtonThemeData(
    buttonColor: secondaryColor,
    textTheme: ButtonTextTheme.primary,
  ),
  colorScheme: ColorScheme.fromSwatch(
    primarySwatch: createMaterialColor(primaryColor),
  ).copyWith(
    secondary: secondaryColor,
  ),
  textTheme: const TextTheme(
    bodyLarge: TextStyle(color: primaryColor),
    bodyMedium: TextStyle(color: secondaryColor),
    displayLarge: TextStyle(color: primaryColor, fontWeight: FontWeight.bold),
    titleLarge: TextStyle(color: primaryColor),
    bodySmall: TextStyle(color: accentColor1),
    labelLarge: TextStyle(color: whiteColor),
  ),
);

MaterialColor createMaterialColor(Color color) {
  List strengths = <double>[.05];
  Map<int, Color> swatch = {};
  final int r = color.red, g = color.green, b = color.blue;

  for (int i = 1; i < 10; i++) {
    strengths.add(0.1 * i);
  }
  for (var strength in strengths) {
    final double ds = 0.5 - strength;
    swatch[(strength * 1000).round()] = Color.fromRGBO(
      r + ((ds < 0 ? r : (255 - r)) * ds).round(),
      g + ((ds < 0 ? g : (255 - g)) * ds).round(),
      b + ((ds < 0 ? b : (255 - b)) * ds).round(),
      1,
    );
  }
  return MaterialColor(color.value, swatch);
}
