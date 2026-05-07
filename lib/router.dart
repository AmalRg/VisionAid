import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'screens/splash_screen.dart';
import 'screens/onboarding_screen.dart';
import 'screens/home_screen.dart';
import 'screens/detection_screen.dart';
import 'screens/ocr_screen.dart';
import 'screens/history_screen.dart';
import 'screens/scan_detail_screen.dart';
import 'screens/settings_screen.dart';
import 'screens/language_screen.dart';
import 'screens/notifications_screen.dart';
import 'screens/about_screen.dart';
import 'models/history_item.dart';

final GoRouter appRouter = GoRouter(
  initialLocation: '/splash',
  debugLogDiagnostics: false,
  routes: [
    GoRoute(
      path: '/splash',
      pageBuilder: (c, s) => _fade(s, const SplashScreen()),
    ),
    GoRoute(
      path: '/onboarding',
      pageBuilder: (c, s) => _slide(s, const OnboardingScreen()),
    ),
    GoRoute(
      path: '/home',
      pageBuilder: (c, s) => _fade(s, const HomeScreen()),
    ),
    GoRoute(
      path: '/detection',
      pageBuilder: (c, s) => _slide(s, const DetectionScreen()),
    ),
    GoRoute(
      path: '/ocr',
      pageBuilder: (c, s) => _slide(s, const OcrScreen()),
    ),
    GoRoute(
      path: '/history',
      pageBuilder: (c, s) => _slide(s, const HistoryScreen()),
    ),
    GoRoute(
      path: '/history/detail',
      pageBuilder: (c, s) {
        final item = s.extra as HistoryItem;
        return _slide(s, ScanDetailScreen(item: item));
      },
    ),
    GoRoute(
      path: '/settings',
      pageBuilder: (c, s) => _slide(s, const SettingsScreen()),
    ),
    GoRoute(
      path: '/language',
      pageBuilder: (c, s) => _slide(s, const LanguageScreen()),
    ),
    GoRoute(
      path: '/notifications',
      pageBuilder: (c, s) => _slideUp(s, const NotificationsScreen()),
    ),
    GoRoute(
      path: '/about',
      pageBuilder: (c, s) => _slide(s, const AboutScreen()),
    ),
  ],
);

// Transitions personnalisées

CustomTransitionPage<void> _fade(GoRouterState state, Widget child) {
  return CustomTransitionPage<void>(
    key: state.pageKey,
    child: child,
    transitionDuration: const Duration(milliseconds: 350),
    transitionsBuilder: (_, animation, __, child) =>
        FadeTransition(opacity: animation, child: child),
  );
}

CustomTransitionPage<void> _slide(GoRouterState state, Widget child) {
  return CustomTransitionPage<void>(
    key: state.pageKey,
    child: child,
    transitionDuration: const Duration(milliseconds: 300),
    transitionsBuilder: (_, animation, __, child) {
      final tween = Tween(begin: const Offset(1.0, 0.0), end: Offset.zero)
          .chain(CurveTween(curve: Curves.easeInOut));
      return SlideTransition(position: animation.drive(tween), child: child);
    },
  );
}

CustomTransitionPage<void> _slideUp(GoRouterState state, Widget child) {
  return CustomTransitionPage<void>(
    key: state.pageKey,
    child: child,
    transitionDuration: const Duration(milliseconds: 350),
    transitionsBuilder: (_, animation, __, child) {
      final tween = Tween(begin: const Offset(0.0, 1.0), end: Offset.zero)
          .chain(CurveTween(curve: Curves.easeOut));
      return SlideTransition(position: animation.drive(tween), child: child);
    },
  );
}
