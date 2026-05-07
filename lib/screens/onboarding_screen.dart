import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';
import '../core/app_colors.dart';
import '../providers/settings_provider.dart';

class _OnboardingPage {
  final String title;
  final String description;
  final IconData icon;
  const _OnboardingPage({
    required this.title,
    required this.description,
    required this.icon,
  });
}

class OnboardingScreen extends StatefulWidget {
  const OnboardingScreen({super.key});

  @override
  State<OnboardingScreen> createState() => _OnboardingScreenState();
}

class _OnboardingScreenState extends State<OnboardingScreen> {
  final PageController _pageController = PageController();
  int _currentPage = 0;

  final List<_OnboardingPage> _pages = const [
    _OnboardingPage(
      title: 'Décrivez votre\nenvironnement',
      description:
          'Pointez la caméra et VisionAid identifie les objets autour de vous et les décrit à voix haute en temps réel.',
      icon: Icons.visibility_outlined,
    ),
    _OnboardingPage(
      title: 'Scannez vos\ndocuments',
      description:
          'Pointez la caméra vers n\'importe quel texte — ordonnance, panneau, livre — et VisionAid le lit à voix haute instantanément.',
      icon: Icons.document_scanner_outlined,
    ),
    _OnboardingPage(
      title: 'Alertes obstacles\nen temps réel',
      description:
          'VisionAid vibre et vous alerte vocalement dès qu\'un obstacle est détecté à proximité. 100% hors ligne.',
      icon: Icons.sensors,
    ),
  ];

  void _next() {
    if (_currentPage < _pages.length - 1) {
      _pageController.nextPage(
        duration: const Duration(milliseconds: 350),
        curve: Curves.easeInOut,
      );
    } else {
      _finish();
    }
  }

  Future<void> _finish() async {
    await context.read<SettingsProvider>().markOnboardingDone();
    if (mounted) context.go('/home');
  }

  @override
  void dispose() {
    _pageController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      body: SafeArea(
        child: Column(
          children: [
            // bouton passer
            Align(
              alignment: Alignment.topRight,
              child: Padding(
                padding: const EdgeInsets.only(right: 20, top: 12),
                child: TextButton(
                  onPressed: _finish,
                  child: const Text(
                    'Passer',
                    style: TextStyle(
                      color: AppColors.primary,
                      fontSize: 15,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ),
              ),
            ),

            // pages
            Expanded(
              child: PageView.builder(
                controller: _pageController,
                onPageChanged: (i) => setState(() => _currentPage = i),
                itemCount: _pages.length,
                itemBuilder: (context, index) =>
                    _OnboardingPageWidget(page: _pages[index]),
              ),
            ),

            // indicateurs
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: List.generate(_pages.length, (i) {
                return AnimatedContainer(
                  duration: const Duration(milliseconds: 300),
                  margin: const EdgeInsets.symmetric(horizontal: 4),
                  width: i == _currentPage ? 24 : 8,
                  height: 8,
                  decoration: BoxDecoration(
                    color: i == _currentPage
                        ? AppColors.primary
                        : AppColors.surface3,
                    borderRadius: BorderRadius.circular(4),
                  ),
                );
              }),
            ),

            const SizedBox(height: 28),

            // bouton suivant
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 24),
              child: SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: _next,
                  child: Text(
                    _currentPage < _pages.length - 1
                        ? 'Suivant →'
                        : 'Commencer →',
                  ),
                ),
              ),
            ),

            const SizedBox(height: 12),

            // lien deja utilise
            TextButton(
              onPressed: _finish,
              child: RichText(
                text: const TextSpan(
                  style: TextStyle(color: AppColors.textSecondary, fontSize: 13),
                  children: [
                    TextSpan(text: 'Déjà utilisé ? '),
                    TextSpan(
                      text: 'Reprendre',
                      style: TextStyle(
                        color: AppColors.primary,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ],
                ),
              ),
            ),

            const SizedBox(height: 16),
          ],
        ),
      ),
    );
  }
}

class _OnboardingPageWidget extends StatelessWidget {
  final _OnboardingPage page;
  const _OnboardingPageWidget({required this.page});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 24),
      child: Column(
        children: [
          // illustration
          Expanded(
            child: Container(
              margin: const EdgeInsets.symmetric(vertical: 16),
              decoration: BoxDecoration(
                color: AppColors.surface,
                borderRadius: BorderRadius.circular(20),
                border: Border.all(color: AppColors.border),
              ),
              child: Center(
                child: _OnboardingIllustration(icon: page.icon),
              ),
            ),
          ),

          const SizedBox(height: 24),

          // titre
          Text(
            page.title,
            textAlign: TextAlign.left,
            style: const TextStyle(
              color: AppColors.textPrimary,
              fontSize: 26,
              fontWeight: FontWeight.bold,
              height: 1.2,
            ),
          ),

          const SizedBox(height: 12),

          // description
          Text(
            page.description,
            textAlign: TextAlign.left,
            style: const TextStyle(
              color: AppColors.textSecondary,
              fontSize: 14,
              height: 1.6,
            ),
          ),

          const SizedBox(height: 20),
        ],
      ),
    );
  }
}

// illustration animee pour chaque slide
class _OnboardingIllustration extends StatefulWidget {
  final IconData icon;
  const _OnboardingIllustration({required this.icon});

  @override
  State<_OnboardingIllustration> createState() =>
      _OnboardingIllustrationState();
}

class _OnboardingIllustrationState extends State<_OnboardingIllustration>
    with SingleTickerProviderStateMixin {
  late AnimationController _ctrl;
  late Animation<double> _pulse;

  @override
  void initState() {
    super.initState();
    _ctrl = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 2),
    )..repeat(reverse: true);
    _pulse = Tween<double>(begin: 0.85, end: 1.0).animate(
      CurvedAnimation(parent: _ctrl, curve: Curves.easeInOut),
    );
  }

  @override
  void dispose() {
    _ctrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _ctrl,
      builder: (_, __) => Stack(
        alignment: Alignment.center,
        children: [
          // Anneau externe
          Transform.scale(
            scale: _pulse.value,
            child: Container(
              width: 130,
              height: 130,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                border: Border.all(
                  color: AppColors.primary.withOpacity(0.25),
                  width: 1.5,
                ),
              ),
            ),
          ),
          // Anneau intermédiaire
          Transform.scale(
            scale: 1.0 - (_pulse.value - 0.85) * 0.3,
            child: Container(
              width: 95,
              height: 95,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                border: Border.all(
                  color: AppColors.primary.withOpacity(0.45),
                  width: 1.5,
                  style: BorderStyle.solid,
                ),
              ),
            ),
          ),
          // Cercle intérieur + icône
          Container(
            width: 64,
            height: 64,
            decoration: const BoxDecoration(
              shape: BoxShape.circle,
              color: AppColors.primary,
            ),
            child: Icon(widget.icon, color: Colors.white, size: 30),
          ),
          // Croix de visée haut
          Positioned(
            top: 40,
            child: Container(width: 2, height: 14,
                color: AppColors.primary.withOpacity(0.6)),
          ),
          // Croix de visée bas
          Positioned(
            bottom: 40,
            child: Container(width: 2, height: 14,
                color: AppColors.primary.withOpacity(0.6)),
          ),
          // Croix de visée gauche
          Positioned(
            left: 40,
            child: Container(width: 14, height: 2,
                color: AppColors.primary.withOpacity(0.6)),
          ),
          // Croix de visée droite
          Positioned(
            right: 40,
            child: Container(width: 14, height: 2,
                color: AppColors.primary.withOpacity(0.6)),
          ),
        ],
      ),
    );
  }
}
