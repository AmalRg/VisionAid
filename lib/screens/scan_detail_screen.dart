import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';
import '../core/app_colors.dart';
import '../models/history_item.dart';
import '../services/tts_service.dart';
import '../services/language_service.dart';
import '../providers/settings_provider.dart';
import '../providers/history_provider.dart';

class ScanDetailScreen extends StatefulWidget {
  final HistoryItem item;
  const ScanDetailScreen({super.key, required this.item});
  @override
  State<ScanDetailScreen> createState() => _ScanDetailScreenState();
}

class _ScanDetailScreenState extends State<ScanDetailScreen> {
  bool    _reading     = false;
  bool    _translating = false;
  String? _translated;

  @override
  void initState() {
    super.initState();
    _translated = widget.item.translatedContent;
  }

  Future<void> _read() async {
    final tts      = context.read<TtsService>();
    final settings = context.read<SettingsProvider>();
    setState(() => _reading = true);
    final text = _translated ?? widget.item.content;
    final lang = widget.item.targetLanguage ?? widget.item.detectedLanguage ?? settings.interfaceLanguage;
    try {
      await tts.setLanguage(lang);
      await tts.speak(text, language: lang, speed: settings.ttsSpeed);
    } catch (_) {}
    if (mounted) setState(() => _reading = false);
  }

  void _stop() { context.read<TtsService>().stop(); setState(() => _reading = false); }

  Future<void> _translate() async {
    final settings = context.read<SettingsProvider>();
    if (widget.item.detectedLanguage == null) return;
    setState(() => _translating = true);
    try {
      final t = await LanguageService.instance.translate(
          widget.item.content, widget.item.detectedLanguage!, settings.targetLanguage);
      if (mounted) setState(() { _translated = t; _translating = false; });
    } catch (_) {
      if (mounted) setState(() => _translating = false);
    }
  }

  Future<void> _copy() async {
    await Clipboard.setData(ClipboardData(text: _translated ?? widget.item.content));
    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
        content: Text('✓ Copié'), backgroundColor: AppColors.primary,
        duration: Duration(seconds: 2),
      ));
    }
  }

  Future<void> _delete() async {
    final history = context.read<HistoryProvider>();
    if (widget.item.id != null) await history.deleteItem(widget.item.id!);
    if (mounted) context.pop();
  }

  @override
  Widget build(BuildContext context) {
    final item    = widget.item;
    final display = _translated ?? item.content;

    return Scaffold(
      backgroundColor: AppColors.bg(context),
      appBar: AppBar(
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () => context.pop(),
        ),
        title: const Text('Détail du scan'),
        actions: [
          TextButton(
            onPressed: _delete,
            child: const Text('Supprimer', style: TextStyle(color: AppColors.danger)),
          ),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
        child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [

          // appercu image
          Container(
            width: double.infinity, height: 160,
            decoration: BoxDecoration(
              color: AppColors.card(context),
              borderRadius: BorderRadius.circular(14),
              border: Border.all(color: AppColors.brd(context)),
            ),
            child: item.imagePath != null && File(item.imagePath!).existsSync()
                ? ClipRRect(
              borderRadius: BorderRadius.circular(14),
              child: Image.file(File(item.imagePath!), fit: BoxFit.cover),
            )
                : Column(mainAxisAlignment: MainAxisAlignment.center, children: [
              Icon(
                item.type == ScanType.ocr ? Icons.description_outlined : Icons.camera_alt_outlined,
                color: AppColors.hint(context), size: 36,
              ),
              const SizedBox(height: 8),
              Text('Aperçu document', style: TextStyle(color: AppColors.hint(context), fontSize: 13)),
            ]),
          ),

          const SizedBox(height: 14),

          // badges
          Row(children: [
            _TypeBadge(item: item),
            const SizedBox(width: 8),
            if (item.detectedLanguage != null && item.targetLanguage != null)
              _LangBadge(
                from: item.detectedLanguage!.toUpperCase(),
                to:   item.targetLanguage!.toUpperCase(),
              ),
            const Spacer(),
            Text(_formatDate(item.timestamp),
                style: TextStyle(color: AppColors.sub(context), fontSize: 12)),
          ]),

          const SizedBox(height: 14),

          // texte
          Text('TEXTE EXTRAIT',
              style: TextStyle(color: AppColors.hint(context), fontSize: 10,
                  letterSpacing: 1.4, fontWeight: FontWeight.w600)),
          const SizedBox(height: 8),

          Container(
            width: double.infinity,
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: AppColors.card(context),
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: AppColors.brd(context)),
            ),
            child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
              if (_translated != null && _translated != item.content) ...[
                Text('ORIGINAL (${item.detectedLanguage?.toUpperCase() ?? 'FR'})',
                    style: TextStyle(color: AppColors.hint(context), fontSize: 9, letterSpacing: 1.2)),
                const SizedBox(height: 6),
                Text(item.content, style: TextStyle(color: AppColors.sub(context), fontSize: 13, height: 1.6)),
                Divider(color: AppColors.brd(context), height: 20),
                Text('TRADUIT (${item.targetLanguage?.toUpperCase() ?? ''})',
                    style: TextStyle(color: AppColors.hint(context), fontSize: 9, letterSpacing: 1.2)),
                const SizedBox(height: 6),
              ],
              if (_translating)
                const Center(child: CircularProgressIndicator(color: AppColors.primary))
              else
                SelectableText(display,
                    style: TextStyle(color: AppColors.txt(context), fontSize: 14, height: 1.7)),
            ]),
          ),

          const SizedBox(height: 20),

          // actions
          Row(children: [
            Expanded(child: _ActionBtn(
              icon: _reading ? Icons.stop : Icons.volume_up,
              label: _reading ? 'Arrêter' : 'Lire',
              color: AppColors.primary, filled: true,
              onTap: _reading ? _stop : _read,
            )),
            const SizedBox(width: 10),
            Expanded(child: _ActionBtn(
              icon: Icons.translate, label: _translating ? '...' : 'Traduire',
              onTap: _translating ? null : _translate,
            )),
            const SizedBox(width: 10),
            Expanded(child: _ActionBtn(icon: Icons.copy, label: 'Copier', onTap: _copy)),
            const SizedBox(width: 10),
            Expanded(child: _ActionBtn(
              icon: Icons.share_outlined, label: 'Partager',
              onTap: _copy,
            )),
          ]),

          const SizedBox(height: 20),
        ]),
      ),
    );
  }

  String _formatDate(DateTime dt) =>
      '${dt.day.toString().padLeft(2,'0')}/${dt.month.toString().padLeft(2,'0')} '
          '${dt.hour.toString().padLeft(2,'0')}:${dt.minute.toString().padLeft(2,'0')}';
}

