import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';
import '../core/app_colors.dart';
import '../providers/settings_provider.dart';

class SettingsScreen extends StatelessWidget {
  const SettingsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final settings = context.watch<SettingsProvider>();

    return Scaffold(
      backgroundColor: AppColors.bg(context),
      appBar: AppBar(
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () => context.pop(),
        ),
        title: const Text('Paramètres'),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
        child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [

          // profil
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: AppColors.card(context),
              borderRadius: BorderRadius.circular(14),
              border: Border.all(color: AppColors.brd(context)),
            ),
            child: Row(children: [
              Container(
                width: 52, height: 52,
                decoration: const BoxDecoration(
                    color: AppColors.primary, shape: BoxShape.circle),
                child: const Center(
                  child: Text('VA',
                      style: TextStyle(color: Colors.black, fontSize: 18,
                          fontWeight: FontWeight.bold)),
                ),
              ),
              const SizedBox(width: 14),
              Expanded(
                child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                  Text('VisionAid User',
                      style: TextStyle(color: AppColors.txt(context), fontSize: 16,
                          fontWeight: FontWeight.w600)),
                  const SizedBox(height: 3),
                  Text('Mode accessibilité actif',
                      style: TextStyle(color: AppColors.sub(context), fontSize: 12)),
                ]),
              ),
            ]),
          ),

          const SizedBox(height: 20),
          _SLabel('AUDIO & RETOURS', context),
          const SizedBox(height: 10),

          _Card(context: context, children: [
            _SwitchTile(
              context: context,
              icon: Icons.volume_up_outlined,
              title: 'Lecture vocale',
              subtitle: 'Text-to-speech',
              value: settings.ttsEnabled,
              onChanged: settings.setTtsEnabled,
            ),
            _Div(context),

            _NavTile(
              context: context,
              icon: Icons.speed,
              title: 'Vitesse lecture',
              trailingText: _speedLabel(settings.ttsSpeed),
              onTap: () => _showSpeedSheet(context, settings),
            ),
            _Div(context),

            _SwitchTile(
              context: context,
              icon: Icons.vibration,
              title: 'Vibration',
              subtitle: 'Alertes haptiques',
              value: settings.vibrationEnabled,
              onChanged: settings.setVibrationEnabled,
            ),
          ]),

          const SizedBox(height: 16),
          _SLabel('AFFICHAGE', context),
          const SizedBox(height: 10),

          _Card(context: context, children: [
            _SwitchTile(
              context: context,
              icon: Icons.dark_mode_outlined,
              title: 'Mode sombre',
              value: settings.darkMode,
              onChanged: settings.setDarkMode,
            ),
            _Div(context),
            _NavTile(
              context: context,
              icon: Icons.language,
              title: 'Langue interface',
              trailingText: _langLabel(settings.interfaceLanguage),
              onTap: () => context.push('/language'),
            ),
          ]),

          const SizedBox(height: 16),
          _SLabel('NOTIFICATIONS', context),
          const SizedBox(height: 10),

          _Card(context: context, children: [
            _SwitchTile(
              context: context,
              icon: Icons.notifications_outlined,
              title: 'Notifications push',
              subtitle: 'Rappels d\'utilisation',
              value: settings.notificationsEnabled,
              onChanged: (v) {
                if (v) { context.push('/notifications'); }
                else   { settings.setNotificationsEnabled(false); }
              },
            ),
            _Div(context),
            _NavTile(
              context: context,
              icon: Icons.info_outline,
              title: 'À propos',
              onTap: () => context.push('/about'),
            ),
          ]),

          const SizedBox(height: 24),
        ]),
      ),
    );
  }

  String _speedLabel(double speed) {
    if (speed <= 0.4) return 'Lente ›';
    if (speed <= 0.65) return 'Normale ›';
    return 'Rapide ›';
  }

  void _showSpeedSheet(BuildContext context, SettingsProvider settings) {
    const speeds = [
      _SpeedOption(label: 'Lente',   value: 0.3,  desc: 'Lecture très confortable'),
      _SpeedOption(label: 'Normale', value: 0.5,  desc: 'Vitesse recommandée'),
      _SpeedOption(label: 'Rapide',  value: 0.8,  desc: 'Pour les habitués'),
    ];

    showModalBottomSheet(
      context: context,
      backgroundColor: AppColors.card(context),
      shape: const RoundedRectangleBorder(
          borderRadius: BorderRadius.vertical(top: Radius.circular(20))),
      builder: (_) => StatefulBuilder(
        builder: (ctx, setModalState) => Padding(
          padding: const EdgeInsets.all(24),
          child: Column(mainAxisSize: MainAxisSize.min, children: [
            Text('Vitesse de lecture',
                style: TextStyle(color: AppColors.txt(context), fontSize: 18,
                    fontWeight: FontWeight.w600)),
            const SizedBox(height: 8),
            Text('Choisissez la vitesse de lecture vocale',
                style: TextStyle(color: AppColors.sub(context), fontSize: 13)),
            const SizedBox(height: 20),

            for (final opt in speeds)
              GestureDetector(
                onTap: () {
                  settings.setTtsSpeed(opt.value);
                  setModalState(() {});
                  Navigator.pop(context);
                },
                child: Container(
                  margin: const EdgeInsets.only(bottom: 10),
                  padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
                  decoration: BoxDecoration(
                    color: _isSelected(settings.ttsSpeed, opt.value)
                        ? AppColors.primary.withOpacity(0.12)
                        : AppColors.card(context),
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(
                      color: _isSelected(settings.ttsSpeed, opt.value)
                          ? AppColors.primary
                          : AppColors.brd(context),
                      width: _isSelected(settings.ttsSpeed, opt.value) ? 1.5 : 1,
                    ),
                  ),
                  child: Row(children: [
                    Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                      Text(opt.label,
                          style: TextStyle(
                            color: _isSelected(settings.ttsSpeed, opt.value)
                                ? AppColors.primary
                                : AppColors.txt(context),
                            fontSize: 15, fontWeight: FontWeight.w600,
                          )),
                      const SizedBox(height: 2),
                      Text(opt.desc,
                          style: TextStyle(color: AppColors.sub(context), fontSize: 12)),
                    ])),
                    if (_isSelected(settings.ttsSpeed, opt.value))
                      const Icon(Icons.check_circle, color: AppColors.primary, size: 22),
                  ]),
                ),
              ),

            const SizedBox(height: 8),
          ]),
        ),
      ),
    );
  }

  bool _isSelected(double current, double target) => (current - target).abs() < 0.15;

  String _langLabel(String code) {
    switch (code) {
      case 'fr': return 'Français ›';
      case 'en': return 'English ›';
      case 'ar': return 'العربية ›';
      default:   return '$code ›';
    }
  }
}

