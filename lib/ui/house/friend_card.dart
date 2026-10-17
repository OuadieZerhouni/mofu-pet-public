import 'dart:async';

import 'package:flutter/material.dart';

import '../../creatures/boop/boop_catalog.dart';
import '../../creatures/creature.dart';
import '../../creatures/oink/oink_catalog.dart';
import '../../creatures/wuff/wuff_catalog.dart';
import '../../creatures/wuff/wuff_creature.dart';
import '../../l10n/app_localizations.dart';
import '../../l10n/species_text.dart';
import '../../model/catalog.dart';
import '../../model/house_store.dart';
import '../../model/wardrobe.dart';
import '../../world/creature_factory.dart';
import '../../world/house_controller.dart';
import '../name_dialog.dart';
import '../names.dart';
import '../theme.dart';
import 'house_text.dart';
import 'parts.dart';

List<String> mofuReactionIds() => [for (final r in Catalog.reactions) 'mofu.${r.id}'];

/// Localised (or catalogue) name of a coat / colour variant.
String variantName(AppLocalizations l, Species s, String id) =>
    s == Species.mofu ? l.colorName(id) : (speciesVariant(l.localeName, s.name, id) ?? id);

String trickName(AppLocalizations l, String id) => speciesTrick(l.localeName, id) ?? id;

/// Voice pads per species: (label id, sound id).
List<(String, String)> voicePads(Species s) => switch (s) {
      Species.mofu => const [('squeak', 'mofu.squeak'), ('giggle', 'mofu.giggle'), ('coo', 'mofu.coo'), ('whee', 'mofu.whee'), ('yawn', 'mofu.yawn'), ('hmph', 'mofu.hmph')],
      Species.oink => const [('oink', 'oink.oink1'), ('oink!', 'oink.oink3'), ('snort', 'oink.snort1'), ('giggle', 'oink.giggle1'), ('squeal', 'oink.squeal'), ('yawn', 'oink.yawn')],
      Species.wuff => [for (final p in wuffBarkPads) (p.id, p.sound)],
      Species.boop => const [('boop', 'boop.boop_02'), ('boop!', 'boop.boop_06'), ('boop!!', 'boop.boop_10'), ('giggle', 'boop.giggle'), ('achoo', 'boop.sneeze'), ('hug', 'boop.hug')],
    };

/// One recognisable icon per voice, so the pads read without words in every language.
IconData voiceIcon(String id) => switch (id) {
      'hello' => Icons.waving_hand_rounded,
      'squeak' || 'yip' => Icons.music_note_rounded,
      'giggle' => Icons.sentiment_very_satisfied_rounded,
      'coo' || 'hug' => Icons.favorite_rounded,
      'whee' || 'play' => Icons.celebration_rounded,
      'yawn' => Icons.bedtime_rounded,
      'hmph' || 'growl' => Icons.sentiment_dissatisfied_rounded,
      'whimper' => Icons.water_drop_rounded,
      'howl' => Icons.nightlight_round,
      'sneeze' || 'achoo' || 'pant' || 'snort' => Icons.air_rounded,
      'squeal' => Icons.campaign_rounded,
      'oink' || 'boop' => Icons.chat_bubble_rounded,
      'oink!' || 'boop!' => Icons.mark_chat_unread_rounded,
      'boop!!' => Icons.bolt_rounded,
      _ => Icons.graphic_eq_rounded,
    };

const _padFills = [Color(0xFFFFE3D6), Color(0xFFFFF0C2), Color(0xFFDDF1D3), Color(0xFFE3ECFF), Color(0xFFF6E2F5), Color(0xFFD6F2EE)];

Future<void> showFriendCard(BuildContext context, {required HouseController house, required String friendId, required void Function(String) toast}) {
  return showModalBottomSheet<void>(
    context: context,
    isScrollControlled: true,
    backgroundColor: House.paper,
    shape: const RoundedRectangleBorder(borderRadius: BorderRadius.vertical(top: Radius.circular(34))),
    builder: (context) => DraggableScrollableSheet(
      expand: false,
      initialChildSize: 0.78,
      maxChildSize: 0.94,
      minChildSize: 0.5,
      builder: (context, scroll) => _FriendCard(house: house, friendId: friendId, scroll: scroll, toast: toast),
    ),
  );
}

