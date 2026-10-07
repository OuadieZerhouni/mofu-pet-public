import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';

import '../core/app_scope.dart';
import '../l10n/app_localizations.dart';
import 'name_dialog.dart';
import 'theme.dart';
import 'widgets.dart';

Future<void> showSettings(BuildContext context) {
  final services = AppScope.of(context);
  return showModalBottomSheet<void>(
    context: context,
    isScrollControlled: true,
    builder: (_) => AppScope(services: services, child: const SettingsSheet()),
  );
}

class SettingsSheet extends StatelessWidget {
  const SettingsSheet({super.key});

  @override
  Widget build(BuildContext context) {
    final l = AppLocalizations.of(context);
    final app = AppScope.of(context);
    final store = app.store;
    final cfg = app.config.value;
    final t = Theme.of(context).textTheme;

    Future<void> open(String url) async {
      if (url.isEmpty) return;
      await launchUrl(Uri.parse(url), mode: LaunchMode.externalApplication);
    }

    return ListenableBuilder(
      listenable: store,
      builder: (context, _) => SafeArea(
        top: false,
        child: SingleChildScrollView(
          padding: const EdgeInsets.fromLTRB(20, 0, 20, 20),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              MofuPreview(colorId: store.colorId, accessoryId: store.accessoryId, fluff: store.fluffFraction, size: 104),
              Text(store.name, style: t.titleLarge),
              const SizedBox(height: 16),
              _Card(children: [
                SwitchListTile(
                  title: Text(l.settingsSound, style: t.titleMedium),
                  secondary: const Icon(Icons.volume_up_rounded, color: MofuColors.accentDeep),
                  value: store.soundOn,
                  onChanged: store.setSound,
                ),
                SwitchListTile(
                  title: Text(l.settingsHaptics, style: t.titleMedium),
                  secondary: const Icon(Icons.vibration_rounded, color: MofuColors.accentDeep),
                  value: store.hapticsOn,
                  onChanged: store.setHaptics,
                ),
              ]),
              const SizedBox(height: 12),
              _Card(children: [
                _Row(
                  icon: Icons.edit_rounded,
                  label: l.settingsRename,
                  onTap: () async {
                    final name = await askName(context, initial: store.name);
                    if (name != null) store.rename(name);
                  },
                ),
                if (cfg.storeUrl.isNotEmpty) _Row(icon: Icons.star_rounded, label: l.settingsRate, onTap: () => open(cfg.storeUrl)),
                _Row(icon: Icons.mail_rounded, label: l.settingsSupport, onTap: () => open(cfg.supportUrl)),
                _Row(icon: Icons.lock_rounded, label: l.settingsPrivacy, onTap: () => open(cfg.privacyUrl)),
              ]),
              const SizedBox(height: 12),
              _Card(children: [
                _Row(
                  icon: Icons.restart_alt_rounded,
                  label: l.settingsReset,
                  danger: true,
                  onTap: () async {
                    final ok = await showDialog<bool>(
                      context: context,
                      builder: (ctx) => AlertDialog(
                        title: Text(l.resetTitle),
                        content: Text(l.resetBody(store.name)),
                        actions: [
                          TextButton(onPressed: () => Navigator.pop(ctx, false), child: Text(l.actionCancel)),
                          FilledButton(onPressed: () => Navigator.pop(ctx, true), child: Text(l.resetConfirm)),
                        ],
                      ),
                    );
                    if (ok == true) {
                      await store.reset();
                      if (context.mounted) Navigator.of(context).maybePop();
                    }
                  },
                ),
              ]),
              const SizedBox(height: 14),
              Text(l.settingsVersion(app.config.appVersion), style: t.bodySmall),
            ],
          ),
        ),
      ),
    );
  }
}

class _Card extends StatelessWidget {
  const _Card({required this.children});
  final List<Widget> children;

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(color: MofuColors.card, borderRadius: BorderRadius.circular(22)),
      clipBehavior: Clip.antiAlias,
      child: Material(type: MaterialType.transparency, child: Column(children: children)),
    );
  }
}

class _Row extends StatelessWidget {
  const _Row({required this.icon, required this.label, required this.onTap, this.danger = false});
  final IconData icon;
  final String label;
  final VoidCallback onTap;
  final bool danger;

  @override
  Widget build(BuildContext context) {
    return ListTile(
      leading: Icon(icon, color: MofuColors.accentDeep),
      title: Text(
        label,
        style: Theme.of(context).textTheme.titleMedium?.copyWith(color: danger ? MofuColors.accentDeep : MofuColors.ink),
      ),
      trailing: const Icon(Icons.chevron_right_rounded, color: MofuColors.lock),
      onTap: onTap,
    );
  }
}
