import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';
import '../core/app_colors.dart';
import '../providers/history_provider.dart';
import '../models/history_item.dart';

class HistoryScreen extends StatefulWidget {
  const HistoryScreen({super.key});
  @override
  State<HistoryScreen> createState() => _HistoryScreenState();
}

class _HistoryScreenState extends State<HistoryScreen> {
  String _activeFilter = 'Tous';
  String _searchQuery = '';
  final _searchCtrl = TextEditingController();
  final List<String> _filters = ['Tous', 'OCR', 'Détection', 'Traduits'];

  @override
  void dispose() { _searchCtrl.dispose(); super.dispose(); }

  @override
  Widget build(BuildContext context) {
    final history = context.watch<HistoryProvider>();
    final filtered = _searchQuery.isNotEmpty
        ? history.search(_searchQuery)
        : history.getFiltered(_activeFilter);

    return Scaffold(
      backgroundColor: Theme.of(context).scaffoldBackgroundColor,
      appBar: AppBar(
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () => context.pop(),
        ),
        title: const Text('Historique'),
        actions: [
          TextButton(
            onPressed: () => _confirmClear(context, history),
            child: const Text('Tout effacer', style: TextStyle(color: AppColors.danger)),
          ),
        ],
      ),
      body: Column(children: [
        // Barre de recherche
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
          child: TextField(
            controller: _searchCtrl,
            onChanged: (v) => setState(() => _searchQuery = v),
            decoration: InputDecoration(
              hintText: 'Rechercher un scan...',
              prefixIcon: const Icon(Icons.search, color: AppColors.textHint, size: 20),
              suffixIcon: _searchQuery.isNotEmpty
                  ? GestureDetector(
                onTap: () { _searchCtrl.clear(); setState(() => _searchQuery = ''); },
                child: const Icon(Icons.close, color: AppColors.textHint, size: 18),
              )
                  : null,
            ),
          ),
        ),

        // Filtres
        SizedBox(
          height: 34,
          child: ListView.separated(
            padding: const EdgeInsets.symmetric(horizontal: 20),
            scrollDirection: Axis.horizontal,
            itemCount: _filters.length,
            separatorBuilder: (_, __) => const SizedBox(width: 8),
            itemBuilder: (_, i) {
              final f = _filters[i];
              final active = f == _activeFilter;
              return GestureDetector(
                onTap: () => setState(() => _activeFilter = f),
                child: Container(
                  padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
                  decoration: BoxDecoration(
                    color: active ? AppColors.primary : Theme.of(context).cardTheme.color,
                    borderRadius: BorderRadius.circular(20),
                    border: Border.all(color: active ? AppColors.primary : AppColors.border),
                  ),
                  child: Text(f, style: TextStyle(
                    color: active ? Colors.black : AppColors.textSecondary,
                    fontSize: 13, fontWeight: active ? FontWeight.w600 : FontWeight.normal,
                  )),
                ),
              );
            },
          ),
        ),

        const SizedBox(height: 10),

        // Liste d'historiques
        Expanded(
          child: filtered.isEmpty
              ? _EmptyState()
              : ListView.separated(
            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 4),
            itemCount: filtered.length,
            separatorBuilder: (_, __) => const SizedBox(height: 8),
            itemBuilder: (context, i) => _HistoryTile(item: filtered[i]),
          ),
        ),
      ]),
    );
  }

  void _confirmClear(BuildContext context, HistoryProvider history) {
    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        title: const Text('Tout effacer'),
        content: const Text('Supprimer tout l\'historique ?'),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context), child: const Text('Annuler')),
          TextButton(
            onPressed: () { history.clearAll(); Navigator.pop(context); },
            child: const Text('Supprimer', style: TextStyle(color: AppColors.danger)),
          ),
        ],
      ),
    );
  }
}

class _HistoryTile extends StatelessWidget {
  final HistoryItem item;
  const _HistoryTile({required this.item});

  Color get _iconColor {
    switch (item.type) {
      case ScanType.ocr: return AppColors.primary;
      case ScanType.detection: return AppColors.warning;
      case ScanType.obstacle: return AppColors.danger;
    }
  }

  IconData get _iconData {
    switch (item.type) {
      case ScanType.ocr: return Icons.document_scanner_outlined;
      case ScanType.detection: return Icons.camera_alt_outlined;
      case ScanType.obstacle: return Icons.warning_outlined;
    }
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () => context.push('/history/detail', extra: item),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
        decoration: BoxDecoration(
          color: Theme.of(context).cardTheme.color,
          borderRadius: BorderRadius.circular(14),
          border: Border.all(color: Theme.of(context).brightness == Brightness.dark ? AppColors.border : const Color(0xFFE2E8F0)),
        ),
        child: Row(children: [
          Container(
            width: 40, height: 40,
            decoration: BoxDecoration(color: _iconColor.withOpacity(0.15), borderRadius: BorderRadius.circular(10)),
            child: Icon(_iconData, color: _iconColor, size: 20),
          ),
          const SizedBox(width: 12),
          Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
            Text(item.title, style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w500), maxLines: 1, overflow: TextOverflow.ellipsis),
            const SizedBox(height: 2),
            Text(item.subtitle, style: const TextStyle(color: AppColors.textSecondary, fontSize: 12), maxLines: 1, overflow: TextOverflow.ellipsis),
          ])),
          Column(crossAxisAlignment: CrossAxisAlignment.end, children: [
            Text(item.timeLabel, style: const TextStyle(color: AppColors.textSecondary, fontSize: 11)),
            const SizedBox(height: 4),
            Container(
              width: 28, height: 28,
              decoration: BoxDecoration(color: AppColors.primary.withOpacity(0.1), shape: BoxShape.circle),
              child: const Icon(Icons.play_arrow, color: AppColors.primary, size: 16),
            ),
          ]),
        ]),
      ),
    );
  }
}

class _EmptyState extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Center(child: Column(mainAxisSize: MainAxisSize.min, children: [
      Icon(Icons.history, color: AppColors.textHint, size: 52),
      const SizedBox(height: 12),
      const Text('Aucun historique', style: TextStyle(color: AppColors.textSecondary, fontSize: 16)),
      const SizedBox(height: 6),
      const Text('Vos scans apparaîtront ici', style: TextStyle(color: AppColors.textHint, fontSize: 13)),
    ]));
  }
}
