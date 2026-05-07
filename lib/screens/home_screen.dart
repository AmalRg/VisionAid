import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';
import '../core/app_colors.dart';
import '../providers/settings_provider.dart';
import '../providers/history_provider.dart';

class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final settings = context.watch<SettingsProvider>();
    final history  = context.watch<HistoryProvider>();

    return Scaffold(
      backgroundColor: AppColors.bg(context),
      bottomNavigationBar: _BottomNav(currentIndex: 0),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _HomeAppBar(),
              const SizedBox(height: 16),
              _StatusCard(),
              const SizedBox(height: 20),
              Text('MODES PRINCIPAUX',
                  style: TextStyle(
                    color: AppColors.hint(context),
                    fontSize: 11,
                    fontWeight: FontWeight.w600,
                    letterSpacing: 1.5,
                  )),
              const SizedBox(height: 10),
              Row(children: [
                Expanded(child: _ModeCard(
                  label: 'Détection',
                  subtitle: 'Obstacles & scène',
                  icon: Icons.camera_alt_outlined,
                  iconColor: AppColors.primary,
                  iconBg: AppColors.primary.withOpacity(0.15),
                  isHighlighted: true,
                  onTap: () => context.push('/detection'),
                )),
                const SizedBox(width: 12),
                Expanded(child: _ModeCard(
                  label: 'Scanner OCR',
                  subtitle: 'Texte & documents',
                  icon: Icons.document_scanner_outlined,
                  iconColor: AppColors.warning,
                  iconBg: AppColors.warning.withOpacity(0.15),
                  onTap: () => context.push('/ocr'),
                )),
              ]),
              const SizedBox(height: 12),
              Row(children: [
                Expanded(child: _ModeCard(
                  label: 'Historique',
                  subtitle: 'Scans sauvegardés',
                  icon: Icons.history,
                  iconColor: const Color(0xFF9B59B6),
                  iconBg: const Color(0xFF9B59B6).withOpacity(0.15),
                  onTap: () => context.push('/history'),
                )),
                const SizedBox(width: 12),
                Expanded(child: _ModeCard(
                  label: 'Paramètres',
                  subtitle: 'Préférences',
                  icon: Icons.tune,
                  iconColor: AppColors.info,
                  iconBg: AppColors.info.withOpacity(0.15),
                  onTap: () => context.push('/settings'),
                )),
              ]),
              const SizedBox(height: 20),
              _StatsRow(
                scansToday:     history.scansToday,
                obstacleAlerts: history.obstacleAlerts,
                language:       settings.interfaceLanguage.toUpperCase(),
              ),
              const SizedBox(height: 20),
              SizedBox(
                width: double.infinity,
                child: ElevatedButton.icon(
                  onPressed: () => context.push('/detection'),
                  icon: const Icon(Icons.play_circle_outline, size: 22),
                  label: const Text('Lancer l\'analyse'),
                  style: ElevatedButton.styleFrom(
                      padding: const EdgeInsets.symmetric(vertical: 18)),
                ),
              ),
              const SizedBox(height: 12),
            ],
          ),
        ),
      ),
    );
  }
}

// Widgets

class _HomeAppBar extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Row(children: [
      Container(
        width: 36, height: 36,
        decoration: const BoxDecoration(color: AppColors.primary, shape: BoxShape.circle),
        child: const Icon(Icons.visibility, color: Colors.white, size: 18),
      ),
      const SizedBox(width: 10),
      Text('VisionAid',
          style: TextStyle(
              color: AppColors.txt(context), fontSize: 20, fontWeight: FontWeight.bold)),
      const Spacer(),
      _IconBtn(icon: Icons.notifications_none, onTap: () => context.push('/notifications')),
      const SizedBox(width: 8),
      _IconBtn(icon: Icons.tune, onTap: () => context.push('/settings')),
    ]);
  }
}

class _IconBtn extends StatelessWidget {
  final IconData icon;
  final VoidCallback onTap;
  const _IconBtn({required this.icon, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: 38, height: 38,
        decoration: BoxDecoration(
          color: AppColors.card(context),
          borderRadius: BorderRadius.circular(10),
          border: Border.all(color: AppColors.brd(context)),
        ),
        child: Icon(icon, color: AppColors.sub(context), size: 20),
      ),
    );
  }
}

