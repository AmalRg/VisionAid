import 'package:flutter/material.dart';

class AppColors {
  AppColors._();

  // Accent
  static const Color primary     = Color(0xFF2ECC7A);
  static const Color primaryDark = Color(0xFF25A866);
  static const Color warning     = Color(0xFFF39C12);
  static const Color danger      = Color(0xFFE74C3C);
  static const Color info        = Color(0xFF3498DB);

  // Dark
  static const Color background    = Color(0xFF0D1117);
  static const Color surface       = Color(0xFF161B27);
  static const Color surface2      = Color(0xFF1E2535);
  static const Color surface3      = Color(0xFF252D3D);
  static const Color border        = Color(0xFF2A3347);
  static const Color textPrimary   = Color(0xFFFFFFFF);
  static const Color textSecondary = Color(0xFF8892A4);
  static const Color textHint      = Color(0xFF4A5568);

  // Light
  static const Color lBackground    = Color(0xFFF5F7FA);
  static const Color lSurface       = Color(0xFFFFFFFF);
  static const Color lSurface2      = Color(0xFFF0F4F8);
  static const Color lBorder        = Color(0xFFE2E8F0);
  static const Color lTextPrimary   = Color(0xFF0D1117);
  static const Color lTextSecondary = Color(0xFF5A6478);
  static const Color lTextHint      = Color(0xFF9AA3B2);

  // Helpers
  static bool _dark(BuildContext c) => Theme.of(c).brightness == Brightness.dark;
  static Color bg(BuildContext c)       => _dark(c) ? background    : lBackground;
  static Color card(BuildContext c)     => _dark(c) ? surface       : lSurface;
  static Color card2(BuildContext c)    => _dark(c) ? surface2      : lSurface2;
  static Color brd(BuildContext c)      => _dark(c) ? border        : lBorder;
  static Color txt(BuildContext c)      => _dark(c) ? textPrimary   : lTextPrimary;
  static Color sub(BuildContext c)      => _dark(c) ? textSecondary : lTextSecondary;
  static Color hint(BuildContext c)     => _dark(c) ? textHint      : lTextHint;
  static Color navBar(BuildContext c)   => _dark(c) ? surface       : lSurface;
}
