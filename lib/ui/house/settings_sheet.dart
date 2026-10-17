import 'dart:async';

import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';

import '../../core/app_scope.dart';
import '../../l10n/app_localizations.dart';
import '../../world/house_controller.dart';
import '../theme.dart';

Future<void> showHouseSettings(BuildContext context, {required HouseController house}) {
  final services = AppScope.of(context);
  return showModalBottomSheet<void>(
    context: context,
    isScrollControlled: true,
    backgroundColor: House.paper,
    shape: const RoundedRectangleBorder(borderRadius: BorderRadius.vertical(top: Radius.circular(30))),
    builder: (_) => AppScope(services: services, child: _Settings(house: house)),
  );
}

class _Settings extends StatelessWidget {
  const _Settings({required this.house});
  final HouseController house;

  @override
  Widget build(BuildContext context) {
    final l = AppLocalizations.of(context);
    final app = AppScope.of(context);
    final store = app.store;
    final cfg = app.config.value;

    Future<void> open(String url) async {
      if (url.isEmpty) return;
      await launchUrl(Uri.parse(url), mode: LaunchMode.externalApplication);
    }

    return ListenableBuilder(
      listenable: store,
      builder: (context, _) => SafeArea(
        top: false,
        child: SingleChildScrollView(
          padding: const EdgeInsets.fromLTRB(20, 14, 20, 20),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(width: 46, height: 5, decoration: BoxDecoration(color: const Color(0xFFD9C3AD), borderRadius: BorderRadius.circular(3))),
              const SizedBox(height: 14),
              Text(l.settingsTitle, style: const TextStyle(fontWeight: FontWeight.w900, fontSize: 22, color: House.ink)),
              const SizedBox(height: 14),
              _Card(children: [
                SwitchListTile(
                  title: Text(l.settingsSound, style: const TextStyle(fontWeight: FontWeight.w800)),
                  secondary: const Icon(Icons.volume_up_rounded, color: House.rose),
                  value: store.soundOn,
                  onChanged: (v) {
                    store.setSound(v);
                    app.audio.soundOn = v;
                    if (!v) app.audio.stopAllLoops();
                  },
                ),
                SwitchListTile(
                  title: Text(l.settingsHaptics, style: const TextStyle(fontWeight: FontWeight.w800)),
                  secondary: const Icon(Icons.vibration_rounded, color: House.rose),
                  value: store.hapticsOn,
                  onChanged: (v) {
                    store.setHaptics(v);
                    app.audio.hapticsOn = v;
                  },
                ),
                SwitchListTile(
                  title: Text(l.settingsReduceMotion, style: const TextStyle(fontWeight: FontWeight.w800)),
                  secondary: const Icon(Icons.motion_photos_off_rounded, color: House.rose),
                  value: store.reduceMotion,
                  onChanged: store.setReduceMotion,
                ),
              ]),
              const SizedBox(height: 12),
              _Card(children: [
                if (cfg.storeUrl.isNotEmpty) _Row(icon: Icons.star_rounded, label: l.settingsRate, onTap: () => open(cfg.storeUrl)),
                _Row(icon: Icons.mail_rounded, label: l.settingsSupport, onTap: () => open(cfg.supportUrl)),
                _Row(icon: Icons.lock_rounded, label: l.settingsPrivacy, onTap: () => open(cfg.privacyUrl)),
                _Row(
                  icon: Icons.favorite_rounded,
                  label: l.settingsCredits,
                  onTap: () => showDialog<void>(
                    context: context,
                    builder: (ctx) => AlertDialog(
                      title: Text(l.settingsCredits),
                      content: Text('${l.creditsBody}\n\n${l.creditsAudio}'),
                      actions: [TextButton(onPressed: () => Navigator.pop(ctx), child: Text(l.actionClose))],
                    ),
                  ),
                ),
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
                        content: Text(l.resetHouseBody),
                        actions: [
                          TextButton(onPressed: () => Navigator.pop(ctx, false), child: Text(l.actionCancel)),
                          FilledButton(onPressed: () => Navigator.pop(ctx, true), child: Text(l.resetConfirm)),
                        ],
                      ),
                    );
                    if (ok == true) {
                      unawaited(app.audio.mixerStop());
                      app.audio.stopAllLoops();
                      await store.reset();
                      house.sync();
                      if (context.mounted) Navigator.of(context).maybePop();
                    }
                  },
                ),
              ]),
              const SizedBox(height: 14),
              Text(l.settingsVersion(app.config.appVersion), style: const TextStyle(fontWeight: FontWeight.w700, color: House.inkSoft)),
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
      decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(22)),
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
      leading: Icon(icon, color: House.rose),
      title: Text(label, style: TextStyle(fontWeight: FontWeight.w800, color: danger ? House.rose : House.ink)),
      trailing: const Icon(Icons.chevron_right_rounded, color: Color(0xFFCDBFC7)),
      onTap: onTap,
    );
  }
}
