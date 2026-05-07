import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../core/app_colors.dart';

class AboutScreen extends StatelessWidget {
  const AboutScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.bg(context),
      appBar: AppBar(
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () => context.pop(),
        ),
        title: const Text('À propos'),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
        child: Column(children: [

          // Card logo
          Container(
            width: double.infinity,
            padding: const EdgeInsets.symmetric(vertical: 28, horizontal: 20),
            decoration: BoxDecoration(
              color: AppColors.card(context),
              borderRadius: BorderRadius.circular(16),
              border: Border.all(color: AppColors.brd(context)),
            ),
            child: Column(children: [
              Container(
                width: 72, height: 72,
                decoration: const BoxDecoration(
                    color: AppColors.primary, shape: BoxShape.circle),
                child: const Icon(Icons.visibility, color: Colors.white, size: 34),
              ),
              const SizedBox(height: 16),
              Text('VisionAid',
                  style: TextStyle(color: AppColors.txt(context), fontSize: 22,
                      fontWeight: FontWeight.bold)),
              const SizedBox(height: 6),
              Text('Version 1.0.0 · Flutter 3.x · Google ML Kit',
                  style: TextStyle(color: AppColors.sub(context), fontSize: 12)),
              const SizedBox(height: 10),
              Text(
                'Assistant visuel pour personnes malvoyantes. 100% hors ligne.',
                textAlign: TextAlign.center,
                style: TextStyle(color: AppColors.sub(context), fontSize: 13, height: 1.6),
              ),
            ]),
          ),

          const SizedBox(height: 20),

          // Services ML Kit
          Align(
            alignment: Alignment.centerLeft,
            child: Text('SERVICES ML KIT INTÉGRÉS',
                style: TextStyle(color: AppColors.hint(context), fontSize: 10,
                    letterSpacing: 1.4, fontWeight: FontWeight.w600)),
          ),
          const SizedBox(height: 10),

          _ServiceTile(
            context: context,
            title: 'Étiquetage d\'image',
            subtitle: 'Description de la scène en temps réel',
            badge: 'image_labeling',
            dotColor: AppColors.primary,
            badgeColor: AppColors.primary,
          ),
          const SizedBox(height: 8),
          _ServiceTile(
            context: context,
            title: 'Détection d\'objets',
            subtitle: 'Localisation et alerte obstacles',
            badge: 'object_detection',
            dotColor: AppColors.warning,
            badgeColor: AppColors.warning,
          ),
          const SizedBox(height: 8),
          _ServiceTile(
            context: context,
            title: 'Reconnaissance texte',
            subtitle: 'OCR de documents et panneaux (Latin + Arabe)',
            badge: 'text_recognition',
            dotColor: const Color(0xFF9B59B6),
            badgeColor: const Color(0xFF9B59B6),
          ),
          const SizedBox(height: 8),
          _ServiceTile(
            context: context,
            title: 'Langue & traduction',
            subtitle: 'Détection auto + traduction on-device (FR/EN/AR)',
            badge: 'language_id',
            dotColor: AppColors.info,
            badgeColor: AppColors.info,
          ),

          const SizedBox(height: 20),

          // Infos techniques
          Align(
            alignment: Alignment.centerLeft,
            child: Text('INFORMATIONS TECHNIQUES',
                style: TextStyle(color: AppColors.hint(context), fontSize: 10,
                    letterSpacing: 1.4, fontWeight: FontWeight.w600)),
          ),
          const SizedBox(height: 10),

          Container(
            decoration: BoxDecoration(
              color: AppColors.card(context),
              borderRadius: BorderRadius.circular(14),
              border: Border.all(color: AppColors.brd(context)),
            ),
            child: Column(children: [
              _InfoRow(context: context, label: 'Framework',      value: 'Flutter (Dart)'),
              _Div(context),
              _InfoRow(context: context, label: 'Plateforme',     value: 'Android & iOS'),
              _Div(context),
              _InfoRow(context: context, label: 'Mode IA',        value: 'On-device (hors ligne)'),
              _Div(context),
              _InfoRow(context: context, label: 'Langues',        value: 'FR · EN · AR'),
              _Div(context),
              _InfoRow(context: context, label: 'Services ML Kit',value: '4 services'),
              _Div(context),
              _InfoRow(context: context, label: 'TTS',            value: 'flutter_tts'),
            ]),
          ),

          const SizedBox(height: 40),
        ]),
      ),
    );
  }
}

// Widgets

class _ServiceTile extends StatelessWidget {
  final BuildContext context;
  final String title, subtitle, badge;
  final Color dotColor, badgeColor;
  const _ServiceTile({
    required this.context, required this.title, required this.subtitle,
    required this.badge, required this.dotColor, required this.badgeColor,
  });
  @override
  Widget build(BuildContext _) => Container(
    padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
    decoration: BoxDecoration(
      color: AppColors.card(context),
      borderRadius: BorderRadius.circular(12),
      border: Border.all(color: AppColors.brd(context)),
    ),
    child: Row(children: [
      Container(width: 10, height: 10,
          decoration: BoxDecoration(color: dotColor, shape: BoxShape.circle)),
      const SizedBox(width: 12),
      Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        Text(title, style: TextStyle(color: AppColors.txt(context), fontSize: 14,
            fontWeight: FontWeight.w500)),
        const SizedBox(height: 2),
        Text(subtitle, style: TextStyle(color: AppColors.sub(context), fontSize: 12)),
      ])),
      Container(
        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
        decoration: BoxDecoration(
          color: badgeColor.withOpacity(0.12), borderRadius: BorderRadius.circular(6),
          border: Border.all(color: badgeColor.withOpacity(0.3)),
        ),
        child: Text(badge, style: TextStyle(color: badgeColor, fontSize: 10,
            fontWeight: FontWeight.w600, fontFamily: 'monospace')),
      ),
    ]),
  );
}

class _InfoRow extends StatelessWidget {
  final BuildContext context;
  final String label, value;
  const _InfoRow({required this.context, required this.label, required this.value});
  @override
  Widget build(BuildContext _) => Padding(
    padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 13),
    child: Row(children: [
      Text(label, style: TextStyle(color: AppColors.sub(context), fontSize: 14)),
      const Spacer(),
      Text(value, style: TextStyle(color: AppColors.txt(context), fontSize: 14,
          fontWeight: FontWeight.w500)),
    ]),
  );
}

class _Div extends StatelessWidget {
  final BuildContext ctx;
  const _Div(this.ctx);
  @override
  Widget build(BuildContext context) =>
      Divider(height: 1, color: AppColors.brd(context), indent: 16);
}