// Data class vitesse
class _SpeedOption {
  final String label;
  final double value;
  final String desc;
  const _SpeedOption({required this.label, required this.value, required this.desc});
}

// Widgets

class _SLabel extends StatelessWidget {
  final String text;
  final BuildContext ctx;
  const _SLabel(this.text, this.ctx);
  @override
  Widget build(BuildContext context) => Text(text,
      style: TextStyle(color: AppColors.hint(context), fontSize: 10,
          letterSpacing: 1.5, fontWeight: FontWeight.w600));
}

class _Card extends StatelessWidget {
  final List<Widget> children;
  final BuildContext context;
  const _Card({required this.children, required this.context});
  @override
  Widget build(BuildContext _) => Container(
    decoration: BoxDecoration(
      color: AppColors.card(context),
      borderRadius: BorderRadius.circular(14),
      border: Border.all(color: AppColors.brd(context)),
    ),
    child: Column(children: children),
  );
}

class _Div extends StatelessWidget {
  final BuildContext ctx;
  const _Div(this.ctx);
  @override
  Widget build(BuildContext context) =>
      Divider(height: 1, color: AppColors.brd(context), indent: 54);
}

class _SwitchTile extends StatelessWidget {
  final BuildContext context;
  final IconData icon;
  final String title;
  final String? subtitle;
  final bool value;
  final ValueChanged<bool> onChanged;
  const _SwitchTile({
    required this.context, required this.icon, required this.title,
    this.subtitle, required this.value, required this.onChanged,
  });
  @override
  Widget build(BuildContext _) => Padding(
    padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
    child: Row(children: [
      Icon(icon, color: AppColors.sub(context), size: 20),
      const SizedBox(width: 14),
      Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        Text(title, style: TextStyle(color: AppColors.txt(context), fontSize: 15)),
        if (subtitle != null)
          Text(subtitle!, style: TextStyle(color: AppColors.sub(context), fontSize: 12)),
      ])),
      Switch(value: value, onChanged: onChanged),
    ]),
  );
}

class _NavTile extends StatelessWidget {
  final BuildContext context;
  final IconData icon;
  final String title;
  final String? trailingText;
  final VoidCallback onTap;
  const _NavTile({
    required this.context, required this.icon, required this.title,
    this.trailingText, required this.onTap,
  });
  @override
  Widget build(BuildContext _) => GestureDetector(
    onTap: onTap,
    child: Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
      child: Row(children: [
        Icon(icon, color: AppColors.sub(context), size: 20),
        const SizedBox(width: 14),
        Expanded(child: Text(title, style: TextStyle(color: AppColors.txt(context), fontSize: 15))),
        Text(trailingText ?? '›', style: const TextStyle(color: AppColors.primary, fontSize: 13)),
      ]),
    ),
  );
}
