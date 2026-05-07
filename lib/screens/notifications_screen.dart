import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';
import '../core/app_colors.dart';
import '../providers/settings_provider.dart';
import '../services/notification_service.dart';

class NotificationsScreen extends StatefulWidget {
  const NotificationsScreen({super.key});
  @override
  State<NotificationsScreen> createState() => _NotificationsScreenState();
}

class _NotificationsScreenState extends State<NotificationsScreen>
    with SingleTickerProviderStateMixin {
  late AnimationController _bellCtrl;
  late Animation<double> _bellAnim;
  bool _isLoading = false;
  bool _testSent = false;

  @override
  void initState() {
    super.initState();
    _bellCtrl = AnimationController(vsync: this, duration: const Duration(milliseconds: 700))
      ..repeat(reverse: true);
    _bellAnim = Tween<double>(begin: -0.08, end: 0.08)
        .animate(CurvedAnimation(parent: _bellCtrl, curve: Curves.easeInOut));
  }

  @override
  void dispose() { _bellCtrl.dispose(); super.dispose(); }

  Future<void> _authorize() async {
    setState(() => _isLoading = true);
    final settings = context.read<SettingsProvider>();
    final granted = await NotificationService.instance.requestPermission();
    if (granted) {
      await NotificationService.instance.scheduleDaily();
      settings.setNotificationsEnabled(true);
      await NotificationService.instance.showTestNotification();
    }
    setState(() => _isLoading = false);
    if (mounted) context.pop();
  }

  Future<void> _sendTest() async {
    setState(() { _isLoading = true; _testSent = false; });
    await NotificationService.instance.showTestNotification();
    setState(() { _isLoading = false; _testSent = true; });
    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('✓ Notification de test envoyée ! Regardez votre barre de notifications.'),
          backgroundColor: AppColors.primary,
          duration: Duration(seconds: 4),
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final settings = context.watch<SettingsProvider>();

    return Scaffold(
      backgroundColor: Theme.of(context).scaffoldBackgroundColor,
      appBar: AppBar(
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () => context.pop(),
        ),
        title: const Text('Notifications'),
      ),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 28),
          child: Column(children: [
            const Spacer(flex: 2),

            // icone cloche animee
            AnimatedBuilder(
              animation: _bellCtrl,
              builder: (_, child) => Transform.rotate(angle: _bellAnim.value, child: child),
              child: Container(
                width: 90, height: 90,
                decoration: BoxDecoration(
                  color: settings.notificationsEnabled
                      ? AppColors.primary.withOpacity(0.15)
                      : Theme.of(context).cardTheme.color,
                  shape: BoxShape.circle,
                  border: Border.all(
                    color: settings.notificationsEnabled ? AppColors.primary : AppColors.border,
                  ),
                ),
                child: Icon(
                  settings.notificationsEnabled
                      ? Icons.notifications_active
                      : Icons.notifications_outlined,
                  color: settings.notificationsEnabled ? AppColors.primary : AppColors.textSecondary,
                  size: 40,
                ),
              ),
            ),

            const SizedBox(height: 24),

            Text(
              settings.notificationsEnabled
                  ? 'Notifications activées ✓'
                  : 'Activer les notifications',
              textAlign: TextAlign.center,
              style: const TextStyle(fontSize: 22, fontWeight: FontWeight.bold),
            ),

            const SizedBox(height: 12),

            const Text(
              'Recevez des rappels pour utiliser VisionAid et des alertes sur vos scans sauvegardés.',
              textAlign: TextAlign.center,
              style: TextStyle(color: AppColors.textSecondary, fontSize: 14, height: 1.6),
            ),

            const Spacer(),

            // fonctionnalites
            for (final label in [
              'Rappels quotidiens d\'utilisation',
              'Alertes après détection d\'obstacle',
              'Notifications de scan terminé',
            ])
              Container(
                margin: const EdgeInsets.only(bottom: 10),
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
                decoration: BoxDecoration(
                  color: Theme.of(context).cardTheme.color,
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: AppColors.border),
                ),
                child: Row(children: [
                  Container(width: 10, height: 10,
                      decoration: const BoxDecoration(color: AppColors.primary, shape: BoxShape.circle)),
                  const SizedBox(width: 14),
                  Expanded(child: Text(label, style: const TextStyle(fontSize: 14))),
                ]),
              ),

            const Spacer(),

            // bouton de test de notification
            if (settings.notificationsEnabled) ...[
              SizedBox(
                width: double.infinity,
                child: OutlinedButton.icon(
                  onPressed: _isLoading ? null : _sendTest,
                  icon: Icon(_testSent ? Icons.check : Icons.send, size: 18),
                  label: Text(_testSent ? 'Notification envoyée !' : 'Envoyer une notification test'),
                  style: OutlinedButton.styleFrom(
                    foregroundColor: AppColors.primary,
                    side: const BorderSide(color: AppColors.primary),
                    padding: const EdgeInsets.symmetric(vertical: 14),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
                  ),
                ),
              ),
              const SizedBox(height: 12),
            ],

            // Bouton principal
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: _isLoading ? null : (settings.notificationsEnabled ? null : _authorize),
                style: ElevatedButton.styleFrom(
                  padding: const EdgeInsets.symmetric(vertical: 18),
                  backgroundColor: settings.notificationsEnabled ? AppColors.surface2 : AppColors.primary,
                  foregroundColor: settings.notificationsEnabled ? AppColors.textSecondary : Colors.black,
                ),
                child: _isLoading
                    ? const SizedBox(
                  width: 20, height: 20,
                  child: CircularProgressIndicator(color: Colors.black, strokeWidth: 2),
                )
                    : Text(settings.notificationsEnabled
                    ? 'Notifications déjà activées'
                    : 'Autoriser les notifications'),
              ),
            ),

            const SizedBox(height: 14),
            TextButton(
              onPressed: () => context.pop(),
              child: const Text('Plus tard', style: TextStyle(color: AppColors.textSecondary)),
            ),
            const SizedBox(height: 20),
          ]),
        ),
      ),
    );
  }
}
