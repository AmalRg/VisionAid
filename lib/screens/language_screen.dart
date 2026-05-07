import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';
import '../core/app_colors.dart';
import '../providers/settings_provider.dart';
import '../services/tts_service.dart';

class LanguageScreen extends StatelessWidget {
  const LanguageScreen({super.key});

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
        title: const Text('Choisir la langue'),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
        child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [

          _Label('LANGUE DE L\'INTERFACE ET DE LA VOIX', context),
          const SizedBox(height: 10),

          _LangTile(
            flag: 'FR', flagBg: const Color(0xFF1565C0),
            name: 'Français', native: 'Français',
            selected: settings.interfaceLanguage == 'fr',
            onTap: () => _apply(context, settings, 'fr'),
          ),
          const SizedBox(height: 8),
          _LangTile(
            flag: 'EN', flagBg: const Color(0xFF1B5E20),
            name: 'English', native: 'English',
            selected: settings.interfaceLanguage == 'en',
            onTap: () => _apply(context, settings, 'en'),
          ),
          const SizedBox(height: 8),
          _LangTile(
            flag: 'ع', flagBg: const Color(0xFF880E4F),
            name: 'Arabe', native: 'العربية',
            selected: settings.interfaceLanguage == 'ar',
            onTap: () => _apply(context, settings, 'ar'),
          ),

          const SizedBox(height: 24),
          _Label('LANGUE DE TRADUCTION AUTOMATIQUE (OCR)', context),
          const SizedBox(height: 10),

          Container(
            decoration: BoxDecoration(
              color: AppColors.card(context),
              borderRadius: BorderRadius.circular(14),
              border: Border.all(color: AppColors.brd(context)),
            ),
            child: Column(children: [
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                child: Row(children: [
                  Expanded(child: Text('Traduire automatiquement',
                      style: TextStyle(color: AppColors.txt(context), fontSize: 15))),
                  Switch(value: settings.autoTranslate, onChanged: settings.setAutoTranslate),
                ]),
              ),
              if (settings.autoTranslate) ...[
                Divider(height: 1, color: AppColors.brd(context)),
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                  child: Row(children: [
                    Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                      Text('Langue cible',
                          style: TextStyle(color: AppColors.txt(context), fontSize: 15)),
                      Text('Résultat traduit dans',
                          style: TextStyle(color: AppColors.sub(context), fontSize: 12)),
                    ])),
                    GestureDetector(
                      onTap: () => _pickTarget(context, settings),
                      child: Row(children: [
                        Text(_langName(settings.targetLanguage),
                            style: const TextStyle(color: AppColors.primary, fontSize: 13)),
                        const Icon(Icons.chevron_right, color: AppColors.primary, size: 18),
                      ]),
                    ),
                  ]),
                ),
              ],
            ]),
          ),
          const SizedBox(height: 20),
        ]),
      ),
    );
  }

  void _apply(BuildContext context, SettingsProvider settings, String code) {
    settings.setInterfaceLanguage(code);
    try { context.read<TtsService>().setLanguage(code); } catch (_) {}

    // affichage du snackbar de confirmation
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(
      content: Text('Langue changée : ${_langName(code)}'),
      backgroundColor: AppColors.primary,
      duration: const Duration(seconds: 2),
    ));
  }

  void _pickTarget(BuildContext context, SettingsProvider settings) {
    showModalBottomSheet(
      context: context,
      backgroundColor: AppColors.card(context),
      shape: const RoundedRectangleBorder(
          borderRadius: BorderRadius.vertical(top: Radius.circular(20))),
      builder: (ctx) => Padding(
        padding: const EdgeInsets.all(24),
        child: Column(mainAxisSize: MainAxisSize.min, children: [
          Text('Langue cible', style: TextStyle(
              color: AppColors.txt(context), fontSize: 18, fontWeight: FontWeight.w600)),
          const SizedBox(height: 16),
          for (final e in [
            MapEntry('fr', 'Français'),
            MapEntry('en', 'English'),
            MapEntry('ar', 'Arabe'),
          ])
            ListTile(
              title: Text(e.value, style: TextStyle(color: AppColors.txt(context))),
              trailing: settings.targetLanguage == e.key
                  ? const Icon(Icons.check, color: AppColors.primary) : null,
              onTap: () { settings.setTargetLanguage(e.key); Navigator.pop(ctx); },
            ),
        ]),
      ),
    );
  }

  String _langName(String c) {
    switch (c) {
      case 'fr': return 'Français';
      case 'en': return 'English';
      case 'ar': return 'Arabe';
      default:   return c;
    }
  }
}

class _Label extends StatelessWidget {
  final String text;
  final BuildContext ctx;
  const _Label(this.text, this.ctx);
  @override
  Widget build(BuildContext context) => Text(text,
      style: TextStyle(color: AppColors.hint(context), fontSize: 10,
          letterSpacing: 1.4, fontWeight: FontWeight.w600));
}

class _LangTile extends StatelessWidget {
  final String flag, name, native;
  final Color flagBg;
  final bool selected;
  final VoidCallback onTap;
  const _LangTile({required this.flag, required this.flagBg, required this.name,
    required this.native, required this.selected, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
        decoration: BoxDecoration(
          color: selected ? AppColors.primary.withOpacity(0.08) : AppColors.card(context),
          borderRadius: BorderRadius.circular(14),
          border: Border.all(
            color: selected ? AppColors.primary.withOpacity(0.5) : AppColors.brd(context),
            width: selected ? 1.5 : 1,
          ),
        ),
        child: Row(children: [
          Container(
            width: 40, height: 40,
            decoration: BoxDecoration(color: flagBg, borderRadius: BorderRadius.circular(10)),
            child: Center(child: Text(flag,
                style: const TextStyle(color: Colors.white, fontSize: 14, fontWeight: FontWeight.bold))),
          ),
          const SizedBox(width: 14),
          Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
            Text(name, style: TextStyle(color: AppColors.txt(context), fontSize: 15, fontWeight: FontWeight.w500)),
            Text(native, style: TextStyle(color: AppColors.sub(context), fontSize: 12)),
          ])),
          if (selected)
            Container(
              width: 24, height: 24,
              decoration: const BoxDecoration(color: AppColors.primary, shape: BoxShape.circle),
              child: const Icon(Icons.check, color: Colors.white, size: 14),
            )
          else
            Container(
              width: 24, height: 24,
              decoration: BoxDecoration(shape: BoxShape.circle,
                  border: Border.all(color: AppColors.brd(context), width: 1.5)),
            ),
        ]),
      ),
    );
  }
}
