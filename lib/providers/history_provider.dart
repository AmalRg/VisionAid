import 'package:flutter/material.dart';
import '../models/history_item.dart';
import '../services/database_service.dart';

class HistoryProvider extends ChangeNotifier {
  List<HistoryItem> _items = [];
  int _scansToday = 0;
  int _obstacleAlerts = 0;

  List<HistoryItem> get items => _items;
  int get scansToday => _scansToday;
  int get obstacleAlerts => _obstacleAlerts;

  List<HistoryItem> getFiltered(String filter) {
    if (filter == 'Tous') return _items;
    if (filter == 'OCR') return _items.where((i) => i.type == ScanType.ocr).toList();
    if (filter == 'Détection') return _items.where((i) => i.type == ScanType.detection).toList();
    if (filter == 'Traduits') return _items.where((i) => i.translatedContent != null).toList();
    return _items;
  }

  List<HistoryItem> search(String query) {
    if (query.isEmpty) return _items;
    final q = query.toLowerCase();
    return _items.where((i) =>
      i.title.toLowerCase().contains(q) ||
      i.content.toLowerCase().contains(q)
    ).toList();
  }

  Future<void> load() async {
    _items = await DatabaseService.instance.getAllItems();
    _computeStats();
    notifyListeners();
  }

  Future<void> addItem(HistoryItem item) async {
    await DatabaseService.instance.insertItem(item);
    await load();
  }

  Future<void> deleteItem(int id) async {
    await DatabaseService.instance.deleteItem(id);
    await load();
  }

  Future<void> clearAll() async {
    await DatabaseService.instance.clearAll();
    _items = [];
    _scansToday = 0;
    _obstacleAlerts = 0;
    notifyListeners();
  }

  void _computeStats() {
    final today = DateTime.now();
    _scansToday = _items.where((i) {
      final d = i.timestamp;
      return d.year == today.year && d.month == today.month && d.day == today.day;
    }).length;
    _obstacleAlerts = _items.where((i) => i.type == ScanType.obstacle).length;
  }
}