class _StatusCard extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
      decoration: BoxDecoration(
        color: AppColors.card(context),
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: AppColors.brd(context)),
      ),
      child: Row(children: [
        Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          Text('STATUT SYSTÈME',
              style: TextStyle(color: AppColors.hint(context), fontSize: 10,
                  letterSpacing: 1.4, fontWeight: FontWeight.w600)),
          const SizedBox(height: 4),
          Text('Prêt à analyser',
              style: TextStyle(color: AppColors.txt(context), fontSize: 18,
                  fontWeight: FontWeight.w600)),
        ])),
        Container(width: 12, height: 12,
            decoration: const BoxDecoration(color: AppColors.primary, shape: BoxShape.circle)),
      ]),
    );
  }
}

class _ModeCard extends StatelessWidget {
  final String label;
  final String subtitle;
  final IconData icon;
  final Color iconColor;
  final Color iconBg;
  final VoidCallback onTap;
  final bool isHighlighted;

  const _ModeCard({
    required this.label, required this.subtitle, required this.icon,
    required this.iconColor, required this.iconBg, required this.onTap,
    this.isHighlighted = false,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: isHighlighted
              ? AppColors.primary.withOpacity(0.08)
              : AppColors.card(context),
          borderRadius: BorderRadius.circular(14),
          border: Border.all(
            color: isHighlighted
                ? AppColors.primary.withOpacity(0.4)
                : AppColors.brd(context),
          ),
        ),
        child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          Container(
            width: 40, height: 40,
            decoration: BoxDecoration(color: iconBg, borderRadius: BorderRadius.circular(10)),
            child: Icon(icon, color: iconColor, size: 22),
          ),
          const SizedBox(height: 12),
          Text(label,
              style: TextStyle(color: AppColors.txt(context), fontSize: 15,
                  fontWeight: FontWeight.w600)),
          const SizedBox(height: 2),
          Text(subtitle, style: TextStyle(color: AppColors.sub(context), fontSize: 12)),
        ]),
      ),
    );
  }
}

class _StatsRow extends StatelessWidget {
  final int scansToday;
  final int obstacleAlerts;
  final String language;
  const _StatsRow({required this.scansToday, required this.obstacleAlerts, required this.language});

  @override
  Widget build(BuildContext context) {
    return Row(children: [
      Expanded(child: _StatItem(value: '$scansToday', label: 'Scans\naujourd\'hui')),
      const SizedBox(width: 10),
      Expanded(child: _StatItem(value: '$obstacleAlerts', label: 'Alertes\nobstacles')),
      const SizedBox(width: 10),
      Expanded(child: _StatItem(value: language, label: 'Langue\nactive')),
    ]);
  }
}

class _StatItem extends StatelessWidget {
  final String value;
  final String label;
  const _StatItem({required this.value, required this.label});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 14),
      decoration: BoxDecoration(
        color: AppColors.card(context),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: AppColors.brd(context)),
      ),
      child: Column(children: [
        Text(value,
            style: TextStyle(color: AppColors.txt(context), fontSize: 22,
                fontWeight: FontWeight.bold)),
        const SizedBox(height: 4),
        Text(label, textAlign: TextAlign.center,
            style: TextStyle(color: AppColors.sub(context), fontSize: 11)),
      ]),
    );
  }
}

class _BottomNav extends StatelessWidget {
  final int currentIndex;
  const _BottomNav({required this.currentIndex});

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: AppColors.navBar(context),
        border: Border(top: BorderSide(color: AppColors.brd(context))),
      ),
      child: BottomNavigationBar(
        currentIndex: currentIndex,
        backgroundColor: Colors.transparent,
        elevation: 0,
        onTap: (i) {
          switch (i) {
            case 0: context.go('/home'); break;
            case 1: context.push('/detection'); break;
            case 2: context.push('/history'); break;
            case 3: context.push('/settings'); break;
          }
        },
        items: const [
          BottomNavigationBarItem(icon: Icon(Icons.home_outlined), activeIcon: Icon(Icons.home), label: 'Accueil'),
          BottomNavigationBarItem(icon: Icon(Icons.camera_alt_outlined), activeIcon: Icon(Icons.camera_alt), label: 'Caméra'),
          BottomNavigationBarItem(icon: Icon(Icons.history), label: 'Historique'),
          BottomNavigationBarItem(icon: Icon(Icons.tune), label: 'Réglages'),
        ],
      ),
    );
  }
}
