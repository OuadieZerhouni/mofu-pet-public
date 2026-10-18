import 'dart:async';

import 'package:flutter/material.dart';

import '../../../creatures/creature.dart';
import '../../../model/house_store.dart';
import '../../../world/creature_factory.dart';
import '../../games/boop_rush_screen.dart';
import '../../games/snack_catch_screen.dart';
import '../../theme.dart';
import '../parts.dart';
import '../room_context.dart';
import '../snack_icons.dart';

/// Playroom: two mini-games on cards; friends play in the background.
class PlayroomRoom extends RoomModule {
  @override
  bool get hasTopCard => true;

  const PlayroomRoom();

  @override
  Widget overlay(BuildContext context, RoomContext rc) {
    final top = MediaQuery.of(context).padding.top + 74;
    final l = rc.l;
    return Positioned(
      top: top,
      left: 16,
      right: 16,
      child: ListenableBuilder(
        listenable: rc.store,
        builder: (context, _) {
          final store = rc.store;
          final catcher = store.inRoom(Room.playroom).firstOrNull ?? store.friends.firstOrNull;
          return Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              _GameCard(
                title: l.gameBoopRush,
                body: l.gameBoopRushDesc,
                meta: '${l.gameBest(store.bestBoopRush)} · ${l.gameStarsCap(HouseStore.dailyCap[StarSource.boopRush]!)}',
                art: _BoardArt(boop: store.friends.where((f) => f.species == Species.boop).firstOrNull),
                onPlay: () => unawaited(playBoopRush(context, store: store)),
                playLabel: l.gamePlay(l.gameBoopRush),
              ),
              const SizedBox(height: 12),
              _GameCard(
                title: l.gameSnackCatch,
                body: l.gameSnackCatchDesc,
                meta: '${l.gameBest(store.bestSnackCatch)} · ${l.gameStarsCap(HouseStore.dailyCap[StarSource.snackCatch]!)}',
                art: _CatchArt(catcher: catcher),
                onPlay: catcher == null ? null : () => unawaited(playSnackCatch(context, store: store, friend: catcher)),
                playLabel: l.gamePlay(l.gameSnackCatch),
              ),
            ],
          );
        },
      ),
    );
  }
}

class _GameCard extends StatelessWidget {
  const _GameCard({required this.title, required this.body, required this.meta, required this.art, required this.onPlay, required this.playLabel});
  final String title;
  final String body;
  final String meta;
  final Widget art;
  final VoidCallback? onPlay;
  final String playLabel;

  @override
  Widget build(BuildContext context) => Squish(child: _build(context));

  Widget _build(BuildContext context) {
    return Semantics(
      button: true,
      enabled: onPlay != null,
      label: playLabel,
      child: GestureDetector(
        onTap: onPlay,
        child: Container(
          padding: const EdgeInsets.all(14),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(26),
            boxShadow: const [BoxShadow(color: Color(0xFFDCD0FF), offset: Offset(0, 6))],
          ),
          child: Row(
            children: [
              SizedBox(width: 84, height: 84, child: art),
              const SizedBox(width: 14),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(title, style: const TextStyle(fontWeight: FontWeight.w900, fontSize: 19, color: House.ink)),
                    const SizedBox(height: 2),
                    Text(body, style: const TextStyle(fontWeight: FontWeight.w700, fontSize: 13, color: House.inkSoft)),
                    const SizedBox(height: 4),
                    Text(meta, style: const TextStyle(fontWeight: FontWeight.w800, fontSize: 12, color: House.roseDeep)),
                  ],
                ),
              ),
              const Icon(Icons.play_circle_fill_rounded, color: House.rose, size: 40),
            ],
          ),
        ),
      ),
    );
  }
}

/// Boop Rush: holes in the lawn, a Boop popping out of the middle one.
class _BoardArt extends StatelessWidget {
  const _BoardArt({this.boop});
  final Friend? boop;

  @override
  Widget build(BuildContext context) {
    final f = boop ?? Friend(id: 'thumb-boop', species: Species.boop, name: '', variant: HouseStore.boopOrder.first, hatchedDay: '');
    return ClipRRect(
      borderRadius: BorderRadius.circular(20),
      child: ColoredBox(
        color: const Color(0xFFDDEFD3),
        child: Stack(
          children: [
            const Positioned.fill(child: CustomPaint(painter: _HolesPainter())),
            Positioned(left: 21, top: 18, child: FriendPortrait(friend: f, size: 42)),
          ],
        ),
      ),
    );
  }
}

class _HolesPainter extends CustomPainter {
  const _HolesPainter();

  @override
  void paint(Canvas canvas, Size size) {
    final rim = Paint()..color = const Color(0xFFC48A5C);
    final hole = Paint()..color = const Color(0xFF4A2C1C);
    for (final (x, y) in const [(0.22, 0.34), (0.78, 0.34), (0.5, 0.62), (0.22, 0.86), (0.78, 0.86)]) {
      final c = Offset(size.width * x, size.height * y);
      canvas.drawOval(Rect.fromCenter(center: c, width: 30, height: 12), rim);
      canvas.drawOval(Rect.fromCenter(center: c.translate(0, -1), width: 24, height: 8), hole);
    }
  }

  @override
  bool shouldRepaint(_HolesPainter oldDelegate) => false;
}

/// Snack Catch: the friend who plays, with snacks falling toward it.
class _CatchArt extends StatelessWidget {
  const _CatchArt({this.catcher});
  final Friend? catcher;

  @override
  Widget build(BuildContext context) {
    final f = catcher;
    final menu = f == null ? const ['strawberry', 'cookie'] : snacksFor(f.species);
    return ClipRRect(
      borderRadius: BorderRadius.circular(20),
      child: ColoredBox(
        color: const Color(0xFFE3F2F6),
        child: Stack(
          children: [
            Positioned(left: 10, top: 6, child: SnackIcon(menu.first, size: 22)),
            Positioned(right: 10, top: 20, child: SnackIcon(menu[menu.length > 1 ? 1 : 0], size: 20)),
            if (f != null) Positioned(left: 19, bottom: 2, child: FriendPortrait(friend: f, size: 46)),
          ],
        ),
      ),
    );
  }
}