class _FriendCard extends StatefulWidget {
  const _FriendCard({required this.house, required this.friendId, required this.scroll, required this.toast});
  final HouseController house;
  final String friendId;
  final ScrollController scroll;
  final void Function(String) toast;

  @override
  State<_FriendCard> createState() => _FriendCardState();
}

class _FriendCardState extends State<_FriendCard> {
  int _tab = 0;

  HouseStore get store => widget.house.store;

  @override
  Widget build(BuildContext context) {
    final l = AppLocalizations.of(context);
    return ListenableBuilder(
      listenable: store,
      builder: (context, _) {
        final f = store.friend(widget.friendId);
        if (f == null) return const SizedBox.shrink();
        return ListView(
          controller: widget.scroll,
          padding: const EdgeInsets.fromLTRB(18, 0, 18, 28),
          children: [
            _header(l, f),
            const SizedBox(height: 16),
            _tabs(l),
            const SizedBox(height: 14),
            switch (_tab) {
              0 => _play(l, f),
              1 => _wardrobe(l, f),
              _ => _journal(l, f),
            },
            const SizedBox(height: 18),
            Row(
              children: [
                Expanded(
                  child: OutlinedButton(
                    style: OutlinedButton.styleFrom(
                      minimumSize: const Size.fromHeight(52),
                      side: const BorderSide(color: House.rose, width: 2),
                      foregroundColor: House.rose,
                      shape: const StadiumBorder(),
                    ),
                    onPressed: () async {
                      final name = await askName(context, initial: f.name);
                      if (name != null) store.rename(f.id, name);
                    },
                    child: Text(l.cardRename, style: const TextStyle(fontWeight: FontWeight.w900, fontSize: 16)),
                  ),
                ),
                const SizedBox(width: 10),
                Expanded(
                  child: FilledButton(
                    style: FilledButton.styleFrom(minimumSize: const Size.fromHeight(52), backgroundColor: House.rose, shape: const StadiumBorder()),
                    onPressed: () => _moveSheet(l, f),
                    child: Text(l.cardMoveTo, style: const TextStyle(fontWeight: FontWeight.w900, fontSize: 16, color: Colors.white)),
                  ),
                ),
              ],
            ),
          ],
        );
      },
    );
  }