// widgets

class _TypeBadge extends StatelessWidget {
  final HistoryItem item;
  const _TypeBadge({required this.item});
  @override
  Widget build(BuildContext context) {
    final color = item.type == ScanType.ocr ? AppColors.info
        : item.type == ScanType.detection   ? AppColors.warning
        : AppColors.danger;
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: color.withOpacity(0.15), borderRadius: BorderRadius.circular(6),
        border: Border.all(color: color.withOpacity(0.4)),
      ),
      child: Text(item.typeLabel,
          style: TextStyle(color: color, fontSize: 11, fontWeight: FontWeight.w600)),
    );
  }
}

class _LangBadge extends StatelessWidget {
  final String from, to;
  const _LangBadge({required this.from, required this.to});
  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: AppColors.warning.withOpacity(0.12),
        borderRadius: BorderRadius.circular(6),
        border: Border.all(color: AppColors.warning.withOpacity(0.4)),
      ),
      child: Text('$from → $to',
          style: const TextStyle(color: AppColors.warning, fontSize: 11, fontWeight: FontWeight.w600)),
    );
  }
}

class _ActionBtn extends StatelessWidget {
  final IconData icon;
  final String label;
  final VoidCallback? onTap;
  final Color color;
  final bool filled;
  const _ActionBtn({required this.icon, required this.label, this.onTap,
    this.color = AppColors.textSecondary, this.filled = false});
  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Opacity(
        opacity: onTap != null ? 1.0 : 0.4,
        child: Container(
          padding: const EdgeInsets.symmetric(vertical: 12),
          decoration: BoxDecoration(
            color: filled ? color.withOpacity(0.15) : AppColors.card(context),
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: filled ? color.withOpacity(0.5) : AppColors.brd(context)),
          ),
          child: Column(mainAxisSize: MainAxisSize.min, children: [
            Icon(icon, color: filled ? color : AppColors.sub(context), size: 22),
            const SizedBox(height: 4),
            Text(label, style: TextStyle(color: filled ? color : AppColors.sub(context), fontSize: 11)),
          ]),
        ),
      ),
    );
  }
}
