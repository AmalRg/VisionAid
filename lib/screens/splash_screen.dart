import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';
import '../core/app_colors.dart';
import '../providers/settings_provider.dart';

class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});
  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> with TickerProviderStateMixin {
  late AnimationController _logo;
  late AnimationController _text;
  late AnimationController _prog;
  late Animation<double> _scale, _logoOpacity, _textOpacity, _subOpacity, _progress;

  @override
  void initState() {
    super.initState();

    _logo = AnimationController(vsync: this, duration: const Duration(milliseconds: 900));
    _scale       = Tween<double>(begin: 0.4, end: 1.0).animate(CurvedAnimation(parent: _logo, curve: Curves.elasticOut));
    _logoOpacity = Tween<double>(begin: 0.0, end: 1.0).animate(CurvedAnimation(parent: _logo, curve: const Interval(0.0, 0.5, curve: Curves.easeIn)));

    _text = AnimationController(vsync: this, duration: const Duration(milliseconds: 700));
    _textOpacity = Tween<double>(begin: 0.0, end: 1.0).animate(CurvedAnimation(parent: _text, curve: Curves.easeIn));
    _subOpacity  = Tween<double>(begin: 0.0, end: 1.0).animate(CurvedAnimation(parent: _text, curve: const Interval(0.3, 1.0, curve: Curves.easeIn)));

    _prog = AnimationController(vsync: this, duration: const Duration(milliseconds: 1800));
    _progress = Tween<double>(begin: 0.0, end: 1.0).animate(CurvedAnimation(parent: _prog, curve: Curves.easeInOut));

    _start();
  }

  Future<void> _start() async {
    await Future.delayed(const Duration(milliseconds: 300));
    _logo.forward();
    await Future.delayed(const Duration(milliseconds: 600));
    _text.forward();
    _prog.forward();
    await Future.delayed(const Duration(milliseconds: 2600));
    if (!mounted) return;
    final settings = context.read<SettingsProvider>();
    final isFirst = await settings.isFirstLaunch();
    if (!mounted) return;
    context.go(isFirst ? '/onboarding' : '/home');
  }

  @override
  void dispose() {
    _logo.dispose(); _text.dispose(); _prog.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final bg = AppColors.bg(context);

    return Scaffold(
      backgroundColor: bg,
      body: Center(
        child: Column(mainAxisAlignment: MainAxisAlignment.center, children: [
          const Spacer(flex: 2),

          // Logo
          AnimatedBuilder(
            animation: _logo,
            builder: (_, __) => Opacity(
              opacity: _logoOpacity.value,
              child: Transform.scale(
                scale: _scale.value,
                child: Container(
                  width: 100, height: 100,
                  decoration: BoxDecoration(
                    color: AppColors.primary,
                    shape: BoxShape.circle,
                    boxShadow: [BoxShadow(
                      color: AppColors.primary.withOpacity(0.35),
                      blurRadius: 30, spreadRadius: 6,
                    )],
                  ),
                  child: const Icon(Icons.visibility, color: Colors.white, size: 46),
                ),
              ),
            ),
          ),

          const SizedBox(height: 32),

          // Texte
          AnimatedBuilder(
            animation: _text,
            builder: (_, __) => Column(children: [
              Opacity(
                opacity: _textOpacity.value,
                child: Text('VisionAid',
                    style: TextStyle(
                      color: AppColors.txt(context),
                      fontSize: 34,
                      fontWeight: FontWeight.bold,
                    )),
              ),
              const SizedBox(height: 8),
              Opacity(
                opacity: _subOpacity.value,
                child: const Text(
                  'Votre assistant visuel intelligent',
                  style: TextStyle(color: AppColors.primary, fontSize: 15),
                ),
              ),
            ]),
          ),

          const Spacer(flex: 2),

          // Barre progression
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 60),
            child: Column(children: [
              AnimatedBuilder(
                animation: _prog,
                builder: (_, __) => ClipRRect(
                  borderRadius: BorderRadius.circular(4),
                  child: LinearProgressIndicator(
                    value: _progress.value,
                    backgroundColor: AppColors.brd(context),
                    valueColor: const AlwaysStoppedAnimation<Color>(AppColors.primary),
                    minHeight: 3,
                  ),
                ),
              ),
              const SizedBox(height: 14),
              Text('v1.0.0 · Google ML Kit',
                  style: TextStyle(color: AppColors.hint(context), fontSize: 12)),
            ]),
          ),

          const SizedBox(height: 48),
        ]),
      ),
    );
  }
}