  Widget _header(AppLocalizations l, Friend f) {
    final hatched = DateTime.tryParse(f.hatchedDay);
    final date = hatched == null ? f.hatchedDay : MaterialLocalizations.of(context).formatMediumDate(hatched);
    final fav = favoriteSnack(f);
    final knowsFav = store.discovered.contains('house.favorite.${f.species.name}') || f.level >= 3;
    return Row(
      children: [
        Container(
          width: 96,
          height: 96,
          decoration: BoxDecoration(shape: BoxShape.circle, color: Colors.white, border: Border.all(color: House.stitch, width: 3)),
          child: ClipOval(child: FriendPortrait(friend: f, size: 90)),
        ),
        const SizedBox(width: 14),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(f.name, maxLines: 1, overflow: TextOverflow.ellipsis, style: const TextStyle(fontWeight: FontWeight.w900, fontSize: 24, color: House.ink)),
              Text(l.cardHatched(date), style: const TextStyle(fontWeight: FontWeight.w700, fontSize: 14, color: House.inkSoft)),
              Text(knowsFav ? l.cardLoves(l.snackName(fav)) : l.cardLovesSecret, style: const TextStyle(fontWeight: FontWeight.w700, fontSize: 14, color: House.inkSoft)),
              const SizedBox(height: 4),
              Semantics(
                label: l.cardLevel(f.level),
                excludeSemantics: true,
                child: Row(
                  children: [
                    // One heart per friendship level (10), so the row and the label always agree.
                    for (var i = 1; i <= 10; i++)
                      Icon(Icons.favorite_rounded, size: 13, color: f.level >= i ? House.rose : const Color(0xFFE8D5C4)),
                    const SizedBox(width: 4),
                    Flexible(
                      child: Text(l.cardLevel(f.level),
                          maxLines: 1, overflow: TextOverflow.ellipsis, style: const TextStyle(fontWeight: FontWeight.w900, fontSize: 13, color: House.ink)),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _tabs(AppLocalizations l) {
    final labels = [l.cardTabPlay, l.cardTabWardrobe, l.cardTabJournal];
    return Container(
      padding: const EdgeInsets.all(4),
      decoration: BoxDecoration(color: const Color(0xFFF1E3D2), borderRadius: BorderRadius.circular(22)),
      child: Row(
        children: [
          for (var i = 0; i < 3; i++)
            Expanded(
              child: Semantics(
                selected: _tab == i,
                button: true,
                child: GestureDetector(
                  onTap: () => setState(() => _tab = i),
                  child: AnimatedContainer(
                    duration: const Duration(milliseconds: 180),
                    height: 44,
                    alignment: Alignment.center,
                    decoration: BoxDecoration(
                      color: _tab == i ? Colors.white : Colors.transparent,
                      borderRadius: BorderRadius.circular(18),
                      boxShadow: _tab == i ? const [BoxShadow(color: House.tagShadow, offset: Offset(0, 2))] : null,
                    ),
                    child: Text(labels[i],
                        maxLines: 1, overflow: TextOverflow.ellipsis, style: TextStyle(fontWeight: FontWeight.w900, fontSize: 15, color: _tab == i ? House.ink : const Color(0xFF6A5560))),
                  ),
                ),
              ),
            ),
        ],
      ),
    );
  }

  // ── play: voice board (+ tricks for puppies) ──────────────────────────
  Widget _play(AppLocalizations l, Friend f) {
    final c = widget.house.creature(f.id);
    final today = store.today;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        if (f.species == Species.wuff) ...[
          Text(l.cardTricks, style: const TextStyle(fontWeight: FontWeight.w900, fontSize: 16, color: House.ink)),
          const SizedBox(height: 8),
          GridView.count(
            padding: EdgeInsets.zero,
            crossAxisCount: 2,
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            mainAxisSpacing: 10,
            crossAxisSpacing: 10,
            childAspectRatio: 2.4,
            children: [
              for (final t in wuffTricks)
                _CardTile(
                  title: trickName(l, t.id),
                  subtitle: f.tricks.contains(t.id)
                      ? l.trickMastered
                      : (f.trickLastDay[t.id] == today ? l.trickDoneToday : (f.trickPractice[t.id] ?? 0) == 0 ? l.trickTryIt : l.trickPractice(3 - (f.trickPractice[t.id] ?? 0))),
                  good: f.tricks.contains(t.id),
                  onTap: () {
                    if (c is WuffCreature) c.doTrick(t.id, success: true);
                    if (store.practiceTrick(f.id, t.id)) widget.toast(l.toastTrickMastered(f.name, trickName(l, t.id)));
                  },
                ),
            ],
          ),
          const SizedBox(height: 16),
        ],
        Text(l.cardVoice, style: const TextStyle(fontWeight: FontWeight.w900, fontSize: 16, color: House.ink)),
        const SizedBox(height: 8),
        GridView.count(
          padding: EdgeInsets.zero,
          crossAxisCount: 3,
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          mainAxisSpacing: 10,
          crossAxisSpacing: 10,
          childAspectRatio: 1.7,
          children: [
            for (final (i, pad) in voicePads(f.species).indexed)
              Semantics(
                button: true,
                label: l.voicePad(f.name),
                child: GestureDetector(
                  onTap: () {
                    if (c is WuffCreature) {
                      c.bark(pad.$1);
                    } else {
                      widget.house.audio.play(pad.$2);
                      c?.react(SocialCue.nuzzled);
                    }
                    widget.house.audio.haptic('light');
                  },
                  child: Container(
                    decoration: BoxDecoration(
                      color: f.species == Species.wuff ? wuffBarkPads[i].color : _padFills[i % _padFills.length],
                      borderRadius: BorderRadius.circular(18),
                      border: Border.all(color: Colors.white, width: 2),
                      boxShadow: const [BoxShadow(color: House.tagShadow, offset: Offset(0, 3))],
                    ),
                    child: Center(child: Icon(voiceIcon(pad.$1), color: House.ink, size: 28)),
                  ),
                ),
              ),
          ],
        ),
      ],
    );
  }

  // ── wardrobe ──────────────────────────────────────────────────────────
  Widget _wardrobe(AppLocalizations l, Friend f) {
    final variants = coatOptions(f);
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Text(l.wardrobeCoats, style: const TextStyle(fontWeight: FontWeight.w900, fontSize: 16, color: House.ink)),
        const SizedBox(height: 8),
        GridView.count(
          padding: EdgeInsets.zero,
          crossAxisCount: 3,
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          mainAxisSpacing: 10,
          crossAxisSpacing: 10,
          childAspectRatio: 0.82,
          children: [
            for (final v in variants)
              _WearTile(
                friend: f,
                variant: v,
                label: variantName(l, f.species, v),
                lockText: variantUnlocked(f, v) ? null : l.unlockLevel(variantLevel(f.species, v)),
                selected: f.variant == v,
                onTap: () {
                  if (!variantUnlocked(f, v)) return;
                  store.setVariant(f.id, v);
                  widget.house.audio.play('ui.pop');
                },
              ),
          ],
        ),
        const SizedBox(height: 16),
        Text(l.wardrobeAccessories, style: const TextStyle(fontWeight: FontWeight.w900, fontSize: 16, color: House.ink)),
        const SizedBox(height: 8),
        GridView.count(
          padding: EdgeInsets.zero,
          crossAxisCount: 3,
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          mainAxisSpacing: 10,
          crossAxisSpacing: 10,
          childAspectRatio: 0.82,
          children: [
            for (final item in wardrobeItems)
              if (item.rule.kind != WearRuleKind.seasonal || itemUnlocked(store, f, item))
                _WearTile(
                  friend: f,
                  variant: f.variant,
                  accessory: item.id,
                  label: l.accessoryName(item.id),
                  lockText: itemUnlocked(store, f, item)
                      ? null
                      : switch (item.rule.kind) {
                          WearRuleKind.level => l.unlockLevel(item.rule.amount),
                          WearRuleKind.stars => l.unlockStars(item.rule.amount),
                          _ => l.unlockSeasonal,
                        },
                  selected: f.wear[item.slot.name] == item.id,
                  onTap: () {
                    if (!itemUnlocked(store, f, item)) return;
                    final on = f.wear[item.slot.name] == item.id;
                    store.wear(f.id, item.slot.name, on ? null : item.id);
                    widget.house.audio.play('ui.pop');
                    if (!on) store.discover('house.dressUp');
                  },
                ),
          ],
        ),
      ],
    );
  }

  // ── journal ───────────────────────────────────────────────────────────
  Widget _journal(AppLocalizations l, Friend f) {
    final ids = switch (f.species) {
      Species.oink => oinkReactions.map((r) => r.id).toList(),
      Species.wuff => wuffReactions.map((r) => r.id).toList(),
      Species.boop => boopReactions.map((r) => r.id).toList(),
      Species.mofu => mofuReactionIds(),
    };
    String hint(String id) => l.reactionText(id).$2;
    final found = ids.where(store.discovered.contains).length;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Text(l.journalCount(found, ids.length), style: const TextStyle(fontWeight: FontWeight.w900, fontSize: 16, color: House.ink)),
        const SizedBox(height: 8),
        for (final id in ids)
          Container(
            margin: const EdgeInsets.only(bottom: 8),
            padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
            decoration: BoxDecoration(
              color: store.discovered.contains(id) ? Colors.white : const Color(0xFFF4EADF),
              borderRadius: BorderRadius.circular(16),
            ),
            child: Row(
              children: [
                Icon(store.discovered.contains(id) ? Icons.auto_awesome_rounded : Icons.help_outline_rounded,
                    color: store.discovered.contains(id) ? House.star : const Color(0xFFB9A592), size: 22),
                const SizedBox(width: 10),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(store.discovered.contains(id) ? l.reactionName(id) : l.journalHidden,
                          style: const TextStyle(fontWeight: FontWeight.w900, fontSize: 15, color: House.ink)),
                      Text(hint(id), style: const TextStyle(fontWeight: FontWeight.w700, fontSize: 13, color: House.inkSoft)),
                    ],
                  ),
                ),
              ],
            ),
          ),
      ],
    );
  }

  void _moveSheet(AppLocalizations l, Friend f) {
    unawaited(showModalBottomSheet<void>(
      context: context,
      backgroundColor: House.paper,
      shape: const RoundedRectangleBorder(borderRadius: BorderRadius.vertical(top: Radius.circular(28))),
      builder: (ctx) => SafeArea(
        child: Wrap(
          children: [
            for (final r in Room.values)
              ListTile(
                leading: Icon(f.room == r ? Icons.radio_button_checked_rounded : Icons.radio_button_off_rounded, color: House.rose),
                title: Text(l.roomName(r), style: const TextStyle(fontWeight: FontWeight.w800)),
                onTap: () {
                  Navigator.pop(ctx);
                  if (widget.house.moveFriend(f.id, r)) {
                    widget.toast(l.toastMoved(f.name, l.roomName(r)));
                  } else {
                    widget.toast(l.roomFull);
                  }
                },
              ),
          ],
        ),
      ),
    ));
  }
}

