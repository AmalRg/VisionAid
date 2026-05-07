import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'app_colors.dart';

class AppTheme {
  AppTheme._();

  static ThemeData get darkTheme  => _make(true);
  static ThemeData get lightTheme => _make(false);

  static ThemeData _make(bool dark) {
    final bg      = dark ? AppColors.background    : AppColors.lBackground;
    final card    = dark ? AppColors.surface        : AppColors.lSurface;
    final card2   = dark ? AppColors.surface2       : AppColors.lSurface2;
    final brd     = dark ? AppColors.border         : AppColors.lBorder;
    final txtP    = dark ? AppColors.textPrimary    : AppColors.lTextPrimary;
    final txtS    = dark ? AppColors.textSecondary  : AppColors.lTextSecondary;
    final txtH    = dark ? AppColors.textHint       : AppColors.lTextHint;
    final navBar  = dark ? AppColors.surface        : AppColors.lSurface;

    return ThemeData(
      useMaterial3: true,
      brightness: dark ? Brightness.dark : Brightness.light,
      scaffoldBackgroundColor: bg,

      colorScheme: ColorScheme(
        brightness: dark ? Brightness.dark : Brightness.light,
        primary: AppColors.primary,
        onPrimary: Colors.black,
        secondary: AppColors.primaryDark,
        onSecondary: Colors.black,
        error: AppColors.danger,
        onError: Colors.white,
        background: bg,
        onBackground: txtP,
        surface: card,
        onSurface: txtP,
      ),

      appBarTheme: AppBarTheme(
        backgroundColor: bg,
        elevation: 0,
        scrolledUnderElevation: 0,
        centerTitle: true,
        systemOverlayStyle: SystemUiOverlayStyle(
          statusBarColor: Colors.transparent,
          statusBarIconBrightness: dark ? Brightness.light : Brightness.dark,
          statusBarBrightness: dark ? Brightness.dark : Brightness.light,
          systemNavigationBarColor: Colors.transparent,
        ),
        titleTextStyle: TextStyle(
          color: txtP, fontSize: 18, fontWeight: FontWeight.w600,
        ),
        iconTheme: IconThemeData(color: txtP),
      ),

      bottomNavigationBarTheme: BottomNavigationBarThemeData(
        backgroundColor: navBar,
        selectedItemColor: AppColors.primary,
        unselectedItemColor: txtS,
        type: BottomNavigationBarType.fixed,
        elevation: 0,
      ),

      cardTheme: CardThemeData(
        color: card,
        elevation: 0,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(14),
          side: BorderSide(color: brd),
        ),
      ),

      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          backgroundColor: AppColors.primary,
          foregroundColor: Colors.black,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
          padding: const EdgeInsets.symmetric(vertical: 16),
          elevation: 0,
          textStyle: const TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
        ),
      ),

      textButtonTheme: TextButtonThemeData(
        style: TextButton.styleFrom(foregroundColor: AppColors.primary),
      ),

      switchTheme: SwitchThemeData(
        thumbColor: MaterialStateProperty.resolveWith((s) =>
        s.contains(MaterialState.selected) ? AppColors.primary : txtS),
        trackColor: MaterialStateProperty.resolveWith((s) =>
        s.contains(MaterialState.selected)
            ? AppColors.primary.withOpacity(0.35)
            : brd),
        trackOutlineColor: MaterialStateProperty.all(Colors.transparent),
      ),

      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: card,
        hintStyle: TextStyle(color: txtH, fontSize: 14),
        contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide(color: brd),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide(color: brd),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: AppColors.primary, width: 1.5),
        ),
      ),

      dividerTheme: DividerThemeData(color: brd, thickness: 1, space: 1),

      snackBarTheme: SnackBarThemeData(
        backgroundColor: dark ? card2 : const Color(0xFF1E2535),
        contentTextStyle: const TextStyle(color: Colors.white, fontSize: 14),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
        behavior: SnackBarBehavior.floating,
      ),

      dialogTheme: DialogThemeData(
        backgroundColor: card,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        titleTextStyle: TextStyle(color: txtP, fontSize: 18, fontWeight: FontWeight.w600),
        contentTextStyle: TextStyle(color: txtS, fontSize: 14),
      ),

      textTheme: TextTheme(
        displayLarge : TextStyle(color: txtP, fontSize: 32, fontWeight: FontWeight.bold),
        headlineLarge: TextStyle(color: txtP, fontSize: 26, fontWeight: FontWeight.bold),
        headlineMedium:TextStyle(color: txtP, fontSize: 22, fontWeight: FontWeight.w600),
        titleLarge   : TextStyle(color: txtP, fontSize: 18, fontWeight: FontWeight.w600),
        titleMedium  : TextStyle(color: txtP, fontSize: 16, fontWeight: FontWeight.w500),
        bodyLarge    : TextStyle(color: txtP, fontSize: 15),
        bodyMedium   : TextStyle(color: txtS, fontSize: 13, height: 1.5),
        labelSmall   : TextStyle(color: txtH, fontSize: 11, letterSpacing: 1.2,
            fontWeight: FontWeight.w600),
      ),
    );
  }
}