class _CardTile extends StatelessWidget {
  const _CardTile({required this.title, required this.subtitle, required this.onTap, this.good = false});
  final String title;
  final String subtitle;
  final VoidCallback onTap;
  final bool good;

  @override
  Widget build(BuildContext context) {
    return Semantics(
      button: true,
      child: GestureDetector(
        onTap: onTap,
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
          decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(20), border: Border.all(color: const Color(0xFFE6D3BE), width: 2)),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Text(title, maxLines: 1, overflow: TextOverflow.ellipsis, style: const TextStyle(fontWeight: FontWeight.w900, fontSize: 16, color: House.ink)),
              Text(subtitle, maxLines: 1, overflow: TextOverflow.ellipsis, style: TextStyle(fontWeight: FontWeight.w700, fontSize: 13, color: good ? House.leaf : House.inkSoft)),
            ],
          ),
        ),
      ),
    );
  }
}

/// A wardrobe tile: the friend wearing this coat / accessory, live.
class _WearTile extends StatelessWidget {
  const _WearTile({
    required this.friend,
    required this.variant,
    required this.label,
    required this.lockText,
    required this.selected,
    required this.onTap,
    this.accessory,
  });
  final Friend friend;
  final String variant;
  final String? accessory;
  final String label;
  final String? lockText;
  final bool selected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final locked = lockText != null;
    final preview = Friend(id: friend.id, species: friend.species, name: friend.name, variant: variant, hatchedDay: friend.hatchedDay);
    if (accessory != null) preview.wear['head'] = accessory!;
    return Semantics(
      button: true,
      selected: selected,
      label: locked ? '$label. $lockText' : label,
      excludeSemantics: true,
      child: GestureDetector(
        onTap: onTap,
        child: Container(
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(18),
            border: Border.all(color: selected ? House.rose : const Color(0xFFE6D3BE), width: selected ? 3 : 2),
          ),
          padding: const EdgeInsets.all(6),
          child: Column(
            children: [
              Expanded(
                child: Stack(
                  fit: StackFit.expand,
                  children: [
                    Opacity(
                      opacity: locked ? 0.55 : 1,
                      child: FittedBox(child: FriendPortrait(friend: preview, size: 76)),
                    ),
                    if (locked)
                      const PositionedDirectional(
                        top: 0,
                        end: 0,
                        child: CircleAvatar(radius: 11, backgroundColor: House.rose, child: Icon(Icons.lock_rounded, size: 13, color: Colors.white)),
                      ),
                  ],
                ),
              ),
              Text(label, maxLines: 1, overflow: TextOverflow.ellipsis, style: const TextStyle(fontWeight: FontWeight.w900, fontSize: 12, color: House.ink)),
              if (locked)
                Text(lockText!, maxLines: 1, overflow: TextOverflow.ellipsis, textAlign: TextAlign.center, style: const TextStyle(fontWeight: FontWeight.w800, fontSize: 11, color: House.roseDeep)),
            ],
          ),
        ),
      ),
    );
  }
}
